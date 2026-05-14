# Branch Checkout Rules

This bundled file is a placeholder until a project-specific rules file is provided.

## Required Output

Every handoff must include:

- Checkout branch name.
- Checkout base branch.
- Rule source path.
- Safety status.

## Safety Guard

Never use `main` or `master` as the checkout base. If a project rule, Jira text, or repository state suggests `main` or `master`, mark the checkout plan as blocked and ask for the allowed integration branch.

## Default When Project Rules Are Missing

- Checkout branch: `Needs rule file`
- Checkout base: `Needs rule file`
- Safety status: `blocked: missing rules`

Replace this file or point `$env:JIRA_WORKFLOW_BRANCH_RULES` to a project-specific rule file when branch naming rules are available.
