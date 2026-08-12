/**
 * Pretty code blocks for Pi's Markdown renderer.
 *
 * Design mirrors christophercardoso.dev:
 * - Full-width Catppuccin Mantle background
 * - No border or internal padding
 * - Pi's existing theme-aware syntax highlighting
 * - No visible Markdown fences or decorative title notch
 *
 * Environment:
 * - PI_CODEBLOCK_BG=#rrggbb       Override the panel background
 * - PI_CODEBLOCK_STYLE=panel      panel | compact (default: panel)
 * - PI_CODEBLOCK_LANG=1           Show a subtle language label
 *
 * Pi does not yet expose a renderer hook for normal assistant messages, so this
 * uses the same reload-safe Markdown prototype patch as other current Pi code
 * block extensions. Remove this patch when Pi exposes a first-class hook.
 *
 * Based in part on vvv850/pi-pretty-codeblocks (MIT). See the adjacent
 * pretty-codeblocks.LICENSE file.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Markdown, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";

const PATCHED = Symbol.for("kriscard.pi.pretty-codeblocks.patched");
const ORIGINAL_RENDER = Symbol.for("kriscard.pi.pretty-codeblocks.original-render");
const ORIGINAL_RENDER_TOKEN = Symbol.for("kriscard.pi.pretty-codeblocks.original-render-token");

const RESET = "\x1b[0m";
const CONFIGURED_PANEL_BG = process.env.PI_CODEBLOCK_BG
	? ansiBackground(process.env.PI_CODEBLOCK_BG)
	: undefined;
const MACCHIATO_MANTLE_BG = ansiBackground("#1e2030");
const COMPACT = process.env.PI_CODEBLOCK_STYLE === "compact";
const SHOW_LANGUAGE = process.env.PI_CODEBLOCK_LANG === "1";

let currentThemeBackground = () => MACCHIATO_MANTLE_BG;

interface MarkdownThemeLike {
	bold(text: string): string;
	code(text: string): string;
	codeBlock(text: string): string;
	codeBlockBorder(text: string): string;
	highlightCode?: (code: string, language?: string) => string[];
	link(text: string): string;
}

interface CodeToken {
	type: "code";
	text: string;
	lang?: string;
}

function ansiBackground(hex: string): string {
	const match = /^#([\da-f]{2})([\da-f]{2})([\da-f]{2})$/i.exec(hex);
	if (!match) return "\x1b[48;2;24;25;38m";
	const [, red, green, blue] = match;
	return `\x1b[48;2;${Number.parseInt(red, 16)};${Number.parseInt(green, 16)};${Number.parseInt(blue, 16)}m`;
}

function panelBackground(): string {
	return CONFIGURED_PANEL_BG ?? currentThemeBackground();
}

function fillBackground(line: string, width: number): string {
	const background = panelBackground();
	const padding = " ".repeat(Math.max(0, width - visibleWidth(line)));
	const withPersistentBackground = line.replaceAll(RESET, `${RESET}${background}`);
	return `${background}${withPersistentBackground}${padding}${RESET}`;
}

function isShellLanguage(language: string): boolean {
	return /^(?:ba)?sh|shell|zsh|fish|powershell|ps1$/i.test(language);
}

function highlightShellLine(line: string, theme: MarkdownThemeLike): string {
	if (/^\s*#/.test(line)) return theme.codeBlockBorder(line);

	return line
		.replace(/(^|[|&;]\s*)([A-Za-z0-9_./-]+)/g, (_match, prefix: string, command: string) =>
			`${prefix}${theme.link(command)}`,
		)
		.replace(/(\s)(--?[A-Za-z0-9][A-Za-z0-9-_]*)/g, (_match, prefix: string, flag: string) =>
			`${prefix}${theme.code(flag)}`,
		);
}

function highlightedLines(code: string, language: string, theme: MarkdownThemeLike): string[] {
	if (isShellLanguage(language)) {
		return code.split("\n").map((line) => highlightShellLine(line, theme));
	}
	if (theme.highlightCode) return theme.highlightCode(code, language || undefined);
	return code.split("\n").map((line) => theme.codeBlock(line));
}

function renderCompact(
	token: CodeToken,
	width: number,
	nextTokenType: string | undefined,
	theme: MarkdownThemeLike,
): string[] {
	const language = token.lang?.trim() ?? "";
	const output: string[] = [];

	if (SHOW_LANGUAGE && language) {
		output.push(theme.link(theme.bold(language.toLowerCase())));
	}

	for (const line of highlightedLines(token.text, language, theme)) {
		output.push(...wrapTextWithAnsi(`  ${line}`, Math.max(1, width)));
	}

	if (nextTokenType && nextTokenType !== "space") output.push("");
	return output;
}

function renderPanel(
	token: CodeToken,
	width: number,
	nextTokenType: string | undefined,
	theme: MarkdownThemeLike,
): string[] {
	const panelWidth = Math.max(1, width);
	const language = token.lang?.trim().toLowerCase() ?? "";
	const output: string[] = [];

	if (SHOW_LANGUAGE && language) {
		output.push(fillBackground(theme.link(theme.bold(language)), panelWidth));
	}

	for (const line of highlightedLines(token.text, language, theme)) {
		const wrapped = wrapTextWithAnsi(line || " ", panelWidth);
		for (const part of wrapped.length > 0 ? wrapped : [""]) {
			output.push(fillBackground(part, panelWidth));
		}
	}

	if (nextTokenType && nextTokenType !== "space") output.push("");
	return output;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		// Read through ctx.ui on every render so theme-sync changes (including
		// Macchiato ↔ Latte) update existing and future code blocks automatically.
		currentThemeBackground = () => {
			const paintedSpace = ctx.ui.theme.bg("userMessageBg", " ");
			return paintedSpace.match(/\x1b\[48[^m]*m/)?.[0] ?? MACCHIATO_MANTLE_BG;
		};
	});

	const prototype = Markdown.prototype as Markdown["constructor"]["prototype"] & Record<symbol, unknown>;
	const mutablePrototype = prototype as any;

	// /reload evaluates extensions again in the same process. Restore Pi's true
	// originals before installing the latest version of this patch.
	if (mutablePrototype[PATCHED]) {
		if (mutablePrototype[ORIGINAL_RENDER_TOKEN]) {
			mutablePrototype.renderToken = mutablePrototype[ORIGINAL_RENDER_TOKEN];
		}
		if (mutablePrototype[ORIGINAL_RENDER]) {
			mutablePrototype.render = mutablePrototype[ORIGINAL_RENDER];
		}
	}

	if (typeof mutablePrototype.renderToken !== "function") return;

	mutablePrototype[ORIGINAL_RENDER_TOKEN] = mutablePrototype.renderToken;
	mutablePrototype[ORIGINAL_RENDER] = mutablePrototype.render;

	mutablePrototype.renderToken = function (
		token: CodeToken | { type?: string },
		width: number,
		nextTokenType?: string,
		styleContext?: unknown,
	) {
		if (token?.type === "code") {
			const theme = this.theme as MarkdownThemeLike;
			return COMPACT
				? renderCompact(token as CodeToken, width, nextTokenType, theme)
				: renderPanel(token as CodeToken, width, nextTokenType, theme);
		}
		return mutablePrototype[ORIGINAL_RENDER_TOKEN].call(this, token, width, nextTokenType, styleContext);
	};

	mutablePrototype.render = function (width: number) {
		const lines = mutablePrototype[ORIGINAL_RENDER].call(this, width) as string[];
		if (this.defaultTextStyle?.bgColor) return lines;

		const background = panelBackground();
		return lines.map((line) => {
			// Markdown adds its own left/right message padding after renderToken().
			// Repaint those outer cells so code backgrounds reach both edges.
			if (line.includes(background)) return fillBackground(line, width);
			return line.trimEnd();
		});
	};

	mutablePrototype[PATCHED] = true;
}
