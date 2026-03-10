# agent-seed

**Self-evolving AI assistant starter kit. Markdown-only. Works with any LLM agent.**

Plant the seed. It grows with you.

---

## What is this?

A collection of markdown files that teach AI agents who you are — your voice, your preferences, your work context, your priorities.

It works with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://openai.com/index/introducing-codex/), [Devin](https://devin.ai), [Cursor](https://cursor.sh), [Windsurf](https://codeium.com/windsurf), and anything else that reads markdown.

No API keys. No runtime. No vendor lock-in. Just `.md` files.

### What it does

- **Gives any AI your voice** — communication style, tone, patterns
- **Tracks your daily priorities** — todos, drafts, notes
- **Self-improves** — learns from each session, proposes new agents via PRs
- **Stays small** — enforced size limits prevent markdown bloat
- **Grows with you** — `/setup` generates agents based on YOUR workflow, `/learn` evolves them over time

### What it doesn't do

- Doesn't require API keys or expose secrets
- Doesn't lock you into any tool or vendor
- Doesn't run any code — it's just context files

## Quick Start

### 1. Use this template

Click **"Use this template"** on GitHub, or:

```bash
git clone https://github.com/jcurbelo/agent-seed.git my-agent
cd my-agent
rm -rf .git && git init
```

### 2. Run setup

Open the repo in your preferred AI coding tool and run:

```
/setup
```

The setup wizard will ask about your name, role, communication style, and tools — then generate personalized agents, voice profiles, and context files.

### 3. Start using it

```
/standup    # Morning briefing — scan todos, plan the day
/review     # Quick check-in — what needs attention?
/eod        # End of day — capture learnings, prep tomorrow
/learn      # Self-improvement — prune, evolve, grow new agents
```

## How It Works

### The Index Pattern

Every folder has an `index.md` that links to detail pages — like imports in code:

```
context/
├── index.md              # Master index → links to voice/, work/
├── voice/
│   ├── index.md          # Voice overview → links to patterns.md
│   └── patterns.md       # Detailed examples
└── work/
    ├── index.md          # Role overview → links to tools.md
    └── tools.md          # Services and repos you use
```

Index files are always loaded first. Detail pages load on demand. Size limits keep everything fast.

### Self-Evolution

This is the core idea. Three layers:

1. **Reflection agent** — after meaningful sessions, captures learnings to `memory/`
2. **`/learn` skill** — periodic self-improvement: prunes stale entries, identifies gaps, creates new agents via PR
3. **`/setup` re-run** — add new integrations or agents anytime

When the system detects a gap (e.g., you keep asking about Slack but there's no Slack agent), it creates one and files a PR.

### Frontmatter

Every `.md` file has YAML frontmatter that defines its role:

```yaml
# Agent definition
---
model: sonnet                    # Model tier: haiku | sonnet | opus
tools: [Read, Write, Edit]      # Allowed tools
permissionMode: default          # default | bypassPermissions
maxTurns: 10                     # Max agent turns
---

# Scoped rule
---
paths: ["todos/**"]              # When these paths are active
---

# Context/memory page
---
title: Voice Profile
description: Communication style and tone
parent: ../index.md              # Navigation link
max_lines: 250                   # Enforced by policy script
---
```

### Markdown Policy

A script (`scripts/check-markdown-policy.sh`) enforces:

- Size limits per file type (index: 150 lines, pages: 250 lines, memory: 200 lines)
- Required frontmatter keys
- Required todo sections
- No orphaned pages (every page linked from an index)

Run it locally or add it to CI.

## File Structure

```
agent-seed/
├── CLAUDE.md                     # Claude Code / LLM entrypoint
├── AGENTS.md                     # Devin / Codex entrypoint
├── .cursorrules                  # Cursor entrypoint
├── README.md                     # You are here
├── LICENSE                       # MIT
│
├── .claude/
│   ├── settings.json             # Safety hooks
│   ├── agents/                   # Agent definitions
│   │   ├── index.md              # Agent registry + routing
│   │   ├── researcher.md         # Web research
│   │   ├── coder.md              # Code writing
│   │   ├── reviewer.md           # Code review
│   │   ├── todo-manager.md       # Daily todos
│   │   └── reflection.md         # Self-improvement engine
│   ├── skills/                   # Slash commands
│   │   ├── setup/SKILL.md        # /setup wizard
│   │   ├── standup/SKILL.md      # Morning briefing
│   │   ├── eod/SKILL.md          # End of day
│   │   ├── review/SKILL.md       # Quick check-in
│   │   ├── learn/SKILL.md        # Self-improvement
│   │   └── update-todos/SKILL.md # Interactive todo review
│   └── rules/                    # Scoped rules (load by file path)
│       ├── todos.md
│       ├── context.md
│       └── drafts.md
│
├── context/                      # Who you are (populated by /setup)
│   ├── index.md
│   ├── voice/
│   │   ├── index.md
│   │   └── patterns.md
│   └── work/
│       ├── index.md
│       └── tools.md
│
├── memory/                       # What the AI has learned
│   ├── MEMORY.md                 # Master index (always loaded)
│   ├── learnings.md
│   ├── preferences.md
│   ├── patterns.md
│   └── improvements.md
│
├── todos/                        # Daily task tracking
│   └── _template.md
│
└── scripts/
    └── check-markdown-policy.sh  # Enforces structure + size limits
```

## Compatibility

| Tool | Entrypoint | Status |
|------|-----------|--------|
| Claude Code | `CLAUDE.md` | Full support (agents, skills, rules, hooks) |
| Cursor | `.cursorrules` | Context + rules |
| Codex | `AGENTS.md` | Context + agents |
| Devin | `AGENTS.md` | Context + agents |
| Windsurf | `CLAUDE.md` | Context + rules |
| Any LLM | `CLAUDE.md` | Read as context |

## Philosophy

Your AI assistant should know you the way a good colleague does — your communication style, your priorities, your tools. This repo is that knowledge, version-controlled and self-evolving.

Use it with current AI coding agents. Don't expose private keys. Do whatever you want with it.

## License

MIT — do whatever you want.
