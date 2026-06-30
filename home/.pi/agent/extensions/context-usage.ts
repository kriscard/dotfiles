/**
 * context-usage — /context command with an omp-style token budget breakdown.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

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

function estimateTokens(s: string): number {
	return Math.ceil(s.length / 4);
}

function fmt(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 1_000_000) return `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`;
	return `${(n / 1_000_000).toFixed(1)}m`;
}

function bar(pct: number, width = 24): string {
	const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)));
	return "█".repeat(filled) + "░".repeat(width - filled);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("context", {
		description: "Show context-window usage and token/cost breakdown",
		handler: async (_args, ctx) => {
			const usage = ctx.getContextUsage();
			const used = usage?.tokens ?? 0;
			const max = ctx.model?.contextWindow ?? 0;
			const pct = max > 0 ? Math.round((used / max) * 100) : 0;

			let userEst = 0;
			let assistantEst = 0;
			let toolEst = 0;
			let input = 0;
			let output = 0;
			let cost = 0;
			let turns = 0;

			for (const e of ctx.sessionManager.getBranch()) {
				if (e.type !== "message") continue;
				const m = e.message as { role?: string; content?: unknown } & Partial<AssistantMessage>;
				const est = estimateTokens(textOfContent(m.content));
				if (m.role === "user") userEst += est;
				else if (m.role === "assistant") {
					assistantEst += est;
					turns += 1;
					if (m.usage) {
						input += m.usage.input;
						output += m.usage.output;
						cost += m.usage.cost.total;
					}
				} else if (m.role === "toolResult") toolEst += est;
			}

			const color = pct >= 85 ? "error" : pct >= 60 ? "warning" : "success";
			const lines = [
				`${ctx.ui.theme.fg("accent", ctx.ui.theme.bold("Context usage"))} ${ctx.ui.theme.fg("dim", ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no model")}`,
				`${ctx.ui.theme.fg(color, bar(pct))} ${ctx.ui.theme.fg(color, `${pct}%`)} ${ctx.ui.theme.fg("dim", `${fmt(used)} / ${fmt(max)} tokens`)}`,
				``,
				`${ctx.ui.theme.fg("muted", "estimated branch content")}`,
				`  user      ${fmt(userEst)}`,
				`  assistant ${fmt(assistantEst)}`,
				`  tools     ${fmt(toolEst)}`,
				``,
				`${ctx.ui.theme.fg("muted", "provider-reported totals")}`,
				`  turns     ${turns}`,
				`  input     ${fmt(input)}`,
				`  output    ${fmt(output)}`,
				`  cost      $${cost.toFixed(4)}`,
			];

			if (ctx.mode === "tui") {
				await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
					const text = new Text(lines.join("\n") + "\n\n" + theme.fg("dim", "Press Enter or Esc to close"), 1, 1);
					text.onKey = (key) => {
						if (key === "return" || key === "escape") done();
						return true;
					};
					return text;
				}, { overlay: true, overlayOptions: { anchor: "center", width: "70%", margin: 2 } });
			} else {
				ctx.ui.notify(`context: ${pct}% (${fmt(used)}/${fmt(max)}), cost $${cost.toFixed(4)}`, "info");
			}
		},
	});
}
