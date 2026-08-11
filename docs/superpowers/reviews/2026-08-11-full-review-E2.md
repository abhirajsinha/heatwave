# Review Report

task_id: 2026-08-11-benchmark-runtime-fix | artifact_type: review-report | iteration: 1 | review_type: FULL_REVIEW | produced_by: REVIEWER (claude-opus-4-8) | timestamp: 2026-08-11

## Verdict

GATE_MET — **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 2

## Scope Evaluated

FULL review of the E2 implementation on branch `heatwave-v4-benchmark-runtime-fix` vs base `main`. Fresh context — I did not author any of this. Reviewed: plan, spec, plan-review, impl package, the real `git diff main...HEAD`, and the actual artifacts (`run.sh`, `parse-result.py`, `summarize.awk`, `METHODOLOGY.md`, `RESULTS.md`, the rerun CSV, testdata stubs, and the retained transcripts under `benchmark/results/transcripts/`). Focus per dispatch: termination guarantee, result honesty, diagnosis soundness, scope/regression. I re-ran every free/deterministic check myself (awk unit, both fixture sweeps, both zero-cost stub seams) rather than trusting the package.

## Reconciliation

Iteration 1 — no prior FULL_REVIEW findings. The 5 Minor + 3 Nit from PLAN_REVIEW are all dispositioned in the impl package's findings ledger; I spot-verified the load-bearing ones in code (F-001 APPROVED-wins precedence at run.sh:145; F-006 `[]` charset at parse-result.py:33; F-002 interrupt trap at run.sh:93–97; F-004 stub-aware orphan greps in my own reruns).

## Acceptance Status

All ACs VERIFIED-with-evidence or honestly-NOT-with-disclosure (R-66):

- **AC-F-01** (diagnosis recorded) — PASS. `diag-20260811T165720Z/` present locally: `diag-outcome.txt` `arm_exit=143 wall=598s`, `agent.ndjson` 392 KB with 38 tool_use events, `state-timeline.log` = 27 PLANNING samples, `run-record.yaml` tier STANDARD.
- **AC-F-02** (escalation terminal) — PASS. I re-ran the stub: row `escalated,1,LIGHT,stub-model,...,escalated; state=ESCALATED`; `pgrep` clean for `claude -p` and stub.
- **AC-F-03** (graceful terminal timeout; R-113) — PASS. I re-ran the sleep-stub at `HW_DEADLINE=20`: row `timeout,0,...,21,,timeout; last_state=none`; wall 21 ∈ [20,40]; marker + streamed transcript copied back; no orphans (`claude -p`, stub, `sleep 300` all empty). Red leg is the archival 0-byte pilot artifact per R-64 — declared.
- **AC-F-04** (tier recorded, not forced) — PASS-with-disclosure. Rerun HEATWAVE tiers = STANDARD (timeout row) + empty (interrupted row); both unedited; STANDARD-not-LIGHT disclosed as an intake finding, empty-tier disclosed via the F-003 carve-out. `run.sh` has no tier flag.
- **AC-F-05** (conclusive rerun, no lost rows) — PASS. 10 started (8 raw + 2 heatwave) = 10 CSV rows; every outcome ∈ {graded,timeout,escalated,error}; zero lost/0-byte.
- **AC-F-06** (honesty) — PASS. Forbidden-grep hits all sit inside caveated summary/table/no-delta sentences; no `%`, no "fewer bugs"; no delta claimed (explicit refusal at RESULTS.md:88–91); every headline number traces to a CSV row/aggregate.
- **AC-F-07** (oracle isolation) — PASS. `scratch_root` outside repo; manifest asserted identical (sweeps completed, no FATAL); my own grep over the real rerun `agent.ndjson` = zero oracle/corpus hits.
- **AC-F-08** (no regression) — PASS. `git diff --name-only` = `benchmark/**` + `docs/**` only; **no `protocol/**`, no `PROTOCOL.md`**; `build-protocol.sh --check` → `OK` (exit 0); `check-corpus.sh` → ALL TASKS PASS (8/8). Both re-run by me.
- **AC-N-01..04** — PASS. Recorded spend ≈$8.17, breaker never tripped; `parse-result.py` imports json/re/sys only; fixture sweeps 4 s wall, 8/8 graded good / 8/8 escapes bad; classification `case` total, no fall-through.

## Findings

