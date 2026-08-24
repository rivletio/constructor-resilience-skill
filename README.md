# constructor-resilience-skill

Harness-agnostic [Agent Skill](https://agentskills.io) for the
[constructor-resilience](https://github.com/rivletio/constructor-resilience)
coherence cache.

Same protocol on **Claude Code**, **Grok**, **Codex**, **Cursor**, and any host
that loads a `SKILL.md`. The skill is a thin client of the Python CLI
(`coherence`).

**Product framing:** share *interest surfaces*, not everything. Resume from *packets*.

## Install

```bash
npx skills add rivletio/constructor-resilience-skill
```

Then say *pack this session* (or run `/constructor-resilience`). First `bin/coherence` next to `SKILL.md` bootstraps the CLI if PATH does not have `coherence` yet.

```bash
git clone https://github.com/rivletio/constructor-resilience-skill.git
cd constructor-resilience-skill
./install.sh
```

`./install.sh` does the full setup:

1. Symlinks the skill into Claude / Grok / Codex / Cursor / `~/.agents`
2. Installs the pinned [`constructor-resilience`](https://github.com/rivletio/constructor-resilience) CLI into a venv and puts `coherence` on PATH (`~/.local/bin`)

Then an agent can run `coherence cache "theme"` with no extra setup. Store default is `$COHERENCE_ROOT` or `$PWD/.coherence`.

Optional:

| Flag | What |
|------|------|
| `--project` | Link into `./.claude/skills` (etc.) of the current directory |
| `--mlx` | Apple Silicon extra for `mint` / `critique` / `eval` |
| `--skill-only` | Symlink the skill, skip the CLI |
| `--from-git` | Ignore a sibling package clone; install the GitHub pin in `cli.lock` |

If `../constructor-resilience` exists (Rivlet products layout), the CLI is an editable install of that clone.

Existing real skill directories are moved aside to `*.bak-<timestamp>` before linking.

### Claude Code plugin

This repo is also a Claude plugin (skill under `skills/`). After clone:

```bash
claude plugin marketplace add "$PWD"
claude plugin install constructor-resilience
```

Or add the GitHub repo as a marketplace:

```bash
claude plugin marketplace add rivletio/constructor-resilience-skill
claude plugin install constructor-resilience
```

The plugin loads `SKILL.md`. You still want `./install.sh` so `coherence` is on PATH.

## What the agent does

1. `coherence cache "theme"` or `coherence use <topic-id>`
2. Load the **packet** as privileged context
3. Digest durable net-new claims with the host model (`coherence ingest` or `add-atom`). Mentions/refs are joins on the claim.
4. Review pending atoms; **back out** (`coherence reject` / `backout`) any atom that was ill-defined or does not actually constrain a possibility/impossibility
5. Rebuild the packet; `coherence share --to <id>` for an envelope

Share `topics/<id>/atoms.json` + `packet.json` (or `share.json`) — not transcripts.

See [`skills/constructor-resilience/SKILL.md`](./skills/constructor-resilience/SKILL.md)
for the full protocol.

## Layout

```
.
├── README.md
├── LICENSE
├── install.sh               # skill links + coherence CLI
├── cli.lock                 # pinned constructor-resilience git ref
├── .claude-plugin/          # Claude Code plugin + marketplace
│   ├── plugin.json
│   └── marketplace.json
└── skills/
    └── constructor-resilience/
        ├── SKILL.md
        └── bin/coherence    # fallback if PATH missed ~/.local/bin
```

## License

MIT — see [LICENSE](./LICENSE). Method and wire formats live in the
[constructor-resilience](https://github.com/rivletio/constructor-resilience)
package (also MIT).
