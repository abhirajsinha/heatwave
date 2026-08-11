# Implementation Package — Benchmark Runtime Fix + Conclusive Rerun (Heatwave v4, Sub-project E2)

task_id: 2026-08-11-benchmark-runtime-fix | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

Plan: `docs/superpowers/plans/2026-08-11-benchmark-runtime-fix.md` (APPROVED at PLAN_REVIEW, 0B/0M, 5 Minor + 3 Nit carried).
Branch: `heatwave-v4-benchmark-runtime-fix` off `main` @ `5d4562f`.

## T1 — Diagnosis

### T1(a) — Archival pilot evidence (files re-read on this branch; paths absolute in repo)

1. **Killed runs left zero transcript (the R-113 red leg, archival per R-64).**
   `benchmark/results/transcripts/20260811T115121Z-heatwave/t01-pagination-trial1/agent.json` — **0 bytes**; `agent.err` — **0 bytes**.
   `benchmark/results/transcripts/20260811T124604Z-heatwave/t02-date-window-trial1/agent.json` — **0 bytes**; `agent.err` — **0 bytes**.
   (Verified by `ls -la` on this branch. `--output-format json` buffers until process exit; the watchdog KILL destroyed all in-flight evidence, and the pre-fix CSV schema has no outcome column — the row exists only with `notes=agent-nonzero-or-timeout`.) A faithful *executable* red (running the green command against pre-fix `run.sh`) is impossible cheaply: pre-fix `run.sh` hardcodes `HW_DEADLINE=2700` (line 10) and calls literal `claude` (line 52), so `CLAUDE_BIN=… HW_DEADLINE=20` has no effect on it; the faithful red would be a ~45-min paid run. **Per R-64 the red leg of AC-F-03 is this retained pilot-1 artifact** (plan-review F-005 disposition).
2. **The one terminal HEATWAVE pilot run argues slow-not-stuck.**
   `benchmark/results/transcripts/20260811T124604Z-heatwave/t03-log-summary-trial1/agent.json` (3740 bytes): `"subtype":"success"`, `"terminal_reason":"completed"`, `"num_turns":32`, `"duration_ms":2598441` (2598 s), `"total_cost_usd":12.3666`, result text: "Run `t03-log-summary` reached **APPROVED** — stopping point (1) of R-95, a terminal state." Protocol trail table in the result records **Intake … LIGHT** — i.e. even at LIGHT tier the full loop headless took ~43 min and ~$12.37.
3. **Strongest slow-not-stuck datum (plan-review F-008, folded in):** the killed rows in `benchmark/results/pilot-20260811.csv` are `t01 … 1,1,0,3236` and `t02 … 1,1,0,2709` — **visible_pass=1 AND oracle_pass=1 on both killed runs**. The code work was already complete and correct when the watchdog fired; what was still running was protocol ceremony (review/gate stages), not implementation. This is direct evidence for H1 (slow-but-progressing) over H2 (stall) / H4 (escalation loop).
4. **Kill-latency defect confirmed:** t01 recorded wall 3236 s against a 2700 s deadline — 536 s unaccounted; t02 2709 s (in-spec). See T1(b) for the fixed-path enforcement check.
5. **`claude -p` cannot block on stdin:** t03's session *exited* with an open OWNER question as its result ("say the word if you want them committed") — an ask-the-human moment ends the process, it does not idle.

### T1(b) — Instrumented probe (fresh evidence; time-capped, not run to completion)

