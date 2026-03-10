---
title: Context
description: Everything the AI needs to know about you
max_lines: 150
children:
  - voice/index.md
  - work/index.md
---

# Context

This folder contains everything the AI needs to know about you. It's populated by `/setup` and refined over time by `/learn`.

## Sections

- **[Voice](voice/index.md)** — your communication style, tone, and patterns
- **[Work](work/index.md)** — your role, tools, and work context

## How It's Used

1. LLM agents read `CLAUDE.md` first, then this index
2. Based on the task, they follow links to relevant detail pages
3. The reflection agent updates these files after meaningful sessions
4. The `/learn` skill validates and evolves them periodically

## Adding New Context

To add a new domain (e.g., `context/clients/`):
1. Create the folder with an `index.md`
2. Add detail pages as needed
3. Link the new `index.md` from this file
4. Add frontmatter with `title`, `description`, `max_lines`, `parent`