### F-001 (Nit, security-hardening) — parser charset admits `;` and `$`, which then flow unquoted into `python3 -c "print(...)"`
`benchmark/parse-result.py:33` allows `;$` in the sanitized charset; `benchmark/run.sh:180` interpolates the resulting `$COST` unquoted into a python expression. Not exploitable — the same sanitizer strips `()`, quotes, and space, so an agent-controlled `total_cost_usd` can at worst produce a syntax error that `|| true` swallows (CUM_COST unchanged); the `eval` at run.sh:65 is single-quoted and safe. Still, `COST` is only ever a decimal — restricting its charset to `[0-9.]` (or quoting the run.sh:180 interpolation) removes a needless smell in a public artifact. Direction: hardening only.

### F-002 (Nit, error-handling) — `on_int` trap cannot fire during the foreground `wait`
`benchmark/run.sh:93–97` — as the impl package honestly discloses, a signal delivered while `sh` blocks in `wait "$pid"` is shell-dependent and may not run the trap until the arm's own kill path lands. The row-never-lost guarantee held on the signal that actually terminated the harness (verified: interrupted row `error,0,...,192,,interrupted` exists in the rerun CSV). Residual and external to the core fix; already dispositioned. No action required.

## Verification Log

| Check | Method (re-run by me) | Result |
|---|---|---|
| diff scope | `git diff main...HEAD --name-only` | benchmark/ + docs/ only; zero protocol/ or PROTOCOL.md |
| build drift | `sh build-protocol.sh --check` | `OK: PROTOCOL.md matches protocol/ shards` (exit 0) |
| corpus gate | `sh benchmark/check-corpus.sh` | ALL TASKS PASS (8/8) |
| static | `sh -n run.sh`; `py_compile parse-result.py` | both OK |
| awk unit | `diff <(awk -f summarize.awk testdata/summarize-unit.csv) …expected` | MATCH |
| fixture-good | `run.sh --arm fixture-good` | 8/8 graded, 0 escapes |
| fixture-bad | `run.sh --arm fixture-bad` | 8/8 graded, 8/8 escapes |
| stub timeout | `CLAUDE_BIN=stub-timeout HW_DEADLINE=20 run.sh --arm heatwave --only t01` | row `timeout`, wall 21, marker copied, **no orphans** |
| stub escalate | `CLAUDE_BIN=stub-escalate run.sh --arm heatwave --only t01` | row `escalated` terminal=1 LIGHT, **no orphans** |
| marker-before-TERM | read run.sh:44–46 | `: > "$DL_MARK"` precedes `kill -TERM` |
| real timeout row | read rerun CSV:11 + copied state.yaml | `timeout,0,STANDARD,claude-opus-5[1m],…,1201,6.43996775,…last_state=PLAN_REVIEW` — tier+state+cost+elapsed all recorded despite kill |
| diagnosis evidence | grep diag run-record/state-timeline/ndjson | tier STANDARD recorded (not asserted); 27 PLANNING samples + 38 tool_use = slow-not-stuck |
| oracle isolation | grep rerun agent.ndjson | zero hits |
| METHODOLOGY sync | grep HW_UNATTENDED | verbatim, 1 copy each in run.sh + METHODOLOGY |
| forbidden-grep / delta | grep RESULTS.md | all hits caveated; no `%`; delta explicitly refused |

Not independently reproducible (accepted as recorded artifacts, R-64): the paid RAW×8 and real HEATWAVE timeout/interrupt runs — their transcripts exist locally, numbers trace to the CSV, and re-running would cost real spend the dispatch forbids.

## Summary

The core fix holds. **Termination guarantee: confirmed** — 10 started arms → 10 recorded rows, every outcome in {graded,timeout,escalated,error}, zero lost/0-byte rows; marker touched before SIGTERM; the real HEATWAVE timeout row records tier=STANDARD, state=PLAN_REVIEW, cost $6.44, elapsed 1201 s despite the kill. My own zero-cost stub reruns reproduced terminal timeout and escalated rows with zero orphan processes. **Result honesty: holds** — escape rate is computed over graded rows only (timeouts/errors excluded from the denominator, awk-enforced), completion rate + outcome table present, no RAW-vs-HEATWAVE delta claimed (explicit refusal), no fabricated rows (each traces to a transcript), forbidden-grep clean. The honest finding — HEATWAVE slow/expensive (~43 min/~$12 at LIGHT, completion 1 graded / 5 attempted all-time) — is stated plainly up front. **Diagnosis: evidence-backed, not asserted** — tier=STANDARD is recorded in both the diagnostic run-record and the real timeout run's state.yaml; slow-not-stuck is grounded in continuous tool activity + already-oracle-passing killed pilot code. **Scope: clean** — protocol/ untouched (T9 not fired), drift OK, corpus 8/8, E's oracle isolation preserved. Two Nits, both hardening/already-disclosed, neither blocks.

## Gate

**APPROVED** — GATE_MET (0 Blockers, 0 Majors). The two Nits may be picked up opportunistically; neither gates completion.
