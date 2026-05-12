#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-ai-skills.sh [options]

Options:
  --target DIR         Sync to this AI skills directory. May be repeated.
  --create-defaults   Create all known default target directories.
  --dry-run           Print planned updates without writing files.
  -h, --help          Show this help.

Environment:
  AI_SKILLS_TARGETS   Colon-separated target skill directories.
  CODEX_HOME          Defaults to $HOME/.codex.
  CLAUDE_HOME         Defaults to $HOME/.claude.
  GEMINI_HOME         Defaults to $HOME/.gemini.
  OPENCODE_HOME       Defaults to $HOME/.config/opencode.
EOF
}

dry_run=0
create_defaults=0
explicit_targets=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --target" >&2
        exit 2
      fi
      explicit_targets+=("$2")
      shift 2
      ;;
    --target=*)
      explicit_targets+=("${1#--target=}")
      shift
      ;;
    --create-defaults)
      create_defaults=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"

skill_sources=()
for skill_md in "$repo_root"/*/SKILL.md "$repo_root"/windows-install-suite/*/SKILL.md; do
  [[ -f "$skill_md" ]] || continue
  skill_sources+=("$(dirname "$skill_md")")
done

if [[ ${#skill_sources[@]} -eq 0 ]]; then
  echo "No skill directories found under $repo_root" >&2
  exit 1
fi

targets=()
if [[ ${#explicit_targets[@]} -gt 0 ]]; then
  targets+=("${explicit_targets[@]}")
fi

if [[ -n "${AI_SKILLS_TARGETS:-}" ]]; then
  IFS=':' read -r -a env_targets <<< "$AI_SKILLS_TARGETS"
  for target in "${env_targets[@]}"; do
    [[ -n "$target" ]] && targets+=("$target")
  done
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  codex_skills="${CODEX_HOME:-$HOME/.codex}/skills"
  known_targets=(
    "$codex_skills"
    "${CLAUDE_HOME:-$HOME/.claude}/skills"
    "${GEMINI_HOME:-$HOME/.gemini}/skills"
    "${OPENCODE_HOME:-$HOME/.config/opencode}/skills"
  )

  for target in "${known_targets[@]}"; do
    if [[ -d "$target" || "$create_defaults" -eq 1 ]]; then
      targets+=("$target")
    fi
  done

  if [[ ${#targets[@]} -eq 0 ]]; then
    targets+=("$codex_skills")
  fi
fi

deduped_targets=()
for target in "${targets[@]}"; do
  expanded="${target/#\~/$HOME}"
  duplicate=0
  for existing in "${deduped_targets[@]}"; do
    if [[ "$existing" == "$expanded" ]]; then
      duplicate=1
      break
    fi
  done
  [[ "$duplicate" -eq 0 ]] && deduped_targets+=("$expanded")
done

copy_skill() {
  local source_dir="$1"
  local target_root="$2"
  local skill_name
  local dest
  local tmp

  skill_name="$(basename "$source_dir")"
  dest="$target_root/$skill_name"
  tmp="$target_root/.${skill_name}.tmp.$$"

  if [[ "$dry_run" -eq 1 ]]; then
    echo "[dry-run] $source_dir -> $dest"
    return
  fi

  mkdir -p "$target_root"
  rm -rf "$tmp"
  cp -R "$source_dir" "$tmp"
  rm -rf "$dest"
  mv "$tmp" "$dest"
  echo "Synced $skill_name -> $dest"
}

echo "Repository: $repo_root"
echo "Skills: ${#skill_sources[@]}"

for target in "${deduped_targets[@]}"; do
  echo "Target: $target"
  for source_dir in "${skill_sources[@]}"; do
    copy_skill "$source_dir" "$target"
  done
done
