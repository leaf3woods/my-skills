# Sync AI Skills

Copy every repository skill into AI tool skills directories.

Default targets are existing known skills folders:

- Codex: `$CODEX_HOME/skills` or `$HOME/.codex/skills`
- Claude: `$CLAUDE_HOME/skills` or `$HOME/.claude/skills`
- Gemini: `$GEMINI_HOME/skills` or `$HOME/.gemini/skills`
- OpenCode: `$OPENCODE_HOME/skills` or `$HOME/.config/opencode/skills`

If none exist, the scripts create the Codex target. Use `--create-defaults`
or `-CreateDefaults` to create all known default targets.

## macOS

```bash
bash scripts/sync-ai-skills/macos/sync-ai-skills.sh --dry-run
bash scripts/sync-ai-skills/macos/sync-ai-skills.sh
```

## Linux

```bash
bash scripts/sync-ai-skills/linux/sync-ai-skills.sh --dry-run
bash scripts/sync-ai-skills/linux/sync-ai-skills.sh
```

## Windows

```powershell
.\scripts\sync-ai-skills\windows\Sync-AiSkills.ps1 -DryRun
.\scripts\sync-ai-skills\windows\Sync-AiSkills.ps1
```

Pass explicit targets when needed:

```bash
bash scripts/sync-ai-skills/linux/sync-ai-skills.sh --target "$HOME/.codex/skills"
```

```powershell
.\scripts\sync-ai-skills\windows\Sync-AiSkills.ps1 -Target "$env:USERPROFILE\.codex\skills"
```
