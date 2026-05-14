# Card Tracking Text Rules

This bundled file is a placeholder until a project-specific tracking text format is provided.

## Required Output

Every handoff must include a `Standard Card Tracking Text` section. When no project rule exists, mark it as blocked instead of inventing a team format.

## Default When Project Rules Are Missing

```text
Needs tracking text rule file for <KEY>.
```

- Status: `blocked: missing rules`

Replace this file or point `$env:JIRA_WORKFLOW_TRACKING_TEXT_RULES` to a project-specific rule file when the standard card tracking text format is available.
