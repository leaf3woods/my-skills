---
name: jira-work-context
description: Use Atlassian CLI (`acli`) for Jira Cloud personal work context and comments. Trigger when the user asks to find or summarize their current Jira work, inspect a Jira work item from a branch or key, read recent Jira comments, add a Jira comment, or update a Jira comment. Focus on context gathering and comment workflows; avoid broad Jira administration, project setup, bulk transitions, or unrelated issue management unless explicitly requested.
---

# Jira Work Context

Use `acli` to gather a concise view of the user's Jira work and handle comments. Prefer read-only context gathering first, then comment only when the user explicitly asks to post or update Jira.

## Guardrails

- Verify Jira auth before querying: `acli jira auth status`. If needed, ask the user to authenticate with `acli jira auth login --web` or their preferred token flow.
- Do not delete comments, transition work items, assign work, edit fields, or bulk-comment via JQL/filter unless the user explicitly asks.
- Before posting or updating a comment, read the target work item and recent comments so the reply is anchored in current Jira context.
- Prefer a single `--key` target for comments. Use `--jql` or `--filter` for comments only after confirming the intended batch.

## Find Current Work

Start from the most specific signal available:

1. If the user provides a key, use it directly.
2. If working in a repo, inspect branch/commit text for Jira keys like `ABC-123`.
3. If no key is known, search the user's active or recent work.

Useful commands:

```powershell
git branch --show-current
git log -5 --oneline
acli jira workitem search --jql "assignee = currentUser() AND resolution IS EMPTY ORDER BY updated DESC" --fields "key,summary,status,priority,assignee,updated" --limit 20 --json
acli jira workitem search --jql "(assignee = currentUser() OR reporter = currentUser()) AND updated >= -14d ORDER BY updated DESC" --fields "key,summary,status,priority,assignee,updated" --limit 20 --json
```

If the Jira site does not use `resolution`, adapt the JQL with user-supplied project, status, board, sprint, or label constraints instead of broadening the query unnecessarily.

## Inspect Work Item Context

For a likely target, fetch only fields needed for the task:

```powershell
acli jira workitem view KEY-123 --fields "key,issuetype,summary,status,assignee,reporter,priority,description,comment" --json
acli jira workitem comment list --key KEY-123 --limit 20 --order "-created" --json
```

Summarize for the user with: key, title, status, assignee, priority, recent update signal, relevant description details, latest comment thread, blockers, and any clear next action.

## Comment Workflows

Add a short comment:

```powershell
acli jira workitem comment create --key KEY-123 --body "Comment text" --json
```

Add a multiline comment from a file when quoting would be brittle:

```powershell
acli jira workitem comment create --key KEY-123 --body-file comment.txt --json
```

Update an existing comment only after identifying its ID:

```powershell
acli jira workitem comment list --key KEY-123 --limit 20 --order "-updated" --json
acli jira workitem comment update --key KEY-123 --id 10001 --body "Updated comment text"
```

Use Atlassian Document Format only when rich formatting is required:

```powershell
acli jira workitem comment update --key KEY-123 --id 10001 --body-adf comment.json
```

## Official References

- `jira auth status/login`: https://developer.atlassian.com/cloud/acli/reference/commands/jira-auth-status/
- `jira workitem search/view`: https://developer.atlassian.com/cloud/acli/reference/commands/jira-workitem-search/
- `jira workitem comment list/create/update`: https://developer.atlassian.com/cloud/acli/reference/commands/jira-workitem-comment/
- JQL `currentUser()`: https://support.atlassian.com/jira-software-cloud/docs/jql-functions/
