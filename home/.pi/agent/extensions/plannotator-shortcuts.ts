import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type PlanMode = "enter" | "exit" | "toggle" | "status";
type PlanPhase = "idle" | "planning" | "executing";
type PlanResponse =
	| { status: "handled"; result: { phase: PlanPhase } }
	| { status: "unavailable"; error?: string }
	| { status: "error"; error: string };

const CHANNEL = "plannotator:request";
const TIMEOUT_MS = 5_000;

export default function plannotatorShortcuts(pi: ExtensionAPI): void {
	function requestPlanMode(mode: PlanMode): Promise<PlanResponse> {
		return new Promise((resolve) => {
			const timeout = setTimeout(() => {
				resolve({ status: "unavailable", error: "Timed out waiting for Plannotator." });
			}, TIMEOUT_MS);

			pi.events.emit(CHANNEL, {
				requestId: `dotfiles-plan-${Date.now()}-${Math.random().toString(16).slice(2)}`,
				action: "plan-mode",
				payload: { mode },
				respond: (response: PlanResponse) => {
					clearTimeout(timeout);
					resolve(response);
				},
			});
		});
	}

	async function setPlanMode(mode: PlanMode, ctx: ExtensionContext): Promise<void> {
		const response = await requestPlanMode(mode);
		if (response.status !== "handled") {
			ctx.ui.notify(`Plan mode unavailable: ${response.error ?? response.status}`, "warning");
			return;
		}

		const label = response.result.phase === "idle" ? "off" : response.result.phase;
		ctx.ui.notify(`Plan mode: ${label}`, "info");
	}

	pi.registerCommand("plan", {
		description: "Toggle Plannotator plan mode (alias for /plannotator)",
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			const mode: PlanMode =
				arg === "on" || arg === "enter"
					? "enter"
					: arg === "off" || arg === "exit"
						? "exit"
						: arg === "status"
							? "status"
							: "toggle";
			await setPlanMode(mode, ctx);
		},
	});

	// Ctrl+Alt+P often does not reach terminal apps on macOS unless Option-as-Alt
	// is enabled. F6 is intentionally boring and reliable.
	pi.registerShortcut("f6", {
		description: "Toggle Plannotator plan mode",
		handler: async (ctx) => {
			await setPlanMode("toggle", ctx);
		},
	});
}
