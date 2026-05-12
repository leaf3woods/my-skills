# Company Commit Style

Use when the user wants company ticket-aware commits.

## Ticket Rules

- Extract ticket keys from branch names when available.
- Common pattern: `(?i)(RWC|SDS|DSS)-\d+`.
- Ask for a ticket key if the user requires one and no key can be extracted.

## Default Format

Prefer Conventional Commits with ticket context in the body or footer unless the user asks for ticket prefixing.

```text
<type>[optional scope]: <description>

Refs: <TICKET_KEY>
```

When the team expects ticket-prefix commits, use:

```text
<TICKET_KEY> <type>[optional scope]: <description>
```

## Rules

- Keep the Conventional Commit type semantics.
- Use imperative mood.
- Do not add ticket URLs unless the user asks.
- Do not invent a ticket key.
