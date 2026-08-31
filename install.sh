#!/usr/bin/env bash
# Install the agent skill and the coherence CLI so
#   pack this session
# works in the next chat.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--user | --project] [--dry-run] [--skill-only] [--mlx] [--from-git]

  --user         Link skill into home skill dirs (default)
  --project      Link into ./.claude/skills, ./.grok/skills, ./.cursor/skills of cwd
  --dry-run      Print actions without changing files
  --skill-only   Skip CLI install (skill symlink only)
  --mlx          Also install the optional MLX extra (mint / critique / eval)
  --from-git     Ignore a sibling package clone; pip-install the pinned GitHub ref
EOF
}

MODE="user"
DRY_RUN=0
SKILL_ONLY=0
WITH_MLX=0
FROM_GIT=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) MODE="user"; shift ;;
    --project) MODE="project"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skill-only) SKILL_ONLY=1; shift ;;
    --mlx) WITH_MLX=1; shift ;;
    --from-git) FROM_GIT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
# Functions and SKILL.md live in constructor-resilience. This package only
# links hosts (Grok, Claude, Codex, Cursor) at that one directory.
SIBLING_CLI="${CONSTRUCTOR_RESILIENCE_HOME:-$ROOT/../constructor-resilience}"
if [[ -f "$SIBLING_CLI/skills/constructor-resilience/SKILL.md" ]]; then
  SKILL_SRC="$(cd "$SIBLING_CLI/skills/constructor-resilience" && pwd)"
else
  SKILL_SRC="$ROOT/skills/constructor-resilience"
fi
LOCK="$ROOT/cli.lock"
if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
  echo "Missing $SKILL_SRC/SKILL.md" >&2
  exit 1
fi

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/constructor-resilience"
VENV="${CONSTRUCTOR_RESILIENCE_VENV:-$DATA_DIR/venv}"
USER_BIN="${CONSTRUCTOR_RESILIENCE_BIN:-$HOME/.local/bin}"
MARKER="# constructor-resilience CLI (install.sh)"

if [[ "$MODE" == "user" ]]; then
  DESTS=(
    "$HOME/.claude/skills/constructor-resilience"
    "$HOME/.grok/skills/constructor-resilience"
    "$HOME/.codex/skills/constructor-resilience"
    "$HOME/.cursor/skills/constructor-resilience"
    "$HOME/.agents/skills/constructor-resilience"
  )
else
  DESTS=(
    "$PWD/.claude/skills/constructor-resilience"
    "$PWD/.grok/skills/constructor-resilience"
    "$PWD/.cursor/skills/constructor-resilience"
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

link_skill() {
  local dest="$1"
  local parent
  parent="$(dirname "$dest")"
  run mkdir -p "$parent"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$SKILL_SRC" ]]; then
      echo "already linked: $dest"
      return 0
    fi
    echo "replacing symlink $dest -> $current"
    run rm "$dest"
  elif [[ -d "$dest" ]]; then
    # Keep backups *outside* the skills dir so hosts do not load them as skills.
    local bak_root bak
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
}

read_lock() {
  CLI_REPO=""
  CLI_REF=""
  CLI_VERSION=""
  if [[ ! -f "$LOCK" ]]; then
    echo "Missing $LOCK" >&2
    exit 1
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      ''|'#'*) continue ;;
      repo=*) CLI_REPO="${line#repo=}" ;;
      ref=*) CLI_REF="${line#ref=}" ;;
      version=*) CLI_VERSION="${line#version=}" ;;
    esac
  done < "$LOCK"
  if [[ -z "$CLI_REPO" || -z "$CLI_REF" ]]; then
    echo "cli.lock must set repo= and ref=" >&2
    exit 1
  fi
}

sibling_pkg() {
  local cand="${CONSTRUCTOR_RESILIENCE_HOME:-$ROOT/../constructor-resilience}"
  if [[ "$FROM_GIT" -eq 1 ]]; then
    return 1
  fi
  [[ -f "$cand/pyproject.toml" ]] || return 1
  printf '%s' "$(cd "$cand" && pwd)"
}

