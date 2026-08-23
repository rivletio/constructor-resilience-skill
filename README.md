# constructor-resilience-skill

Harness-agnostic [Agent Skill](https://agentskills.io) for the
[constructor-resilience](https://github.com/rivletio/constructor-resilience)
coherence cache.

Same protocol on **Claude Code**, **Grok**, **Codex**, **Cursor**, and any host
that loads a `SKILL.md`. The skill is a thin client of the Python CLI
(`coherence`).

**Product framing:** share *interest surfaces*, not everything. Resume from *packets*.

## Install the skill

From this repo:

```bash
git clone https://github.com/rivletio/constructor-resilience-skill.git
cd constructor-resilience-skill
./install.sh
```

`install.sh` symlinks `skills/constructor-resilience` into:

| Host | User skill path |
|------|-----------------|
| Claude Code | `~/.claude/skills/constructor-resilience` |
| Grok | `~/.grok/skills/constructor-resilience` |
| Codex | `~/.codex/skills/constructor-resilience` |
| Cross-runtime | `~/.agents/skills/constructor-resilience` |

Project-local (this directory only):

```bash
./install.sh --project
```

Existing real directories are moved aside to `*.bak-<timestamp>` before linking.

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

## Install the CLI

The skill expects `coherence` on `PATH`:

```bash
python3 -m pip install "git+https://github.com/rivletio/constructor-resilience.git"
export COHERENCE_ROOT="${COHERENCE_ROOT:-$PWD/.coherence}"
```

Apple Silicon mint / critique / eval (optional):

```bash
python3 -m pip install "git+https://github.com/rivletio/constructor-resilience.git#egg=constructor-resilience[mlx]"
```

If you already have the package clone (Rivlet products layout):

```bash
pip install -e "${CONSTRUCTOR_RESILIENCE_HOME:-../constructor-resilience}[dev]"
```

## What the agent does

1. `coherence cache "theme"` or `coherence use <topic-id>`
2. Load the **packet** as privileged context
3. Mint only durable net-new claims (`coherence mint` or `add-atom`)
4. Review pending atoms; **back out** (`coherence reject` / `backout`) any atom that was ill-defined or does not actually constrain a possibility/impossibility
5. Rebuild the packet for handoff

Share `topics/<id>/atoms.json` + `packet.json` — not transcripts.

See [`skills/constructor-resilience/SKILL.md`](./skills/constructor-resilience/SKILL.md)
for the full protocol.

## Layout

```
.
├── README.md
├── LICENSE
├── install.sh
├── .claude-plugin/          # Claude Code plugin + marketplace
│   ├── plugin.json
│   └── marketplace.json
└── skills/
    └── constructor-resilience/
        └── SKILL.md         # Agent Skills entry (name matches folder)
```

## License

MIT — see [LICENSE](./LICENSE). Method and wire formats live in the
[constructor-resilience](https://github.com/rivletio/constructor-resilience)
package (also MIT).
