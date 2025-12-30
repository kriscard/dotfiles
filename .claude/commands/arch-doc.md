---
description: Generate architecture documentation with C4 diagrams and ADRs
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <scope: system | service-name | decision-topic>
model: opus
---

# Architecture Documentation Generator

Generate architecture documentation for: $ARGUMENTS

## Process

### 1. Discovery
- Explore project structure, configs, and existing docs
- Identify services, dependencies, and integration points
- Find existing architecture files or diagrams

### 2. Choose Output Type

Based on scope, generate appropriate documentation:

**System Overview** → C4 Context + Container diagrams
**Service Deep-Dive** → C4 Component diagram + data flow
**Decision Documentation** → ADR (Architecture Decision Record)

### 3. Generate Documentation

## Output Formats

### C4 Model (Mermaid)

```markdown
## System Context
[Who uses it, what external systems it integrates with]

## Container Diagram
​```mermaid
C4Container
  title Container Diagram

  Person(user, "User", "Description")
  System_Boundary(b1, "System Name") {
    Container(web, "Web App", "React", "Description")
    Container(api, "API", "Node.js", "Description")
    ContainerDb(db, "Database", "PostgreSQL", "Description")
  }
  System_Ext(ext, "External System", "Description")

  Rel(user, web, "Uses")
  Rel(web, api, "Calls")
  Rel(api, db, "Reads/Writes")
  Rel(api, ext, "Integrates")
​```

## Component Diagram
[For specific service deep-dives]
```

### ADR Template

```markdown
# ADR-XXX: [Decision Title]

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
[Why is this decision needed? What's the problem?]

## Decision
[What did we decide?]

## Options Considered
1. **[Option A]**: [Pros/Cons]
2. **[Option B]**: [Pros/Cons]

## Consequences
- [What becomes easier]
- [What becomes harder]
- [What we need to watch]
```

### Data Flow Diagram

```markdown
## Data Flow
​```mermaid
flowchart LR
  A[Source] --> B[Process]
  B --> C[Store]
  C --> D[Output]
​```

## Key Data Entities
| Entity | Storage | Owner | Notes |
|--------|---------|-------|-------|
```

## File Locations

Place generated docs in:
- `docs/architecture/` - C4 diagrams, system overview
- `docs/adr/` - Architecture Decision Records (ADR-001-*.md)
- `docs/data-flow/` - Data flow documentation

## Usage

```bash
# Full system documentation
/arch-doc system

# Specific service
/arch-doc auth-service

# Document a decision
/arch-doc "migrate to PostgreSQL"

# Data architecture
/arch-doc data-layer
```

Analyze the codebase, generate diagrams in Mermaid format, and create actionable documentation.
