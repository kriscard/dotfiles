---
description: Ensure matching skills are loaded before responding to any prompt
---

# Skill-First Mode

You are now in **skill-first mode**. Before doing ANY work, you MUST search for and load matching skills.

## Step 1: Ask the User

Respond with:

> Got it — skill-first mode is active. I'll search and load any matching skills before responding.
>
> What do you want to work on?

Then **stop and wait** for the user's response.

## Step 2: Match Skills to the User's Prompt

When the user provides their prompt, identify the **1-3 most specific** skills that directly address their request. Precision over breadth — load only what's needed.

### Selection Strategy

1. **Pick the most specific skill first** — if the user asks about LSP config, load `nvim-lsp`, not the broad `neovim-best-practices`
2. **Only add a second/third skill if it covers a clearly different aspect** of the prompt
3. **Never load a general skill when a specific one exists** — e.g. don't load `code-assistant` when `typescript-coder` covers it
4. **Cap at 3 skills max** — if you think you need more, pick the 3 most relevant

### Skill Reference by Domain

Use this to identify candidates, then narrow down to the most specific 1-3:

- **Neovim**: `neovim-best-practices` (general config), `lazy-nvim-optimization` (startup/lazy-loading), `nvim-plugins` (plugin recommendations), `nvim-lsp` (LSP setup), `nvim-perf` (profiling/bottlenecks), `nvim-check-config` (config validation)
- **React/frontend**: `react-best-practices` (audit/patterns), `frontend-developer` (implementation), `code-assistant` (general coding)
- **TypeScript**: `code-assistant` (general), `typescript-coder` (TS-specific)
- **Next.js**: `nextjs-developer` (Next.js specific), `react-best-practices` (React patterns)
- **Code quality**: `code-assistant`, `code-reviewer`, `de-slopify`
- **Architecture**: `senior-architect`, `arch-doc`
- **Testing**: `test-suite` (orchestration), `unit-test-developer`, `integration-test-developer`, `automation-test-developer`
- **Git**: `commit`, `pr`
- **Dotfiles/shell**: `dotfiles-optimizer`, `dotfiles-best-practices`, `dotfiles-audit`
- **Content**: `blog-writer`, `conference-talk-builder`, `doc-coauthoring`
- **AI/LLM**: `ai-engineer`, `prompt-engineer`
- **Learning**: `interactive-teaching`, `learn`
- **Obsidian**: `obsidian-workflows`, `vault-structure`, `daily-startup`, `process-inbox`
- **Debugging**: `debugger`, `code-assistant`
- **Plugin dev**: `claude-code-analyzer`, `plugin-structure`, `skill-development`
- **Security**: `frontend-security-coder`
- **Startup/product**: `studio-startup`, `ideation`
- **Specs**: `spec`, `deep-spec`, `ideation`

### Examples

| Prompt | Load | Skip |
|--------|------|------|
| "My LSP feels slow opening React files" | `nvim-lsp`, `nvim-perf` | `neovim-best-practices`, `lazy-nvim-optimization` |
| "Is this React component following best practices?" | `react-best-practices` | `frontend-developer`, `code-assistant` |
| "Write unit tests for this service" | `unit-test-developer` | `test-suite`, `integration-test-developer` |
| "Create a blog post about Next.js streaming" | `blog-writer` | `nextjs-developer` (writing, not coding) |
| "Optimize my Neovim startup time" | `nvim-perf`, `lazy-nvim-optimization` | `neovim-best-practices`, `nvim-lsp` |

## Step 3: Load Skills

For EACH matching skill, call `Skill(skill-name)` to load it into the conversation. Do NOT just mention them — you must actually invoke the Skill tool for each one.

Report which skills you loaded:

> **Loaded skills:**
> - `skill-name-1` — reason it matches
> - `skill-name-2` — reason it matches

## Step 4: Execute

Now respond to the user's original prompt using the knowledge and instructions from all loaded skills. Follow each loaded skill's workflow and guidelines.

## Rules

- **Load 1-3 skills max** — be selective, not exhaustive
- **Specific beats general** — always prefer the narrower, more targeted skill
- **Actually call Skill()** — reading a skill file is NOT the same as loading it. You must use the Skill tool
- **If nothing matches closely, say so** — don't force-load unrelated skills just to load something
- **Stay in skill-first mode** for the entire conversation — repeat this process for each new prompt the user gives
