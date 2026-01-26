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

---

## 📝 Git & Commit Guidelines

Maintain clean, focused commit history following conventional commit format.

### Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:** feat, fix, docs, style, refactor, test, chore
**Subject:** Imperative mood, lowercase, no period, max 50 chars
**Body:** Explain WHAT and WHY (not HOW), wrap at 72 chars

### Commit Message Examples

✅ **Good:**

```
feat(tmux): add session resurrection plugin

Integrates tmux-resurrect to persist sessions across reboots.
Configured automatic save every 15 minutes.
```

```
fix(nvim): resolve lazy.nvim plugin load order

Telescope was loading before plenary dependency causing errors.
Moved plenary to higher priority in lazy spec.
```

❌ **Bad:**

```
update config
```

```
feat(tmux): add plugin

🤖 Generated with Claude Code
```

### Branch Naming

- **Features:** `feat/descriptive-name`
- **Fixes:** `fix/issue-description`
- **Refactoring:** `refactor/component-name`
- Use lowercase with hyphens

### Pull Request Guidelines

- Summarize changes in bullet points
- Include testing steps if applicable
- Link issues with `Fixes #123` or `Relates to #456`
- Focus on WHAT changed and WHY
- **No AI attribution** in description

---

## 🔌 MCP Server Usage Guidelines

MCP servers provide powerful integrations. Use responsibly with appropriate safety checks.

### Browser MCP (Web Navigation)

**ALWAYS use browsermcp for:**

- Web navigation and interactive browsing
- Research requiring multiple page visits
- Fetching website content for analysis

**Best practices:**

- Take snapshots before clicking/typing on pages
- Close tabs when done
- Respect rate limits and site policies

**Do NOT use browsermcp for:**

- Simple API calls (use curl/httpie)
- Direct file downloads (use wget/curl)

### Obsidian MCP (Personal Knowledge Base)

**⚠️ HIGH SENSITIVITY - Contains personal notes**

**Allowed Without Confirmation:**

- ✅ Read/search notes to answer questions
- ✅ Create new notes when explicitly requested
- ✅ Update specific notes when user names them

**Requires Explicit Confirmation:**

- ⚠️ **Deleting any note** - Ask: "Confirm deletion of '[note name]' by typing 'yes'"
- ⚠️ **Bulk updates** affecting multiple notes - List affected notes, wait for approval
- ⚠️ **Restructuring vault** (moving notes, renaming folders)

**Confirmation Template:**

```
I will [ACTION] the following:
- [Item 1]
- [Item 2]

This will affect N notes. Reply 'yes' to proceed or 'no' to cancel.
```

### Context7 MCP (Library Documentation)

**Use for:**

- Fetching up-to-date library documentation
- Finding usage examples for frameworks
- API reference lookups

**Best practices:**

- Use `resolve-library-id` first to get correct library ID
- Use `get-library-docs` with the resolved ID
- Specify topic parameter to reduce token usage

---

## 📚 TIL (Today I Learned) Documentation

At the end of every project session, create a detailed TIL note in Obsidian.

### File Location & Naming

- **Path:** `1 - Notes/TIL/til-YYYY-MM-DD.md` (use today's date)
- **Example:** `1 - Notes/TIL/til-2024-03-15.md`

### Required Content

The TIL note should explain the project in plain, engaging language. Include:

1. **Technical Architecture**
   - How the system is designed
   - Why this architecture was chosen over alternatives
   - Use analogies to make complex concepts memorable

2. **Codebase Structure**
   - Directory layout and organization
   - How the various parts connect and communicate
   - Data flow through the system

3. **Technology Choices**
   - What technologies/frameworks/libraries are used
   - Why these were selected (trade-offs considered)
   - How they integrate together

4. **Lessons Learned**
   - Bugs encountered and how they were fixed
   - Potential pitfalls and how to avoid them
   - New technologies or patterns discovered
   - Engineering best practices demonstrated
   - "Aha moments" and key insights

### Writing Style

- **Engaging, not boring** - Write like you're telling a story to a friend
- **Use analogies** - Compare technical concepts to everyday things
- **Include anecdotes** - "We tried X, it broke spectacularly because..."
- **Be specific** - Real file names, real error messages, real solutions
- **Teach the reader** - Explain WHY, not just WHAT

### Example Structure

```markdown
# TIL: Building [Project Name]

## The Big Picture
[One paragraph explaining what we built and why it matters]

## Architecture Deep Dive
[Technical architecture with analogies]

## The Journey
[Narrative of what we did, including mistakes and fixes]

## Key Takeaways
- [Lesson 1]
- [Lesson 2]

## Things That Broke (And How We Fixed Them)
[Specific bugs and solutions]

## What I'd Do Differently
[Hindsight insights]
```

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
