param(
    [Parameter(Mandatory = $true)]
    [string]$Key,

    [Parameter(Mandatory = $true)]
    [string]$HandoffPath,

    [Parameter(Mandatory = $true)]
    [string]$StateDir,

    [string]$CommentsJsonPath,

    [string]$CommentsJson,

    [int]$Limit = 30,

    [int]$SnippetLength = 500
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Get-JsonText {
    if ($CommentsJson) {
        return $CommentsJson
    }

    if ($CommentsJsonPath) {
        return Get-Content -LiteralPath $CommentsJsonPath -Raw
    }

    $output = & acli jira workitem comment list --key $Key --limit $Limit --order "-created" --json
    if ($LASTEXITCODE -ne 0) {
        throw "acli comment list failed for $Key with exit code $LASTEXITCODE"
    }
    return ($output -join [Environment]::NewLine)
}

function Select-CommentArray {
    param($Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [array]) {
        return @($Value)
    }

    foreach ($name in @("comments", "values", "results", "data", "nodes")) {
        if ($Value.PSObject.Properties.Name -contains $name) {
            $candidate = $Value.$name
            if ($candidate -is [array]) {
                return @($candidate)
            }
        }
    }

    return @($Value)
}

function Convert-BodyToText {
    param($Body)

    if ($null -eq $Body) {
        return ""
    }

    if ($Body -is [string]) {
        $text = $Body
    } else {
        $text = ($Body | ConvertTo-Json -Depth 20 -Compress)
    }

    $text = ($text -replace "\s+", " ").Trim()
    if ($text.Length -gt $SnippetLength) {
        return $text.Substring(0, $SnippetLength) + "..."
    }
    return $text
}

function Get-AuthorText {
    param($Comment)

    foreach ($name in @("author", "creator", "updateAuthor")) {
        if ($Comment.PSObject.Properties.Name -contains $name) {
            $author = $Comment.$name
            if ($author -is [string]) {
                return $author
            }
            foreach ($field in @("displayName", "name", "emailAddress", "accountId")) {
                if ($author.PSObject.Properties.Name -contains $field -and $author.$field) {
                    return [string]$author.$field
                }
            }
        }
    }

    return "unknown author"
}

function Get-CommentId {
    param($Comment, [int]$Index)

    foreach ($name in @("id", "commentId", "self")) {
        if ($Comment.PSObject.Properties.Name -contains $name -and $Comment.$name) {
            return [string]$Comment.$name
        }
    }

    $created = if ($Comment.PSObject.Properties.Name -contains "created") { [string]$Comment.created } else { "" }
    $body = if ($Comment.PSObject.Properties.Name -contains "body") { Convert-BodyToText $Comment.body } else { "" }
    return "synthetic-$Index-$created-$($body.GetHashCode())"
}

function Get-CommentCreated {
    param($Comment)

    foreach ($name in @("created", "createdAt", "updated", "updatedAt")) {
        if ($Comment.PSObject.Properties.Name -contains $name -and $Comment.$name) {
            if ($Comment.$name -is [DateTime]) {
                return $Comment.$name.ToString("o")
            }
            return [string]$Comment.$name
        }
    }

    return "unknown time"
}

function Format-CommentLine {
    param($Comment, [string]$Id)

    $created = Get-CommentCreated $Comment
    $author = Get-AuthorText $Comment
    $body = if ($Comment.PSObject.Properties.Name -contains "body") { Convert-BodyToText $Comment.body } else { Convert-BodyToText $Comment }
    if ([string]::IsNullOrWhiteSpace($body)) {
        $body = "(empty comment body)"
    }
    return "- [$created] $author ($Id): $body"
}

$stateRoot = Resolve-FullPath $StateDir
New-Item -ItemType Directory -Force -Path $stateRoot | Out-Null

$handoffFullPath = Resolve-FullPath $HandoffPath
$handoffDir = Split-Path -Parent $handoffFullPath
New-Item -ItemType Directory -Force -Path $handoffDir | Out-Null

$statePath = Join-Path $stateRoot "$Key.comments.json"
$hadState = Test-Path -LiteralPath $statePath

$seenIds = @()
if ($hadState) {
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if ($state.seenIds) {
        $seenIds = @($state.seenIds | ForEach-Object { [string]$_ })
    }
}

$jsonText = Get-JsonText
$parsed = $jsonText | ConvertFrom-Json
$comments = Select-CommentArray $parsed

$normalized = @()
for ($i = 0; $i -lt $comments.Count; $i++) {
    $comment = $comments[$i]
    $id = Get-CommentId $comment $i
    $normalized += [PSCustomObject]@{
        Id = $id
        Comment = $comment
        Created = Get-CommentCreated $comment
    }
}

$seenSet = @{}
foreach ($id in $seenIds) {
    $seenSet[$id] = $true
}

$newItems = @()
if ($hadState) {
    $newItems = @($normalized | Where-Object { -not $seenSet.ContainsKey($_.Id) } | Sort-Object Created)
}

$allIds = @($normalized.Id | Sort-Object -Unique)
$newState = [PSCustomObject]@{
    key = $Key
    lastChecked = (Get-Date).ToString("o")
    seenIds = $allIds
}
$newState | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $statePath -Encoding UTF8

$lines = @()
if (-not $hadState) {
    $lines += "- Baseline initialized; existing comments marked as seen."
} elseif ($newItems.Count -eq 0) {
    $lines += "- No new comments."
} else {
    foreach ($item in $newItems) {
        $lines += (Format-CommentLine $item.Comment $item.Id)
    }
}

$checkedAt = (Get-Date).ToString("o")
$block = @"
<!-- jira-sprint-card-intake:comment-delta:start -->
- Last checked: $checkedAt
- State file: ``$statePath``
- New comments since previous handoff: $($newItems.Count)
- Delta summary:
$($lines -join [Environment]::NewLine)
<!-- jira-sprint-card-intake:comment-delta:end -->
"@

if (Test-Path -LiteralPath $handoffFullPath) {
    $handoff = Get-Content -LiteralPath $handoffFullPath -Raw
} else {
    $handoff = "# Handoff: $Key`n`n"
}

$pattern = "(?s)<!-- jira-sprint-card-intake:comment-delta:start -->.*?<!-- jira-sprint-card-intake:comment-delta:end -->"
if ($handoff -match $pattern) {
    $handoff = [regex]::Replace($handoff, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block })
} else {
    $handoff = $handoff.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + "## Incremental Jira Comments" + [Environment]::NewLine + [Environment]::NewLine + $block + [Environment]::NewLine
}

Set-Content -LiteralPath $handoffFullPath -Value $handoff -Encoding UTF8

[PSCustomObject]@{
    key = $Key
    handoffPath = $handoffFullPath
    statePath = $statePath
    baselineInitialized = -not $hadState
    newCommentCount = $newItems.Count
    deltaLines = $lines
} | ConvertTo-Json -Depth 10
