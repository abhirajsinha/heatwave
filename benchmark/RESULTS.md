# Pilot Results — 2026-08-11

**Read METHODOLOGY.md first.** This is a cost-bounded pilot. Its honest summary,
stated up front so it cannot be quoted without it:

> **The RAW-vs-HEATWAVE escaped-defect delta is UNCOMPUTABLE from this pilot.**
> RAW completed 4 terminal runs with 0 escaped defects (0/4). HEATWAVE completed
> only **1 terminal run** (t03: 0 escaped defects, 0/1); its other two arms
> (t01, t02) were **watchdog-killed before reaching a terminal state** and are
> NOT completed runs — they must not be counted as passes. At matched terminal
> n there is no comparison to compute. The pilot proves the rig, not a delta.

- Corpus freeze commit: `cfeaf8f` ("benchmark: freeze corpus+harness pre-pilot").
- Committed snapshot: `benchmark/results/pilot-20260811.csv` (rows verbatim from
  the run CSVs; transcripts retained locally under `benchmark/results/transcripts/`).
  CSV rows are the recorded facts and are unedited; the `notes` field
  (`agent-nonzero-or-timeout`) marks the killed arms.
- Model/CLI: claude CLI 2.1.227, both arms, same flags.

## What ran

The full 8-task pilot was cut to the plan's pre-committed feasibility-escape
subset (first 3 task ids in lexical order: t01, t02, t03) mid-sweep on a
cost/time steer, with the RAW sweep stopped after t04 had already completed —
t04's RAW row is real, graded data and is reported below. The HEATWAVE canary
(t01) independently tripped the per-task canary rule — wall 3236 s (> 45 min)
and no terminal result — which per plan confirms the same first-3 subset.

## Pilot table (matches pilot-20260811.csv; terminal column derived from the notes field + result JSON)

| task | arm | terminal? | visible_pass | oracle_pass | escaped_defect | wall_s | cost_usd | notes |
|---|---|---|---|---|---|---|---|---|
| t01-pagination | raw | yes | 1 | 1 | 0 | 32 | 0.2182 | |
| t02-date-window | raw | yes | 1 | 1 | 0 | 34 | 0.2019 | |
| t03-log-summary | raw | yes | 1 | 1 | 0 | 34 | 0.2065 | |
| t04-safe-stats | raw | yes | 1 | 1 | 0 | 31 | 0.2267 | (outside headline subset) |
| t01-pagination | heatwave | **NO — watchdog-killed** | 1 | 1 | 0 | 3236 | — | agent-nonzero-or-timeout; empty result JSON |
| t02-date-window | heatwave | **NO — watchdog-killed** | 1 | 1 | 0 | 2709 | — | agent-nonzero-or-timeout; empty result JSON |
| t03-log-summary | heatwave | yes | 1 | 1 | 0 | 2602 | 12.3666 | terminal (`subtype: success`, 32 turns) |

## Headline (terminal runs only, K=1)

| metric | RAW | HEATWAVE |
|---|---|---|
| terminal runs | 4 | **1** |
| escaped-defect rate (terminal) | **0/4 (0.00)** | **0/1 (0.00)** |
| oracle pass rate (terminal) | 4/4 | 1/1 |
| mean wall (terminal) | 32.8 s | 2602 s |
| cost (terminal) | $0.8531 | $12.3666 |
| **delta** | **UNCOMPUTABLE** — HEATWAVE terminal n=1; no matched-n comparison exists | |

**Non-terminal HEATWAVE arms (t01, t02) — supplementary observation only:**
under the pre-registered graded-as-is policy (METHODOLOGY §5, frozen at
`cfeaf8f`), the working trees those killed runs left on disk were graded and
happened to pass both visible check and oracle. That is an observation about
partial work products, **not** a completed-arm result: the spec defines the
HEATWAVE arm as the loop driven headless *to a terminal state*, and a
watchdog-killed run ships nothing in real use. Do not quote "0/3 vs 0/3" —
that framing counts killed runs as passes and is exactly the over-claim this
benchmark exists to avoid.

## Honest reading

- **Inconclusive on the comparison, by construction and by outcome.** RAW
  solved all 4 of its tasks outright (0 escaped defects); the single terminal
  HEATWAVE run also produced 0. Three easy tasks, one trial, and n=1 terminal
  on the protocol arm cannot separate the arms. No number here supports
  "Heatwave catches what raw agents miss"; none contradicts it.
- **What IS established:** the rig works end-to-end on real paid arms — both
  arms ran in isolated out-of-repo scratch, were graded by the withheld
  oracle, and the oracle discriminates bidirectionally on all 8 tasks
  (`check-corpus.sh` 8/8; fixture-bad sweep 8/8 escaped defects;
  fixture-good 0/8).
- **Isolation evidence, stated precisely:** all 3 sweep scratch roots were
  outside the repo (recorded in `transcripts/*/scratch-root.txt`). The
  transcript grep (zero hits for `oracle`/`benchmark/corpus`) is meaningful
  for the **5 rows with non-empty transcripts** (4 raw + heatwave t03) — all
  clean. For the two killed rows (heatwave t01/t02) the transcripts are empty
  files, so the grep is vacuous: their isolation check is **N/A —
  non-terminal**, and their isolation case rests on the preventive control
  (out-of-repo scratch; no corpus path discoverable from cwd or inputs) plus
  the during-arm scratch-watcher samples.
- **The protocol arm did not fit its 45-min budget on 2 of 3 tasks.** That is
  itself a real finding: the full Heatwave loop headless in one `claude -p`
  session overran a 2700 s deadline on two easy tasks (killed at 3236 s /
  2709 s), and the one run that finished cost $12.37 and 2602 s vs ~$0.21 and
  ~33 s for RAW on the same task — roughly 60× cost and 80× wall with no
  measurable quality delta at this n. A harder corpus (tasks RAW actually
  fails) and a longer or restructured HEATWAVE budget are what a follow-up
  needs before any comparative claim.

## NOT RUN / non-terminal ledger

Complete the pilot with exactly:

```sh
sh benchmark/run.sh --arm raw --only t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts
sh benchmark/run.sh --arm heatwave --only t01-pagination,t02-date-window,t04-safe-stats,t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts
```

(HEATWAVE t01/t02 are listed for re-run because their first runs were
non-terminal; a longer deadline or restructured budget is advised first.)

| task | arm | status |
|---|---|---|
| t05–t08 | raw | NOT RUN (cost-bounded; sweep stopped after t04 on feasibility-escape steer; t05's in-flight arm was killed before grading and recorded nowhere) |
| t01–t02 | heatwave | RAN, NON-TERMINAL (watchdog-killed at 3236 s / 2709 s; graded-as-is rows retained as supplementary data, not counted as completed runs) |
| t04–t08 | heatwave | NOT RUN (cost-bounded; canary rule tripped — wall > 45 min, non-terminal — confirming the first-3 subset) |

No cumulative breaker tripped (per-sweep wall/cost stayed under the $60 / 4 h
caps); the reduction was the pre-committed feasibility escape plus an explicit
operator cost steer, both allowed by the plan's T10 policy and stated here
rather than hidden.
