# Installing claude-codex-bridge for Codex

Enable cross-tool plan execution in Codex. Claude Code writes plans, Codex implements them.

## Installation

```bash
mkdir -p ~/.agents/skills
ln -s ~/.claude-codex-bridge/skills ~/.agents/skills/claude-codex-bridge
```

## Verify

```bash
ls -la ~/.agents/skills/claude-codex-bridge
```

You should see a symlink pointing to `~/.claude-codex-bridge/skills/`.

## Usage

1. In Claude Code: brainstorm and plan using `plan-for-codex` skill
2. Plan is saved to `docs/superpowers/plans/` with Codex-ready format
3. In Codex: run `execute-claude-plan` skill to pick up and implement the plan
