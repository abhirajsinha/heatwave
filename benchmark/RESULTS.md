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

## Addendum — 2026-08-12: LIGHT fixture added and confirmed LIGHT live (n=1)

The corpus-suitability blocker above is now resolved. Added a tier-stratified
fixture `benchmark/corpus-tiering/lt01-progress-cap/` (behind the `CORPUS`
knob, frozen reliability corpus untouched): an already-implemented **internal**
`percent_complete` helper with a `min(pct,99)` bug that corrupts only
`done==total`. The SPEC is symptom-framed ("bars stall just short of full;
diagnose why the finished state is wrong") — no line naming, no
public-contract/API language — so the driver has no legitimate R-102 hook and
the defect is not a single handed-over locatable edit.

Confirmatory live run (`HW_DEADLINE=600 CORPUS=corpus-tiering`, n=1):

| task | arm | tier | change_class | wall_s | cost | last_state |
|---|---|---|---|---|---|---|
| lt01-progress-cap | heatwave | **LIGHT** | bugfix | 604 | 2.57 | PLANNING (capped) |

The driver's recorded `tier_justification`: *"Bounded fix to one existing
internal helper in a single file; no sensitive path, no new dependency or
public surface — but not a copy/config/typo edit (it needs diagnosis +
behavioral verification), so EXPRESS doubt resolves upward to LIGHT (R-103,
R-103a rung 3)."* This threads the needle the stub tasks could not: **not
EXPRESS** (diagnosis required → not a single locatable edit), **not STANDARD**
(internal single-file bugfix, no R-102 public-API hook). Contrast t01, which
flipped LIGHT↔STANDARD at rung 1 because it defines a public contract.

Caveat (honest): the run timed out in PLANNING at the 10-min cap, so it is
non-terminal; `oracle_pass=0 / escaped_defect=1` are **meaningless** for a run
that never reached implementation (the shipped buggy code was never fixed) —
they are NOT a real escaped defect. The validated signal is the **intake
tier**, observable seconds after start, and it is LIGHT. n=1; the cap was 600 s
(tighter than the plan's 1200 s) because the tier lands at intake.

This unblocks the corrected Doc 1 §6 experiment (baseline all-frontier LIGHT vs
tiered cheap-`PLAN_REVIEW` LIGHT on this fixture). That measurement is NOT YET
RUN.

## Addendum — 2026-08-12: LIGHT cheap-PLAN_REVIEW measurement (Doc 1 §6; n=1)

Ran the corrected single-variable experiment on `lt01-progress-cap`: two
HEATWAVE-arm runs, `HW_DEADLINE=1200`, identical except the model serving
`PLAN_REVIEW`. Both classified **LIGHT** (valid comparison). R-116 routed
exactly the intended stage — the tiered run's `stage_model` shows
**haiku on PLAN_REVIEW only**, opus on PLANNING / IMPLEMENTING / the combined
FULL+FINAL pass (frontier-required) — confirming the tiering knob cheapens the
one cheap-eligible stage and nothing else.

Real-clock stage timing (state-timeline, ±30 s sampling, n=1 each):

| metric | baseline (all frontier) | tiered (cheap PLAN_REVIEW) |
|---|---|---|
| tier | LIGHT | LIGHT |
| PLAN_REVIEW model | opus-5 | **haiku-4.5** |
| **PLAN_REVIEW stage wall** | **~6 min** | **~3.5 min** |
| PLANNING | ~7 min | ~6 min |
| IMPLEMENTING | ~4 min | ~7.5 min |
| time to combined-review | +18 min | +18 min |
| total wall / cost | 1201 s / $6.49 | 1200 s / $6.22 |

**Finding (honest, and slightly humbling):** the cheap model cut the
`PLAN_REVIEW` **stage** ~40 % (~6 → ~3.5 min) exactly as designed — but
**total wall time and cost did not move** (both hit the cap at ~+18 min;
$6.49 vs $6.22 is within noise). The ~2.5 min plan-review saving was swallowed
by ordinary implementation-stage variance (4 min vs 7.5 min, both opus). This
is direct evidence for the priority ordering in the Product/Engineering plan
§9: **model-tiering is the smallest LIGHT lever** — it touches one of four
sequential frontier dispatches, and inter-dispatch variance already exceeds the
saving. The real latency lives in the number and per-dispatch cost of the
frontier round-trips (planning, implementation, combined review), not in which
model reviews the plan.

**Caveats:** n=1 per arm, 30 s sampling granularity, stage durations are
stochastic — this is a directional spot-check, not a powered measurement. It
cannot prove the total-time question either way; it shows the stage-level
saving is real and that at n=1 it did not surface in the total. No further runs
spent chasing significance (cost-bounded). The stage-level result + the R-116
routing verification are the durable takeaways.

---

## Addendum — 2026-08-24: LIGHT-2D two-dispatch A/B (v4.2; n=2)

Measures the v4.2 change that makes a LIGHT run **two dispatches** (IMPLEMENTER
writes a capped plan then the code; one independent combined FULL+FINAL review)
instead of four (PLANNING → PLAN_REVIEW → IMPLEMENTING → combined review).

**Command (exactly as run):**
```
HW_MODEL='claude-opus-5[1m]' CORPUS=corpus-tiering HW_DEADLINE=1200 \
  sh benchmark/run.sh --arm heatwave --only lt01-progress-cap --trials 2
```
- Repo HEAD at launch: `04b59b5`, working tree **dirty** (the v4.2 change was uncommitted; `install.sh` copies working-tree files into the benchmark scratch, so the runs executed under the new protocol).
- Model: `HW_MODEL=claude-opus-5[1m]`; CSV `stage_model` = `claude-opus-5[1m]` on **both** new rows.
- Installed config: the example config's `roles:` block was **commented out for the duration of this A/B only** (restored immediately after), so the runs held the model constant at `claude-opus-5[1m]` rather than inheriting the maintainer role models. `HW_CHEAP_MODEL` unused.

**Baseline (existing terminal LIGHT run, not re-run):** `20260812T094216Z` —
1878 s / $9.978, oracle pass. Its CSV `stage_model` = **`claude-opus-5[1m]`**.

**No model confound.** Baseline and both new runs ran on the *same* model
(`claude-opus-5[1m]`, verified from each row's `stage_model`). The wall/cost
delta is therefore attributable to the ceremony change (four dispatches → two),
with the model held constant — not to a model difference.

| run_id | tier | outcome/terminal | last_state | dispatches | wall_s | cost_usd | oracle | pkg/report lines | shape check | wall vs 1878 | cost vs $9.98 | target ≤50% |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 20260812T094216Z (baseline) | LIGHT | graded / 1 | APPROVED | 4 | 1878 | 9.978 | pass | 325/163/507/186 (4 artifacts) | — | — | — | — |
| 20260824T165539Z trial 1 | LIGHT | graded / 1 | APPROVED | 2 (impl + combined review; no planner) | 696 | 4.441 | pass | 141/77 | package PASS, report PASS | 37.1% | 44.5% | **MET** (wall + cost) |
| 20260824T165539Z trial 2 | LIGHT | graded / 1 | APPROVED | 2 (impl + combined review; no planner) | 692 | 4.414 | pass | 122/71 | package PASS, report +1 surplus `## Approval` section (Minor, R-126 — non-gating) | 36.8% | 44.2% | **MET** (wall + cost) |

- Total cost, 2 paid runs: **$8.855** (≤ $20 budget).
- Both runs: `state: APPROVED`, tier LIGHT, run-record transitions exactly
  `START→IMPLEMENTING`, `IMPLEMENTING→FULL_REVIEW`, `FULL_REVIEW→APPROVED`
  (zero PLANNING/PLAN_REVIEW); `agent.ndjson` shows `heatwave-implementer` and
  `heatwave-reviewer` as **separate** subagent invocations (no planner
  dispatched) — R-1/R-2 isolation held with the two contexts that exist.
- lt01 is a bugfix; each package carries the red→green reproduction (RED: 3/12
  checks fail on unmodified `progress.py`; GREEN: same check passes after the fix).

**Honesty rule (verbatim):** n=2; directional only; no percentage claim beyond
what n=2 supports; a miss is a valid result; any unrun or non-terminal run is
listed as such with its last state; a fabricated hit is a Blocker (R-65).

**Reading:** at n=2, both trials came in at ~37% of baseline wall and ~44% of
baseline cost — under the ≤50% target on both axes — with the same model, same
task, same oracle pass. The mechanism is visible in the artifact counts: two
short capped artifacts (~140/~75 lines) replace four longer ones
(325/163/507/186), and generation is the wall (E6/E7), so fewer, shorter
artifacts is less wall. This is a two-sample directional result, not a powered
measurement; it does not claim a precise percentage, only that the two-dispatch
structure landed well under the target here. Raw data: CSV
`benchmark/results/20260824T165539Z-heatwave.csv`; transcripts, run records,
`agent.ndjson`, and state timelines under
`benchmark/results/transcripts/20260824T165539Z-heatwave/`.

---

## Addendum — 2026-08-25: v4.4 context-brief + capped-STANDARD-review baseline (targets, not gates)

This addendum pins the **baseline** for the v4.4 change (context brief at intake +
STANDARD review output-shape cap, R-131/R-132) and records the **follow-up method**.
Per the run's AC-N-04, the wall/cost improvement itself is **not** claimed here — no
post-v4.4 STANDARD run exists yet; claiming it now would be assertion, not evidence
(R-65/R-66). What is pinned is the measurement machinery and honest targets.

**Baseline — `jira-mode` (the clean STANDARD sample this session).** Per-stage wall
and token totals as reported by the harness (intake note table; provenance: per-dispatch
harness wall/token counts for each subagent):

| Stage | Wall | Share |
|---|---|---|
| Jira intake + repo-ownership ladder | 0 min (0 dispatches) | 0% |
| PLANNING | 10.6 min | 14% |
| PLAN_REVIEW ×2 | 8.5 min | 11% |
| IMPLEMENTING | 19.3 min | 25% |
| **FULL + TARGETED + FINAL review** | **30.4 min** | **40%** |
| FIXING | 7.4 min | 10% |
| **Total** | **~76 min, ~1.8M subagent tokens** | |

**Baseline — review-artifact length**, measured directly from `.heatwave/runs/jira-mode/`
this session (`wc -w`, and non-blank lines via `grep -cv '^[[:space:]]*$'`):

| Artifact | Words | Non-blank lines |
|---|---|---|
| 02-plan-review-1.md | 2450 | 167 |
| 04-plan-review-2.md | 1669 | 48 |
| 06-review-report-1.md | 3301 | 99 |
| 08-review-report-2.md | 1906 | 59 |
| 09-final-review.md | 2421 | 83 |
| **review-artifact total** | **11,747 words** | **456 non-blank lines** |

These are unbounded-prose STANDARD reviews — the premise R-132 caps.

**Follow-up method (free, no paid A/B).** The next real STANDARD run in this repo
carries per-stage wall in its run-record transition timestamps, and its review artifacts
are measured with the same `wc -w` / non-blank-line commands. No dedicated benchmark
arm is spent: the only corpus fixtures are eight single-module katas + one LIGHT fixture
(`benchmark/corpus`, `benchmark/corpus-tiering`), none of which classifies STANDARD
honestly (R-103a) — forcing them through STANDARD would measure tier inflation, at
~76 min / ~1.8M tokens per arm, on an unrepresentative ceremony. Cost of measurement: **$0 now**.

**Targets — labeled targets, never gates (an honest miss is a valid result):**

- review-cluster wall ≤ **60%** of the baseline 40% share (i.e. the review cluster stops being the dominant stage);
- review-artifact length ≤ **50%** of the baseline (≤ ~5,900 words / ≤ ~228 non-blank lines across the same review set);
- PLANNING cache-creation (input) tokens directionally lower, the planner substituting targeted reads for exploratory ones.

n will be stated when the follow-up run exists (n=0 today). These are directional
targets measured from run records, not asserted results — a fabricated hit is a Blocker (R-65).

## Addendum — 2026-09-10: hard corpus RAW validation sweep (run `hard-corpus`)

**Additive.** The locked scoring section and every figure above are unchanged.
This addendum records the RAW validation sweep for the new discriminating corpus
`benchmark/corpus-hard/` (see METHODOLOGY §7). Escape rate is over **graded rows
only**, per the locked rule.

### What ran

```
$ CORPUS=corpus-hard sh benchmark/run.sh --arm raw --tasks 14 --trials 3
$ awk -F, -f benchmark/summarize.awk benchmark/results/20260909T194129Z-raw.csv
raw: completed=42/42 escaped_defects=0/42 gradable (rate=0.000) oracle_pass=42/42 \
     outcomes[graded=42 timeout=0 escalated=0 error=0] mean_wall=31.3s total_cost=$9.7155 (over 42 costed rows)
```

- Model: session default `claude-opus-5[1m]` (a frontier model; `stage_model`
  column shows `claude-haiku-4-5;claude-opus-5[1m]` — the CLI's own sub-agent
  split, RAW arm, `HW_MODEL` unset, no model asymmetry). CLI 2.1.266,
  `raw_deadline=900s`.
- CSV: `benchmark/results/20260909T194129Z-raw.csv` (42 data rows + header).

### Completion integrity (locked E2 scoring)

All **42/42 rows are `graded`** — zero `timeout`, zero `error`, zero
`escalated`, zero `notes`. Every RAW run reached its own terminal state with
gradable code, so the escape denominator is the full 42. There are **no
completion failures to report separately** — the miss below is a pure
discrimination result, not a harness or flakiness artifact (the corpus is
deterministic: the free self-test is byte-identical across 5 runs).

### Per-task escape counts (n = 3 trials each; reported as n, un-averaged)

| task | defect class | graded | escaped | discriminating (≥2/3)? |
|---|---|---|---|---|
| h01-refund-idempotency | idempotency | 3/3 | 0/3 | no |
| h02-order-idempotency | idempotency/retry | 3/3 | 0/3 | no |
| h03-doc-ownership | authorization/security | 3/3 | 0/3 | no |
| h04-list-scope-leak | authorization/security | 3/3 | 0/3 | no |
| h05-seat-reservation-toctou | race/concurrency/security | 3/3 | 0/3 | no |
| h06-keyset-pagination | concurrency | 3/3 | 0/3 | no |
| h07-batch-save-atomic | error-handling/data-integrity | 3/3 | 0/3 | no |
| h08-import-rollback-cleanup | error-handling | 3/3 | 0/3 | no |
| h09-legacy-record-loader | backwards-compat | 3/3 | 0/3 | no |
| h10-booking-overlap-boundary | validation | 3/3 | 0/3 | no |
| h11-token-expiry-auth | authentication/security | 3/3 | 0/3 | no |
| h12-migration-idempotent | migration-safety | 3/3 | 0/3 | no |
| h13-retry-nonidempotent | retry | 3/3 | 0/3 | no |
| h14-required-param-compat | api-compat | 3/3 | 0/3 | no |

**Every one of the 14 tasks escaped 0/3.** No task trapped RAW in any trial.

### Disposition against the pre-registered threshold (frozen before any data; not reinterpreted)

The plan froze two conditions; **both must hold**. Stated separately:

1. **Corpus RAW escape rate ≥ 0.60 over graded rows** → measured **0.000**
   (0/42). **NOT MET.**
2. **≥ 8 of 14 tasks escaping in ≥ 2/3 trials** → measured **0/14**. **NOT MET.**

**Verdict: the hard corpus as built is NOT hard enough. The run does not claim a
discriminating corpus.** This is the honest-miss path (plan AC-F-07): reported
plainly, not softened. The RAW-vs-HEATWAVE delta remains UNCOMPUTABLE — this
corpus, like the frozen 8-task one, does not yet make a frontier RAW agent ship
wrong code. The corpus is **NOT frozen** (no freeze SHA recorded — the freeze
rule records a SHA only after the threshold is met).

### Why it missed, and what it tells us (evidence for the follow-on)

The miss is not flakiness, unfairness, or a broken oracle: the mechanism is
sound (42/42 graded, deterministic, fair inputs, `good`/`bad` discriminate under
`check-corpus.sh` and both fixture arms; FULL_REVIEW independently reproduced an
escape with five hand-written wrong solutions distinct from the shipped `bad.py`).
RAW (`opus-5`) simply implemented the correct contract on every task. Below are
the contributing levers the run makes visible. **A caveat governs all of them:
the data is n=3 per task and 0/42 across the board — a null with no variance — so
it can establish that each lever was *present*, but it CANNOT rank them or
apportion how much each contributed. No ordering among these is claimed or
supported.**

1. **The subtlety is spelled out in the SPEC (evidenced).** AC-F-10 (difficulty
   from the problem, not ambiguity) requires each SPEC to state its requirement
   explicitly — and several SPECs document the *crux primitive the defect turns
   on*, which is closer to telegraphing the trapped edge than merely stating a
   goal. Verbatim from the delivered files:
   `corpus-hard/h05-seat-reservation-toctou/SPEC.md` — "it returns `True` when it
   set the value and `False` when it did not" and "If the seat is already held,
   raise SeatTaken";
   `corpus-hard/h11-token-expiry-auth/SPEC.md` — "A token has expired when
   expires_at is less than or equal to now";
   `corpus-hard/h10-booking-overlap-boundary/SPEC.md` — "Intervals are half-open:
   [start, end) includes start and excludes end" and "Two intervals that touch
   only at an endpoint do not overlap." When the exact edge is a stated sentence,
   a frontier model implements it.

2. **The visible test ships inside the agent's surface (evidenced).** `run.sh`
   copies `repo/.` (which includes `repo/test_visible.py`) plus `SPEC.md` to the
   agent — see `run.sh:114-118` copy surface. So the agent reads the happy-path
   test: the exact call shape, argument order, and expected return types are
   demonstrated, not inferred, before it writes a line. Part of the contract is
   readable off the shipped test rather than reconstructed. (The test is
   *supposed* to be visible — it is the agent-visible check by design — but its
   presence is a difficulty-reducer a follow-on must account for, not just a
   fairness fixture.)

3. **`opus-5` self-verifies beyond the visible check (evidenced, and the most
   consequential).** On h05 trial 1 the model, unprompted, wrote its own
   adversarial probe reconstructing the *withheld* oracle's mechanism. Transcript
   `benchmark/results/transcripts/20260909T194129Z-raw/h05-seat-reservation-toctou-trial1/agent.ndjson`:
   after a first mis-written "Racy" probe it self-corrected —
   `class LyingGet(SeatStore): def get(self, seat_id): return None` with
   `s._holders["s1"] = "alice"` ("really held") — i.e. a store whose `get()`
   reports the seat free while another user holds it, which is exactly the
   oracle's `StaleSeatStore`/lost-update trap. It then asserted its own
   `reserve_seat` raises `SeatTaken`. The model independently generated the same
   adversarial case the withheld oracle uses and checked its code against it. A
   trap only the withheld oracle exercises does not stay withheld from a model
   that self-tests to the same standard.

4. **Single-function, self-contained shape (inferred, untested here).** The
   original diagnosis — a kata whose full contract fits one short SPEC gives the
   model nothing to lose track of — is plausible but this run cannot isolate it:
   every task in the corpus has that shape, so there is no multi-function /
   cross-file contrast to attribute the null to. It is listed as a lever to test,
   not a demonstrated cause.

**Open question the follow-on must design around (constraint, not answer).** If a
frontier model already performs its own adversarial self-verification on a
self-contained, fully-specified function (lever 3), then a corpus of that shape
**cannot measure what independent verification adds** — the model has already
done the equivalent of the withheld check itself, regardless of how subtle the
defect is. Making individual tasks subtler does not escape this: a subtler
single-function spec is still something the model can self-probe. The follow-on
must therefore find a shape where correct behavior is NOT establishable by the
model's own local self-testing — e.g. a defect whose manifestation depends on
state, callers, or interactions outside the unit the model holds in view — or the
null will recur. This is stated as a constraint on the redesign; it is **not** a
claim about any RAW-vs-HEATWAVE delta, which remains UNCOMPUTABLE at this n.

**All 14 tasks are hardening candidates** (none retained as discriminating).
Directions to test — not executed here (out of scope): multi-function / cross-file
surfaces where the critical interaction is not local to one stated sentence;
defects whose effect surfaces only across calls or components the model cannot
self-probe in isolation; withholding or restructuring the visible test's
information; and specs that state the requirement without naming the primitive
the defect turns on. Whether the arm model should be pinned (a weaker RAW model
would escape more, but the thesis is frontier reliability) is a methodology
decision for the driver, not a corpus change.

### Cost / wall vs estimate (now checkable — budget evidence for the §22 three-arm sweep)

| metric | plan estimate | measured | delta |
|---|---|---|---|
| runs | 42 | 42 | 0 |
| total cost | ~$8.82 | **$9.7155** | +$0.90 (+10.3%) |
| total wall | ~24.5 min | **21.9 min** (1316 s) | −2.6 min |
| mean/run | ~$0.21 / ~35 s | $0.2313 / 31.3 s | +$0.02 / −3.7 s |

RAW mean cost/run came in ~10% above the RESULTS.md history (~$0.21), consistent
with the frontier session model; wall was slightly under. The three-arm sweep's
Heatwave arms (STANDARD tier) remain the budget driver — this RAW figure does not
change that, but it confirms the RAW leg is cheap and the per-run cost basis for
budgeting the follow-on is ~$0.23/run at the current session model.
