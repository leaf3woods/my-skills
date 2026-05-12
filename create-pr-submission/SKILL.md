---
name: create-pr-submission
description: Generate and optionally submit pull requests from git commits, branch metadata, ticket information, reviewers, and reusable conversation context. Supports company and personal presets, configurable ticket rules, reviewer rules, title formats, and PR body templates. Use when the user asks to prepare, draft, or submit a PR.
---

# Create PR Submission

## Purpose

Generate a concise PR title/body and optionally submit the PR.

Keep this `SKILL.md` focused on workflow. Load preset and template references only as needed.

## Inputs

- `preset`: `company` by default; use `personal` when requested.
- `template`: default from the selected preset.
- `base_branch`: target branch, optional.
- `ticket_link`: full ticket link, optional.
- `additional_reviewers`: GitHub usernames or team handles, optional.
- `optional_context`: business, implementation, validation, or risk context, optional.

## References

Load in this order:

1. [references/presets/company.md](references/presets/company.md) by default, or [references/presets/personal.md](references/presets/personal.md) when requested.
2. The PR body template named by the preset:
   - [references/templates/company-pr.md](references/templates/company-pr.md)
   - [references/templates/personal-pr.md](references/templates/personal-pr.md)

If the user asks for a one-off format, use the closest preset/template and adapt only the output, not the stored template.

## Workflow

1. Select preset and template.
2. Detect current branch.
3. Resolve ticket metadata from user input, branch name, or selected preset rules.
4. Resolve base branch using user input first, then selected preset candidates.
5. Analyze commits first.
6. Analyze changed files only for scope, CODEOWNERS, or reviewer inference.
7. Inspect diffs only when commit messages and changed files are insufficient.
8. Generate PR title using the selected preset title rule.
9. Generate PR body using the selected template.
10. Resolve reviewers using selected preset reviewer rules.
11. Present confirmation summary before submission.
12. Submit with GitHub CLI only after confirmation, or output title/body/reviewers for manual submission.

## Git Commands

Run only the commands needed for missing information.

```bash
git branch --show-current
git fetch --all --prune
git log --no-merges --pretty=format:"%h%n%s%n%b%n---" <base_branch>..HEAD
git diff --name-status <base_branch>...HEAD
git diff <base_branch>...HEAD -- <file_path>
```

Use diff only when commit messages are unclear.

## Base Branch Resolution

Use this priority:

1. User-provided base branch.
2. Reusable conversation context.
3. Selected preset base branch candidates.
4. Ask the user.

Never default to `main` or `master` unless the selected preset explicitly allows it or the user requests it.

## Reviewer Resolution

Use the selected preset reviewer policy.

General rules:

- User-provided reviewers have highest priority.
- CODEOWNERS may be used when the preset allows it.
- Git history candidates may be used only for changed files and only when the preset allows it.
- Deduplicate reviewers.
- If required reviewers cannot be submitted, stop and report the failure instead of silently omitting them.

## Confirmation Before Submission

Before running `gh pr create`, present:

- current branch
- target/base branch
- preset and template
- ticket
- PR title
- reviewers
- inferred reviewer sources, if any

Ask for confirmation. Do not submit until the user confirms.

## Submission

```bash
gh pr create --base <base> --head <current> --title "<title>" --body-file <file> --reviewer <reviewers>
```

If GitHub CLI is unavailable or submission is not requested, output the title, body, and reviewers.

## Edge Cases

- No commits: report `No code changes` and ask before creating a PR.
- Missing ticket and preset requires ticket: ask the user.
- Base branch uncertain: ask the user.
- No reviewers and preset requires reviewers: ask the user or stop before submission.
