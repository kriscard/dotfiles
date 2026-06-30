/**
 * cost-footer — a polished status line for pi.
 *
 * Segments (left → right):
 *    model · thinking   |    context gauge + %    |  ↑in ↓out  $cost  |   git-branch
 *
 * Colors follow the active theme; the context gauge shifts green → yellow → red
 * as the window fills. Segments drop gracefully on narrow terminals.
 *
 * Enabled on session start. Toggle with /cost-footer.
 *
 * Config (env):
 *   PI_FOOTER_ICONS  "0" to disable Nerd Font glyphs (plain text labels)
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const ICONS = (process.env.PI_FOOTER_ICONS ?? "1") !== "0";
const I = ICONS
	? { model: "\udb80\ude9a", ctx: "\uf080", branch: "\ue0a0", up: "↑", down: "↓", cost: "$" }
	: { model: "", ctx: "ctx", branch: "", up: "↑", down: "↓", cost: "$" };

const SEP = " ";

function fmt(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 1_000_000) return `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`;
	return `${(n / 1_000_000).toFixed(1)}m`;
}

function gauge(pct: number, width = 8): string {
	const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)));
	return "█".repeat(filled) + "░".repeat(width - filled);
}

function ctxColor(pct: number): "success" | "warning" | "error" {
	if (pct < 60) return "success";
	if (pct < 85) return "warning";
	return "error";
}

export default function (pi: ExtensionAPI) {
	let enabled = false;

	function install(ctx: ExtensionContext): void {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					// --- session totals from the active branch ---
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							input += m.usage.input;
							output += m.usage.output;
							cost += m.usage.cost.total;
						}
					}

					// --- live context window usage ---
					const usage = ctx.getContextUsage();
					const winMax = ctx.model?.contextWindow ?? 0;
					const used = usage?.tokens ?? 0;
					const pct = winMax > 0 ? Math.min(100, Math.round((used / winMax) * 100)) : 0;

					// --- model + thinking level ---
					const modelId = ctx.model?.id ?? "no-model";
					const level = pi.getThinkingLevel?.() ?? "off";
					const modelSeg =
						theme.fg("accent", `${I.model ? I.model + " " : ""}${modelId}`) +
						(level && level !== "off" ? theme.fg("dim", ` · ${level}`) : "");

					// --- context gauge ---
					const cc = ctxColor(pct);
					const ctxSeg =
						theme.fg("muted", `${I.ctx} `) +
						theme.fg(cc, gauge(pct)) +
						theme.fg(cc, ` ${pct}%`) +
						theme.fg("dim", ` ${fmt(used)}/${fmt(winMax)}`);

					// --- tokens + cost ---
					const tokSeg = theme.fg(
						"dim",
						`${I.up}${fmt(input)} ${I.down}${fmt(output)} ${I.cost}${cost.toFixed(3)}`,
					);

					// --- git branch (only via footerData) ---
					const branch = footerData.getGitBranch();
					const branchSeg = branch
						? theme.fg("success", `${I.branch ? I.branch + " " : ""}${branch}`)
						: "";

					const div = theme.fg("border", SEP + "│" + SEP);

					// Progressive degradation: keep model + context first, then tokens, then branch.
					const left = [modelSeg, ctxSeg, tokSeg].filter(Boolean).join(div);
					const full = branchSeg ? left + div + branchSeg : left;
					if (visibleWidth(full) <= width) {
						const pad = " ".repeat(Math.max(0, width - visibleWidth(full)));
						// Right-align the branch by padding before it when it exists.
						if (branchSeg) {
							const padR = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(branchSeg)));
							return [truncateToWidth(left + padR + branchSeg, width)];
						}
						return [left + pad];
					}

					const noBranch = [modelSeg, ctxSeg, tokSeg].filter(Boolean).join(div);
					if (visibleWidth(noBranch) <= width) return [noBranch];

					const compact = [modelSeg, ctxSeg].filter(Boolean).join(div);
					if (visibleWidth(compact) <= width) return [compact];

					return [truncateToWidth(modelSeg, width)];
				},
			};
		});
		enabled = true;
	}

	pi.on("session_start", (_event, ctx) => {
		if (ctx.hasUI) install(ctx);
	});

	pi.registerCommand("cost-footer", {
		description: "Toggle the cost/context status footer",
		handler: async (_args, ctx) => {
			if (enabled) {
				ctx.ui.setFooter(undefined);
				enabled = false;
				ctx.ui.notify("cost-footer: default footer restored", "info");
			} else {
				install(ctx);
				ctx.ui.notify("cost-footer: enabled", "info");
			}
		},
	});
}
