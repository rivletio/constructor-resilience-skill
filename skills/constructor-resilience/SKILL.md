---
name: constructor-resilience
description: >
  Pack a session into durable claims and a small resume packet. Use when
  digesting research, handing off between agents, sharing what was decided
  (not the transcript), attaching names and citations to claims, or checking
  whether a claim still holds. Triggers: pack this session, digest this,
  handoff, share claims, coherence cache, atoms, ingest, mint, packet,
  constructor resilience, interest intersection.
license: MIT
compatibility: Requires Python 3.10+. First `bin/coherence` next to this file installs the CLI if needed.
metadata:
  author: Rivlet
  version: "0.1.2"
  homepage: https://github.com/rivletio/constructor-resilience-skill
  upstream: https://github.com/rivletio/constructor-resilience
when-to-use: >
  pack this session, digest this into claims, handoff, share what we
  decided, cache this research
---

# Constructor Resilience

Turn this conversation into **atoms** (durable claims) and a **packet** (a small set to resume from). Share the packet, not the transcript.

An atom must constrain a possibility, an impossibility, a fact, or a decision. Names and citations hang on the claim; they are not a second graph.

## Setup

Use `coherence` on PATH. If missing, run `bin/coherence` next to this file (first run installs the CLI).

Store: `$COHERENCE_ROOT` or `$PWD/.coherence`.

## Protocol

### Resume

`coherence cache "theme"` (or `use <topic-id>`). Read the **packet** before new work.

If that misses, pack claims (below) — do not stop at CACHE MISS.

### Pack (default)

Write claims from this session. Do not wait for MLX.

```bash
coherence pack --title "theme" --json ./claims.json
# or one claim:
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

`constraint`: `possibility` | `impossibility` | `fact` | `decision`.  
`mentions` / `refs`: optional names and citations on that claim.

`pack` / `ingest` / `add-atom` keep claims. MLX `mint` starts `pending`. Pass `--pending` to queue a claim for review.

### Review / back out

Headless (do **not** open a browser unless the user asks):

```bash
coherence reject 3 --reason "claimed impossibility does not hold"
```

Human UI only if requested: `coherence review --serve --browser` (prints http://127.0.0.1:8765; default is no browser).

Rejected atoms stay on disk for audit and drop out of packets. Indices stay stable.

### Handoff

`pack` already writes `packet.json`. To give it to someone:

```bash
coherence share --to <id> --audience circle --forward none
```

Hand over `topics/<id>/atoms.json` + `packet.json`, or `share.json`.

### Import / overlap

```bash
coherence import ./their-atoms.json --title "Their surface" --use
coherence intersect <mine> <theirs> --query "…" --max-size 8
```

### Optional local MLX (Apple Silicon)

`./install.sh --mlx`, then `coherence mint` / `critique` / `eval`. Skip if unavailable.

## Circles

Keep private claims off public topics. Share only with `coherence share`.

## Docs

[SPEC.md](https://github.com/rivletio/constructor-resilience/blob/main/SPEC.md) ·
[USER_MANUAL.md](https://github.com/rivletio/constructor-resilience/blob/main/docs/USER_MANUAL.md) ·
[README.md](https://github.com/rivletio/constructor-resilience/blob/main/README.md)
