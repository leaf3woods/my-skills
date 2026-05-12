# Personal Self-Test Preset

Use this preset for personal projects, open-source projects, or generic verification notes.

## Ticket Rules

- Ticket is optional.
- Accept full URLs from user context.
- Accept obvious issue keys or GitHub issue numbers from branch names.
- Do not generate organization-specific ticket URLs.

## Base Branch Candidates

Use this priority:

1. User-provided base branch.
2. Repository default branch from git metadata when available.
3. `origin/main`.
4. `origin/master`.
5. Ask the user.

## Default Template

Use [../templates/smoke.md](../templates/smoke.md) unless the user asks for a regression report.

## Analysis Style

- Keep the report short and practical.
- Do not default to `Passed` unless validation context exists.
- Mention unknown verification status clearly.
