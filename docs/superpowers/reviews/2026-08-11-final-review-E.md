# Review Report

task_id: 2026-08-11-credibility-benchmark | artifact_type: review-report | iteration: 3 | review_type: FINAL_REVIEW | produced_by: REVIEWER (claude-fable-5, fresh context — reconciled from prior reports per R-4) | timestamp: 2026-08-11

## Verdict

**GATE_MET — APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 1 (deferred by REVIEWER) | Nit: 1

Approval granted per R-81/R-82 by REVIEWER (claude-fable-5), 2026-08-11.

## Scope Evaluated

Full scope (R-118 degrade: working tree dirty at dispatch — the uncommitted file is the prior reviewer's own iteration-2 appendix, see FR-2 — so this review evaluated the entire branch, not a delta). Branch `heatwave-v4-subproject-e` vs `main`: 71 files, +2716, confirmed confined to `benchmark/**`, one `.gitignore` hunk, and E docs under `docs/superpowers/` + `docs/specs/` (filter `git diff main...HEAD --name-only | grep -v` those prefixes → empty). Adversarial focus per dispatch: result honesty on a public credibility benchmark, no fabrication, oracle isolation, plus §8.3 item-by-item (FULL tier). Every machine gate re-run from scratch by this reviewer (R-117 safety clause) — no verdict carried over from iterations 1–2.

## Scope Changes

None (R-49). The one out-of-delta read (working-tree diff of `full-review-E.md`) was forced by the dirty-tree degrade and is recorded here.

## Reconciliation

All five iteration-1 findings re-confirmed closed from the files (not from the iteration-2 report's claims):

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-1 (Major — killed HEATWAVE arms counted as headline passes) | Closed (iter 2) | **Closed — re-verified** | `benchmark/RESULTS.md:6-11` leads with the blockquote: delta **UNCOMPUTABLE**; RAW terminal n=4 (0/4), HEATWAVE terminal n=1 (t03, 0/1); t01/t02 "watchdog-killed before reaching a terminal state and are NOT completed runs — they must not be counted as passes." Pilot table has `terminal?` column (`NO — watchdog-killed`, lines 37-38); headline table terminal-only with delta row "UNCOMPUTABLE" (line 50); killed rows quarantined "supplementary observation only ... Do not quote '0/3 vs 0/3'" (52-60); NOT-RUN ledger includes `RAN, NON-TERMINAL` row + re-run commands (94-108). Reviewer grep for surviving `0/3` across benchmark/ + impl package + README: only (a) labeled verbatim `summarize.awk` output carrying the F-1 qualification note (impl pkg :110-116) and (b) the do-not-quote warning itself (RESULTS.md:58). No surviving statement anywhere implies a computable delta. |
| F-2 (Minor — vacuous grep on killed rows) | Closed (iter 2) | Closed — re-verified | RESULTS.md:74-82 and impl pkg AC-F-10(b) qualification: grep meaningful for the 5 non-empty-transcript rows; hw t01/t02 "N/A — non-terminal", preventive control + watcher samples. Matches reality: reviewer `wc -c` → both killed `agent.json` = 0 bytes. |
| F-3 (Minor — agent-modifiable visible check) | Closed (iter 2) | Closed — re-verified | `run.sh:118-122` re-copies both `test_oracle.py` and `repo/test_visible.py` post-arm, comment cites the finding; METHODOLOGY control 8 matches. Regression: reviewer fixture-good 0/8 escapes ×2 identical, fixture-bad 8/8. |
| F-4 (Nit — watchdog overshoot) | Closed (iter 2) | Closed — re-verified | `run.sh:36-42`: monotonic `date +%s` elapsed check; code read; exercised in reviewer sweeps. |
| F-5 (Nit — stale diff-scope line) | Closed (iter 2) | Closed — re-verified | Impl pkg :24 restates 69 files/+2479 at T12 + notes post-FIXING commits; consistent with current 71/+2716 (the two extra files are the committed review + fix report). |

Late findings: FR-1 and FR-2 below — both new to this iteration, both about material outside the FIXING delta (README caveat sentence; run-trail bookkeeping), which is why iterations 1–2 did not surface them; neither contradicts a prior pass.

## Acceptance Status

All commands below re-run by this reviewer in this session unless marked otherwise.

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | `sh benchmark/check-corpus.sh` → 8/8 tasks PASS all 5 legs, `check-corpus: ALL TASKS PASS`, exit 0. Copy surface `repo/.` + `SPEC.md` only (`run.sh:97-98`) + fatal leak assert (`run.sh:100-102`) |
| AC-F-02 | Satisfied | Same run: `good-oracle` 8/8 PASS |
| AC-F-03 | Satisfied | Same run: `bad-oracle` 8/8 + `bad-visible` 8/8; fixture-bad sweep → `escaped_defects=8/8 escape_rate=1.000` |
| AC-F-04 | Satisfied | Three reviewer sweeps, no `FATAL: corpus originals mutated`; fixture-good ×2 → byte-identical summary lines |
| AC-F-05 | Satisfied | 7 pilot rows (4 raw + 3 heatwave) in `pilot-20260811.csv`; per-row transcript dirs on disk with `agent.json/agent.err/visible.log/oracle.log` (+`install.log` heatwave); t03 `agent.json` parsed: `subtype: success, 32 turns, $12.3666`. Caveat (disclosed everywhere): only 1 of 3 heatwave rows terminal |
| AC-F-06 | Satisfied | Headline is terminal-only (0/4 vs 0/1, delta UNCOMPUTABLE); `summarize.awk` graded-as-is aggregate labeled as not-headline (impl pkg note); NOT-RUN rows absent from every denominator, listed with exact completion commands (RESULTS.md:96-99). This is the AC iteration 1 failed; the fix is verbatim-verified above (F-1) |
| AC-F-07 | Satisfied | Reviewer fixture-good ×2: identical `graded=8 oracle_pass=8/8 escaped_defects=0/8`; pilot commands verbatim in METHODOLOGY §6 |
| AC-F-08 | Satisfied | Reviewer ran `--tasks 2 --trials 2` → `graded=4 oracle_pass=4/4` |
| AC-F-09 | Satisfied | `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0; diff-scope filter → empty outside benchmark/.gitignore/E-docs; zero `protocol/`/`PROTOCOL.md`/installer/adapter changes |
| AC-F-10 | Satisfied | (a) 3 pilot `scratch-root.txt` records all `/var/folders/.../T//hw-bench.*` "(outside /Users/abhirajsinha/Projects/heatwave)"; fatal assert `run.sh:80`; (b) reviewer grep `oracle`/`benchmark/corpus` over all pilot `agent.json`+`agent.err` → zero hits (exit 1); vacuous-for-killed-rows caveat correctly disclosed (F-2); (c) oracle `cp` at `run.sh:121` strictly after `run_agent` returns — code read |
| AC-N-01 | Satisfied | Reviewer imports grep → stdlib only (`json,os,re,tempfile,unittest,datetime` + task modules); harness commands audit matches plan list; install skip-path evidence in heatwave `install.log` |
| AC-N-02 | Satisfied | `sh -n` both scripts → OK; both executed under /bin/sh in this session. shellcheck NOT AVAILABLE — declared (R-64), fallback per plan |
| AC-N-03 | Satisfied | Breaker code `run.sh:63-70,136-143`; pilot 4+3 ≤ 8×1; watchdog walls 3236/2709 s in CSV; escape + canary-rule trip disclosed with real numbers (RESULTS.md:106-113) |
| AC-N-04 | Satisfied | Reviewer fixture-good sweeps each completed in seconds (≪ 300 s) |
| AC-N-05 | Satisfied | `git ls-files benchmark/results/` → `.gitkeep` + `pilot-20260811.csv` only; `git status --porcelain benchmark/results/` empty after 5 reviewer sweeps; `ls $TMPDIR/hw-bench.*` → none (trap-clean holds) |

**15/15 Satisfied. Zero Unverified (R-66 clear).**

## Findings

Canonical detail here (no separate ledger file supplied to this fresh context; prior findings tracked in the iteration 1+2 report).

### FR-1 — MINOR — README pilot-scale wording overstates executed n | Status: Deferred (REVIEWER)

`benchmark/README.md:35-36`: "the pilot is n=8, single-trial" — the pilot *design* is 8×1, but the executed pilot completed RAW terminal n=4 and HEATWAVE terminal n=1. The sentence is a caveat (it weakens, not strengthens, the numbers) and immediately directs readers to RESULTS.md, which is exact — so it cannot mislead anyone into a computable delta, and it does not touch the headline. Deferred as non-blocking by this reviewer (R-5/R-6): reword in the next docs commit to "the pilot design is 8 tasks × 1 trial; the executed pilot completed fewer — see RESULTS.md".

### FR-2 — NIT — Iteration-2 review appendix uncommitted

`docs/superpowers/reviews/2026-08-11-full-review-E.md`'s iteration-2 TARGETED_REVIEW section (the GATE_MET verdict) exists only in the working tree; the committed copy (`fc58942`) ends at iteration 1. Artifacts govern and the artifact exists on disk, but the run trail is incomplete in git. Driver: commit it together with this report. (This dirty file also triggered the R-118 full-scope degrade, honored above.)

## Production Readiness Checklist (§8.3, FULL tier — item by item)

| Item | Status | Evidence |
|---|---|---|
| Acceptance criteria | **PASS** | 15/15 individually Satisfied above, each with re-run or first-hand evidence; none Unverified |
| Plan conformance | **PASS** | Impl matches the approved iteration-2 plan (T1–T12); corpus t01/t03 verbatim from plan; 4 deviations (D-1 operator cost steer via pre-committed escape, D-2 .gitignore restore, D-3 empty freeze marker, D-4 watchdog overshoot) all recorded with rationale, none self-approving a skip |
| In-scope review categories | **PASS** | Result honesty, fabrication, oracle isolation, rigging, harness correctness, docs — covered across FULL_REVIEW iter 1 + this pass; anti-rigging spot-check (iter 1) found the corpus if anything biased *against* the protocol arm |
| Tests | **PASS** | All declared suites executed by this reviewer this session: check-corpus 8/8 exit 0; fixture-good ×2 identical 0/8 escapes; fixture-bad 8/8 escapes rate 1.000; scaling 4/4; outputs above |
| Non-functional targets | **PASS** | NFR-1 zero deps (imports + command audit); NFR-2 cost/wall bounds held (CSV walls, breaker never tripped, $13.22 total ≪ $60); NFR-3 fixture sweep seconds ≪ 300 s, byte-identical repeats; NFR-4 manifest assert exercised, never fired |
| Tooling gaps | **PASS** | shellcheck + mutation NOT AVAILABLE, declared per R-64 with executed fallbacks (`sh -n` + real /bin/sh execution; bidirectional discrimination gate as oracle-strength equivalent); no unwaived criterion affected. gitleaks + semgrep present; secrets rung run (below) |
| Reconciliation | **PASS** | F-1..F-5 all Closed, re-verified from files this session; no unexplained reversals; 2 late findings explained |
| Open findings | **PASS** | Blockers 0, Majors 0 |
| Deferred findings | **PASS** | FR-1 (Minor) deferred, approver: REVIEWER (this report), reason recorded |
| Waived findings | **PASS** | None |
| Documentation | **PASS** | METHODOLOGY (controls + 6 threats incl. residual skip-permissions oracle access, small-n/single-trial, deadline asymmetry, headless fidelity, task-authorship bias, Devin caution), RESULTS (honest headline + NOT-RUN ledger), README (quickstart + honesty framing; FR-1 wording nit) all present per plan |
| Observability | **PASS** | Per scope: per-row transcripts + scratch-root records + escape.txt channel + committed CSV snapshot; results hygiene verified |
| Rollback | **PASS** | Additive-only proven by diff scope; `git rm -r benchmark/` + revert one `.gitignore` hunk restores pre-E tree exactly |
| Secrets rung (R-121) | **PASS** | `gitleaks detect --no-git` over the full `main...HEAD` diff (199 KB): **no leaks found** |

## Verification Log

Machine evidence (R-110) — every row below executed by this reviewer, this session:

| Item | Method | Result | Evidence |
|---|---|---|---|
| Oracle discrimination | `sh benchmark/check-corpus.sh` | PASS | 8/8 tasks × 5 legs PASS; `check-corpus: ALL TASKS PASS`; exit 0 |
| Protocol drift (A–D untouched) | `sh build-protocol.sh --check` | PASS | `OK: PROTOCOL.md matches protocol/ shards`; exit 0 |
| Diff scope | `git diff main...HEAD --name-only` filtered | PASS | Empty outside `benchmark/`, `.gitignore`, `docs/superpowers/`, `docs/specs/` |
| Secrets | gitleaks over the branch diff | PASS | `no leaks found` (a first pass over the whole scratchpad dir flagged 13 hits — all pre-existing unrelated scratch files, none in this diff; re-scanned diff-only) |
| Fixture pipeline | `run.sh --arm fixture-good` ×2, `fixture-bad`, `--tasks 2 --trials 2` | PASS | good 0/8 ×2 identical; bad 8/8 rate 1.000; scaling 4/4 |
| Oracle isolation | scratch-root records + agent-transcript grep | PASS | 3 roots outside repo; grep `oracle`/`benchmark/corpus` over all pilot `agent.json`/`agent.err` → zero hits (a naive `-r` grep hits `oracle.log` — that is the harness's own post-arm grading log, not agent output) |
| Killed-arm status | `wc -c` + JSON parse | Confirmed | hw t01/t02 `agent.json` 0 bytes (non-terminal); hw t03 `subtype: success`, 32 turns, $12.3666; raw t01–t04 1.9–2.4 KB |
| Headline honesty | Full read of RESULTS.md + `0/3` sweep across benchmark/, impl pkg, README, docs | PASS | Only labeled raw output + the do-not-quote warning survive; headline: delta UNCOMPUTABLE, RAW 0/4 terminal, HEATWAVE 0/1 terminal, t01/t02 NOT counted as passes |
| Results hygiene | `git ls-files` + porcelain + tmp listing after 5 sweeps | PASS | Snapshot-only tracked; no noise; no scratch residue |
| CSV traceability | Row-by-row vs transcript dirs (+ iter-1 byte-diff vs run CSVs, accepted as recorded evidence) | PASS | 7 rows ↔ 7 transcript dirs; NOT-RUN rows carry exact completion commands; no fabricated rows |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Paid-arm re-execution | Cost-bounded; accepted on committed CSV + transcripts + terminal-state JSON + iter-1 timeline-consistency check | AC-F-05 (Satisfied on that evidence) |
| shellcheck | NOT AVAILABLE (R-64); `sh -n` + /bin/sh execution substituted | AC-N-02 |
| During-arm scratch-watcher samples | Ephemeral; accepted as impl-package testimony corroborated by harness control flow (`run.sh:121` post-arm copy, code-read) | AC-F-10(c) |

## Summary

The crux of this gate was result honesty, and it holds. RESULTS.md leads with, verbatim: "The RAW-vs-HEATWAVE escaped-defect delta is UNCOMPUTABLE from this pilot" — RAW terminal n=4 (0/4 escaped), HEATWAVE terminal n=1 (t03, 0/1), and the two watchdog-killed arms "are NOT completed runs — they must not be counted as passes." Every surviving "0/3" in the tree is either labeled raw tool output with the qualification attached or the do-not-quote warning itself. The impl package says the same. Nothing anywhere implies a computable delta; the honest finding that the protocol arm blew its 45-minute budget on 2 of 3 easy tasks (and cost ~60× RAW on the one it finished) is stated plainly rather than buried. Nothing is fabricated: every CSV row traces to a transcript directory whose contents match its claimed state — 0-byte result JSON for the kills, `subtype: success` for the terminal run — and every not-run row carries its completion command. This reviewer re-ran every machine gate from scratch: discrimination 8/8 both directions, drift OK, fixture sweeps deterministic, diff confined to the additive benchmark surface, secrets clean. All 15 ACs Satisfied with first-hand evidence; the §8.3 checklist passes item by item. The pilot number is inconclusive by honest construction — that is a PASS under this gate; the deliverable is the rig plus the honesty, and both are real. One deferred Minor (README pilot-n wording) and one bookkeeping Nit (uncommitted iteration-2 appendix) remain; neither blocks. **GATE_MET — sub-project E APPROVED.**
