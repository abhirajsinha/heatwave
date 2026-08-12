# Results — 2026-08-11 (conclusive rerun, E2 harness)

**Read METHODOLOGY.md first** — especially the locked scoring section: escape
rate is computed **over graded runs only**; runs that did not finish are
**completion failures**, reported separately and never hidden. The honest
summary, stated up front so it cannot be quoted without it:

> **RAW completed 8/8 tasks with 0 escaped defects (0/8 graded). The HEATWAVE
> arm's only graded run to date (pilot 1, t03 at LIGHT tier) also had 0
> escaped defects (0/1). The RAW-vs-HEATWAVE escaped-defect delta remains
> UNCOMPUTABLE at this n — no delta is claimed.** The conclusive, publishable
> finding is the **completion/cost profile**: headless HEATWAVE takes ~43 min
> and ~$12 per task even at LIGHT tier on tasks RAW solves in ~35 s for
> ~$0.21, and adaptive intake classifies these stub-implementation tasks
> STANDARD (heavier still). The E2 harness now records that terminally
> (timeout/escalated/error rows with elapsed + last protocol state + streamed
> transcripts) instead of hanging or losing the row.

## Provenance

- Corpus freeze: `cfeaf8f` (unchanged since pilot 1; `check-corpus.sh` ALL
  TASKS PASS re-verified before every paid sweep; manifest asserted identical
  pre/post inside each sweep).
- **Schema:** rows below use the E2 CSV schema
  (`outcome,terminal,tier,stage_model` columns; see METHODOLOGY "Scoring").
  Pilot-1 files (`pilot-20260811.csv`, schema without outcome columns) are
  immutable history, reinterpreted below through the outcome lens using their
  retained notes/transcripts — the rows themselves are unedited.
- Committed snapshot: `benchmark/results/rerun-20260811.csv` (rows verbatim
  from run CSVs `20260811T171717Z-raw` and `20260811T172224Z-heatwave` /
  `20260811T172553Z-heatwave`; transcripts retained locally under
  `benchmark/results/transcripts/`).
- Model/CLI: claude CLI 2.1.227, both arms, same flags
  (`--output-format stream-json --verbose`), session-default model
  (`stage_model` per row; `HW_MODEL` unset — no model asymmetry). HEATWAVE
  deadline for the minimal rerun: `HW_DEADLINE=1200` (20 min,
  operator-bounded; disclosed — the default is 2700 s).

## What ran (E2 rerun, cost-bounded by operator instruction)

- **RAW: all 8 tasks**, one trial each — every row terminal `graded`.
- **HEATWAVE: t01-pagination only** (smallest task), one trial under a 20-min
  graceful cap — the minimal demonstration that the fixed harness produces a
  terminal recorded row on a real arm. One additional started canary
  (2700 s sweep) was operator-stopped after 192 s; its trial is recorded as
  `error / interrupted` (a real row — the old harness would have lost it).
- Everything else: NOT RUN (cost-bounded), completion commands below.

## Rerun table (E2 schema; verbatim in rerun-20260811.csv)

| task | arm | outcome | terminal | tier | vis | ora | escape | wall_s | cost_usd | notes |
|---|---|---|---|---|---|---|---|---|---|---|
| t01-pagination | raw | graded | 1 | — | 1 | 1 | 0 | 31 | 0.2109 | |
| t02-date-window | raw | graded | 1 | — | 1 | 1 | 0 | 27 | 0.2014 | |
| t03-log-summary | raw | graded | 1 | — | 1 | 1 | 0 | 35 | 0.2134 | |
| t04-safe-stats | raw | graded | 1 | — | 1 | 1 | 0 | 33 | 0.2025 | |
| t05-cart-total | raw | graded | 1 | — | 1 | 1 | 0 | 52 | 0.2385 | |
| t06-username-policy | raw | graded | 1 | — | 1 | 1 | 0 | 29 | 0.1986 | |
| t07-slugify | raw | graded | 1 | — | 1 | 1 | 0 | 44 | 0.2537 | |
| t08-dedupe-contacts | raw | graded | 1 | — | 1 | 1 | 0 | 32 | 0.2080 | |
| t01-pagination | heatwave | error | 0 | — | — | — | — | 192 | — | interrupted (operator stop; row recorded by the E2 trap) |
| t01-pagination | heatwave | timeout | 0 | STANDARD | 0 | 0 | 0 | 1201 | 6.4400 | timeout; last_state=PLAN_REVIEW; agent-nonzero |

