# Company Critical Code Review Reference

Use this reference for company PR/code review tasks that should report only critical issues.

## Project

Design-Service dental design service cloud platform.

## Tech Stack

- Frontend: Angular 9, TypeScript, NgRx, Apollo GraphQL, SCSS, Angular Material.
- Backend: C# ASP.NET Core, Entity Framework Core, PostgreSQL.
- AWS Lambda: Python AI/ML processing, TypeScript, JavaScript.
- Automation: C# SpecFlow automated tests.
- AWS: AWS CDK in TypeScript.
- Database: PostgreSQL and SQL scripts under `bytebase`.

## Jira Context

Do this before reviewing code:

1. Read `jira_ticket.txt` to get the Jira ticket ID.
2. If the ticket ID is not empty, read `.claude/skills/fetch-jira-context/SKILL.md` in the target repository and follow its instructions to fetch Jira context.
3. Use fetched requirements, description, and acceptance criteria to inform the review.
4. If the ticket has linked issues in the fetch output, fetch linked tickets as needed to understand requirements and broader context.
5. If Jira fetch fails or the ticket is empty, include the full failure reason in `summary.summary`, such as HTTP status, error message, missing environment variables, or empty ticket ID. Continue the review without Jira context.

## Project Rules

The project stores coding conventions in `CLAUDE.md` files. Read these before reviewing:

1. Root `CLAUDE.md`.
2. Determine top-level directories containing changed files from `changed_files.txt`.
3. For each such directory, read that directory's `CLAUDE.md` if it exists and apply those rules during review.

Examples:

- Changed files under `Backend/`: read `Backend/CLAUDE.md`.
- Changed files under `Frontend/`: read `Frontend/CLAUDE.md`.
- Changed files under `AWSLambda/`: read `AWSLambda/CLAUDE.md`.
- Changed files under `.github/workflows/`: read `.github/CLAUDE.md`.

Treat violations of these project rules as critical only when they could cause bugs, runtime errors, security problems, data loss, or serious operational failures.

## Previously Dismissed Issues

If dismissed issues are supplied, do not report them again. Skip any issue matching the same file, line, and concern.

## Review Task

1. Read `changed_files.txt` to get changed files.
2. Read `pr_diff.txt` to inspect concrete changes.
3. For each changed file, read the full file content to understand context.
4. Identify only critical issues.

## Review Focus

Only report genuinely critical issues. Do not report style issues, naming suggestions, minor improvements, maintainability suggestions, or nice-to-have changes.

Critical issues include:

- Memory leaks, infinite loops, or unhandled exceptions that crash the process.
- Sensitive data exposure, SQL injection, or XSS vulnerabilities.
- Serious performance problems, such as obviously inefficient algorithms, avoidable O(n^2) behavior where O(n) is trivial, heavy loops on large collections, or unsafe database queries.
- Data corruption or data loss risks.
- Race conditions or concurrency bugs.
- Security vulnerabilities, such as missing authorization checks or privilege escalation.

## Frontend Critical Checks

For `Frontend/**.ts`, `Frontend/**.html`, and `Frontend/**.scss`:

- Subscriptions that are never cleaned up and create a guaranteed memory leak.
- Direct NgRx state mutation that will cause bugs.
- Infinite change detection loops.

## Backend Critical Checks

For `Backend/**.cs`:

- `.Result` or `.Wait()` usage that can cause deadlocks.
- N+1 query patterns that will cause real performance degradation at scale.
- Missing authorization on sensitive endpoints.
- Entity Framework queries that trigger hidden lazy loading in request paths.
- Swallowed exceptions that hide real failures.

## Lambda Critical Checks

For `AWSLambda/**`:

- Unhandled exceptions that silently fail the Lambda.
- Secrets hardcoded in source code.
- Connections or resources that are never closed.

## SQL Critical Checks

For `bytebase/**.sql`:

- Data migrations that cause data loss.
- Missing `WHERE` clauses on `UPDATE` or `DELETE`.
- Full table locks on large tables.

## Output Format

Output a valid JSON object in this exact shape. All text must be in English only. Report a maximum of 10 issues. If there are no critical issues, return an empty `comments` array.

```json
{
  "comments": [
    {
      "path": "relative file path",
      "line": 123,
      "severity": "critical",
      "confidence": 95,
      "message": "Concise description: 1.What is the issue 2.Why it matters 3.Suggested fix",
      "code_suggestion": "Optional: corrected code snippet or empty string"
    }
  ],
  "summary": {
    "critical_count": 0,
    "files_reviewed": ["list of reviewed files"],
    "key_issues": ["Key issue 1"],
    "summary": "Overall English summary"
  }
}
```

Strict rules:

1. Output only the JSON object, no other text.
2. `line` must be a number and must refer to the line in the file, not the diff line.
3. `path` must be relative to the repository root.
4. `severity` must always be `critical`.
5. `confidence` must be an integer from 1 to 100.
6. Only report issues where confidence is at least 85.
7. Report at most 10 comments, prioritized by severity and confidence.
8. All text must be English only.
