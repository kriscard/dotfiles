/**
 * gh-read — agent-facing GitHub PR/issue reader.
 *
 * The LLM can call gh_read with:
 *   - "pr 123", "pr://123", full PR URL
 *   - "issue 456", "issue://456", full issue URL
 *
 * This complements Plannotator:
 *   - gh_read feeds PR/issue context to the MODEL for reasoning.
 *   - /plannotator-review <PR URL> opens Plannotator's HUMAN visual review UI.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { DEFAULT_MAX_BYTES, DEFAULT_MAX_LINES, formatSize, truncateHead } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

function detectTarget(raw: string): { kind: "pr" | "issue"; ref: string } {
	const s = raw.trim();
	const url = s.match(/github\.com\/[^/]+\/[^/]+\/(pull|issues)\/(\d+)/i);
	if (url) return { kind: url[1].toLowerCase() === "pull" ? "pr" : "issue", ref: s };
	const scheme = s.match(/^(pr|issue):\/\/(\d+)$/i);
	if (scheme) return { kind: scheme[1].toLowerCase() as "pr" | "issue", ref: scheme[2] };
	const words = s.match(/^(pr|pull|issue|i)\s+#?(\d+)$/i);
	if (words) return { kind: words[1].toLowerCase().startsWith("i") ? "issue" : "pr", ref: words[2] };
	if (/^#?\d+$/.test(s)) return { kind: "pr", ref: s.replace(/^#/, "") };
	throw new Error(`Could not parse GitHub target: ${raw}`);
}

function compactJson(json: string): string {
	try {
		return JSON.stringify(JSON.parse(json), null, 2);
	} catch {
		return json;
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "gh_read",
		label: "GitHub Read",
		description: "Read a GitHub PR or issue via gh CLI. Output truncates at 50KB/2000 lines.",
		promptSnippet: "Read GitHub PRs/issues with gh_read when the user references a PR/issue number or GitHub URL.",
		promptGuidelines: [
			"Use gh_read when the user asks about a GitHub PR or issue and the repository uses GitHub.",
			"Use /plannotator-review for human visual PR annotation; use gh_read when the model needs PR/issue text in context.",
		],
		parameters: Type.Object({
			target: Type.String({ description: "PR/issue target: pr 123, issue 456, pr://123, issue://456, or GitHub URL" }),
			includeDiff: Type.Optional(Type.Boolean({ description: "For PRs, include gh pr diff output" })),
		}),
		async execute(_id, params, signal, _onUpdate, ctx) {
			const target = detectTarget(params.target);
			let output = "";
			if (target.kind === "issue") {
				const res = await pi.exec(
					"gh",
					["issue", "view", target.ref, "--json", "number,title,state,author,body,url,labels,assignees,comments"],
					{ signal, cwd: ctx.cwd },
				);
				if (res.code !== 0) throw new Error(res.stderr || res.stdout || "gh issue view failed");
				output = `# GitHub issue ${target.ref}\n\n${compactJson(res.stdout)}`;
			} else {
				const res = await pi.exec(
					"gh",
					[
						"pr",
						"view",
						target.ref,
						"--json",
						"number,title,state,author,body,url,headRefName,baseRefName,additions,deletions,changedFiles,reviewDecision,reviews,comments,files",
					],
					{ signal, cwd: ctx.cwd },
				);
				if (res.code !== 0) throw new Error(res.stderr || res.stdout || "gh pr view failed");
				output = `# GitHub PR ${target.ref}\n\n${compactJson(res.stdout)}`;
				if (params.includeDiff) {
					const diff = await pi.exec("gh", ["pr", "diff", target.ref], { signal, cwd: ctx.cwd });
					if (diff.code !== 0) throw new Error(diff.stderr || diff.stdout || "gh pr diff failed");
					output += `\n\n## Diff\n\n\`\`\`diff\n${diff.stdout}\n\`\`\``;
				}
			}

			const truncated = truncateHead(output, { maxBytes: DEFAULT_MAX_BYTES, maxLines: DEFAULT_MAX_LINES });
			let text = truncated.content;
			if (truncated.truncated) {
				text += `\n\n[gh_read output truncated: ${truncated.outputLines}/${truncated.totalLines} lines, ${formatSize(truncated.outputBytes)}/${formatSize(truncated.totalBytes)}.]`;
			}
			return { content: [{ type: "text", text }], details: { target } };
		},
	});
}
