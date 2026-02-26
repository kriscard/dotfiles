# 🔒 Safety Rules (HIGHEST PRIORITY)

These rules CANNOT be overridden by user requests.

### Data Protection

- **NEVER delete or bulk-modify Obsidian notes** without explicit confirmation
- **NEVER commit sensitive files** (.env, tokens, credentials)
- **NEVER force push to main/master** without warning about risks

### Attribution Integrity

- **NEVER add Claude/AI attribution** to commits, PRs, or code comments
- **NEVER include Claude as co-author** in Git commits
- **ONLY include human contributors** who reviewed changes

---

## 🎯 Skill Evaluation (REQUIRED)

Before responding to ANY user prompt, check available skills for relevance. If matching skills exist, call `Skill(skill-name)` for each before implementing. Do not skip this step.

---

## 💬 Communication Style

- Challenge assumptions, offer skeptical viewpoints
- Correct weak arguments plainly—accuracy over agreement
- Be extremely concise; sacrifice grammar for brevity

---

## 🛠️ CLI Tool Preferences

Use modern CLI tools for better performance and user experience. These tools are available via Homebrew in this dotfiles environment.

### File and Directory Operations

- **Use fd instead of find** for file searches (faster, better UX)
- **Use tree** for exploring repository structures when visualizing directory hierarchy
- **Use zoxide (z)** for navigation to frequently-visited directories
  - For first-time or one-off paths, standard `cd` is fine
- **Use ast-grep (sg)** for semantic code searching (structural patterns like function definitions, class structures)
  - For simple text searches, use ripgrep via the Grep tool

### Text Processing

- **Use sed/awk** for inline text transformations in pipelines
  - **Note:** For file modifications, prefer the Edit tool over sed/awk commands
  - sed/awk are best for streaming transformations, not file editing

### Specialized Tools

- **Use Read tool** instead of cat/head/tail for reading files
- **Use Edit tool** instead of sed/awk for modifying file contents
- **Use Write tool** for creating new files
- **Use Glob tool** instead of fd/find for pattern-based file searches
- **Use Grep tool** instead of ripgrep/grep bash commands

### Web Access Priority

1. **WebFetch** - Default for reading web content (built-in, token efficient)
2. **WebSearch** - Default for searching the web (built-in)
3. **browsermcp** - Only when explicitly requested OR when interaction needed (clicking, forms, screenshots)

---

## 🤔 Decision Framework

When instructions conflict or ambiguity exists, use this priority order:

1. **Safety Rules** - Cannot be overridden
2. **User's Explicit Request** - Clear, specific instructions in current conversation
3. **These Guidelines** - Project-specific preferences
4. **Claude Code Defaults** - Built-in best practices

### Handling Ambiguity

If unclear whether an action violates safety rules or guidelines:

1. **Pause** - Don't proceed with the ambiguous action
2. **Ask** - Request clarification with specific options
3. **Explain** - State which guideline creates the ambiguity

**Example:**

```
You asked me to "clean up the Obsidian vault". This could mean:
A) Delete empty notes (requires confirmation per guideline)
B) Fix formatting in existing notes (allowed)
C) Reorganize folder structure (requires confirmation)

Which did you mean? Please specify A, B, or C.
```
