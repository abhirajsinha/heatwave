# Pilot Results — 2026-08-11

**Read METHODOLOGY.md first.** This is a cost-bounded pilot subset, n = 3 tasks
per arm on the pre-committed first-3 lexical subset (plus one extra completed
RAW row). It is a rig-proving signal, not evidence that either arm is better.

- Corpus freeze commit: `cfeaf8f` ("benchmark: freeze corpus+harness pre-pilot").
- Committed snapshot: `benchmark/results/pilot-20260811.csv` (rows verbatim from
  the run CSVs; transcripts retained locally under `benchmark/results/transcripts/`).
- Model/CLI: claude CLI 2.1.227, both arms, same flags.

## What ran

The full 8-task pilot was cut to the plan's pre-committed feasibility-escape
subset (first 3 task ids in lexical order: t01, t02, t03) mid-sweep on a
cost/time steer, with the RAW sweep stopped after t04 had already completed —
t04's RAW row is real, graded data and is reported below (its HEATWAVE
counterpart was never run, so it is excluded from the headline comparison).
The HEATWAVE canary (t01) also tripped the per-task canary rule — wall 3236 s
(> 45 min) and no terminal result — which per plan confirms the same first-3
subset.

## Pilot table (matches pilot-20260811.csv exactly)

| task | arm | visible_pass | oracle_pass | escaped_defect | wall_s | cost_usd | notes |
|---|---|---|---|---|---|---|---|
| t01-pagination | raw | 1 | 1 | 0 | 32 | 0.2182 | |
| t02-date-window | raw | 1 | 1 | 0 | 34 | 0.2019 | |
| t03-log-summary | raw | 1 | 1 | 0 | 34 | 0.2065 | |
| t04-safe-stats | raw | 1 | 1 | 0 | 31 | 0.2267 | (outside headline subset) |
| t01-pagination | heatwave | 1 | 1 | 0 | 3236 | — | agent-nonzero-or-timeout |
| t02-date-window | heatwave | 1 | 1 | 0 | 2709 | — | agent-nonzero-or-timeout |
| t03-log-summary | heatwave | 1 | 1 | 0 | 2602 | 12.3666 | |

## Headline (pre-committed 3-task subset, K=1)

| metric | RAW (n=3) | HEATWAVE (n=3) |
|---|---|---|
| escaped-defect rate | **0/3 (0.00)** | **0/3 (0.00)** |
| oracle pass rate | 3/3 | 3/3 |
| mean wall | 33.3 s | 2849.0 s |
| cost (where reported) | $0.6265 (3/3 rows) | $12.3666 (1/3 rows) |

Supplementary: RAW t04 also graded 0 escapes (RAW total 0/4).

## Honest reading

- **The delta claim is inconclusive at this n.** Both arms produced
  spec-complete solutions on every graded task; zero escaped defects either
  way. Three easy tasks and one trial cannot separate the arms — the corpus's
  `difficulty: easy` tasks were all solved outright by the RAW arm, so there
  was no escaped-defect signal for HEATWAVE to prevent. No number here
  supports "Heatwave catches what raw agents miss"; equally, none contradicts
  it.
- **What IS established:** the rig works end-to-end on real paid arms — both
  arms ran in isolated out-of-repo scratch, were graded by the withheld
  oracle, and produced clean isolation evidence (scratch roots outside the
  repo; transcript grep zero hits for `oracle`/`benchmark/corpus` on all 7
  rows). The oracle discriminates bidirectionally on all 8 tasks
  (`check-corpus.sh` 8/8; fixture-bad sweep 8/8 escaped defects).
- **Timeout asymmetry in practice:** HEATWAVE t01/t02 hit the 2700 s watchdog
  before emitting a terminal result (graded as-is, per METHODOLOGY §5; the
  work on disk was nonetheless oracle-complete). Their cost is unobtainable
  (empty result JSON) — only t03's $12.37 is a measured HEATWAVE cost. On
  these tasks the protocol arm cost roughly 60× the raw arm's ~$0.21 and 80×
  its wall time, with no measurable quality delta at this n. A harder corpus
  (tasks raw agents actually fail) is what a follow-up needs.

## NOT RUN (cost-bounded)

Remaining tasks were not run; complete them with exactly:

```sh
sh benchmark/run.sh --arm raw --only t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts
sh benchmark/run.sh --arm heatwave --only t04-safe-stats,t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts
```

| task | arm | status |
|---|---|---|
| t05–t08 | raw | NOT RUN (cost-bounded; sweep stopped after t04 on feasibility-escape steer; t05's in-flight arm was killed before grading and recorded nowhere) |
| t04–t08 | heatwave | NOT RUN (cost-bounded; canary rule tripped — wall > 45 min, non-terminal — confirming the first-3 subset) |

No cumulative breaker tripped (per-sweep wall/cost stayed under the $60 / 4 h
caps); the reduction was the pre-committed feasibility escape plus an explicit
operator cost steer, both allowed by the plan's T10 policy and stated here
rather than hidden.
