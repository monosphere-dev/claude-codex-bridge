---
name: plan-for-codex
description: Write implementation plans in Claude Code that are optimized for Codex execution. Use when you want Claude Code to architect and Codex to build.
---

# Plan for Codex

## Overview

Write a comprehensive implementation plan that will be executed by Codex (not Claude Code). The plan must be self-contained — Codex has zero context about your conversation, your codebase exploration, or your design decisions. Everything it needs must be in the plan file.

**Announce at start:** "I'm using the plan-for-codex skill to create an implementation plan for Codex execution."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Why This Exists

Claude Code excels at deep codebase understanding, architecture, and planning. Codex excels at fast, parallel implementation. This skill bridges them: Claude Code does the thinking, Codex does the building.

## Before Writing the Plan

1. **Understand the codebase** — Read relevant files, trace patterns, understand conventions
2. **Brainstorm the approach** — Use superpowers:brainstorming if needed
3. **Map the file structure** — Know exactly which files exist, which to create, which to modify
4. **Identify conventions** — Codex needs explicit guidance on project patterns it can't infer

## Plan Document Format

Every plan MUST use this exact format. Codex parses this structure.

```markdown
# [Feature Name] Implementation Plan

> **Execution target: Codex CLI**
> This plan was written by Claude Code for Codex execution.
> Run with: `codex "execute the plan at docs/plans/<this-file>.md"`

**Goal:** [One sentence — what this builds and why]

**Architecture:** [2-3 sentences about the approach and key design decisions]

**Tech Stack:** [Key technologies, frameworks, libraries involved]

---

## Codebase Context

[This section is CRITICAL. Codex starts with zero context. Include:]

### Project Structure (relevant parts only)
```
src/
├── relevant/
│   ├── directory/
│   └── structure/
```

### Key Patterns to Follow
- [Pattern 1: e.g., "All endpoints use wrapCallable with middleware chain: auth → appCheck → tenantContext → validation"]
- [Pattern 2: e.g., "Tests go in __tests__/ adjacent to implementation, named *.unit.test.ts"]
- [Pattern 3: e.g., "Zod schemas for validation, TypeScript types for compile-time safety"]

### Existing Code References
- `path/to/similar-feature.ts` — Follow this pattern for [what]
- `path/to/shared-utility.ts` — Use this for [what]
- `path/to/types.ts` — Extend these types

### Environment & Commands
- Build: `[exact build command]`
- Test: `[exact test command]`
- Lint: `[exact lint command]`
- Run specific test: `[exact command pattern]`

---

## Tasks

### Task 1: [Component Name]

**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts` (lines ~50-75, the `functionName` function)
- Test: `exact/path/to/__tests__/file.unit.test.ts`

**Dependencies:** None | Task N must be completed first

- [ ] **Step 1: [Action — imperative verb]**

[Complete code block or exact instructions. No placeholders.]

```typescript
// Full code here — not pseudocode, not "implement X"
```

- [ ] **Step 2: [Action]**

Run: `exact command here`
Expected: [exact expected output or behavior]

- [ ] **Step 3: Commit**

```bash
git add [specific files]
git commit -m "feat: [descriptive message]"
```

### Task 2: [Component Name]
...

---

## Verification

After all tasks complete:

- [ ] Run full test suite: `[exact command]`
- [ ] Run linter: `[exact command]`
- [ ] Run build: `[exact command]`
- [ ] [Any manual verification steps]

## Definition of Done

- [ ] All tasks completed and committed
- [ ] All tests pass
- [ ] Lint clean
- [ ] Build succeeds
- [ ] [Feature-specific acceptance criteria]
```

## Critical Rules

### 1. No Claude Code Tool References
Codex doesn't have `Task`, `TodoWrite`, `Skill`, `Agent`, `Read`, `Write`, `Edit` tools by those names.
- Use plain commands: `cat`, `echo`, file paths, shell commands
- Use `update_plan` instead of `TodoWrite` references
- Use `spawn_agent` instead of `Task` references
- Or better: just write the steps as imperative actions with code blocks

### 2. No Placeholders — Ever
Every step must contain the actual content. These are plan failures:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code)
- Steps that describe what to do without showing how

### 3. Complete Codebase Context
Codex has ZERO context from your Claude Code session. Include:
- Relevant file structure
- Naming conventions and patterns
- Import paths and module resolution
- Type definitions it will need
- Existing utilities it should reuse (with exact import paths)

### 4. Exact File Paths Always
- Never use relative references like "the config file" — use `src/config/app.config.ts`
- Include line numbers when modifying existing code: `src/feature/handler.ts:45-60`

### 5. Independent Tasks When Possible
- Mark task dependencies explicitly
- Independent tasks can be parallelized by Codex's multi-agent mode
- Tightly coupled tasks should be sequential and clearly marked

### 6. Commit Boundaries
- Each task should end with a commit step
- Commits should be atomic and self-contained
- Include exact `git add` and `git commit` commands

## Scope Check

If the feature spans multiple independent subsystems, break into separate plan files:
- `docs/plans/YYYY-MM-DD-feature-part-1-backend.md`
- `docs/plans/YYYY-MM-DD-feature-part-2-frontend.md`

Each plan should produce working, testable software on its own.

## Self-Review Checklist

After writing the plan, verify:

1. **Context completeness:** Could someone with zero codebase knowledge execute this? Are all patterns, imports, and conventions documented?
2. **Placeholder scan:** Search for "TBD", "TODO", "implement", "similar to", "appropriate". Fix them.
3. **Type consistency:** Do types, method names, and property names match across all tasks?
4. **Command accuracy:** Are all build/test/lint commands correct for this project?
5. **Path accuracy:** Do all file paths exist (for modifications) or have valid parent directories (for new files)?
6. **Dependency order:** Are task dependencies correctly marked? Can independent tasks run in parallel?

## Handoff

After saving the plan, present:

**"Plan saved to `docs/plans/<filename>.md`.**

**To execute in Codex:**
```bash
codex "Read and execute the implementation plan at docs/plans/<filename>.md. Use update_plan to track progress. Follow each task sequentially, commit after each task. Run the verification checklist at the end."
```

**Or if you want Codex to use multi-agent mode for independent tasks:**
```bash
codex "Read the implementation plan at docs/plans/<filename>.md. Identify independent tasks and execute them in parallel using spawn_agent. Sequential tasks should be executed in order. Track progress with update_plan."
```
**"**
