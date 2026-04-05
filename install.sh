#!/usr/bin/env bash
#
# claude-codex-bridge installer
# Installs skills into Claude Code and Codex via symlinks.
#
# Usage:
#   bash install.sh
#
# Idempotent — safe to re-run.

set -euo pipefail

# Resolve the repo root (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"

CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.agents/skills"

echo "claude-codex-bridge installer"
echo "=============================="
echo "Repo: $REPO_ROOT"
echo ""

# Sanity check — make sure we're in the right repo
if [[ ! -d "$REPO_ROOT/skills/plan-for-codex" ]] || [[ ! -d "$REPO_ROOT/skills/execute-claude-plan" ]]; then
  echo "ERROR: This doesn't look like the claude-codex-bridge repo."
  echo "Expected skills/ directory with plan-for-codex and execute-claude-plan subdirectories."
  exit 1
fi

# --- Claude Code ---
echo "[1/2] Installing into Claude Code ($CLAUDE_SKILLS_DIR)..."
mkdir -p "$CLAUDE_SKILLS_DIR"

for skill in plan-for-codex execute-claude-plan; do
  target="$CLAUDE_SKILLS_DIR/$skill"
  source="$REPO_ROOT/skills/$skill"

  if [[ -L "$target" ]]; then
    # Existing symlink — replace it (in case source moved)
    rm "$target"
  elif [[ -e "$target" ]]; then
    echo "  ERROR: $target exists and is not a symlink. Aborting."
    echo "  Remove it manually and re-run the installer."
    exit 1
  fi

  ln -s "$source" "$target"
  echo "  ✓ $skill"
done

# --- Codex ---
echo "[2/2] Installing into Codex ($CODEX_SKILLS_DIR)..."
mkdir -p "$CODEX_SKILLS_DIR"

codex_target="$CODEX_SKILLS_DIR/claude-codex-bridge"
codex_source="$REPO_ROOT/skills"

if [[ -L "$codex_target" ]]; then
  rm "$codex_target"
elif [[ -e "$codex_target" ]]; then
  echo "  ERROR: $codex_target exists and is not a symlink. Aborting."
  echo "  Remove it manually and re-run the installer."
  exit 1
fi

ln -s "$codex_source" "$codex_target"
echo "  ✓ claude-codex-bridge (both skills discovered via this symlink)"

# --- Codex multi-agent check ---
CODEX_CONFIG="$HOME/.codex/config.toml"
if [[ -f "$CODEX_CONFIG" ]]; then
  if grep -q "multi_agent.*=.*true" "$CODEX_CONFIG"; then
    echo ""
    echo "  ✓ Codex multi-agent mode is enabled"
  else
    echo ""
    echo "  ⚠  Codex multi-agent mode not detected in $CODEX_CONFIG"
    echo "     Add this for parallel task execution:"
    echo "       [features]"
    echo "       multi_agent = true"
  fi
else
  echo ""
  echo "  ℹ  Codex config not found at $CODEX_CONFIG"
  echo "     Install Codex CLI, then add to ~/.codex/config.toml:"
  echo "       [features]"
  echo "       multi_agent = true"
fi

echo ""
echo "Done. Restart Claude Code and/or Codex to pick up the new skills."
echo ""
echo "Usage:"
echo "  Claude Code: 'Use the plan-for-codex skill to plan <feature>'"
echo "  Codex:       codex 'execute the plan at docs/plans/<filename>.md'"
