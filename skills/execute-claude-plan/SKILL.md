---
name: execute-claude-plan
description: Execute implementation plans written by Claude Code. Use when Claude Code has created a plan and you need to implement it in Codex.
---

# Execute Claude Plan

## Overview

Find and execute an implementation plan that was written by Claude Code using the `plan-for-codex` skill. Plans are self-contained documents with full codebase context, exact file paths, and complete code for every step.

**Announce at start:** "I'm using the execute-claude-plan skill to implement a plan written by Claude Code."

## Step 0: Find the Plan

Check these locations in order:
1. Path provided by the user (if any)
2. `docs/plans/` — sorted by date (newest first)
3. `docs/superpowers/plans/` — sorted by date (newest first)

If multiple plans exist, list them and ask the user which to execute:

```
Found plans:
1. docs/plans/2026-04-05-billing-overhaul.md
2. docs/plans/2026-04-03-notification-refactor.md

Which plan should I execute?
```

## Step 1: Load and Review

1. Read the full plan file
2. Verify the plan has the expected structure:
   - Goal, Architecture, Tech Stack
   - Codebase Context section (patterns, commands, references)
   - Numbered tasks with checkbox steps
   - Verification section
3. Review critically — identify any concerns:
   - Missing context or unclear steps
   - File paths that don't exist (for modifications)
   - Commands that look wrong for this project
   - Dependencies between tasks that aren't marked
4. If concerns: raise them and wait for guidance
5. If no concerns: create task tracking and proceed

Use `update_plan` to track all tasks from the plan.

## Step 2: Set Up Workspace

Before writing any code:

1. **Check branch state:**
   ```bash
   git branch --show-current
   git status
   ```

2. **Create a feature branch** (unless already on one):
   ```bash
   git checkout -b feat/<feature-name-from-plan>
   ```

3. **Verify environment:**
   - Run the build command from the plan's "Environment & Commands" section
   - Run the test command to confirm baseline passes
   - If either fails, stop and report before proceeding

## Step 3: Execute Tasks

For each task in order:

1. **Mark as in-progress** via `update_plan`
2. **Check dependencies** — if task depends on another, verify that task is complete
3. **Follow each step exactly:**
   - Code steps: write the code as shown
   - Command steps: run the command and verify expected output
   - Commit steps: stage and commit exactly as specified
4. **If a step fails:**
   - Read the error carefully
   - Attempt to fix based on the plan's codebase context
   - If the fix is non-trivial (changes the plan's approach), stop and report
5. **Mark as complete** via `update_plan`

### Parallel Execution (when multi-agent is enabled)

If tasks are marked with `**Dependencies:** None`, they can be executed in parallel:

```
spawn_agent for Task 1 (independent)
spawn_agent for Task 2 (independent)
wait for both
Execute Task 3 (depends on Task 1 and 2) sequentially
```

Only parallelize tasks explicitly marked as independent. When in doubt, execute sequentially.

### Worker Agent Instructions

When dispatching worker agents for parallel tasks, frame the message as:

```
Your task is to implement the following. Follow the instructions exactly.

<task-instructions>
[Full task text from the plan, including Files section and all steps]
</task-instructions>

<codebase-context>
[Copy the Codebase Context section from the plan header]
</codebase-context>

Execute each step in order. Run verification commands after implementation.
Commit your work as specified. Report back with:
- Status: DONE | BLOCKED | NEEDS_CONTEXT
- Files changed
- Test results
- Any issues encountered
```

## Step 4: Verification

After all tasks are complete:

1. Run every item in the plan's "Verification" section
2. Run every item in the plan's "Definition of Done" section
3. If anything fails:
   - Diagnose the root cause
   - Fix it (minimal change)
   - Re-run verification
4. Report results:

```
All tasks complete.

Verification:
- Tests: PASS (42 passed, 0 failed)
- Lint: PASS (0 errors, 0 warnings)
- Build: PASS

Definition of Done:
- [x] All tasks completed and committed
- [x] All tests pass
- [x] Lint clean
- [x] Build succeeds
- [x] [Feature-specific criteria]

Branch: feat/<feature-name>
Commits: <count> commits
Ready for review.
```

## Step 5: Finish

After verification passes:

1. **If branch operations are available** (not in sandbox/detached HEAD):
   ```bash
   git log --oneline main..HEAD  # Show what was implemented
   ```
   Ask the user if they want to:
   - Push and create a PR
   - Merge locally
   - Leave as-is for review

2. **If in sandbox/detached HEAD:**
   - Commit all work
   - Report the branch name and commit summary
   - Instruct user to use the App's native controls to create branch/PR

## When to Stop

**STOP and report immediately when:**
- A step's expected output doesn't match actual output
- A file path from the plan doesn't exist and can't be inferred
- A test fails and the fix would change the plan's architecture
- You need information not in the plan and can't find it in the codebase
- Multiple consecutive steps fail

**Do NOT:**
- Guess at missing context
- Rewrite the plan's approach
- Skip failing steps
- Modify files not mentioned in the plan (unless fixing an obvious import/typo)

## Integration

This skill works with plans written by:
- `claude-codex-bridge:plan-for-codex` (recommended — optimized for Codex)
- `superpowers:writing-plans` (compatible — may reference Claude Code tools)

If the plan references Claude Code tools, use this mapping:
- `Task` / `Agent` tool → `spawn_agent`
- `TodoWrite` → `update_plan`
- `Skill` tool → skills load natively, just follow the instructions
- `Read`, `Write`, `Edit` → use native file tools
- `Bash` → use native shell
