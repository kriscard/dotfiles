/**
 * theme-sync — keep pi's Catppuccin theme aligned with your environment.
 *
 * Behavior:
 *  - Dark macOS appearance  -> catppuccin-<$THEME_FLAVOUR>  (default: macchiato)
 *  - Light macOS appearance -> catppuccin-latte
 *  - Polls every 2s and only re-applies on change.
 *
 * Config (env):
 *  - THEME_FLAVOUR           dark flavour: frappe | macchiato | mocha  (default macchiato)
 *  - PI_THEME_LIGHT          override light theme name (default catppuccin-latte)
 *  - PI_THEME_DARK           override dark theme name  (default catppuccin-<THEME_FLAVOUR>)
 *  - PI_THEME_FOLLOW_SYSTEM  "0" to pin the dark flavour and ignore macOS appearance
 *
 * Commands:
 *  - /theme-sync            toggle auto follow on/off
 *  - /theme-sync <name>     apply a theme once (autocompletes installed themes)
 */

import { exec } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";

const execAsync = promisify(exec);

const DARK_FLAVOUR = (process.env.THEME_FLAVOUR || "macchiato").trim().toLowerCase();
const DARK_THEME = process.env.PI_THEME_DARK || `catppuccin-${DARK_FLAVOUR === "latte" ? "mocha" : DARK_FLAVOUR}`;
const LIGHT_THEME = process.env.PI_THEME_LIGHT || "catppuccin-latte";
const POLL_MS = 2000;

async function isDarkMode(): Promise<boolean> {
	try {
		const { stdout } = await execAsync(
			"defaults read -g AppleInterfaceStyle 2>/dev/null",
			{ timeout: 1500 },
		);
		return stdout.trim() === "Dark";
	} catch {
		// `defaults read` exits non-zero in Light mode (key absent).
		return false;
	}
}

export default function (pi: ExtensionAPI) {
	let intervalId: ReturnType<typeof setInterval> | null = null;
	let current = "";
	let follow = (process.env.PI_THEME_FOLLOW_SYSTEM ?? "1") !== "0";

	const available = (ctx: ExtensionContext): Set<string> =>
		new Set(ctx.ui.getAllThemes().map((t) => t.name));

	function apply(ctx: ExtensionContext, name: string): void {
		if (name === current) return;
		if (!available(ctx).has(name)) {
			ctx.ui.notify(`theme-sync: theme "${name}" not installed`, "warning");
			return;
		}
		const result = ctx.ui.setTheme(name);
		if (result.success) current = name;
		else ctx.ui.notify(`theme-sync: ${result.error}`, "error");
	}

	async function desired(): Promise<string> {
		if (!follow) return DARK_THEME;
		return (await isDarkMode()) ? DARK_THEME : LIGHT_THEME;
	}

	function startPolling(ctx: ExtensionContext): void {
		if (intervalId || ctx.mode !== "tui") return;
		intervalId = setInterval(async () => {
			if (!follow) return;
			apply(ctx, await desired());
		}, POLL_MS);
	}

	function stopPolling(): void {
		if (intervalId) {
			clearInterval(intervalId);
			intervalId = null;
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		apply(ctx, await desired());
		startPolling(ctx);
	});

	pi.on("session_shutdown", () => stopPolling());

	pi.registerCommand("theme-sync", {
		description: "Toggle macOS theme follow, or apply a theme once",
		getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
			// Static list; refined per-session list is fetched in the handler.
			const items = ["catppuccin-latte", "catppuccin-frappe", "catppuccin-macchiato", "catppuccin-mocha"]
				.filter((n) => n.startsWith(prefix))
				.map((n) => ({ value: n, label: n }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const name = args.trim();
			if (name) {
				follow = false;
				stopPolling();
				apply(ctx, name);
				ctx.ui.notify(`theme-sync: pinned "${name}" (follow off)`, "info");
				return;
			}
			follow = !follow;
			if (follow) {
				apply(ctx, await desired());
				startPolling(ctx);
				ctx.ui.notify("theme-sync: following macOS appearance", "info");
			} else {
				stopPolling();
				ctx.ui.notify("theme-sync: follow off", "info");
			}
		},
	});
}
