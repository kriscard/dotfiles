#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Multi-Agent Code Review
# @raycast.mode compact
# @raycast.packageName Dev

# Optional parameters:
# @raycast.icon 🔬
# @raycast.argument1 { "type": "text", "placeholder": "PR URL/# or branch (optional)", "optional": true }
# @raycast.argument2 { "type": "dropdown", "placeholder": "Project", "optional": true, "data": [{"title": "Roofr", "value": "roofr"}, {"title": "Claude Plugins", "value": "claude-plugins"}, {"title": "dotfiles", "value": "dotfiles"}, {"title": "Blog", "value": "blog"}, {"title": "Playground", "value": "playground"}] }

# Documentation:
# @raycast.description 9-agent parallel review: security → architecture → impl → perf → maintainability → composition → UX → a11y → polish. Findings scored P0–P4.

set -euo pipefail

TARGET="${1:-}"
PROJECT="${2:-roofr}"
PROMPT_FILE="/tmp/claude-review-$(date +%s).md"
RUNNER="/tmp/claude-review-runner-$(date +%s).sh"

# --- Resolve project path ---
case "$PROJECT" in
  "roofr")        PATH_DIR="$HOME/Code/roofr-dev/roofr" ;;
  "claude-plugins") PATH_DIR="$HOME/projects/kriscard-claude-plugins" ;;
  "dotfiles")     PATH_DIR="$HOME/.dotfiles" ;;
  "blog")         PATH_DIR="$HOME/projects/christophercardoso.dev" ;;
  "playground")   PATH_DIR="$HOME/projects/playground" ;;
  *)              PATH_DIR="$HOME/Code/roofr-dev/roofr" ;;
esac

# Override project from PR URL if github.com link is passed
if [[ "$TARGET" =~ github\.com ]]; then
  if [[ "$TARGET" =~ roofr ]]; then
    PATH_DIR="$HOME/Code/roofr-dev/roofr"
  fi
fi

# --- Build scope section ---
if [[ -n "$TARGET" ]]; then
  SCOPE="**Scope:** PR/ref \`${TARGET}\`

Before spawning agents, run:
\`\`\`bash
gh pr view \"${TARGET}\" --json number,title,body,baseRefName,headRefName,files,additions,deletions
\`\`\`
Use that output as the shared diff context for all agents."
else
  SCOPE="**Scope:** Current branch vs \`main\`

Before spawning agents, run:
\`\`\`bash
git diff main...HEAD --stat
git diff main...HEAD
\`\`\`
Use that output as the shared diff context for all agents."
fi

# --- Write prompt ---
cat > "$PROMPT_FILE" << PROMPT
# Multi-Agent Code Review

${SCOPE}

---

## Review Team

Spawn all 9 in a **single parallel message** (one Agent tool call block, all 9 calls):

| Priority | Type  | ID                                          | Focus                                          |
|----------|-------|---------------------------------------------|------------------------------------------------|
| 1        | agent | developer-tools:code-reviewer               | Security, production reliability, perf risks   |
| 2        | skill | architecture:senior-architect               | Design patterns, scalability, tech debt        |
| 3        | agent | developer-tools:frontend-developer          | React/TS quality, hooks, types                 |
| 4        | skill | vercel-react-best-practices                 | Performance, Core Web Vitals, Next.js          |
| 5        | agent | developer-tools:code-refactoring-specialist | Complexity, dead code, maintainability         |
| 6        | skill | vercel-composition-patterns                 | Component architecture, prop patterns          |
| 7        | agent | developer-tools:ui-ux-designer              | UX flows, usability, interaction quality       |
| 8        | skill | web-design-guidelines                       | A11y, responsive design, standards compliance  |
| 9        | skill | emil-design-engineering                     | UI polish, micro-interactions, design tokens   |

The Priority column is the **tiebreaker order** when agents contradict — lower number wins.

---

## Scoring

Every finding from every agent (skill or agent type) must carry one tag:

| Tag | Meaning                                      | Action              |
|-----|----------------------------------------------|---------------------|
| P0  | Security vuln · breaking bug · a11y blocker  | Block merge         |
| P1  | Perf regression · arch smell · prod risk     | Fix this sprint     |
| P2  | Code quality · maintainability debt          | Fix near-term       |
| P3  | UX/design polish · DX improvement           | Nice-to-have        |
| P4  | Suggestion · style preference                | Backlog / skip      |

---

## Consolidation (after all 9 agents complete)

1. **Dedup** — merge identical findings from multiple agents into one entry; cite all sources in brackets.
2. **Sort** — present full list P0 → P4, then by file:line within each tier.
3. **Contradictions** — when two agents give opposing recommendations:
   - List both as: ⚠️ **CONFLICT** — \`[AgentA]\` says X / \`[AgentB]\` says Y
   - Apply tiebreaker priority from the team table
   - Group all conflicts in a **⚠️ Conflicts to Resolve** section at the end
   - Ask me to confirm each conflict resolution before finalizing the report
4. **Format per finding:**
   \`[P#] [Source(s)] path/file.tsx:LINE — finding → recommendation\`

---

Spawn all 9 agents in a single parallel message now.
PROMPT

# --- Write runner ---
cat > "$RUNNER" << RUNNER
#!/bin/bash
cd "$PATH_DIR"
claude "\$(cat $PROMPT_FILE)"
rm -f "$PROMPT_FILE" "$RUNNER"
RUNNER
chmod +x "$RUNNER"

# --- Launch in a unique named tmux session (avoids the sesh --command skip-if-exists issue) ---
SESSION="review-$(date +%H%M%S)"
tmux new-session -d -s "$SESSION" -c "$PATH_DIR" "$RUNNER"

# Switch to it — tmux switch-client works from inside tmux, sesh --switch works from Raycast
tmux switch-client -t "$SESSION" 2>/dev/null || sesh connect "$SESSION" --switch

osascript -e 'tell application "Ghostty" to activate'

echo "Review started · session: $SESSION · project: $PROJECT${TARGET:+ · target: $TARGET}"
