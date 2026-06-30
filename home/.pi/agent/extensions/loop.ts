/**
 * loop — omp-style repeat mode for Pi.
 *
 * Usage:
 *   /loop            arm loop for the next prompt with default repeat cap
 *   /loop 10         re-submit the next prompt up to 10 times after it yields
 *   /loop 20m        loop until 20 minutes elapse (also capped by hard max)
 *   /loop off        stop
 *   /loop status     show state
 *
 * Safety:
 *   - hard capped by PI_LOOP_HARD_MAX (default 25)
 *   - status widget visible while armed/running
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const DEFAULT_REPEATS = Number(process.env.PI_LOOP_DEFAULT_REPEATS || 5);
const HARD_MAX = Number(process.env.PI_LOOP_HARD_MAX || 25);

type LoopState = {
	enabled: boolean;
	prompt?: string;
	repeatsRemaining: number;
	deadline?: number;
	runs: number;
	awaitingFirstPrompt: boolean;
};

function parseDurationMs(input: string): number | undefined {
	const m = input.trim().match(/^(\d+(?:\.\d+)?)\s*(s|sec|secs|second|seconds|m|min|mins|minute|minutes|h|hr|hrs|hour|hours)$/i);
	if (!m) return undefined;
	const n = Number(m[1]);
	const unit = m[2].toLowerCase();
	if (unit.startsWith("s")) return n * 1000;
	if (unit.startsWith("m")) return n * 60_000;
	return n * 60 * 60_000;
}

function label(state: LoopState): string {
	if (!state.enabled) return "loop: off";
	const parts = [state.awaitingFirstPrompt ? "loop: armed" : "loop: running"];
	parts.push(`${state.runs} run${state.runs === 1 ? "" : "s"}`);
	if (state.repeatsRemaining >= 0) parts.push(`${state.repeatsRemaining} repeat${state.repeatsRemaining === 1 ? "" : "s"} left`);
	if (state.deadline) {
		const left = Math.max(0, state.deadline - Date.now());
		parts.push(`${Math.ceil(left / 60_000)}m left`);
	}
	return parts.join(" · ");
}

function updateUi(ctx: ExtensionContext, state: LoopState): void {
	if (!ctx.hasUI) return;
	ctx.ui.setStatus("loop", state.enabled ? ctx.ui.theme.fg("warning", label(state)) : undefined);
	ctx.ui.setWidget(
		"loop",
		state.enabled ? [ctx.ui.theme.fg("warning", `↻ ${label(state)}`)] : undefined,
		{ placement: "belowEditor" },
	);
}

export default function (pi: ExtensionAPI) {
	const state: LoopState = {
		enabled: false,
		repeatsRemaining: DEFAULT_REPEATS,
		runs: 0,
		awaitingFirstPrompt: false,
	};

	function stop(ctx?: ExtensionContext, reason?: string) {
		state.enabled = false;
		state.prompt = undefined;
		state.repeatsRemaining = DEFAULT_REPEATS;
		state.deadline = undefined;
		state.runs = 0;
		state.awaitingFirstPrompt = false;
		if (ctx) {
			updateUi(ctx, state);
			if (reason) ctx.ui.notify(`loop: ${reason}`, "info");
		}
	}

	pi.registerCommand("loop", {
		description: "Repeat the next prompt after each yield until a count/duration cap",
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			if (arg === "off" || arg === "stop" || arg === "cancel") {
				stop(ctx, "stopped");
				return;
			}
			if (arg === "status") {
				ctx.ui.notify(label(state), "info");
				return;
			}

			let repeats = DEFAULT_REPEATS;
			let deadline: number | undefined;
			if (arg) {
				const duration = parseDurationMs(arg);
				if (duration !== undefined) {
					deadline = Date.now() + duration;
					repeats = HARD_MAX;
				} else if (/^\d+$/.test(arg)) {
					repeats = Math.min(Number(arg), HARD_MAX);
				} else {
					ctx.ui.notify("loop: expected count, duration (20m), status, or off", "warning");
					return;
				}
			}

			state.enabled = true;
			state.prompt = undefined;
			state.repeatsRemaining = repeats;
			state.deadline = deadline;
			state.runs = 0;
			state.awaitingFirstPrompt = true;
			updateUi(ctx, state);
			ctx.ui.notify(`loop: armed for next prompt (${repeats} repeat cap)`, "info");
		},
	});

	pi.on("before_agent_start", (event, ctx) => {
		if (!state.enabled) return;
		if (state.awaitingFirstPrompt) {
			state.prompt = event.prompt;
			state.awaitingFirstPrompt = false;
		}
		state.runs += 1;
		updateUi(ctx, state);
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (!state.enabled || !state.prompt) return;
		if (state.deadline && Date.now() >= state.deadline) {
			stop(ctx, "deadline reached");
			return;
		}
		if (state.repeatsRemaining <= 0) {
			stop(ctx, "repeat cap reached");
			return;
		}
		state.repeatsRemaining -= 1;
		updateUi(ctx, state);
		pi.sendUserMessage(state.prompt, { deliverAs: "followUp" });
	});

	pi.on("session_shutdown", () => stop());
}
