# Conventional Commit Style

Default style for `git-commit`.

## Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | Purpose |
| --- | --- |
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting/style only |
| `refactor` | Refactor without feature/fix |
| `perf` | Performance improvement |
| `test` | Add/update tests |
| `build` | Build system/dependencies |
| `ci` | CI/config changes |
| `chore` | Maintenance/misc |
| `revert` | Revert commit |

## Rules

- Use present tense.
- Use imperative mood.
- Keep the description under 72 characters when practical.
- Add a scope when it clarifies the affected area.
- Use `!` or `BREAKING CHANGE:` only for real breaking changes.

## Examples

```text
feat(auth): add password reset flow
fix(api): handle empty filter values
docs(skills): document windows install suite
```
