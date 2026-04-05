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

## Installation

### Prerequisites

- **Git** (for cloning the repo)
- **[Claude Code](https://claude.com/claude-code)** installed
- **[Codex CLI](https://github.com/openai/codex)** installed (optional, but needed for the execution side): `npm install -g @openai/codex`

### Quick Install (one command)

```bash
git clone https://github.com/monosphere-dev/claude-codex-bridge.git ~/.claude-codex-bridge \
  && bash ~/.claude-codex-bridge/install.sh
```

That's it. The installer handles both tools automatically.

**What the installer does:**

1. Clones the repo to `~/.claude-codex-bridge/`
2. Creates symlinks in `~/.claude/skills/` so Claude Code discovers the `plan-for-codex` skill
3. Creates a symlink in `~/.agents/skills/claude-codex-bridge` so Codex discovers the `execute-claude-plan` skill
4. Checks `~/.codex/config.toml` and warns if `multi_agent = true` isn't set (needed for parallel execution in Codex)

The installer is **idempotent** — safe to re-run, replaces stale symlinks, and fails safely if a non-symlink file exists at the target (no clobbering).

### Enable Codex Multi-Agent Mode

If the installer warned you about missing multi-agent config, add this to `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

Required for `spawn_agent` — used by `execute-claude-plan` to run independent tasks in parallel.

### Verify Installation

```bash
# Should show two symlinks
ls -la ~/.claude/skills/

# Should show claude-codex-bridge symlink
ls -la ~/.agents/skills/
```

Then **restart Claude Code and Codex** (quit and relaunch) so they pick up the new skills.

### Manual Install

If you'd rather not run the script:

**Claude Code:**
```bash
git clone https://github.com/monosphere-dev/claude-codex-bridge.git ~/.claude-codex-bridge
mkdir -p ~/.claude/skills
ln -s ~/.claude-codex-bridge/skills/plan-for-codex ~/.claude/skills/plan-for-codex
ln -s ~/.claude-codex-bridge/skills/execute-claude-plan ~/.claude/skills/execute-claude-plan
```

**Codex:**
```bash
mkdir -p ~/.agents/skills
ln -s ~/.claude-codex-bridge/skills ~/.agents/skills/claude-codex-bridge
```

### Windows (PowerShell)

The bash installer won't work directly on Windows. Use WSL, or create junctions manually:

```powershell
git clone https://github.com/monosphere-dev/claude-codex-bridge.git "$env:USERPROFILE\.claude-codex-bridge"

New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"

cmd /c mklink /J "$env:USERPROFILE\.claude\skills\plan-for-codex"       "$env:USERPROFILE\.claude-codex-bridge\skills\plan-for-codex"
cmd /c mklink /J "$env:USERPROFILE\.claude\skills\execute-claude-plan"  "$env:USERPROFILE\.claude-codex-bridge\skills\execute-claude-plan"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\claude-codex-bridge"  "$env:USERPROFILE\.claude-codex-bridge\skills"
```

### Updating

Pull new changes anytime:

```bash
cd ~/.claude-codex-bridge && git pull
```

Symlinks follow the files — no reinstall needed. Restart your tools if they're already running to reload the skills.

### Uninstall

```bash
rm ~/.claude/skills/plan-for-codex
rm ~/.claude/skills/execute-claude-plan
rm ~/.agents/skills/claude-codex-bridge
rm -rf ~/.claude-codex-bridge
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

## Troubleshooting

**"Skill not found" in Claude Code:**
- Confirm `ls ~/.claude/skills/plan-for-codex/SKILL.md` resolves through the symlink
- Restart Claude Code completely (quit, not just close the window)

**"Skill not found" in Codex:**
- Confirm `ls ~/.agents/skills/claude-codex-bridge/plan-for-codex/SKILL.md` works
- Restart the Codex CLI

**Installer fails with "file exists, not a symlink":**
- You have a real file/directory at the target path. Remove it manually, then re-run:
  ```bash
  rm -rf ~/.claude/skills/plan-for-codex ~/.claude/skills/execute-claude-plan
  bash ~/.claude-codex-bridge/install.sh
  ```

## Plan Format

Plans written by `plan-for-codex` are self-contained — Codex reads them with zero context from Claude Code's session:

- **Goal / Architecture / Tech Stack** — one-liner context
- **Codebase Context** — project structure, patterns, commands, existing code references
- **Tasks** — numbered, checkbox steps with full code and exact commands
- **Dependencies** — explicit per task (enables parallel execution)
- **Verification** — test/lint/build commands
- **Definition of Done** — acceptance criteria

See [`skills/plan-for-codex/SKILL.md`](skills/plan-for-codex/SKILL.md) for the full format spec.

## Why Not Just Use Superpowers?

[Superpowers](https://github.com/obra/superpowers) has excellent `writing-plans` and `executing-plans` skills that work in both tools. This plugin extends that workflow with Codex-specific optimizations:

| Superpowers | claude-codex-bridge |
|---|---|
| Plan format targets Claude Code's execution model | Plan format strips Claude Code tool references |
| Implicit assumption: same-session context | Explicit "Codebase Context" section (Codex has none) |
| Plans in `docs/superpowers/plans/` | Plans in `docs/plans/` (separate, Codex-targeted) |
| No parallel execution hints | Explicit `Dependencies: None` markers for `spawn_agent` |

You can use both plugins side-by-side.

## Team Setup

Share the install command with your team:

```bash
git clone https://github.com/monosphere-dev/claude-codex-bridge.git ~/.claude-codex-bridge \
  && bash ~/.claude-codex-bridge/install.sh
```

Updates propagate via `git pull` in `~/.claude-codex-bridge/` — no reinstall needed.

## License

MIT
