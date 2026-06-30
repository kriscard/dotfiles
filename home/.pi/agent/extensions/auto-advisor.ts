/**
 * auto-advisor — a cheap reviewer model that watches each turn and posts
 * short inline notes (aside / concern / blocker) without you asking.
 *
 * Design (cost-first):
 *   - Fires on turn_end, edits-only by default (skips read/search turns).
 *   - Sends ONLY the turn delta (assistant text + edit/write diffs + bash tail),
 *     truncated — never the whole conversation.
 *   - Runs on a budget model (GLM/Kimi/DeepSeek/Haiku), not your main model.
 *   - Notes render as display-only custom messages -> NOT added to the main
 *     model's context (zero bloat to expensive turns).
 *   - Severity floor suppresses chatter; blockers can optionally steer.
 *
 * Config (env):
 *   PI_ADVISOR_DISABLE=1            off entirely
 *   PI_ADVISOR_MODEL=prov/id        reviewer model (default: cheap list below)
 *   PI_ADVISOR_ON_EDITS_ONLY=0      review every turn (default 1 = edits only)
 *   PI_ADVISOR_MIN_SEVERITY=aside   floor: aside | concern | blocker (default concern)
 *   PI_ADVISOR_STEER_BLOCKERS=1     let blockers interrupt the main agent (default 0)
 *   PI_ADVISOR_MAX_CHARS=6000       max delta chars sent to reviewer
 *
 * Commands:  /advisor [on|off|status]
 */

import { complete, type Api, type Model, type UserMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const DEFAULT_MODELS = [
	"opencode-go/glm-5.2",
	"opencode-go/kimi-k2.7-code",
	"opencode-go/deepseek-v4-pro",
	"anthropic/claude-haiku-4-5",
];
const SEVERITIES = ["aside", "concern", "blocker"] as const;
type Severity = (typeof SEVERITIES)[number];

const SYSTEM_PROMPT = `You are a terse senior code reviewer watching another agent work.
You see ONLY the latest turn's changes (diffs + output), not the whole project.
Flag at most ONE real risk: a correctness bug, security issue, data loss, or a
clear design mistake in THIS change. Ignore style and nits.

Respond with exactly one line:
  none
or
  <severity>: <one sentence>
where <severity> is one of: aside, concern, blocker.
- aside   = minor FYI
- concern = likely worth a look
- blocker = will break / leak / lose data
If the change looks fine, respond with: none`;

function extractText(content: unknown): string {
	if (!Array.isArray(content)) return typeof content === "string" ? content : "";
	return content
		.map((p) => (p && typeof p === "object" && (p as { type?: string }).type === "text" ? (p as { text: string }).text : ""))
		.join("");
}

function sevRank(s: Severity): number {
	return SEVERITIES.indexOf(s);
}

async function resolveModel(ctx: ExtensionContext): Promise<Model<Api> | undefined> {
	const prefs: string[] = [];
	if (process.env.PI_ADVISOR_MODEL) prefs.push(process.env.PI_ADVISOR_MODEL);
	prefs.push(...DEFAULT_MODELS);
	for (const ref of prefs) {
		const [provider, ...rest] = ref.split("/");
		const id = rest.join("/");
		if (!provider || !id) continue;
		const model = ctx.modelRegistry.find(provider, id);
		if (!model) continue;
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (auth.ok) return model;
	}
	return undefined;
}

export default function (pi: ExtensionAPI) {
	if (process.env.PI_ADVISOR_DISABLE === "1") return;

	let enabled = true;
	const editsOnly = (process.env.PI_ADVISOR_ON_EDITS_ONLY ?? "1") !== "0";
	const steerBlockers = process.env.PI_ADVISOR_STEER_BLOCKERS === "1";
	const minSeverity = (process.env.PI_ADVISOR_MIN_SEVERITY as Severity) || "concern";
	const maxChars = Number(process.env.PI_ADVISOR_MAX_CHARS || 6000);

	let busy = false;
	let skipNext = false; // avoid reviewing our own blocker-steer turn

	pi.registerMessageRenderer("advisor", (message, _options, theme) => {
		const sev = ((message.details as { severity?: Severity })?.severity ?? "aside") as Severity;
		const color = sev === "blocker" ? "error" : sev === "concern" ? "warning" : "dim";
		const label = theme.fg(color, theme.bold(`󰭹 advisor · ${sev}`));
		return new Text(`${label}  ${theme.fg("muted", message.content)}`, 0, 0);
	});

	pi.registerCommand("advisor", {
		description: "Toggle the auto-advisor reviewer (on|off|status)",
		handler: async (args, ctx) => {
			const a = args.trim().toLowerCase();
			if (a === "off") enabled = false;
			else if (a === "on") enabled = true;
			else if (a === "status" || a === "") {
				const model = await resolveModel(ctx);
				ctx.ui.notify(
					`advisor: ${enabled ? "on" : "off"} · model ${model ? `${model.provider}/${model.id}` : "none available"} · floor ${minSeverity} · steer ${steerBlockers}`,
					"info",
				);
				return;
			} else enabled = !enabled;
			ctx.ui.notify(`advisor: ${enabled ? "on" : "off"}`, "info");
		},
	});

	pi.on("turn_end", async (event, ctx) => {
		if (!enabled || busy) return;
		if (skipNext) {
			skipNext = false;
			return;
		}

		const toolResults = (event as { toolResults?: Array<{ toolName?: string; content?: unknown; isError?: boolean }> })
			.toolResults ?? [];
		const hadEdit = toolResults.some((r) => r.toolName === "edit" || r.toolName === "write");
		if (editsOnly && !hadEdit) return;

		// Build the delta: assistant text + tool result snippets.
		const assistantText = extractText((event as { message?: { content?: unknown } }).message?.content);
		const toolText = toolResults
			.map((r) => `[${r.toolName}${r.isError ? " ERROR" : ""}]\n${extractText(r.content)}`)
			.join("\n\n");
		let delta = [assistantText, toolText].filter(Boolean).join("\n\n").trim();
		if (!delta) return;
		if (delta.length > maxChars) delta = `${delta.slice(0, maxChars)}\n…[truncated]`;

		const model = await resolveModel(ctx);
		if (!model) return;

		busy = true;
		try {
			const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
			if (!auth.ok) return;
			const userMessage: UserMessage = {
				role: "user",
				content: [{ type: "text", text: `Review this turn's changes:\n\n${delta}` }],
				timestamp: Date.now(),
			};
			const response = await complete(
				model,
				{ systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
				{ apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
			);
			if (response.stopReason === "aborted") return;

			const line = extractText(response.content).trim().split("\n")[0]?.trim() ?? "";
			if (!line || /^none\b/i.test(line)) return;

			const m = line.match(/^\s*(aside|concern|blocker)\s*[:\-–]\s*(.+)$/i);
			if (!m) return;
			const severity = m[1].toLowerCase() as Severity;
			const note = m[2].trim();
			if (sevRank(severity) < sevRank(minSeverity)) return;

			pi.sendMessage({
				customType: "advisor",
				content: note,
				display: true,
				details: { severity },
			});

			if (severity === "blocker" && steerBlockers) {
				skipNext = true;
				pi.sendUserMessage(`[advisor blocker] ${note}`, { deliverAs: "steer" });
			}
		} catch {
			// reviewer failures are non-fatal — stay silent
		} finally {
			busy = false;
		}
	});
}
