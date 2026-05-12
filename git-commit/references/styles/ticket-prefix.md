# Ticket-Prefix Commit Style

Use when the user wants ticket keys in commit messages without a full company preset.

## Format

```text
<TICKET_KEY> <summary>
```

Or, when the user also wants Conventional Commits:

```text
<TICKET_KEY> <type>[optional scope]: <description>
```

## Rules

- Extract ticket from user input or branch name when obvious.
- Ask for the ticket key when required but missing.
- Keep the summary imperative.
- Do not generate organization-specific ticket URLs.

## Examples

```text
ABC-123 add report export
ABC-123 fix(api): handle empty filter values
```
