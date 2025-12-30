# Story Circle Framework for Tech Content

The Story Circle is an eight-step narrative framework adapted from Dan Harmon's storytelling technique. It structures technical content to create engaging narratives.

## The Structure

```
        ORDER (Comfort Zone)
           1. You
           2. Need
    8. Change      3. Go
           ↑        ↓
    7. Return    4. Search
           ↑        ↓
    6. Take      5. Find
           CHAOS (Unknown)
```

## The Eight Steps

### 1. Introduction (You)
**Top half - Order**

Introduce the current status quo.

- Set the scene with existing workflow or technology
- Establish the baseline before disruption
- Make the audience understand the familiar ground
- "I was using X, and it worked fine..."

### 2. Problem Statement (Need)
**Top half - Order**

Identify the problem or motivation for change.

- Clearly articulate what's not working
- Help the reader feel the pain point
- Create the motivation for the journey
- "But then I noticed..." or "The problem was..."

### 3. Exploration (Go)
**Crossing to bottom half - Chaos**

Describe stepping into the unknown.

- What did you try first?
- Initial attempts and experiments
- Leaving the comfort zone
- "I decided to try..." or "My first attempt was..."

### 4. Experimentation (Search)
**Bottom half - Chaos**

Detail the process of discovery.

- What did you learn along the way?
- Experiments, failures, pivots
- The messy middle of problem-solving
- "After some digging..." or "I discovered that..."

### 5. Solution (Find)
**Bottom half - Chaos**

The breakthrough moment.

- Present what finally clicked
- Show the technical solution
- Explain the approach that worked
- "Then I found..." or "The key insight was..."

### 6. Challenges (Take)
**Bottom half - Chaos**

Implementation difficulties and trade-offs.

- What was hard about implementing?
- Trade-offs you had to accept
- The cost of the change
- "It wasn't perfect..." or "The challenge was..."

### 7. Apply Knowledge (Return)
**Crossing to top half - Order**

Bringing the solution back.

- How you integrated the solution
- Practical application
- Return to familiar with new tools
- "I applied this to..." or "In practice..."

### 8. Results & Insights (Change)
**Top half - Order**

The new status quo.

- What changed as a result
- Lessons learned
- Actionable insights for the reader
- "Now I..." or "The key takeaway is..."

## When to Use Story Circle

**Good fit:**
- Tutorial posts with a discovery journey
- "How I solved X" posts
- Migration or adoption stories
- Learning experiences
- Problem → Solution narratives

**Not every post needs it:**
- Quick TILs
- Reference documentation
- Feature announcements
- Pure how-to guides (no discovery journey)

## Simplified Patterns

Not every post needs all 8 steps. Common shortcuts:

### The Discovery Arc (5 steps)
1. Status quo → 2. Problem → 5. Solution → 7. Application → 8. Insights

### The Learning Journey (4 steps)
1. I thought X → 4. I tried Y → 5. I learned Z → 8. Now I do W

### The Quick Win (3 steps)
2. Problem → 5. Solution → 8. Takeaway

## Example Application

**Topic**: Switching from npm to pnpm

1. **You**: Using npm for all projects, 45-second installs
2. **Need**: Build times slowing down development
3. **Go**: Heard about pnpm, decided to try it
4. **Search**: Tested on a small project, researched how it works
5. **Find**: Symlink approach, 8-second installs
6. **Take**: Had to update CI scripts, peer deps behave differently
7. **Return**: Migrated main projects, updated team docs
8. **Change**: Faster builds, team adopted it, new standard

## Integration with Voice

When using Story Circle:
- Use first-person throughout ("I discovered...")
- Show vulnerability in steps 3-6 (the chaos)
- Be specific with numbers and details
- Let the reader learn alongside you
- End with actionable insight, not just "it worked"
