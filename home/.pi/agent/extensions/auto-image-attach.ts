import {
  CustomEditor,
  type ExtensionAPI,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { constants, existsSync } from "node:fs";
import { access, readFile, unlink } from "node:fs/promises";
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

type AttachmentState = {
  nextId: number;
  pending: Map<number, string>;
};

const STATE_KEY = Symbol.for("kriscard.pi.auto-image-attach");
const globalState = globalThis as typeof globalThis & {
  [STATE_KEY]?: AttachmentState;
};
const attachmentState = (globalState[STATE_KEY] ??= {
  nextId: 1,
  pending: new Map(),
});

function markerFor(id: number): string {
  return `[Image #${id}]`;
}

function isPiClipboardImagePath(value: string): boolean {
  const path = value.trim();
  return (
    isAbsolute(path) &&
    basename(path).startsWith("pi-clipboard-") &&
    Boolean(IMAGE_MIME_TYPES[extname(path).toLowerCase()]) &&
    existsSync(path)
  );
}

function registerClipboardImage(path: string): string {
  const id = attachmentState.nextId++;
  attachmentState.pending.set(id, path);
  return markerFor(id);
}

async function removeClipboardImage(path: string): Promise<void> {
  if (!basename(path).startsWith("pi-clipboard-")) return;
  await unlink(path).catch(() => undefined);
}

async function clearPendingImages(): Promise<void> {
  const paths = [...attachmentState.pending.values()];
  attachmentState.pending.clear();
  attachmentState.nextId = 1;
  await Promise.all(paths.map(removeClipboardImage));
}

const BRACKETED_PASTE_START = "\x1b[200~";
const BRACKETED_PASTE_END = "\x1b[201~";
const IMAGE_MARKER_REGEX = /\[Image #(\d+)\]/g;

function compactPastedImagePaths(payload: string): string {
  let next = payload;

  for (const token of parseShellishTokens(payload)) {
    const path = normalizePath(token.value, process.cwd());
    if (
      !path ||
      !IMAGE_MIME_TYPES[extname(path).toLowerCase()] ||
      !existsSync(path)
    ) {
      continue;
    }

    next = next.replace(token.raw, registerClipboardImage(path));
  }

  return next;
}

function compactBracketedImagePastes(data: string): string {
  let result = "";
  let offset = 0;

  while (offset < data.length) {
    const start = data.indexOf(BRACKETED_PASTE_START, offset);
    if (start === -1) {
      result += data.slice(offset);
      break;
    }

    const payloadStart = start + BRACKETED_PASTE_START.length;
    const end = data.indexOf(BRACKETED_PASTE_END, payloadStart);
    if (end === -1) {
      result += data.slice(offset);
      break;
    }

    result += data.slice(offset, payloadStart);
    result += compactPastedImagePaths(data.slice(payloadStart, end));
    result += BRACKETED_PASTE_END;
    offset = end + BRACKETED_PASTE_END.length;
  }

  return result;
}

class ImagePasteEditor extends CustomEditor {
  private bracketedPasteBuffer: string | undefined;

  constructor(
    tui: TUI,
    theme: EditorTheme,
    private readonly appKeybindings: KeybindingsManager,
  ) {
    super(tui, theme, appKeybindings);
  }

  private removeImageMarker(
    direction: "backward" | "forward",
  ): boolean {
    const { line, col } = this.getCursor();
    const lines = this.getLines();
    const currentLine = lines[line] ?? "";

    for (const match of currentLine.matchAll(IMAGE_MARKER_REGEX)) {
      const start = match.index;
      const end = start + match[0].length;
      const touchesMarker =
        direction === "backward"
          ? col > start && col <= end
          : col >= start && col < end;

      if (!touchesMarker) continue;

      lines[line] = currentLine.slice(0, start) + currentLine.slice(end);
      this.setText(lines.join("\n"));

      const internals = this as unknown as {
        state: { cursorLine: number; cursorCol: number };
        preferredVisualCol: number | null;
        snappedFromCursorCol: number | null;
      };
      internals.state.cursorLine = line;
      internals.state.cursorCol = start;
      internals.preferredVisualCol = null;
      internals.snappedFromCursorCol = null;
      this.tui.requestRender();
      return true;
    }

    return false;
  }

  override handleInput(data: string): void {
    if (
      this.appKeybindings.matches(
        data,
        "tui.editor.deleteCharBackward",
      ) &&
      this.removeImageMarker("backward")
    ) {
      return;
    }

    if (
      this.appKeybindings.matches(data, "tui.editor.deleteCharForward") &&
      this.removeImageMarker("forward")
    ) {
      return;
    }

    if (this.bracketedPasteBuffer !== undefined) {
      const buffered = this.bracketedPasteBuffer + data;
      if (!buffered.includes(BRACKETED_PASTE_END)) {
        this.bracketedPasteBuffer = buffered;
        return;
      }

      this.bracketedPasteBuffer = undefined;
      super.handleInput(compactBracketedImagePastes(buffered));
      return;
    }

    const start = data.indexOf(BRACKETED_PASTE_START);
    if (
      start !== -1 &&
      data.indexOf(
        BRACKETED_PASTE_END,
        start + BRACKETED_PASTE_START.length,
      ) === -1
    ) {
      this.bracketedPasteBuffer = data;
      return;
    }

    super.handleInput(compactBracketedImagePastes(data));
  }

  override insertTextAtCursor(text: string): void {
    super.insertTextAtCursor(
      isPiClipboardImagePath(text) ? registerClipboardImage(text.trim()) : text,
    );
  }
}

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

    if (
      (char === " " || char === "\t" || char === "\r" || char === "\n") &&
      !quote
    ) {
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
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setEditorComponent(
      (tui, theme, keybindings) =>
        new ImagePasteEditor(tui, theme, keybindings),
    );
  });

  pi.on("input", async (event, ctx) => {
    let text = event.text;
    let textChanged = false;
    let unavailableImages = 0;
    const imagePaths: string[] = [];
    const clipboardImagePaths = new Set<string>();
    const rawImageTokens: string[] = [];

    if (event.source === "interactive") {
      for (const [id, path] of attachmentState.pending) {
        const marker = markerFor(id);
        clipboardImagePaths.add(path);

        if (text.includes(marker)) {
          if (await isReadableImage(path)) {
            imagePaths.push(path);
            text = text.replaceAll(marker, " ");
          } else {
            unavailableImages++;
            text = text.replaceAll(marker, "[Image unavailable]");
          }
          textChanged = true;
        }

        attachmentState.pending.delete(id);
      }

      if (attachmentState.pending.size === 0) {
        attachmentState.nextId = 1;
      }
    }

    for (const token of parseShellishTokens(text)) {
      const path = normalizePath(token.value, ctx.cwd);
      if (!path || !(await isReadableImage(path))) continue;

      imagePaths.push(path);
      rawImageTokens.push(token.raw);
    }

    const uniqueImagePaths = [...new Set(imagePaths)];
    if (uniqueImagePaths.length === 0) {
      await Promise.all([...clipboardImagePaths].map(removeClipboardImage));

      if (unavailableImages > 0) {
        ctx.ui.notify("The pasted image is no longer available", "warning");
      }

      return textChanged
        ? { action: "transform", text }
        : { action: "continue" };
    }

    let images: ImageContent[];
    try {
      images = await Promise.all(uniqueImagePaths.map(loadImage));
    } finally {
      await Promise.all([...clipboardImagePaths].map(removeClipboardImage));
    }
    text = removeRawTokens(text, rawImageTokens);

    ctx.ui.notify(
      `Attached ${images.length} image${images.length === 1 ? "" : "s"}`,
      "info",
    );

    return {
      action: "transform",
      text:
        text ||
        (images.length === 1
          ? "Describe the attached image."
          : "Describe the attached images."),
      images: [...(event.images ?? []), ...images],
    };
  });

  pi.on("session_shutdown", async (event) => {
    if (event.reason !== "reload") {
      await clearPendingImages();
    }
  });
}
