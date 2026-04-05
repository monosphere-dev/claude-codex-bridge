# claude-codex-bridge

Cross-tool handoff plugin: **Claude Code plans, Codex implements.**

Claude Code excels at deep codebase understanding, architecture, and planning. Codex excels at fast, parallel implementation. This plugin bridges them with a shared plan format and two skills — one for each tool.

## Workflow

```
┌─────────────────┐                    ┌─────────────────┐
│  Claude Code    │                    │     Codex       │
│                 │                    │                 │
│  plan-for-codex │─── plan.md ───────▶│ execute-claude- │
│  (architect)    │   docs/plans/      │      plan       │
│                 │                    │    (builder)    │
└─────────────────┘                    └─────────────────┘
```

1. In **Claude Code**, use `plan-for-codex` skill — explores codebase, writes self-contained plan to `docs/plans/YYYY-MM-DD-<feature>.md`
2. In **Codex**, use `execute-claude-plan` skill — picks up the plan and implements it

## Quick Install (one command)

```bash
git clone https://github.com/<your-org>/claude-codex-bridge.git ~/.claude-codex-bridge && bash ~/.claude-codex-bridge/install.sh
```

This installs the skills into both tools:
- Claude Code: symlinks into `~/.claude/skills/`
- Codex: symlinks into `~/.agents/skills/claude-codex-bridge`

Restart either tool after install to pick up the new skills.

## Manual Install

### Claude Code

```bash
git clone https://github.com/<your-org>/claude-codex-bridge.git ~/.claude-codex-bridge
mkdir -p ~/.claude/skills
ln -s ~/.claude-codex-bridge/skills/plan-for-codex ~/.claude/skills/plan-for-codex
ln -s ~/.claude-codex-bridge/skills/execute-claude-plan ~/.claude/skills/execute-claude-plan
```

### Codex

```bash
mkdir -p ~/.agents/skills
ln -s ~/.claude-codex-bridge/skills ~/.agents/skills/claude-codex-bridge
```

Ensure Codex multi-agent mode is enabled in `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

## Usage

### 1. Plan in Claude Code

```
Use the plan-for-codex skill to plan [feature description]
```

Claude Code will:
- Explore the relevant parts of the codebase
- Document conventions, patterns, and commands the builder will need
- Write a self-contained plan with exact file paths and complete code
- Save it to `docs/plans/YYYY-MM-DD-<feature>.md`
- Print the exact `codex` command to run

### 2. Execute in Codex

```bash
codex "execute the plan at docs/plans/2026-04-05-feature.md"
```

Codex will invoke `execute-claude-plan` automatically and:
- Load and review the plan
- Create a feature branch
- Run tasks sequentially (or parallelize independent tasks via `spawn_agent`)
- Run the verification + Definition of Done checklist
- Report results

## Plan Format

Plans written by `plan-for-codex` are self-contained — Codex reads them with zero context from Claude Code's session:

- **Goal / Architecture / Tech Stack** — one-liner context
- **Codebase Context** — project structure, patterns, commands, existing code references
- **Tasks** — numbered, checkbox steps with full code and exact commands
- **Dependencies** — explicit per task (enables parallel execution)
- **Verification** — test/lint/build commands
- **Definition of Done** — acceptance criteria

See `skills/plan-for-codex/SKILL.md` for the full format spec.

## Why Not Just Use Superpowers?

[Superpowers](https://github.com/obra/superpowers) has excellent `writing-plans` and `executing-plans` skills that work in both tools. This plugin extends that workflow with Codex-specific optimizations:

| Superpowers | claude-codex-bridge |
|---|---|
| Plan format targets Claude Code's execution model | Plan format strips Claude Code tool references |
| Implicit assumption: same-session context | Explicit "Codebase Context" section (Codex has none) |
| Plans in `docs/superpowers/plans/` | Plans in `docs/plans/` (separate, Codex-targeted) |
| No parallel execution hints | Explicit `Dependencies: None` markers for `spawn_agent` |

You can use both plugins side-by-side.

## Uninstall

```bash
rm ~/.claude/skills/plan-for-codex
rm ~/.claude/skills/execute-claude-plan
rm ~/.agents/skills/claude-codex-bridge
rm -rf ~/.claude-codex-bridge
```

## Team Setup

Share this repo URL with your team. Each member runs the one-command install above. Updates propagate via `git pull` in `~/.claude-codex-bridge/` — no reinstall needed (symlinks follow the files).

## License

MIT
