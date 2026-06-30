/**
 * clipboard — /clip and /dump helpers.
 *
 * /clip last   -> copy last assistant text
 * /clip code   -> copy code blocks from last assistant text
 * /clip cmd    -> copy last bash command/output we can find
 * /clip all    -> copy the branch transcript markdown
 *
 * /dump        -> copy the FULL current branch transcript to macOS clipboard.
 * /dump path   -> also write that transcript markdown to a file.
 */

import { spawn } from "node:child_process";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

function textOfContent(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.map((part) => {
			if (!part || typeof part !== "object") return "";
			if ((part as { type?: string }).type === "text") return (part as { text?: string }).text ?? "";
			if ((part as { type?: string }).type === "image") return "[image]";
			return "";
		})
		.join("\n");
}

function transcript(ctx: ExtensionCommandContext): string {
	const out: string[] = [];
	for (const e of ctx.sessionManager.getBranch()) {
		if (e.type !== "message") continue;
		const m = e.message as { role?: string; content?: unknown; toolName?: string; input?: unknown; isError?: boolean };
		const body = textOfContent(m.content).trim();
		if (!body) continue;
		if (m.role === "user") out.push(`## User\n\n${body}`);
		else if (m.role === "assistant") out.push(`## Assistant\n\n${body}`);
		else if (m.role === "toolResult") out.push(`## Tool: ${m.toolName ?? "unknown"}${m.isError ? " (error)" : ""}\n\n\`\`\`\n${body}\n\`\`\``);
	}
	return out.join("\n\n---\n\n") + "\n";
}

function lastAssistant(ctx: ExtensionCommandContext): string {
	const branch = [...ctx.sessionManager.getBranch()].reverse();
	for (const e of branch) {
		if (e.type === "message" && e.message.role === "assistant") {
			const text = textOfContent(e.message.content).trim();
			if (text) return text;
		}
	}
	return "";
}

function codeBlocks(markdown: string): string {
	const blocks = [...markdown.matchAll(/```(?:[^\n]*)\n([\s\S]*?)```/g)].map((m) => m[1].trim());
	return blocks.join("\n\n");
}

function lastCommand(ctx: ExtensionCommandContext): string {
	const branch = [...ctx.sessionManager.getBranch()].reverse();
	for (const e of branch) {
		if (e.type !== "message") continue;
		const m = e.message as { role?: string; toolName?: string; content?: unknown; input?: { command?: string }; details?: { command?: string } };
		if (m.role === "toolResult" && m.toolName === "bash") {
			const command = m.input?.command || m.details?.command;
			const output = textOfContent(m.content).trim();
			return [command ? `$ ${command}` : "# bash", output].filter(Boolean).join("\n\n");
		}
	}
	return "";
}

async function pbcopy(text: string): Promise<void> {
	await new Promise<void>((resolve, reject) => {
		const child = spawn("pbcopy", [], { stdio: ["pipe", "ignore", "pipe"] });
		let stderr = "";
		child.stderr?.on("data", (chunk) => {
			stderr += String(chunk);
		});
		child.on("error", reject);
		child.on("close", (code) => {
			if (code === 0) resolve();
			else reject(new Error(stderr || `pbcopy exited ${code}`));
		});
		child.stdin.end(text);
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("clip", {
		description: "Copy last|code|cmd|all to clipboard",
		handler: async (args, ctx) => {
			const mode = (args.trim() || "last").toLowerCase();
			let text = "";
			if (mode === "last") text = lastAssistant(ctx);
			else if (mode === "code") text = codeBlocks(lastAssistant(ctx));
			else if (mode === "cmd") text = lastCommand(ctx);
			else if (mode === "all") text = transcript(ctx);
			else {
				ctx.ui.notify("clip: expected last, code, cmd, or all", "warning");
				return;
			}
			if (!text) {
				ctx.ui.notify(`clip: nothing found for ${mode}`, "warning");
				return;
			}
			await pbcopy(text);
			ctx.ui.notify(`clip: copied ${mode}`, "info");
		},
	});

	pi.registerCommand("dump", {
		description: "Copy full current branch transcript to clipboard, optionally write to a file",
		handler: async (args, ctx) => {
			const body = transcript(ctx);
			await pbcopy(body);
			const file = args.trim();
			if (file) {
				const out = resolve(ctx.cwd, file);
				await mkdir(dirname(out), { recursive: true });
				await writeFile(out, body, "utf8");
				ctx.ui.notify(`dump: copied and wrote ${file}`, "info");
			} else {
				ctx.ui.notify("dump: transcript copied to clipboard", "info");
			}
		},
	});
}
