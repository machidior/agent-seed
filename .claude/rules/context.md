---
paths:
  - "context/**"
  - "memory/**"
---

# Context and Memory Rules

When updating context or memory files:

- **One interaction is not a pattern, three is.** Don't save garbage.
- Check if there's an existing entry to update before writing a new one.
- Respect `max_lines` in frontmatter. Split by topic when files grow.
- Organize semantically (by topic), not chronologically.
- Remove or update memories that turn out to be wrong.
- Don't duplicate what's already in `CLAUDE.md`.
- Every detail page must be linked from its parent `index.md`.
- User preferences go in `memory/preferences.md`.
- Technical insights go in `memory/learnings.md`.
- Work/role context goes in `context/work/`.
- Voice/tone updates go in `context/voice/`.
