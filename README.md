# constructor-resilience-skill

Host installer for [`constructor-resilience`](https://github.com/rivletio/constructor-resilience).

**Functions live there** (`coherence` / `coherence_cache`). This package only
symlinks one `SKILL.md` into Grok, Claude, Codex, Cursor, and agents. It does
not fork pack, check, lookup, or mint. Mint models share `mlx_backend.generate`;
pick a model with `COHERENCE_MLX_MODEL`.

## Install

```bash
npx skills add rivletio/constructor-resilience-skill
```

`npx skills add` is the public install count ([skills.sh](https://skills.sh/rivletio/constructor-resilience-skill)). Git clones of this repo show up under GitHub Insights (unique cloners, last 14 days, owners). `coherence pack` does not phone home — claims stay local.

```bash
./scripts/usage.sh
```

Then say *pack this session* (or `/constructor-resilience`).

If `coherence` is not on PATH, the agent should run `bin/coherence` next to
`SKILL.md` — that wrapper installs the CLI on first use.

Full setup (skill links + CLI on `~/.local/bin`):

```bash
git clone https://github.com/rivletio/constructor-resilience-skill.git
cd constructor-resilience-skill
./install.sh
```

| Flag | What |
|------|------|
| `--project` | Link into `./.claude/skills` (and peers) of this directory |
| `--mlx` | Apple Silicon extra for `mint` / `critique` / `eval` |
| `--skill-only` | Symlink the skill, skip the CLI |
| `--from-git` | Install the GitHub pin in `cli.lock` even if a sibling clone exists |

Store: `$COHERENCE_ROOT` or `$PWD/.coherence`.

Existing skill directories are moved to a backup folder *outside* the skills
tree so hosts do not load them.

### Claude Code plugin

```bash
claude plugin marketplace add rivletio/constructor-resilience-skill
claude plugin install constructor-resilience
```

The plugin loads `SKILL.md`. Run `./install.sh` (or first `bin/coherence`) so
the CLI exists.

## What the agent does

1. Resume: `coherence cache "theme"` and read the packet (if CACHE MISS, pack).
2. Pack durable claims from **this session** (`coherence pack --draft`). Do not copy leftover example sentences.
3. Loop until quality (observe / reason / experiment) on pack **and** on `intersect` / `union`. `JOIN` is a shared name, not a cartesian of belief checks.
4. Lookup over a union: `coherence lookup "<QUESTION>" --mine <id> --theirs <id>` — hits, possible × impossible, atoms still in question.
5. Back out claims that do not actually constrain a possibility or impossibility.
6. Hand off: `coherence share --to <id>`.

Share `atoms.json` + `packet.json` (or `share.json`) — not the chat log.

Protocol: [`skills/constructor-resilience/SKILL.md`](./skills/constructor-resilience/SKILL.md).

## Layout

```
.
├── install.sh
├── cli.lock                 # pinned constructor-resilience git ref
├── .claude-plugin/
└── skills/constructor-resilience/
    ├── SKILL.md
    └── bin/coherence        # bootstraps CLI if PATH missed it
```

## License

[AGPL-3.0-or-later](./LICENSE) — GNU Affero General Public License v3 or later.
