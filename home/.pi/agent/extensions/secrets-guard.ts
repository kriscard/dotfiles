/**
 * secrets-guard — keep secrets out of git and out of the model's context.
 *
 * Tiers:
 *   HARD BLOCK (never allowed, even with UI):
 *     - git add / git commit that references a secret file
 *     - sending a secret file over the network (curl/wget/scp/nc/http...)
 *   CONFIRM (blocked without a UI to confirm):
 *     - write / edit / read of a secret file
 *     - bash that otherwise reads or writes a secret file (cat, >, etc.)
 *
 * Protected by default (per ~/.dotfiles CLAUDE.md):
 *   .env / .env.*          (but NOT .env.example / .sample / .template)
 *   .tokens/               (OAuth tokens dir)
 *   *.pem *.key *.p12 *.pfx, id_rsa / id_ed25519 / id_ecdsa (private only)
 *   credentials(.json), auth.json
 *
 * Config (env):
 *   SECRETS_GUARD_DISABLE=1      turn the whole guard off
 *   SECRETS_GUARD_EXTRA=a,b,c    extra regex fragments (matched against the path)
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const DISABLED = process.env.SECRETS_GUARD_DISABLE === "1";

// Paths that look like secrets.
const SECRET_PATTERNS: RegExp[] = [
	/(^|\/)\.env(\.[^/]*)?$/i,
	/(^|\/)\.tokens(\/|$)/i,
	/\.(pem|key|p12|pfx)$/i,
	/(^|\/)id_(rsa|ed25519|ecdsa)$/i,
	/(^|\/)credentials(\.json)?$/i,
	/(^|\/)auth\.json$/i,
];

// Explicit allow-list (templates / public keys are safe).
const ALLOW_PATTERNS: RegExp[] = [
	/(^|\/)\.env\.(example|sample|template|dist)$/i,
	/\.pub$/i,
];

for (const frag of (process.env.SECRETS_GUARD_EXTRA || "")
	.split(",")
	.map((s) => s.trim())
	.filter(Boolean)) {
	try {
		SECRET_PATTERNS.push(new RegExp(frag, "i"));
	} catch {
		/* ignore bad fragments */
	}
}

function isSecretPath(raw: string): boolean {
	const path = raw.replace(/^@/, "").trim();
	if (!path) return false;
	if (ALLOW_PATTERNS.some((re) => re.test(path))) return false;
	return SECRET_PATTERNS.some((re) => re.test(path));
}

// Pull candidate path-like tokens out of a shell command.
function secretsInCommand(command: string): string[] {
	const tokens = command.split(/[\s'"=();|&<>]+/).filter(Boolean);
	return [...new Set(tokens.filter(isSecretPath))];
}

const NETWORK_RE = /\b(curl|wget|scp|sftp|rsync|nc|ncat|netcat|http|https|xh)\b/i;
const GIT_STAGE_RE = /\bgit\s+(add|commit)\b/i;

type Verdict = { tier: "hard" | "confirm"; reason: string } | null;

function classifyBash(command: string): Verdict {
	const hits = secretsInCommand(command);
	if (hits.length === 0) return null;
	const list = hits.join(", ");

	if (GIT_STAGE_RE.test(command)) {
		return { tier: "hard", reason: `Refusing to stage/commit secret file(s): ${list}` };
	}
	if (NETWORK_RE.test(command)) {
		return { tier: "hard", reason: `Refusing to send secret file(s) over the network: ${list}` };
	}
	return { tier: "confirm", reason: `Command touches secret file(s): ${list}` };
}

async function gate(ctx: ExtensionContext, verdict: Verdict): Promise<{ block: boolean; reason?: string } | undefined> {
	if (!verdict) return undefined;

	if (verdict.tier === "hard") {
		if (ctx.hasUI) ctx.ui.notify(`🔒 secrets-guard: ${verdict.reason}`, "error");
		return { block: true, reason: `secrets-guard: ${verdict.reason}` };
	}

	// confirm tier
	if (!ctx.hasUI) {
		return { block: true, reason: `secrets-guard: ${verdict.reason} (no UI to confirm)` };
	}
	const ok = await ctx.ui.confirm("🔒 secrets-guard", `${verdict.reason}\n\nAllow this once?`);
	if (!ok) return { block: true, reason: `secrets-guard: blocked by user — ${verdict.reason}` };
	return undefined;
}

export default function (pi: ExtensionAPI) {
	if (DISABLED) return;

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName === "write" || event.toolName === "edit" || event.toolName === "read") {
			const path = (event.input as { path?: string }).path ?? "";
			if (isSecretPath(path)) {
				return gate(ctx, { tier: "confirm", reason: `${event.toolName} targets secret file: ${path}` });
			}
			return undefined;
		}

		if (event.toolName === "bash") {
			const command = (event.input as { command?: string }).command ?? "";
			return gate(ctx, classifyBash(command));
		}

		return undefined;
	});
}
