---
description: Multi-dimensional analysis and systematic problem solving
argument-hint: <problem or decision to analyze>
model: opus
---

# Deep Analysis Mode

Perform systematic, multi-perspective analysis on: $ARGUMENTS

## Analysis Framework

### 1. Problem Framing
- State the core challenge in one sentence
- Identify constraints (time, budget, technical, organizational)
- Surface hidden assumptions
- Define what success looks like

### 2. Multi-Perspective Analysis

**Technical**: Feasibility, scalability, maintainability, security, tech debt
**Business**: ROI, time-to-market, competitive advantage, risk vs reward
**User**: Pain points, usability, accessibility, edge cases
**System**: Integration points, dependencies, emergent behaviors

### 3. Solution Generation

Generate 3-5 distinct approaches:
- At least one conventional/safe option
- At least one innovative/ambitious option
- Consider hybrid approaches

For each option:
- Implementation complexity (Low/Medium/High)
- Time to value
- Key risks and mitigations
- Second-order effects

### 4. Challenge & Stress Test

- Play devil's advocate on each solution
- What could go wrong?
- What are we not seeing?
- Invert: What should we definitely NOT do?

### 5. Synthesis & Recommendation

## Output Structure

```markdown
## Problem
[One paragraph framing]

## Key Constraints
- [Constraint 1]
- [Constraint 2]

## Options Analyzed

### Option A: [Name]
**Approach**: [Description]
**Pros**: [List]
**Cons**: [List]
**Complexity**: [Low/Medium/High]
**Risk**: [Assessment]

### Option B: [Name]
[Same structure]

## Recommendation
**Suggested approach**: [Option + rationale]
**Implementation path**: [Phases or steps]
**Success metrics**: [How to measure]
**Key risks to monitor**: [Top 2-3]

## Uncertainties
- [What we don't know]
- [Areas needing more research]
```

## Thinking Principles

- **First Principles**: Break down to fundamental truths
- **Systems Thinking**: Consider feedback loops and interconnections
- **Inversion**: What to avoid, not just what to pursue
- **Second-Order Effects**: Consequences of consequences

## Usage

```bash
# Architecture decisions
/deep-analyze Should we migrate to microservices or improve our monolith?

# Scaling challenges
/deep-analyze How to handle 10x traffic while reducing costs?

# Technology selection
/deep-analyze What stack for our next-gen platform?

# API design
/deep-analyze How to improve API developer experience while maintaining backward compatibility?
```

Provide comprehensive analysis with clear trade-offs and actionable recommendations.
