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

Store: `$COHERENCE_ROOT` or `$PWD/.coherence`. Do **not** run `coherence review --serve --browser` unless the user asks (it can open Chrome).

## Protocol

### Resume

`coherence cache "theme"` (or `use <topic-id>`). Read the **packet** before new work.

If that misses, pack — do not stop at CACHE MISS.

### Pack (default)

Write stand-alone claims from this session. You extract the names; no extra NER model.

For each claim: the sentence, a `constraint`, the **joins** it is about (`--mention` after that `--atom`), and a **locator** on each join (`--at`).

```bash
coherence pack --title "theme" --constraint fact \
  --atom "ClaimParts attaches joins to the preceding atom." \
  --mention "ClaimParts:concept" --at "src/coherence_cache/cli.py:358" \
  --atom "Lex says a good conversation requires duration." \
  --mention "Lex Fridman:person" --at "t=3033"
```

`constraint`: `possibility` | `impossibility` | `fact` | `decision`.

**Joins** (`person` | `org` | `work` | `place` | `concept` | `other`): names the claim is *about*, not every noun, not a second graph. Pin where you saw the name: `--at file.py:42` / `file.py#L42-L48` (url is that path with `#L42`), `--at t=3033` or a YouTube URL with `&t=`, arXiv `page`+`paragraph`+`excerpt` on the atom `refs`. Intersection keys on the names. Acronym heuristics are a fallback.

**Atom citations.** YouTube: `t` on the original video. arXiv: `page`, `paragraph`, and `excerpt`; `url` is the original PDF `#page=N`. Use `--json` when a claim needs structured `refs`.

Then `coherence share` if handing off.

Duplicates are skipped. `pack` / `ingest` / `add-atom` keep claims. MLX `mint` starts `pending`. `--pending` queues review.

### Back out

```bash
coherence reject 3 --reason "claimed impossibility does not hold"
```

Rejected atoms stay on disk, drop out of packets. Indices stay stable.

### Handoff

```bash
coherence share --to <id> --audience circle --forward none
```

Give `topics/<id>/atoms.json` + `packet.json`, or `share.json`.

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
