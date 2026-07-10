# Personal PR Template

Generate a concise PR body.

```md
## Summary

- <What changed?>

## Validation

- <Requirement, task, acceptance criterion, or bug scenario exercised and the observed result.>
```

Optional sections:

```md
## Related

- <Issue, ticket, or discussion link>

## Notes

- <Risk, migration note, or reviewer attention point>
```

Rules:

- Keep the body short.
- Omit optional sections when empty.
- Include `Validation` only for validation that was actually performed. Focus on requirement, task, or bug completion and the observed behavior.
- Do not include build, compile, lint, static-analysis, dependency-install, or generic test-suite success as PR validation unless the work itself changes that pipeline behavior.
- Do not infer successful validation from code inspection or diffs. Omit `Validation` when no behavior-level result is available.
- Do not add organization-specific reviewer, ticket, or footer text unless the user asks.
