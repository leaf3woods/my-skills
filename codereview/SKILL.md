---
name: codereview
description: Perform analysis-only company code reviews for PR diffs and changed files with Design-Service Jira context, CLAUDE.md project rules, and high-confidence critical findings. Use when the user asks for codereview, code review, PR review, review current changes, or analyze changed_files.txt/pr_diff.txt for Angular, C# ASP.NET Core, AWS Lambda, SpecFlow, CDK, or PostgreSQL changes. This skill reports code problems and concrete modification plans only; it does not edit code or run builds.
---

# Codereview

## Purpose

Review changed code with company rules and report only high-confidence critical issues. Do not modify repository files, run builds, or apply fixes.

## Reference

Always load [references/company-critical-review.md](references/company-critical-review.md) before performing the default company review. Treat it as the canonical severity policy and project context checklist.

## Inputs

- Prepared artifacts when present: `changed_files.txt`, `pr_diff.txt`, `jira_ticket.txt`, and a dismissed-issues list.
- PR context from the user, GitHub, or local git diff when prepared artifacts are absent.
- Full file contents for every changed file under review.
- Root `CLAUDE.md`, plus each changed top-level directory's `CLAUDE.md` when present.

Ask only when no reliable source of changed files and diff can be found.

## Constraints

- Do not modify source code, generated files, tests, configuration, or documentation in the target repository.
- Do not run build, test, lint, format, code generation, dependency installation, migration, or deployment commands.
- Use read-only commands and file reads only to understand the diff and current code.
- Provide the current code problems and concrete modification plans. Leave implementation to the user unless they explicitly ask for a separate fix task.
- Focus on code behavior, data flow, security, performance, concurrency, and runtime failure paths instead of build output or formatting.

## Workflow

1. Load the company critical review reference.
2. Resolve the changed files and diff:
   - Prefer `changed_files.txt` and `pr_diff.txt`.
   - If missing, derive the same information from the user's PR context, GitHub PR data, or local git diff.
3. Read `jira_ticket.txt` when present. If it contains a ticket ID and `.claude/skills/fetch-jira-context/SKILL.md` exists in the target repository, follow that skill to fetch Jira context.
4. Read root `CLAUDE.md`, then read `CLAUDE.md` in each top-level directory that contains changed files when it exists.
5. Read the full current content of every changed file. Use the diff to identify changed lines, but use full files to understand behavior.
6. Review only the code and only for the critical issue categories in the reference.
7. Do not report style, naming, maintainability, minor cleanup, speculative risk, or nice-to-have suggestions.
8. Do not re-report dismissed issues that match the same file, line, and concern.
9. For each reported issue, include what is wrong, why it matters, and the modification plan or code-level fix direction.
10. Present findings in the user's requested language and format. When neither is specified, use concise Markdown ordered by risk and confidence.

## Review Response

- Do not emit machine-oriented JSON unless the user explicitly requests it.
- For each finding, include the file and current-code line, the problem, its impact, and a concrete modification plan.
- If no critical issues are found, say so and note the reviewed scope plus any missing Jira or project context that limited the review.
