---
name: jira-sprint-card-intake
description: Collect the current or next personal Jira sprint cards with Atlassian CLI, summarize each card's title, link, description, and comments, create a note file named after each Jira key, and write concise handoff files with checkout branch/base, standard card tracking text, predicted git repository, and incremental comment deltas for later workflow skills. Use when Codex needs to start a Jira-based work workflow, prepare per-card notes, update new Jira comments cheaply, or pass clean context to the next independent skill/session.
---

# Jira Sprint Card Intake

Use this as step 1 of a Jira workflow suite. Keep Jira operations read-only and write local Markdown artifacts that a later skill can understand without conversation history.

## Inputs

- Jira card keys, if the user already named specific work items.
- Sprint scope: default to the current open sprint; use `+1`, `next`, or a current-sprint miss to inspect the next/future sprint.
- Notes directory: prefer a user-provided path, then `$env:JIRA_WORKFLOW_NOTES_DIR`, then an existing local notes directory in the workspace. If none is discoverable, create `jira-workflow/notes` under the current workspace.
- Note template file: prefer a user-provided path, then `$env:JIRA_WORKFLOW_NOTE_TEMPLATE`, then a template file in the current working directory. Check `jira-note-template.md`, `note-template.md`, and `card-note-template.md` in that order. Use `references/default-note-template.md` only as a fallback and record that assumption.
- Handoff directory: always use `<notes_dir>/_handoffs`.
- Branch checkout rules file: prefer a user-provided path, then `$env:JIRA_WORKFLOW_BRANCH_RULES`, then `references/branch-checkout-rules.md`.
- Card tracking text rules file: prefer a user-provided path, then `$env:JIRA_WORKFLOW_TRACKING_TEXT_RULES`, then `references/card-tracking-text-rules.md`.
- Project background file: prefer a user-provided path, then `$env:JIRA_WORKFLOW_PROJECT_CONTEXT`, then `references/project-context.md`.

## Workflow

1. Verify Jira CLI access before querying real data:

```powershell
acli jira auth status
```

If ACLI syntax has drifted, inspect local help before retrying:

```powershell
acli jira --help
acli jira workitem search --help
acli jira workitem view --help
acli jira workitem comment list --help
```

2. Resolve the cards to process.

If the user supplied keys, skip sprint discovery and process those keys. Otherwise, query current personal sprint cards first:

```powershell
acli jira workitem search --jql "assignee = currentUser() AND sprint in openSprints() ORDER BY Rank ASC" --fields "key,summary,status,priority,assignee,reporter,updated,issuetype,sprint" --limit 50 --json
```

If the current query returns no useful assigned cards, or the user requested `+1`/next sprint, query future sprint cards:

```powershell
acli jira workitem search --jql "assignee = currentUser() AND sprint in futureSprints() ORDER BY Rank ASC" --fields "key,summary,status,priority,assignee,reporter,updated,issuetype,sprint" --limit 50 --json
```

When future results include multiple sprint names, choose the earliest sprint if dates are present. If dates are unavailable, keep the sprint names in the handoff and state the assumption.

3. Gather complete card context for each key:

```powershell
acli jira workitem view KEY-123 --fields "key,summary,status,priority,assignee,reporter,updated,description,issuetype,sprint,labels,components,parent" --json
acli jira workitem comment list --key KEY-123 --limit 30 --order "-created" --json
```

Prefer JSON output and structured parsing. Do not rely on scraped terminal text when JSON is available.

4. Load handoff rule files before writing handoff content.

- Use `references/branch-checkout-rules.md` to derive the checkout branch name and checkout base branch. If the rules file is still a placeholder or unavailable, write `Needs rule file` instead of inventing a branch.
- Never recommend `main` or `master` as the checkout base. If rules or context point to `main`/`master`, mark the handoff `blocked: unsafe base branch` and ask the user for the allowed base, usually `develop`, `dev`, `stage`, or another integration branch.
- Use `references/card-tracking-text-rules.md` to generate the standard card tracking text. Preserve exact required formatting from that file once provided.
- Use `references/project-context.md` to predict which git repository should be used. If several repos match, rank them and mark the confidence.

5. Create or update the output files using `references/output-files.md`.

- Note file: `<notes_dir>/<KEY>.md`
- Note template: use the configured note template file. If no template is configured, search the current working directory for `jira-note-template.md`, `note-template.md`, then `card-note-template.md`. If none exists, use `references/default-note-template.md` and record the fallback in the note and handoff.
- Handoff file: `<notes_dir>/_handoffs/<KEY>.handoff.md`
- Batch index, only when processing multiple cards: `<notes_dir>/_handoffs/sprint-intake-index.md`

If a note file already exists, preserve user-written content. Replace the bounded generated block when markers exist; otherwise append a new generated intake section.

6. Report the result to the user with processed keys, sprint scope used, note paths, handoff paths, checkout branch/base status, tracking text status, and predicted repo status. Mention any cards skipped because Jira details or comments could not be fetched.

## Incremental Comment Updates

Use `scripts/Update-JiraHandoffComments.ps1` when the user asks to refresh a handoff or when a note/handoff already exists and only Jira comments may have changed. This keeps token use low by fetching recent comments, comparing them with local state, and writing only new compact comment deltas into the handoff.

```powershell
.\scripts\Update-JiraHandoffComments.ps1 -Key KEY-123 -HandoffPath "<notes_dir>\_handoffs\KEY-123.handoff.md" -StateDir "<notes_dir>\_handoffs\.state"
```

For tests or when comments were already fetched:

```powershell
.\scripts\Update-JiraHandoffComments.ps1 -Key KEY-123 -HandoffPath "<handoff.md>" -StateDir "<state-dir>" -CommentsJsonPath "<comments.json>"
.\scripts\Update-JiraHandoffComments.ps1 -Key KEY-123 -HandoffPath "<handoff.md>" -StateDir "<state-dir>" -CommentsJson "<raw comments json>"
```

After the script runs, read the compact console output or the bounded `Incremental Jira Comments` block. Update only the impacted handoff fields, such as recent comments, decisions, blockers, open questions, or recommended next step. Do not re-fetch or re-summarize the full Jira comment history unless the delta contradicts existing context.

## Handoff Rules

- Keep handoff files concise enough for the next skill to read quickly, but include every decision, blocker, open question, and source path needed to continue.
- Include absolute paths when available so a later independent session can find files even from a different working directory.
- Build the Jira link from a returned browse URL when present. If only the site base URL is known, infer `<site>/browse/<KEY>` and mark it as inferred.
- Summarize comments by relevant decision, request, blocker, and recency. Do not paste long comment transcripts.
- Always include the three standard handoff sections: `Checkout Plan`, `Standard Card Tracking Text`, and `Predicted Work Repository`.
- Record unknowns explicitly instead of guessing.
- Do not create, edit, transition, assign, delete, or comment on Jira work items in this skill.
