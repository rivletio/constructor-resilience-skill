---
name: constructor-resilience
description: >
  Digest a session into durable claims, pack what was decided, hand off
  compressed findings (not transcripts), extract names and citations as
  joins on those claims, or check whether a claim constrains a possibility
  or impossibility. Use when caching research, packing this session,
  minting/ingesting atoms, handing off between agents, sharing claims,
  reviewing or backing out atoms, packet eval, or interest intersection.
  Triggers on coherence cache, atoms, ingest, digest this, pack this
  session, handoff, share claims, named entities, mint atoms, review
  atoms, packet eval, constructor resilience, interest intersection.
license: MIT
compatibility: Requires Python 3.10+. First `bin/coherence` bootstraps the CLI if needed.
metadata:
  author: Rivlet
  version: "0.1.2"
  homepage: https://github.com/rivletio/constructor-resilience-skill
  upstream: https://github.com/rivletio/constructor-resilience
when-to-use: >
  pack this session, digest this into claims, handoff, share what we
  decided, cache this research, extract names and citations
---

# Constructor Resilience

Harness-agnostic [Agent Skill](https://agentskills.io). Thin client of
[`rivletio/constructor-resilience`](https://github.com/rivletio/constructor-resilience).

Share *interest surfaces*, not everything. Resume from *packets*.
An atom must constrain a *possibility* or an *impossibility* (or record a fact/decision). Mentions and refs are **joins on the claim**, not a second graph.

## Setup

Prefer `coherence` on PATH. If missing, run `bin/coherence` next to this file — it bootstraps the CLI. Store: `$COHERENCE_ROOT` or `$PWD/.coherence`.

Install (once): `npx skills add rivletio/constructor-resilience-skill` or `./install.sh` from the skill repo.

## Protocol

### Session start

1. `coherence cache "theme"` or `coherence use <topic-id>`
2. Load **packet** as privileged context
3. Continue; only durable net-new claims become atoms

### Digest (default — this conversation's model)

Write claims yourself. Do not wait for MLX.

```bash
coherence ingest --json ./claims.json --auto-score
# or:
coherence add-atom "Durable claim." --constraint fact --auto-score
```

`claims.json`:

```json
{
  "atoms": [
    {
      "text": "One stand-alone sentence worth injecting later.",
      "constraint": "fact",
      "mentions": [{"name": "JEPA", "kind": "concept"}]
    }
  ]
}
```

`constraint` is `possibility` | `impossibility` | `fact` | `decision`.
`mentions` / `refs` are optional joins (person, org, work, concept, citations). Do not invent a parallel entity store.

Atoms land `review.status=pending` unless `--accepted`.

### Review / back out

```bash
coherence review --serve
coherence reject 3 --reason "claimed impossibility does not hold"
```

Rejected atoms stay for audit, leave packets. Indices stay stable.

### Packet / handoff

```bash
coherence search --greedy --max-size 6
coherence packet --rebuild
coherence share --to <id> --audience circle --forward none
```

Share `topics/<id>/atoms.json` + `packet.json`, or the `share.json` envelope.

### Import / intersect

```bash
coherence import ./their-atoms.json --title "Their surface" --use
coherence intersect <mine> <theirs> --query "…" --max-size 8
```

### Optional local MLX (Apple Silicon)

`./install.sh --mlx` then `coherence mint` / `critique` / `eval`. Skip if unavailable.

## Circles

Inner personal claims stay out of public topics unless intentional promote.
Share is never ambient — use `coherence share`.

## Docs

Upstream: [SPEC.md](https://github.com/rivletio/constructor-resilience/blob/main/SPEC.md),
[USER_MANUAL.md](https://github.com/rivletio/constructor-resilience/blob/main/docs/USER_MANUAL.md),
[README.md](https://github.com/rivletio/constructor-resilience/blob/main/README.md)
