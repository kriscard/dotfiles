import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import { access, readFile } from "node:fs/promises";
import { constants } from "node:fs";
import { basename, extname, isAbsolute, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const IMAGE_MIME_TYPES: Record<string, string> = {
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
};

type ParsedToken = {
  raw: string;
  value: string;
};

function parseShellishTokens(input: string): ParsedToken[] {
  const tokens: ParsedToken[] = [];
  let raw = "";
  let value = "";
  let quote: '"' | "'" | null = null;
  let escaping = false;

  const push = () => {
    if (!raw) return;
    tokens.push({ raw, value });
    raw = "";
    value = "";
  };

  for (const char of input) {
    if (escaping) {
      raw += char;
      value += char;
      escaping = false;
      continue;
    }

    if (char === "\\") {
      raw += char;
      escaping = true;
      continue;
    }

    if ((char === '"' || char === "'") && !quote) {
      raw += char;
      quote = char;
      continue;
    }

    if (char === quote) {
      raw += char;
      quote = null;
      continue;
    }

    if (/\s/.test(char) && !quote) {
      push();
      continue;
    }

    raw += char;
    value += char;
  }

  push();
  return tokens;
}

function stripTrailingSentencePunctuation(path: string): string {
  return path.replace(/[),.;:!?]+$/g, "");
}

function normalizePath(rawPath: string, cwd: string): string | undefined {
  const cleaned = stripTrailingSentencePunctuation(rawPath.trim());
  if (!cleaned) return undefined;

  if (cleaned.startsWith("file://")) {
    try {
      return fileURLToPath(cleaned);
    } catch {
      return undefined;
    }
  }

  const expanded = cleaned.startsWith("~/")
    ? `${process.env.HOME ?? ""}${cleaned.slice(1)}`
    : cleaned;

  return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

async function isReadableImage(path: string): Promise<boolean> {
  if (!IMAGE_MIME_TYPES[extname(path).toLowerCase()]) return false;

  try {
    await access(path, constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

async function loadImage(path: string): Promise<ImageContent> {
  return {
    type: "image",
    data: await readFile(path, "base64"),
    mimeType: IMAGE_MIME_TYPES[extname(path).toLowerCase()],
  };
}

function removeRawTokens(text: string, rawTokens: string[]): string {
  let next = text;

  for (const raw of rawTokens.sort((a, b) => b.length - a.length)) {
    next = next.replace(raw, " ");
  }

  return next.replace(/\s+/g, " ").trim();
}

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    const imagePaths: string[] = [];
    const rawImageTokens: string[] = [];

    for (const token of parseShellishTokens(event.text)) {
      const path = normalizePath(token.value, ctx.cwd);
      if (!path || !(await isReadableImage(path))) continue;

      imagePaths.push(path);
      rawImageTokens.push(token.raw);
    }

    if (imagePaths.length === 0) {
      return { action: "continue" };
    }

    const images = await Promise.all(imagePaths.map(loadImage));
    const text = removeRawTokens(event.text, rawImageTokens);
    const fallback =
      imagePaths.length === 1
        ? `Describe ${basename(imagePaths[0])}.`
        : `Describe these ${imagePaths.length} images.`;

    ctx.ui.notify(
      `Attached ${imagePaths.length} image${imagePaths.length === 1 ? "" : "s"}`,
      "info",
    );

    return {
      action: "transform",
      text: text || fallback,
      images: [...(event.images ?? []), ...images],
    };
  });
}