One instrumented HEATWAVE arm on t01-pagination (pilot conditions: same `HW_PROMPT`, same flags except `--output-format stream-json --verbose` so evidence survives a kill; 30 s→15 s `state.yaml` sampler). **Hard-capped at ~10 min by operator instruction** (the archival evidence above already establishes slow-not-stuck; the probe's purpose was to *observe state progression*, not to buy a terminal state). Evidence harvested to `benchmark/results/transcripts/diag-20260811T165720Z/`:

- `diag-outcome.txt`: `arm_exit=143 wall=598s` (143 = 128+SIGTERM: the group TERM at the cap landed and the arm died within seconds — no TERM-resistance observed on the fixed-style kill path).
- **Progress, not hang:** `agent.ndjson` is 392 KB, 143 stream events, **38 tool_use events advancing continuously** across the whole 598 s (last tool: Bash). Zero gaps consistent with an API stall or an idle wait.
- **State progression:** intake completed in ~40 s (run dir created 16:58:01Z); the run then sat in `state: PLANNING` for the remaining ~9.5 min — *actively producing* `01-planning-document.md`, which was already **45,848 bytes** (15 FRs, edge-case ledger, verbatim-labelled fact claims) when the cap killed it. `state-timeline.log` shows `PLANNING` at every 15 s sample; `heatwave-runs/t01-pagination/` copy retained.
- **Tier finding (FR-5 relevant):** intake classified t01-pagination **STANDARD** (`run-record.yaml`: `tier_justification: "Implements the full behavioral contract of an imported helper (validation semantics + page boundary/partial-page behavior), not a single obvious edit; EXPRESS/LIGHT doubt resolves upward per R-103"`, `change_class: feature` — the stub raises `NotImplementedError`, so it is genuinely a feature-build, not a bugfix; the PLANNER independently confirmed both). The benchmark's "single-file fixes → LIGHT/EXPRESS" expectation does not hold for the stub-implementation tasks: **the protocol's own R-103 upward-doubt rule inflates them to STANDARD**, multiplying role dispatches (PLANNING → PLAN_REVIEW → IMPLEMENTING → FULL_REVIEW → FINAL_REVIEW, each a fresh subagent). ~10 min bought stage 1 of ≥5.
- **Cost:** no result event (killed run), so no `total_cost_usd` — recorded honestly as unmeasured; bounded by the 598 s cap (t03's measured rate, $12.37/2602 s, extrapolates to roughly $3 — estimate, not a measurement). Well inside the ≤$15/2700 s T1 bound.
- `autonomy: autopilot` sits in `run-record.yaml` as a recorded-only field — confirming it is a dead knob (core §2.5), so termination must come from the harness (T6 decision upheld).

### Diagnosis (recorded finding)

**H1 — slow-but-progressing — is the cause, compounded by H3 (tier inflation) on the feature-stub tasks.** The pilot HEATWAVE arm never hung: `claude -p` exits on owner-questions (fact 5), t03 reached APPROVED on its own at LIGHT in 2602 s, the killed t01/t02 runs had already produced complete, oracle-passing code (fact 3) with review ceremony still running, and the instrumented probe shows continuous tool activity with no stall while a STANDARD-tier ceremony (5+ full role dispatches) grinds through stage 1. H2 (mid-run stall) — no evidence in 143 streamed events; H4 (escalation loop) — no escalation state ever sampled. The t01 3236 s-vs-2700 s pilot overshoot (fact 4) remains unexplained from retained artifacts (0-byte transcripts) but is a kill-path defect class the fixed harness measures directly (AC-F-03 wall bound, verified below).

**Decision: harness-only fix. T9 (protocol change) NOT NEEDED** — no orchestrator headless defect exists: the loop terminates or progresses in every observed case; the failure was the *harness* losing the row and the evidence on deadline kill. `protocol/` stays untouched.

## Findings ledger disposition (plan-review Minors/Nits)

| Finding | Disposition |
|---|---|
| F-001 (Minor) — `RESULT_ESC` substring can override APPROVED | Fixed in classification: the `escalated` leg now requires `LAST_STATE != APPROVED`; parser matches the marker on the **final line** of the result only |
| F-002 (Minor) — harness crash/interrupt loses in-flight row | Fixed: `trap` on INT/TERM writes an `outcome=error,notes=interrupted` row for a started-but-unwritten trial |
| F-003 (Minor) — AC-F-04 empty-tier edge | AC amended in evidence: an empty `tier` passes only with the row unedited + RESULTS disclosure (mirrors the STANDARD/FULL clause) |
| F-004 (Minor) — orphan check blind to stub | Stub-test evidence greps for the stub path and `sleep 300` too, not just `claude -p` |
| F-005 (Minor) — R-113 red leg archival | Declared explicitly in T1(a) item 1 per R-64 |
| F-006 (Nit) — sanitizer mangles `claude-opus-5[1m]` | `[]` added to the parser's allowed charset |
| F-007 (Nit) — METHODOLOGY control 7 canary wording | Control 7 edited in T5 ("fails to reach a terminal state" → `outcome != graded`) |
| F-008 (Nit) — strongest slow-not-stuck datum uncited | Cited as T1(a) fact 3 |

## Task log

- **T1** — Diagnosis above. Commit `fcb4b82`. Deviation (coordinator-directed, recorded, not self-approved): the T1(b) instrumented run was hard-capped at ~10 min instead of the plan's run-to-terminal ≤2700 s bound — the archival evidence already established slow-not-stuck and the probe only needed to show state progression. It did (progress, no stall). Also: the probe ran `git init` in scratch (matching the real harness environment; the plan's snippet omitted it).
- **T2** — `benchmark/run.sh` reworked + new `benchmark/parse-result.py`. Commit `a0023c2`. `sh -n` OK; `py_compile` OK. Two departures from the plan's snippets, both defect fixes found while implementing (recorded as deviations, direction conservative):
  1. **Plan's sampler dies under `set -eu`** — `cat …/*/state.yaml` fails while the glob is unexpanded (before the driver creates the run dir), killing the sampler subshell on its first pass. Proven live: the T1 probe's identical sampler died after one sample. Fixed with `|| :` inside the loop.
  2. **Plan's parser emitted unquoted `KEY=value` for `eval`** with `;` and `$` in the allowed charset — `eval "ST_MODEL=m1;m2"` would *execute* `m2` as a command. Parser now emits single-quoted values and the allowed charset contains no quote, so the quoting cannot be broken.
  Also `STAGE_MODEL` uses `HW_MODEL` only for the heatwave arm (the plan's shared row line would have stamped `HW_MODEL` onto RAW rows when set; Data Design's own wording is per-arm).
- **T3** — `summarize.awk` replaced (spec-§3 scoring); unit CSV `benchmark/testdata/summarize-unit.csv` + committed expected output `summarize-unit.expected` (hand-checked: heatwave 1 graded/4 attempted, 0/1 escapes; raw 1/2 escapes). Commit `cb9e6c0`.
- **T4** — forced-outcome self-tests, all $0, all green (evidence below in AC-F-02/03/AC-N-03/04). Stubs committed: `benchmark/testdata/stub-timeout.sh`, `stub-escalate.sh`. Commit `274e280`.
- **T5** — METHODOLOGY.md: scoring section + unattended profile verbatim, §1 completion metric, §3 stream-json arm commands, §4 control 6 graceful timeout + control 7 canary wording (plan-review F-007), §5 threat updates (timeout-row scoring; unattended-prompt asymmetry disclosed). Commit `1fff465`.
- **T6** — config decision, no file change: `heatwave.config.example.yaml` untouched. The run-config `autonomy` field is RESERVED and consulted by nothing (core §2.5) — confirmed empirically in the T1 probe's `run-record.yaml` (`autonomy: autopilot   # RESERVED … recorded only, no branching`). Termination comes from the harness (unattended prompt + wall-clock), not a phantom config key. T1's finding did not contradict this; T9 not fired.
- **T7/T8** — see Rerun Results below.

## AC evidence

### AC-F-01 (diagnosis recorded) — PASS
Diagnosis section above names H1 (+H3) with archival facts (0-byte `agent.json` paths quoted with byte sizes) and fresh probe evidence (`state-timeline.log` all-PLANNING samples, 38 advancing tool_use events, 45,848-byte in-progress planning artifact), plus the recorded harness-only/T9-not-needed decision. Every quoted file exists under `benchmark/results/transcripts/diag-20260811T165720Z/` (local, transcripts dir is gitignored by E's convention — reviewer verifies on this machine).

### AC-F-02 (no hang, escalation terminal) — PASS
Command: `CLAUDE_BIN=$PWD/benchmark/testdata/stub-escalate.sh sh benchmark/run.sh --arm heatwave --only t01-pagination`
CSV row (verbatim, `benchmark/results/20260811T171304Z-heatwave.csv`):
```
20260811T171304Z-heatwave,t01-pagination,heatwave,1,escalated,1,LIGHT,stub-model,0,0,0,1,0,escalated; state=ESCALATED
```
Orphan checks immediately after (stub-aware per plan-review F-004): `pgrep -f 'claude -p'` → empty (exit 1); `pgrep -f stub-escalate.sh` → empty (exit 1).

### AC-F-03 (graceful terminal timeout; R-113 reproduction) — PASS
**Red (archival per R-64, plan-review F-005 disposition):** pilot-1 deadline kill produced 0-byte `agent.json`/`agent.err` (paths in T1(a) item 1) and a row with no outcome column; the executable red is impossible against pre-fix `run.sh` (hardcoded deadline, literal `claude`) without a ~45-min paid run.
**Green:** `CLAUDE_BIN=$PWD/benchmark/testdata/stub-timeout.sh HW_DEADLINE=20 sh benchmark/run.sh --arm heatwave --only t01-pagination`
CSV row (verbatim, `benchmark/results/20260811T171226Z-heatwave.csv`):
```
20260811T171226Z-heatwave,t01-pagination,heatwave,1,timeout,0,,,0,0,0,20,,timeout; last_state=none; agent-nonzero
```
`wall_secs=20` ∈ [20, 40]; `notes` contains `last_state=`; transcript dir listing: `agent.err agent.ndjson deadline.expired heatwave-runs install.log oracle.log state-timeline.log visible.log` (marker + streamed transcript copied back). Orphans: `pgrep -f 'claude -p'`, `pgrep -f stub-timeout.sh`, `pgrep -f 'sleep 300'` → all empty (exit 1).
**Interrupt residual (plan-review F-002):** a signal to the harness mid-trial (stub run, TERM at 60 s from the tool timeout) recorded `…,error,0,,,,,,60,,interrupted` (`benchmark/results/20260811T171344Z-heatwave.csv`) with zero orphans. Honest nuance: the earlier SIGINT sent while `sh` was blocked in `wait` was not acted on until the TERM arrived — trap delivery during a foreground wait is shell-dependent; the row-never-lost guarantee held on the signal that actually terminated the harness.

### AC-N-02 (zero new dependencies) — PASS
`grep -E '^import|^from' benchmark/parse-result.py` → `import json`, `import re`, `import sys` (stdlib only). Diff introduces no package manifest, no install step, no binary (stubs are committed `/bin/sh` scripts used only via the disclosed `CLAUDE_BIN` seam).

### AC-N-03 (deterministic free path) — PASS
`sh benchmark/run.sh --arm fixture-good` → `fixture-good: completed=8/8 escaped_defects=0/8 gradable (rate=0.000) oracle_pass=8/8 outcomes[graded=8 timeout=0 escalated=0 error=0]` (`20260811T171213Z-fixture-good.csv`).
`sh benchmark/run.sh --arm fixture-bad` → `fixture-bad: completed=8/8 escaped_defects=8/8 gradable (rate=1.000) oracle_pass=0/8 …` (`20260811T171215Z-fixture-bad.csv`). Both sweeps together: **4 s wall** (« 5 min).

### AC-N-04 (no lost rows, by construction) — PASS
Row counts: fixture-good 8 started/8 rows; fixture-bad 8/8; stub-timeout 1/1; stub-escalation 1/1; interrupt test 1 started/1 row (`interrupted`). Classification `case` is total: fixtures → `graded`; marker → `timeout`; ESCALATED/ABANDONED/final-line marker (and not APPROVED) → `escalated`; success+APPROVED (or raw success) → `graded`; else → `error`. No fall-through without assignment (code: `benchmark/run.sh` classification block).

### awk unit (Testing Strategy item 5) — PASS
`awk -F, -f summarize.awk testdata/summarize-unit.csv` output == committed `testdata/summarize-unit.expected`; hand-check in T3 note above.

<!-- AC-RERUN-PENDING: AC-F-04..08, AC-N-01 land with T7/T8 -->

## Rerun Results (T7)

<!-- RERUN-PENDING -->
