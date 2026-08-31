#!/usr/bin/env bash
# Install/clone counts for the skill. Not session telemetry.
# Claims never leave the machine; this only reads GitHub Insights (owners)
# and the skills.sh install leaderboard (npx skills add).
set -euo pipefail

SKILL_REPO="${SKILL_REPO:-rivletio/constructor-resilience-skill}"
CLI_REPO="${CLI_REPO:-rivletio/constructor-resilience}"
SKILL_SLUG="${SKILL_SLUG:-constructor-resilience}"

need_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is required for GitHub clone counts (https://cli.github.com)" >&2
    return 1
  fi
}

traffic() {
  local repo="$1"
  local kind="$2"
  gh api "repos/${repo}/traffic/${kind}" --jq \
    '"  14d '"${kind}"': \(.count)  unique: \(.uniques)"' \
    2>/dev/null || echo "  14d ${kind}: (need repo read access)"
}

echo "== ${SKILL_REPO}"
if need_gh; then
  traffic "$SKILL_REPO" clones
  traffic "$SKILL_REPO" views
  gh api "repos/${SKILL_REPO}" --jq '"  stars: \(.stargazers_count)  forks: \(.forks_count)"'
fi

echo
echo "== ${CLI_REPO}"
if need_gh; then
  traffic "$CLI_REPO" clones
  traffic "$CLI_REPO" views
  gh api "repos/${CLI_REPO}" --jq '"  stars: \(.stargazers_count)  forks: \(.forks_count)"'
fi

echo
echo "== skills.sh (npx skills add — not git clone, not pack)"
search="$(
  curl -fsS "https://skills.sh/api/search?q=${SKILL_REPO}" 2>/dev/null || true
)"
if [[ -z "$search" ]]; then
  echo "  (skills.sh search unreachable)"
else
  python3 - "$search" "$SKILL_REPO" "$SKILL_SLUG" <<'PY'
import json, sys
raw, source, slug = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    data = json.loads(raw)
except json.JSONDecodeError:
    print("  (skills.sh search not JSON)")
    raise SystemExit(0)
hits = [
    s for s in (data.get("skills") or [])
    if s.get("source") == source or s.get("skillId") == slug
]
if not hits:
    print("  not listed yet — counts start after `npx skills add %s`" % source)
    raise SystemExit(0)
for s in hits:
    print("  %s  installs=%s" % (s.get("id") or s.get("skillId"), s.get("installs")))
PY
fi

echo
echo "GitHub unique cloners mix humans, CI, and the skills CLI clone."
echo "skills.sh counts npx installs only. coherence pack does not phone home."
