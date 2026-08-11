# Review Report

task_id: 2026-08-11-benchmark-runtime-fix | artifact_type: review-report | iteration: 2 | review_type: FINAL_REVIEW | produced_by: REVIEWER (claude-opus-4-8) | timestamp: 2026-08-11

## Verdict

GATE_MET — **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 2 (carried, non-gating)

## Scope Evaluated

FINAL_REVIEW (completion gate, §4.7/§8) of sub-project E2 on branch `heatwave-v4-benchmark-runtime-fix` (HEAD `8a7407f`) vs base `main`. FRESH context — I authored neither the code nor the prior FULL_REVIEW. Read: plan, spec, plan-review E2, prior FULL_REVIEW E2, impl package, the real `git diff main...HEAD`, `run.sh`, `parse-result.py`, `summarize.awk`, METHODOLOGY.md, RESULTS.md, the committed `rerun-20260811.csv`, testdata stubs/fixtures, and the retained transcripts. All FULL-tier machine gates re-run from scratch by me (R-118(b)) — no carried verdicts.

## Scope Changes

None. Diff is `benchmark/**` + `docs/**` only; T9 protocol branch not fired.

## Reconciliation

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| FULL F-001 (Nit, parser charset `;$` → `python3 -c`) | Open (hardening) | Open, non-gating | Re-confirmed non-exploitable: sanitizer strips quotes/parens/space, worst case a syntax error swallowed by `|| true` at run.sh:180; COST is only ever decimal. Backlog. |
| FULL F-002 (Nit, `on_int` trap during foreground `wait`) | Open (disclosed residual) | Open, non-gating | Row-never-lost held on the signal that actually terminated the harness (interrupted row present in rerun CSV). External to core fix; disclosed. |

Plan-review's 5 Minor + 3 Nit were all closed in the impl ledger and spot-verified by the FULL reviewer; I re-verified the load-bearing ones (F-001 APPROVED-wins at run.sh:145-147; F-006 `[]` charset at parse-result.py:33; single-quoted eval output at parse-result.py:34-37). Late findings: None.

## Acceptance Status

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 (diagnosis recorded) | Satisfied | `diag-20260811T165720Z/` present: `diag-outcome.txt` `arm_exit=143 wall=598s`, `agent.ndjson`, `state-timeline.log`, `heatwave-runs/`. Diagnosis names H1(+H3) slow-not-stuck with archival 0-byte paths + probe evidence; harness-only decision recorded. |
| AC-F-02 (escalation terminal) | Satisfied | My rerun: `…,escalated,1,LIGHT,stub-model,0,0,0,0,0,escalated; state=ESCALATED`; `pgrep -f 'claude -p'` and `stub-escalate.sh` both empty. |
| AC-F-03 (graceful timeout; R-113) | Satisfied | My rerun (`HW_DEADLINE=20`): `…,timeout,0,,,0,0,0,21,,timeout; last_state=none; agent-nonzero`; wall 21 ∈ [20,40]; `deadline.expired`+`agent.ndjson` copied back; no `claude -p`/stub/`sleep 300` orphans. Red leg = archival 0-byte pilot artifact per R-64 (confirmed 0 bytes). |
| AC-F-04 (tier recorded, not forced) | Satisfied w/ disclosure | Rerun HEATWAVE tiers = STANDARD (timeout) + empty (interrupted), both unedited; STANDARD-not-LIGHT disclosed as intake finding, empty tier as `—`. `run.sh` has no tier flag. |
| AC-F-05 (conclusive rerun, no lost rows) | Satisfied | 10 started (8 raw + 2 heatwave) = 10 CSV rows; outcomes ∈ {graded×8, timeout×1, error×1}; real timeout transcript copied-back state.yaml = tier STANDARD/state PLAN_REVIEW, matching the row. Zero lost/0-byte. |
| AC-F-06 (honesty) | Satisfied | Forbidden-grep: 6 hits, every one inside a caveated summary/table/no-delta sentence; no `%`, no "fewer bugs"; delta explicitly refused (RESULTS.md:11,88); numbers trace to CSV. |
| AC-F-07 (oracle isolation) | Satisfied | Three fatal asserts present (scratch-outside-repo, withheld-leak, manifest-mutation); sweeps completed with no FATAL; my grep over rerun `agent.ndjson` = zero oracle/corpus hits. |
| AC-F-08 (no regression) | Satisfied | `git diff --name-only` = benchmark/ + docs/ only; **no protocol/, no PROTOCOL.md**; `build-protocol.sh --check` → `OK` (exit 0); `check-corpus.sh` → ALL TASKS PASS (8/8). All re-run by me. |
| AC-N-01 (bounded spend) | Satisfied | Recorded ≈$8.17 (RAW $1.727 + HEATWAVE timeout $6.44); breaker constants unchanged, never tripped. |
| AC-N-02 (zero new deps) | Satisfied | `parse-result.py` imports json/re/sys only; diff adds no manifest/install/binary. |
| AC-N-03 (deterministic free path) | Satisfied | My sweeps: fixture-good 8/8 graded 0 escapes; fixture-bad 8/8 graded 8/8 escapes; seconds of wall. |
| AC-N-04 (no lost rows, by construction) | Satisfied | Classification `case` total (no fall-through without assignment); every self-test rows-written == tasks-started. |

