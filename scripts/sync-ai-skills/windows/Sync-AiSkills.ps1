[CmdletBinding()]
param(
  [string[]]$Target = @(),
  [switch]$CreateDefaults,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Normalize-PathString {
  param([Parameter(Mandatory)][string]$Path)

  $expanded = [Environment]::ExpandEnvironmentVariables($Path)
  if ([System.IO.Path]::IsPathRooted($expanded)) {
    return [System.IO.Path]::GetFullPath($expanded)
  }

  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $expanded))
}

function Add-Target {
  param(
    [Parameter(Mandatory)][string]$Path,
    [System.Collections.Generic.List[string]]$Targets
  )

  if ([string]::IsNullOrWhiteSpace($Path)) {
    return
  }

  $normalized = Normalize-PathString -Path $Path.Trim()
  if (-not $Targets.Contains($normalized)) {
    $Targets.Add($normalized) | Out-Null
  }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path
$skillSources = [System.Collections.Generic.List[string]]::new()

Get-ChildItem -LiteralPath $repoRoot -Directory | ForEach-Object {
  $skillFile = Join-Path $_.FullName 'SKILL.md'
  if (Test-Path -LiteralPath $skillFile -PathType Leaf) {
    $skillSources.Add($_.FullName) | Out-Null
  }
}

$suiteRoot = Join-Path $repoRoot 'windows-install-suite'
if (Test-Path -LiteralPath $suiteRoot -PathType Container) {
  Get-ChildItem -LiteralPath $suiteRoot -Directory | ForEach-Object {
    $skillFile = Join-Path $_.FullName 'SKILL.md'
    if (Test-Path -LiteralPath $skillFile -PathType Leaf) {
      $skillSources.Add($_.FullName) | Out-Null
    }
  }
}

if ($skillSources.Count -eq 0) {
  throw "No skill directories found under $repoRoot"
}

$targetRoots = [System.Collections.Generic.List[string]]::new()

foreach ($item in $Target) {
  Add-Target -Path $item -Targets $targetRoots
}

if ($env:AI_SKILLS_TARGETS) {
  foreach ($item in ($env:AI_SKILLS_TARGETS -split ';')) {
    Add-Target -Path $item -Targets $targetRoots
  }
}

if ($targetRoots.Count -eq 0) {
  $userProfile = [Environment]::GetFolderPath('UserProfile')
  $codexSkills = if ($env:CODEX_HOME) {
    Join-Path $env:CODEX_HOME 'skills'
  } else {
    Join-Path $userProfile '.codex\skills'
  }

  $knownTargets = @(
    $codexSkills,
    $(if ($env:CLAUDE_HOME) { Join-Path $env:CLAUDE_HOME 'skills' } else { Join-Path $userProfile '.claude\skills' }),
    $(if ($env:GEMINI_HOME) { Join-Path $env:GEMINI_HOME 'skills' } else { Join-Path $userProfile '.gemini\skills' }),
    $(if ($env:OPENCODE_HOME) { Join-Path $env:OPENCODE_HOME 'skills' } else { Join-Path $userProfile '.config\opencode\skills' })
  )

  foreach ($item in $knownTargets) {
    if ($CreateDefaults -or (Test-Path -LiteralPath $item -PathType Container)) {
      Add-Target -Path $item -Targets $targetRoots
    }
  }

  if ($targetRoots.Count -eq 0) {
    Add-Target -Path $codexSkills -Targets $targetRoots
  }
}

Write-Host "Repository: $repoRoot"
Write-Host "Skills: $($skillSources.Count)"

foreach ($targetRoot in $targetRoots) {
  Write-Host "Target: $targetRoot"

  foreach ($sourceDir in $skillSources) {
    $skillName = Split-Path -Leaf $sourceDir
    $dest = Join-Path $targetRoot $skillName
    $tmp = Join-Path $targetRoot ".$skillName.tmp.$PID"

    if ($DryRun) {
      Write-Host "[dry-run] $sourceDir -> $dest"
      continue
    }

    New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
    if (Test-Path -LiteralPath $tmp) {
      Remove-Item -LiteralPath $tmp -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    Get-ChildItem -LiteralPath $sourceDir -Force |
      Copy-Item -Destination $tmp -Recurse -Force

    if (Test-Path -LiteralPath $dest) {
      Remove-Item -LiteralPath $dest -Recurse -Force
    }

    Move-Item -LiteralPath $tmp -Destination $dest
    Write-Host "Synced $skillName -> $dest"
  }
}
