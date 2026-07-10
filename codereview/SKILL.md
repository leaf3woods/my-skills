---
name: codereview
description: Perform analysis-only reviews of local Git changes and project code, reporting only high-confidence critical defects with concrete fix directions. Use when the user asks for codereview, code review, review current local changes, review staged, unstaged, or untracked files, or inspect a local branch, commit, revision range, or selected source files. This personal-use skill relies only on local Git metadata and project files; it does not edit files or run builds or tests.
---

# Codereview

## Purpose

Review local code changes and report only high-confidence critical defects. Analyze only; do not modify the repository, run builds or tests, or apply fixes.

## Reference

Always load [references/critical-review-rules.md](references/critical-review-rules.md) before reviewing code. Treat it as the canonical severity threshold and technology-specific review checklist.

## Constraints

- Treat local Git metadata and local project files as the complete available context; do not look for auxiliary review artifacts or repository-specific instruction files.
- Do not access remote services or the network.
- Do not modify source code, generated files, tests, configuration, or documentation in the target repository.
- Do not run build, test, lint, format, code generation, dependency installation, migration, or deployment commands.
- Use read-only Git commands, searches, and file reads to understand the selected changes and current code.
- Review only defects introduced by or directly exposed by the selected changes; do not report unrelated pre-existing issues.

## Workflow

1. Load the critical review rules reference.
2. Run `git rev-parse --show-toplevel` and perform all inspection from the repository root.
3. Resolve the review scope:
   - Honor user-specified files, staged state, commits, refs, or revision ranges exactly.
   - Otherwise inspect all staged, unstaged, and untracked changes reported by local Git.
   - If the worktree is clean, compare the current branch with an unambiguous locally available base such as `origin/HEAD`, `main`, `master`, or `develop`, excluding the current branch. Do not fetch. Ask for a base or range only when no reliable local base exists.
4. Collect the selected changes with read-only Git commands:
   - Use `git diff --cached --find-renames` for staged changes.
   - Use `git diff --find-renames` for unstaged changes.
   - Use `git ls-files --others --exclude-standard` for untracked files and treat their full contents as additions.
   - Use `git diff <base>...HEAD --find-renames`, `git diff <range>`, or `git show <commit>` for an explicitly selected committed scope.
5. Read the complete source snapshot for every changed file: the index for staged-only review, the worktree for unstaged or untracked review, and the selected revision for committed review. Inspect the previous snapshot for deleted files.
6. Use local search to inspect callers, types, schemas, and related source files only as needed to prove or disprove a suspected defect.
7. Apply the reference rules and keep only high-confidence critical findings attributable to the selected changes.
8. Do not change files or implement fixes during the review.

## Review Response

- Follow the user's requested language and format; otherwise use concise Markdown ordered by impact and confidence.
- For each finding, include the source path and line, the concrete failure path, its impact, and a code-level fix direction.
- If no critical issues are found, say so and identify the reviewed local scope.
