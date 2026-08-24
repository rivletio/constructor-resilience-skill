# constructor-resilience-skill

An [Agent Skill](https://agentskills.io) so Claude, Grok, Codex, Cursor, and
other hosts can **pack a session into durable claims** and a small resume
packet — not a transcript.

Thin client of [`constructor-resilience`](https://github.com/rivletio/constructor-resilience)
(`coherence` CLI).

## Install

```bash
npx skills add rivletio/constructor-resilience-skill
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
2. Pack durable claims: `coherence pack --title "theme" --atom "Claim one." --atom "Claim two."`.
3. Back out claims that do not actually constrain a possibility or impossibility.
4. Hand off: `coherence share --to <id>`.

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