ensure_path_rc() {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  if grep -qF "$MARKER" "$rc" 2>/dev/null; then
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY: append PATH to $rc"
    return 0
  fi
  printf '\n%s\nexport PATH="$HOME/.local/bin:$PATH"\n' "$MARKER" >> "$rc"
  echo "added ~/.local/bin to PATH in $rc"
}

install_cli() {
  read_lock
  local py pip_spec sibling
  py="$(command -v python3 || true)"
  if [[ -z "$py" ]]; then
    echo "python3 is required to install the coherence CLI" >&2
    exit 1
  fi

  sibling="$(sibling_pkg || true)"
  local extra=""
  if [[ "$WITH_MLX" -eq 1 ]]; then
    extra="[mlx]"
    echo "CLI: including [mlx] extra"
  fi

  run mkdir -p "$DATA_DIR" "$USER_BIN"
  if [[ ! -d "$VENV" || ! -x "$VENV/bin/python" ]]; then
    run "$py" -m venv "$VENV"
  fi

  local pip="$VENV/bin/pip"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY: $pip install -U pip"
    if [[ -n "$sibling" ]]; then
      echo "DRY: $pip install -e ${sibling}${extra}"
    else
      echo "DRY: $pip install git+${CLI_REPO}@${CLI_REF}${extra:+#egg=constructor-resilience${extra}}"
    fi
  else
    "$pip" install -U pip
    if [[ -n "$sibling" ]]; then
      echo "CLI: editable install from $sibling (${CLI_VERSION:-unpinned})"
      "$pip" install -e "${sibling}${extra}"
    else
      local spec="git+${CLI_REPO}@${CLI_REF}"
      if [[ -n "$extra" ]]; then
        spec="${spec}#egg=constructor-resilience${extra}"
      fi
      echo "CLI: pip install $spec (constructor-resilience ${CLI_VERSION:-})"
      "$pip" install "$spec"
    fi
  fi

  if [[ ! -x "$VENV/bin/coherence" && "$DRY_RUN" -eq 0 ]]; then
    echo "pip install succeeded but $VENV/bin/coherence is missing" >&2
    exit 1
  fi

  run ln -sfn "$VENV/bin/coherence" "$USER_BIN/coherence"

  local skill_bin="$SKILL_SRC/bin/coherence"
  if [[ -f "$skill_bin" && "$DRY_RUN" -eq 0 ]]; then
    chmod +x "$skill_bin"
  fi

  case ":$PATH:" in
    *":$USER_BIN:"*) ;;
    *)
      ensure_path_rc "$HOME/.zprofile"
      ensure_path_rc "$HOME/.zshrc"
      ensure_path_rc "$HOME/.bash_profile"
      ensure_path_rc "$HOME/.bashrc"
      echo "this shell: export PATH=\"$USER_BIN:\$PATH\""
      ;;
  esac
}

verify_cli() {
  local bin="$USER_BIN/coherence"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY: $bin --help"
    return 0
  fi
  PATH="$USER_BIN:$PATH"
  if ! command -v coherence >/dev/null 2>&1; then
    echo "coherence is not on PATH. Try: export PATH=\"$USER_BIN:\$PATH\"" >&2
    echo "or run: $bin" >&2
    exit 1
  fi
  if ! coherence --help >/dev/null; then
    echo "coherence --help failed" >&2
    exit 1
  fi
  echo "CLI ok: $(command -v coherence)"
  coherence --help | head -n 2 || true
}

for dest in "${DESTS[@]}"; do
  link_skill "$dest"
done

echo
echo "Skill name: constructor-resilience"

if [[ "$SKILL_ONLY" -eq 1 ]]; then
  echo "CLI: skipped (--skill-only)"
  exit 0
fi

install_cli
verify_cli
echo
echo "Done. Next: tell the agent  pack this session"
echo "Store: \$COHERENCE_ROOT or \$PWD/.coherence"
echo "CLI:   coherence cache \"theme\""
