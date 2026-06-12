# Smoke Self-Test Template

Use for lightweight personal or generic verification.

```md
# Self-Test

## Summary

<Brief summary of what changed.>

## Checks

- <Requirement or changed behavior exercised and observed result, or "Not run" with reason.>

## Result

<Passed / Not run / Needs verification>
```

Rules:

- Keep the output short.
- Do not claim `Passed` unless validation context exists.
- Prefer observable API, UI, workflow, job, integration, or operational behavior over engineering command output.
