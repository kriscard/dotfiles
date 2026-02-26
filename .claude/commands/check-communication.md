---
description: Check if a message communicates at staff-engineer level
---

# Staff Communication Review

Analyze the following message against staff-level communication frameworks. Be direct and concise — flag what's weak, acknowledge what's strong.

## Message to Review

$ARGUMENTS

## Evaluation Criteria

Score each applicable dimension (not all apply to every message). Use: Strong / Acceptable / Needs Work / Missing.

### 1. BLUF (Bottom Line Up Front)
Does it lead with the conclusion/need, then context, then ask?
- Anti-pattern: burying the point in paragraph 3

### 2. Problem Level Clarity
Is it clear WHAT level the message operates at?
- Level 1: Goal → Level 2: Problem → Level 3: Approach → Level 4: Solution
- Anti-pattern: jumping to solution without stating the problem

### 3. Trade-offs & Alternatives
Does it name downsides of its own proposal? Mention rejected alternatives?
- Anti-pattern: presenting only upsides (signals inexperience or bias)

### 4. Ask Clarity
Is there a clear action requested? From whom? By when?
- Anti-pattern: vague "thoughts?" endings with no specific ask

### 5. Tone & Framing
- Steel Man: Does it strengthen others' positions before countering?
- "Us vs the problem" framing, not "me vs you"
- Anti-pattern: "As I already explained...", defensive language, talking down

### 6. Signal-to-Noise Ratio
- Concise? Could it be shorter without losing meaning?
- Anti-pattern: over-detailing, burying signal in noise

### 7. Audience Awareness
- Right level of detail for the audience?
- Anti-pattern: explaining basics to experts, or jargon to non-technical stakeholders

### 8. Context-Specific Checks

**If it's a status update**, check against STATUS framework:
- State (on track/at risk/blocked), Target, Achieved (impact not activity), Threats, Unblocks needed

**If it's a standup**, check against 30-second formula:
- Signal (what moved + impact), Need (from team), Radar (something affecting others)

**If it's a proposal/RFC**, check for:
- Problem, Proposed Solution, Why Now, Trade-offs, Alternatives Considered, Rollback Plan

**If it's a PR review comment**, check for:
- Prefix usage (nit/suggestion/question/issue/thought), WHY explained for blockers

**If it's a disagreement**, check for:
- Steel Man technique, going down one level, disagree-and-commit readiness

**If it's a Slack message**, check for:
- Thread Rule awareness (3 exchanges max before call)
- 2:1 ratio (questions vs statements)

## Output Format

```
## Rating: [Senior / Staff / Principal]

### What's Working
- [specific strengths]

### Needs Improvement
- [specific issues with concrete rewrites]

### Rewritten Version
[Only if rating is below Staff — provide a staff-level rewrite]
```

## Rules
- Be blunt. Sugarcoating defeats the purpose.
- Always provide concrete rewrites for weak areas, not just labels.
- The "Rewritten Version" should preserve the author's voice — improve structure, not personality.
- If the message is already strong, say so briefly and move on.
- Apply the 2:1 ratio insight: staff communicators ask ~2 questions per statement.