## §8.3 Production-readiness checklist

| Item | Status | Evidence |
|---|---|---|
| protocol/ UNTOUCHED | PASS | diff name-only grep for `PROTOCOL.md`/`^protocol/` → NONE. |
| build-protocol.sh drift | PASS | `OK: PROTOCOL.md matches protocol/ shards` (exit 0). |
| check-corpus.sh 8/8 | PASS | ALL TASKS PASS (exit 0). |
| E's F-001 oracle isolation preserved | PASS | All three asserts intact; detective grep zero hits. |
| corpus unchanged | PASS | Freeze `cfeaf8f`; manifest asserted identical in every sweep (no FATAL). |
| no secrets (R-121) | PASS | gitleaks present → `gitleaks detect` over `main..HEAD`: 9 commits, no leaks found (exit 0). Diff secret-grep clean. |
| static (sh -n, py_compile) | PASS | Both OK. |
| awk unit | PASS | `diff` vs committed expected → MATCH. |
| FULL_REVIEW Nits dispositioned | PASS | Both non-gating (disclosed/backlog); see Reconciliation. |

## Findings

Two carried Nits, both non-gating (canonical: prior FULL_REVIEW E2 ledger). F-001 parser-charset hardening; F-002 trap-during-wait residual. Neither blocks completion; may be picked up opportunistically. No new findings.

## Verification Log

Machine evidence (R-110): tests rung — sh -n / py_compile / awk-unit / fixture sweeps / two stub-seam forced-outcome tests all PASS (re-run by me). secrets rung — gitleaks PASS (0 leaks). sast/mutation — NOT AVAILABLE (shell/awk/Markdown; no declared tool) — no AC depends on them.

| Item | Method (re-run by me) | Result |
|---|---|---|
| diff scope | `git diff main...HEAD --name-only` | benchmark/ + docs/ only; zero protocol/ or PROTOCOL.md |
| build drift | `sh build-protocol.sh --check` | `OK` (exit 0) |
| corpus gate | `sh benchmark/check-corpus.sh` | ALL TASKS PASS (8/8) |
| static | `sh -n run.sh`; `py_compile parse-result.py` | both OK |
| awk unit | `diff` vs `summarize-unit.expected` | MATCH |
| fixture-good | `run.sh --arm fixture-good` | 8/8 graded, 0 escapes |
| fixture-bad | `run.sh --arm fixture-bad` | 8/8 graded, 8/8 escapes |
| stub timeout | `CLAUDE_BIN=stub-timeout HW_DEADLINE=20 run.sh --arm heatwave --only t01` | row `timeout,0,…,21,,…last_state=none`; marker+transcript copied; no orphans |
| stub escalate | `CLAUDE_BIN=stub-escalate run.sh --arm heatwave --only t01` | row `escalated,1,LIGHT,stub-model`; no orphans |
| secrets | `gitleaks detect --log-opts main..HEAD` | 9 commits, no leaks (exit 0) |
| forbidden-grep/delta | `grep -nE '0/[0-9]|%|fewer bugs' RESULTS.md` | all hits caveated; no `%`; delta explicitly refused |
| doc sync | `grep -c` HW_UNATTENDED / HW_PROMPT / RAW_PROMPT | verbatim, 1 copy each in run.sh + METHODOLOGY |
| oracle isolation | grep rerun agent.ndjson | zero hits |

Not verified (accepted as recorded artifacts, R-64): the paid RAW×8 and real HEATWAVE timeout/interrupt runs — transcripts exist locally, numbers trace to the CSV, and re-running costs real spend the dispatch forbids. The R-113 red leg is the archival 0-byte pilot transcript (confirmed 0 bytes), not an executable red.

## Summary

The core fix holds at the completion bar. **Termination guarantee: confirmed** — 10 started arms → 10 recorded rows, every outcome in {graded,timeout,escalated,error}, zero lost/0-byte; the marker is touched before SIGTERM (run.sh:45-46); the real HEATWAVE timeout row records tier=STANDARD, state=PLAN_REVIEW, cost $6.44, elapsed 1201 s despite the kill, with its copied-back state.yaml matching. My own zero-cost stub reruns reproduced terminal timeout and escalated rows with zero orphan processes. **Result honesty: holds** — escape rate is awk-computed over graded rows only, timeouts/errors excluded from the denominator; completion rate + outcome table present; no RAW-vs-HEATWAVE delta claimed (explicit refusal); forbidden-grep clean (all hits caveated); no fabricated rows. The honest finding — headless HEATWAVE ~43 min / ~$12 at LIGHT, 1 graded / 5 attempted all-time, intake inflates these stub tasks to STANDARD — is stated plainly up front. **Scope: clean** — protocol/ untouched, drift OK, corpus 8/8, oracle isolation preserved, gitleaks clean. Two Nits carry, both hardening/already-disclosed; neither gates. All 12 ACs Satisfied with evidence.

## Gate

**APPROVED** — GATE_MET (0 open Blockers, 0 open Majors, all ACs Satisfied, §8.3 checklist complete with evidence). Approved by REVIEWER claude-opus-4-8, 2026-08-11.
