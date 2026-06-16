---
name: codereview
description: Perform company code reviews for PR diffs and changed files with Design-Service Jira context, CLAUDE.md project rules, and critical-only JSON comments. Use when the user asks for codereview, code review, PR review, review current changes, or generate review comments from changed_files.txt/pr_diff.txt for Angular, C# ASP.NET Core, AWS Lambda, SpecFlow, CDK, or PostgreSQL changes.
---

# Codereview

## Purpose

Review changed code with company rules and report only high-confidence critical issues.

## Reference

Always load [references/company-critical-review.md](references/company-critical-review.md) before performing the default company review. Treat it as the canonical severity policy, project context checklist, and JSON output contract.

## Inputs

- Prepared artifacts when present: `changed_files.txt`, `pr_diff.txt`, `jira_ticket.txt`, and a dismissed-issues list.
- PR context from the user, GitHub, or local git diff when prepared artifacts are absent.
- Full file contents for every changed file under review.
- Root `CLAUDE.md`, plus each changed top-level directory's `CLAUDE.md` when present.

Ask only when no reliable source of changed files and diff can be found.

## Workflow

1. Load the company critical review reference.
2. Resolve the changed files and diff:
   - Prefer `changed_files.txt` and `pr_diff.txt`.
   - If missing, derive the same information from the user's PR context, GitHub PR data, or local git diff.
3. Read `jira_ticket.txt` when present. If it contains a ticket ID and `.claude/skills/fetch-jira-context/SKILL.md` exists in the target repository, follow that skill to fetch Jira context.
4. Read root `CLAUDE.md`, then read `CLAUDE.md` in each top-level directory that contains changed files when it exists.
5. Read the full current content of every changed file. Use the diff to identify changed lines, but use full files to understand behavior.
6. Review only for the critical issue categories in the reference.
7. Do not report style, naming, maintainability, minor cleanup, speculative risk, or nice-to-have suggestions.
8. Do not re-report dismissed issues that match the same file, line, and concern.
9. Return exactly the requested JSON object when the user asks for review output. Do not add prose around the JSON.

## Output

Use English for all review text. Include at most 10 comments, each with `severity: "critical"` and confidence at least 85. If no critical issues are found, return an empty `comments` array and a summary that notes the reviewed files and any missing Jira context reason.
