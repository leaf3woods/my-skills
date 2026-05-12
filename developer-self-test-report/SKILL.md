---
name: developer-self-test-report
description: Generate developer self-test reports from git commits, branch changes, branch metadata, ticket information, and optional business context. Supports company and personal presets plus multiple report templates such as QA handoff, smoke, and regression. Use when preparing QA handoff, developer verification notes, or self-test evidence summaries.
---

# Developer Self-Test Report

## Purpose

Generate a concise developer self-test report based on commits or branch differences.

Keep this `SKILL.md` focused on workflow. Load preset and template references only as needed.

## Inputs

- `preset`: `company` by default; use `personal` when requested.
- `template`: default from selected preset; may be `qa-handoff`, `smoke`, or `regression`.
- `base_branch`: base branch, optional.
- `current_branch`: auto-detected if not provided.
- `ticket_link`: optional.
- `change_type`: optional hint such as bugfix, feature, refactor, cleanup, config, docs, or test-only.
- `optional_context`: business context, verification notes, evidence notes, change-type hint, or risk context, optional.

## References

Load in this order:

1. [references/presets/company.md](references/presets/company.md) by default, or [references/presets/personal.md](references/presets/personal.md) when requested.
2. The selected report template:
   - [references/templates/qa-handoff.md](references/templates/qa-handoff.md)
   - [references/templates/smoke.md](references/templates/smoke.md)
   - [references/templates/regression.md](references/templates/regression.md)

## Workflow

1. Select preset and template.
2. Get current branch.
3. Resolve ticket metadata from user input, branch name, or selected preset.
4. Determine base branch using user input first, then selected preset candidates.
5. Analyze commits before changed files.
6. Determine the change type from user context, branch name, commits, and changed files.
7. Analyze changed files only for impact scope.
8. Inspect diffs only when commit messages are unclear or insufficient.
9. Apply analysis rules from the selected preset.
10. Generate the report using the selected template.

## Git Commands

Run only the commands needed for missing information.

```bash
git branch --show-current
git fetch --all --prune
git log --oneline --decorate --no-merges <base_branch>..HEAD
git log --no-merges --pretty=format:"%h%n%s%n%b%n---" <base_branch>..HEAD
git diff --name-status <base_branch>...HEAD
git diff <base_branch>...HEAD -- <file_path>
```

Use diff only when commits and changed files are insufficient.

## Analysis Rules

Use information in this priority order:

1. User-provided context.
2. Commit messages and commit bodies.
3. Ticket key and ticket link.
4. Branch title context.
5. Changed files.
6. Diff, only when necessary.

General rules:

- Prefer commit messages over diff.
- Aggregate commits into business-level changes.
- Do not assume every self-test report is for a bug fix. Classify the work as bugfix, feature, refactor, cleanup, config, docs, test-only, or mixed when the context supports it.
- Use change-type-appropriate language: fixes re-test resolved behavior; features verify new behavior; refactors verify preserved behavior and affected flows; config/build changes verify setup or pipeline behavior.
- Ignore non-functional changes unless they affect behavior.
- Avoid code-level details unless the selected template asks for them.
- If the change remains unclear, say so in the report.

## Output Rules

- Use English unless the user asks otherwise.
- Keep the report concise.
- Do not invent test evidence.
- Default result may be `Passed` only when the selected preset/template allows it.
- Keep self-test output distinct from exhaustive QA test plans.

## Edge Cases

- No commits: report `No code changes`.
- Only formatting/comment changes: report `No functional impact`.
- Test-only or docs-only changes: report the direct validation performed and avoid implying runtime product behavior changed.
- Ticket missing and selected preset requires ticket: ask the user.
- Base branch uncertain: ask the user.
- High-risk logic: mention focused regression risk.
