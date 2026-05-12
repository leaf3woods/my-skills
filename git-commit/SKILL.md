---
name: git-commit
description: Execute git commits with configurable commit message styles, intelligent staging, and diff-based message generation. Use when the user asks to commit changes, create a git commit, or mentions "/commit". Defaults to Conventional Commits, with optional simple, ticket-prefix, and company styles.
---

# Git Commit

## Purpose

Create a clean git commit from the current repository changes.

Keep this `SKILL.md` focused on workflow. Load the selected commit style reference when generating the message.

## Inputs

- `style`: `conventional` by default.
- `scope`: optional override.
- `description`: optional override.
- `files`: optional explicit files to stage.
- `ticket`: optional ticket key for styles that use one.

## Commit Styles

Load one style file:

- [references/styles/conventional.md](references/styles/conventional.md) by default.
- [references/styles/simple.md](references/styles/simple.md) when the user wants a plain message.
- [references/styles/ticket-prefix.md](references/styles/ticket-prefix.md) when the user wants a ticket-prefixed message.
- [references/styles/company.md](references/styles/company.md) when the user wants company-style ticket-aware commits.

If the user gives a one-off style instruction, follow it for that commit without editing the stored styles.

## Workflow

1. Check repository status.
2. Inspect staged diff first.
3. If nothing is staged, inspect working tree diff.
4. Decide whether to stage all relevant changes or only a logical subset.
5. Load the selected commit style.
6. Generate a message from the diff and selected style.
7. Stage files if needed.
8. Commit.
9. Report the commit hash and message.

## Git Commands

```bash
git status --porcelain
git diff --staged
git diff
git add <paths>
git commit -m "<message>"
```

Use multi-line commit messages only when the selected style calls for a body or footer.

## Staging Rules

- Prefer one logical change per commit.
- If files are already staged, commit only staged files unless the user asks to add more.
- If nothing is staged, stage files that belong to the requested logical change.
- Never stage secrets such as `.env`, credentials, private keys, or token files.
- Do not stage unrelated user changes.

## Safety Rules

- Do not update git config.
- Do not run destructive commands without explicit request.
- Do not skip hooks unless the user asks.
- Do not force push.
- If commit hooks fail, fix the issue and create a new commit attempt; do not amend unless the user asks.

## Edge Cases

- No changes: report there is nothing to commit.
- Ambiguous unrelated changes: ask the user which files to include.
- Generated message does not fit the selected style: revise before committing.
