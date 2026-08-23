---
name: constructor-resilience
description: >
  Agent coherence-cache: mint durable atoms with provenance, review them, build
  resilient packets, and eval packets on arbitrary queries. Use when caching
  research, handing off between sessions or agents, minting claims, reviewing
  atoms, or measuring packet quality. Triggers on coherence cache, atoms, mint
  atoms, review atoms, packet eval, constructor resilience, interest intersection.
license: MIT
compatibility: Requires Python 3.10+ and the constructor-resilience CLI (coherence) on PATH
metadata:
  author: Rivlet
  version: "0.1.0"
  homepage: https://github.com/rivletio/constructor-resilience-skill
  upstream: https://github.com/rivletio/constructor-resilience
---

# Constructor Resilience

Harness-agnostic [Agent Skill](https://agentskills.io) for Claude Code, Grok,
Codex, Cursor, and any host that loads `SKILL.md`. Thin client of
[`rivletio/constructor-resilience`](https://github.com/rivletio/constructor-resilience).

**Product framing:** share *interest surfaces*, not everything. Resume from *packets*.
**Atom law:** *how* we mint matters — every minted claim carries provenance and starts **pending review**.

## Setup

Need `coherence` on PATH (alias `knowledge_ops`).

```bash
python3 -m pip install "git+https://github.com/rivletio/constructor-resilience.git"
# Apple Silicon local mint / critique / eval:
# python3 -m pip install "git+https://github.com/rivletio/constructor-resilience.git#egg=constructor-resilience[mlx]"
```

If the Python package is already cloned (Rivlet products layout):

```bash
pip install -e "${CONSTRUCTOR_RESILIENCE_HOME:-../constructor-resilience}[dev]"
```

Store root:

```bash
export COHERENCE_ROOT="${COHERENCE_ROOT:-$PWD/.coherence}"
# Optional vault-style host:
# export COHERENCE_ROOT="${VAULT_ROOT}/coherence"
```

Default local model (MLX extra): **`mlx-community/Qwen3-8B-4bit`**.
Override: `COHERENCE_MLX_MODEL=…`

If MLX is unavailable, skip `mint` / `critique` / `eval --ensure-model` and use `add-atom` + `review` instead.

## Protocol

### Session start

1. `coherence cache "theme"` or `coherence use <topic-id>`
2. Load **packet** as privileged context
3. Continue; only durable net-new claims become atoms

### Mint (HOW we make atoms)

```bash
coherence ensure-model
coherence mint --file ./notes.md --theme "…" --auto-score
# atoms land as review.status=pending with model + source excerpt
```

Without MLX:

```bash
coherence add-atom "Durable claim." --auto-score
```

### Critique (pre-human)

```bash
coherence critique --source-file ./notes.md --apply
```

### Review (slick UI)

```bash
coherence review --serve    # http://127.0.0.1:8765
```

Accept / edit / reject. Rejected atoms stay for audit but leave packets.

### Eval (arbitrary queries)

```bash
coherence eval \
  --query "What did we decide about X?" \
  --query "How does Y relate to Z?" \
  --ensure-model
# → eval_report.json (grounded + coverage scores)
```

### Packet / handoff

```bash
coherence search --greedy --max-size 6
coherence packet --rebuild
# Share topics/<id>/atoms.json + packet.json
```

### Interest intersection

```bash
coherence intersect <mine-topic> <their-topic> --query "…" --max-size 8
```

## Circles

- Inner personal claims stay out of public topics unless intentional promote
- Intersection only uses surfaces each party chose to expose

## Docs

Upstream: [`SPEC.md`](https://github.com/rivletio/constructor-resilience/blob/main/SPEC.md),
[`docs/HOSTS.md`](https://github.com/rivletio/constructor-resilience/blob/main/docs/HOSTS.md),
[`docs/USER_MANUAL.md`](https://github.com/rivletio/constructor-resilience/blob/main/docs/USER_MANUAL.md),
[`README.md`](https://github.com/rivletio/constructor-resilience/blob/main/README.md)