RAW `stage_model` (all rows): `claude-haiku-4-5-20251001;claude-opus-5[1m]`;
HEATWAVE timeout row: `claude-opus-5[1m]`. The timeout row demonstrates every
piece of the fix at once: deadline enforced at cap+1 s (1201 vs 1200 — the
pilot's 536 s overshoot class is gone), tier + serving model + last protocol
state recorded, **cost recorded even though the run was killed** (the CLI's
TERM path flushed a final result event into the streamed `agent.ndjson`,
844 KB of surviving evidence), and at kill time the protocol sat at
PLAN_REVIEW **iteration 2** — 20 minutes in, still reviewing the plan for a
one-function task, no code yet (visible/oracle 0/0 as partial-work
observation).

## Headline (per METHODOLOGY scoring — escape over graded, completion separate)

| metric | RAW (E2 rerun) | HEATWAVE (E2 rerun) | HEATWAVE (pilot 1, reinterpreted) |
|---|---|---|---|
| attempted | 8 | 2 | 3 |
| graded (completed) | 8 | 0 | 1 (t03) |
| completion rate | 8/8 | 0/2 | 1/3 |
| escaped defects over graded | **0/8 (0.000)** | N/A (0 graded) | 0/1 (0.000) |
| oracle pass over graded | 8/8 | N/A (0 graded) | 1/1 |
| outcome table | graded 8 | timeout 1, error 1 | graded 1, timeout 2 |
| mean wall (graded) | 35.4 s | — | 2602 s |
| cost | $1.7270 total | $6.4400 recorded (+192 s unrecorded) | $12.3666 (t03) |

**No delta sentence is stated.** A RAW-vs-HEATWAVE escaped-defect comparison
requires terminal graded runs in both arms at comparable n; HEATWAVE has 1
graded run ever (pilot t03) against RAW's 8 — 0/8 vs 0/1 supports no
conclusion in either direction.

## Pilot 1 reinterpreted through the E2 outcome lens

Pilot-1 rows (schema v1, `pilot-20260811.csv`, unedited) map to outcomes as:

| task | arm | E2 outcome | evidence |
|---|---|---|---|
| t01–t04 | raw | graded ×4 (0 escapes) | terminal result JSON per row |
| t01-pagination | heatwave | **timeout** (would-be) | watchdog-killed at 3236 s; 0-byte transcript = the lost-evidence defect E2 fixed |
| t02-date-window | heatwave | **timeout** (would-be) | killed at 2709 s; 0-byte transcript |
| t03-log-summary | heatwave | graded (0 escapes) | `subtype: success`, APPROVED at LIGHT, 2602 s, $12.37 |

The pilot's killed rows passed both visible and oracle checks as left on disk
— under E2 scoring that is a supplementary observation about partial work
products (the code was done; review ceremony was still running), **not** a
completed-arm result, and it is not counted as one.

## Honest reading (conclusive)

1. **The harness defect is fixed and demonstrated.** Every started arm in the
   E2 rerun reached a terminal recorded outcome — including a deliberately
   capped real HEATWAVE run and an operator-interrupted one. No 0-byte
   transcripts: streamed `agent.ndjson` survives every kill (verified on the
   real capped run and the zero-cost stub tests; see the implementation
   package for the forced timeout/escalation/interrupt evidence).
2. **The diagnosis is slow-not-stuck.** The pilot's non-terminal runs were not
   hangs: `claude -p` exits on owner-questions; the instrumented probe showed
   continuous tool activity with the loop mid-ceremony; the killed pilot runs
   had already-complete, oracle-passing code. No orchestrator defect;
   `protocol/` untouched.
3. **The real finding is cost-to-complete.** Headless HEATWAVE on these small
   tasks: ~43 min / ~$12 at LIGHT (pilot t03, the only completed protocol run);
   intake classifies the stub-implementation tasks **STANDARD** (observed in
   all three instrumented t01 runs: R-103 resolves tier doubt upward on a
   feature-stub, since `raise NotImplementedError` is not a "single obvious
   edit"), which multiplies role dispatches and makes a 20–45 min budget
   insufficient — the capped run was still in PLAN_REVIEW (iteration 2, no
   code yet) at 20 minutes. HEATWAVE
   completion rate across all real attempts to date: **1 graded / 5 attempted**
   (pilot 3 + rerun 2, counting the operator-interrupted trial as attempted).
   That number is the honest cost of running the full protocol loop headless
   on one-function tasks — a real, publishable result about protocol overhead,
   not about defect rates.
4. **What would change the picture:** a harder corpus (tasks RAW actually
   fails), more trials, and a HEATWAVE budget sized to its measured ~45-min
   task time (or EXPRESS/LIGHT-classified tasks). Until a matched-n graded
   comparison exists, no escaped-defect claim should cite this benchmark.

## NOT RUN ledger

Complete the sweep with exactly:

```sh
sh benchmark/run.sh --arm heatwave --only t02-date-window,t03-log-summary,t04-safe-stats,t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts
# and a full-budget retry of the capped canary:
sh benchmark/run.sh --arm heatwave --only t01-pagination
```

| task | arm | status |
|---|---|---|
| t01 | heatwave | RAN under a disclosed 1200 s cap (+1 operator-interrupted trial); full-budget (2700 s) retry listed above |
| t02–t08 | heatwave | NOT RUN (cost-bounded by operator instruction; per-task expectation from measured data: ~$12+/task, ≥43 min/task) |

Cumulative breaker never tripped ($60 / 14400 s caps intact); the reduction to
a single real HEATWAVE task was an explicit operator cost bound, stated here
rather than hidden.

## Addendum — 2026-08-12: post intake-fix t01 spot-check (n=1, no delta)

After the intake tier-inflation fix (`main@965b1ad`, v4.1 R-103a ordered
cascade), t01-pagination was re-run on the HEATWAVE arm under a disclosed
1500 s cap to check ONE thing: does the live driver now classify this small
single-file task LIGHT instead of STANDARD? It does.

| task | arm | outcome | tier | vis | ora | escape | wall_s | cost_usd | last_state |
|---|---|---|---|---|---|---|---|---|---|
| t01-pagination | heatwave | timeout | **LIGHT** | 1 | 1 | 0 | 1502 | 7.75 | FULL_REVIEW (LIGHT combined pass) |

- **Confirmed (the only claim made):** intake now routes t01 to **LIGHT**, not
  STANDARD. The driver's recorded `tier_justification` cites the fix directly —
  "non-trivial validation/boundary logic makes EXPRESS doubtful, so it resolves
  upward one rung to LIGHT (R-103/R-103a)" — i.e. doubt resolved to LIGHT (one
  rung), not to the STANDARD default. This is the E2 inflation removed, observed
  live end-to-end, not just in the deterministic decision-table check.
- **NOT claimed:** a cost/time delta. The run hit the 1500 s cap still inside the
  LIGHT combined FULL+FINAL review pass (`oracle_pass=1` — the implementation was
  correct; the run was grinding review ceremony, not stuck on the code), so it did
  NOT reach terminal APPROVED. For reference only (n=1, not a controlled compare):
  the pilot t01 at STANDARD was watchdog-killed at 3236 s non-terminal; this LIGHT
  run reached FULL_REVIEW with correct code in 1502 s / $7.75. LIGHT got further,
  faster, cheaper — but the standing finding stands: headless HEATWAVE is still
  slow, and LIGHT reduces the overhead without erasing it. A terminal-APPROVED
  LIGHT completion and a matched-n comparison remain NOT RUN.

## Addendum — 2026-08-12: model-tiering knob + tier-variance finding

Added an opt-in harness knob `HW_CHEAP_MODEL` (`run.sh`) that pre-seeds a
`heatwave.config.yaml` with `cheap_model: <id>` into the HEATWAVE arm scratch,
enabling R-116 stage model-tiering. Unset = zero-config, byte-identical to the
untiered arm (verified by a deterministic seam self-check + isolated review,
GATE_MET). Purpose: route LIGHT's cheap-eligible `PLAN_REVIEW` (~6 min on the
frontier model in the first t01 run) to a fast model, the only frontier-safe
latency lever — PLANNING, IMPLEMENTING, and the combined FULL+FINAL pass stay
frontier by R-116 and are untouched.

