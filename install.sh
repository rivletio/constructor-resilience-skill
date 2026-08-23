#!/usr/bin/env bash
# Symlink this skill into Agent Skills directories for Claude, Grok, Codex, and
# the cross-runtime ~/.agents/skills path.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--user | --project] [--dry-run]

  --user      Install into home skill dirs (default)
  --project   Install into ./.claude/skills and ./.grok/skills of cwd
  --dry-run   Print actions without changing files
EOF
}

MODE="user"
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) MODE="user"; shift ;;
    --project) MODE="project"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$ROOT/skills/constructor-resilience"
if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
  echo "Missing $SKILL_SRC/SKILL.md" >&2
  exit 1
fi

if [[ "$MODE" == "user" ]]; then
  DESTS=(
    "$HOME/.claude/skills/constructor-resilience"
    "$HOME/.grok/skills/constructor-resilience"
    "$HOME/.codex/skills/constructor-resilience"
    "$HOME/.agents/skills/constructor-resilience"
  )
else
  DESTS=(
    "$PWD/.claude/skills/constructor-resilience"
    "$PWD/.grok/skills/constructor-resilience"
  )
fi

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'DRY: '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

stamp="$(date -u +%Y%m%dT%H%M%SZ)"

for dest in "${DESTS[@]}"; do
  parent="$(dirname "$dest")"
  run mkdir -p "$parent"

  if [[ -L "$dest" ]]; then
    current="$(readlink "$dest")"
    if [[ "$current" == "$SKILL_SRC" ]]; then
      echo "already linked: $dest"
      continue
    fi
    echo "replacing symlink $dest -> $current"
    run rm "$dest"
  elif [[ -d "$dest" ]]; then
    # Keep backups *outside* the skills dir so hosts do not load them as skills.
    bak_root="$(dirname "$parent")/skill-backups"
    run mkdir -p "$bak_root"
    bak="$bak_root/$(basename "$dest").bak-${stamp}"
    echo "backing up $dest -> $bak"
    run mv "$dest" "$bak"
  elif [[ -e "$dest" ]]; then
    echo "refusing to replace non-directory $dest" >&2
    exit 1
  fi

  run ln -sfn "$SKILL_SRC" "$dest"
  echo "linked $dest -> $SKILL_SRC"
done

echo
echo "Skill name: constructor-resilience"
echo "CLI: install constructor-resilience and put coherence on PATH (see README.md)"
