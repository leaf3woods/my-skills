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
- `additional_reviewers`: GitHub usernames or team handles to add to preset-required reviewers, optional.
- `draft`: default from the selected preset; company defaults to draft.
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
4. Resolve and validate the base branch using the selected preset's semantic branch policy.
5. Analyze commits first.
6. Analyze changed files only for scope, CODEOWNERS, or reviewer inference.
7. Inspect diffs only when commit messages and changed files are insufficient.
8. Generate PR title using the selected preset title rule.
9. Generate PR body using the selected template.
10. Resolve draft mode using the selected preset submission policy.
11. Resolve reviewers from all applicable sources using selected preset reviewer rules.
12. Present confirmation summary before submission.
13. Submit with GitHub CLI only after confirmation, or output title/body/reviewers/draft mode for manual submission.

## Git Commands

Run only the commands needed for missing information.

```bash
git branch --show-current
git branch -r --format="%(refname:short)"
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
3. Discovered remote branches accepted by the selected preset's semantic branch policy.
4. Ask the user.

Validate even a user-provided base branch against the selected preset. A company preset may reject primary or production-equivalent branches rather than accepting an explicit but unsafe target.

When a preset defines semantic branch groups, compare normalized names case-insensitively and ignore the remote prefix. Prefer clear long-lived branch aliases; do not classify a feature branch merely because one token resembles `develop` or `staging`. Ask when the meaning is ambiguous.

## Reviewer Resolution

Use the selected preset reviewer policy.

General rules:

- User-provided reviewers are additive to preset-required reviewers unless the user explicitly changes the preset policy.
- Required defaults are a minimum reviewer set, not a cap or replacement list. Retain every required default reviewer even when user-provided, CODEOWNERS, or inferred reviewers are also present.
- Treat reviewer sources as additive unless the preset says otherwise; do not stop after the first source produces a candidate.
- CODEOWNERS may be used when the preset allows it.
- Recent merged PR reviewers and git history candidates may be used only for directly changed files or ownership areas and only when the preset allows it.
- Prefer coverage of each materially different ownership area over adding several reviewers with the same context.
- Exclude the PR author, bots, duplicates, inactive accounts, and identities that cannot be mapped confidently to a GitHub username or team.
- Deduplicate reviewers.
- If required reviewers cannot be submitted, stop and report the failure instead of silently omitting them.

## Confirmation Before Submission

Before running `gh pr create`, present:

- current branch
- target/base branch
- ticket
- PR title
- draft mode
- reviewers
- inferred reviewer sources, if any

Ask for confirmation. Do not submit until the user confirms.

## Submission

```bash
gh pr create --base <base> --head <current> --title "<title>" --body-file <file> --reviewer <reviewers> [--draft]
```

Include `--draft` when the selected preset's submission policy defaults to draft, such as the company preset, unless the user explicitly requests a ready-for-review PR.

If GitHub CLI is unavailable or submission is not requested, output the title, body, reviewers, and draft mode.

## Edge Cases

- No commits: report `No code changes` and ask before creating a PR.
- Missing ticket and preset requires ticket: ask the user.
- Base branch uncertain or rejected by the selected preset: ask the user for an allowed branch.
- No reviewers and preset requires reviewers: ask the user or stop before submission.