**The intended LIGHT+haiku measurement did NOT land, for an honest reason.** The
tiered t01 rerun (`HW_CHEAP_MODEL=claude-haiku-4-5-20251001`, 1500 s cap)
classified t01 **STANDARD**, not LIGHT — so cheap-tiering correctly did not
apply (STANDARD `PLAN_REVIEW` is frontier-required, R-116). No LIGHT+haiku
datapoint was obtained; no speedup is claimed.

| task | arm | cheap_model | outcome | tier | wall_s | cost | last_state |
|---|---|---|---|---|---|---|---|
| t01-pagination | heatwave | — (untiered) | timeout | LIGHT | 1502 | 7.75 | FULL_REVIEW |
| t01-pagination | heatwave | haiku-4-5 | timeout | STANDARD | 1502 | 7.08 | IMPLEMENTING |

**Tier-variance finding (the real result).** The same task classified LIGHT in
one run and STANDARD in another — but the flip is at cascade **rung 1 (R-102
sensitive path)**, not the LIGHT/STANDARD boundary, and both runs cite R-103a:

- LIGHT run: "no new public surface … EXPRESS doubtful → LIGHT."
- STANDARD run: "`pagination.paginate` is imported by callers and defines its
  public contract → **public API surface (R-102)** → EXPRESS/LIGHT forbidden."

This is the sensitive-path floor working, not inflation: a stub that defines a
public contract is a defensible read of "public API surface," which R-102
forces to STANDARD+. The consequence for benchmarking: **every corpus task is a
function-stub that defines a public contract, so they all straddle the R-102
line and none reliably classifies LIGHT.** Measuring LIGHT-tiering needs an
unambiguously-LIGHT task (a bounded fix to already-implemented, non-public
behavior) — which the current corpus lacks. The knob is landed and correct; a
clean live LIGHT-tiering number remains NOT MEASURED, blocked on corpus
suitability rather than on the knob.
