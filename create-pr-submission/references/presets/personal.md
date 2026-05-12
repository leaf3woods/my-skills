# Personal PR Preset

Use this preset when the user asks for a personal, open-source, or generic PR style.

## Ticket Rules

- Ticket is optional.
- Accept full URLs from the user.
- Accept common ticket keys from branch names when obvious, for example `ABC-123`.
- Do not generate an organization-specific ticket URL unless the user provides the URL pattern.

## Base Branch Candidates

Use this priority:

1. User-provided base branch.
2. Repository default branch from git remote metadata when available.
3. `origin/main`.
4. `origin/master`.
5. Ask the user.

## Title Rule

Use the clearest short title from commits and branch context.

Prefer:

```text
<type>: <summary>
```

when commits already follow Conventional Commits. Otherwise use a concise imperative phrase.

## Reviewer Policy

Reviewers are optional.

Use this priority:

1. User-provided reviewers.
2. CODEOWNERS matched by changed files, when available.

Do not infer reviewers from git history unless the user asks.

## Template

Default template:

```text
personal-pr
```

Use [../templates/personal-pr.md](../templates/personal-pr.md).
