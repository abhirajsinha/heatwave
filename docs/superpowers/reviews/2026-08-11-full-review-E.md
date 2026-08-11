# Review Report

task_id: 2026-08-11-credibility-benchmark | artifact_type: review-report | iteration: 1+2 | review_type: FULL_REVIEW (iter 1) + TARGETED_REVIEW (iter 2) | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

**Current verdict (iteration 2, TARGETED_REVIEW): GATE_MET — see the Iteration 2 section at the end of this file.**

---

## Verdict (iteration 1, FULL_REVIEW — historical)

**GATE_NOT_MET → FIXING**
Blockers: 0 open | Majors: 1 open | Minor: 2 | Nit: 2

## Scope Evaluated

Sub-project E (Credibility Benchmark), branch `heatwave-v4-subproject-e` vs `main`:
`benchmark/` (harness `run.sh`, `check-corpus.sh`, `summarize.awk`, 8-task corpus,
`METHODOLOGY.md`, `RESULTS.md`, `README.md`, `results/pilot-20260811.csv`,
`results/transcripts/`), `.gitignore` hunk, and the E artifact docs. Reviewed
adversarially for result honesty (fabrication, killed-arm counting, oracle
isolation, rigging) plus standard FULL_REVIEW scope (ACs, isolation from A–D,
drift). Diff basis: `git diff main...heatwave-v4-subproject-e` (69 files, +2479;
65 files/+1300 of that under `benchmark/` + `.gitignore`, remainder E docs).

## Scope Changes

None (R-49).

## Reconciliation

First FULL_REVIEW iteration. Prior PLAN_REVIEW findings (F-001..F-006) were closed
at plan iteration 2; the two the plan review ordered re-verified live are re-verified
here:

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| PLAN F-001 (oracle reachable from in-repo scratch) | Resolved in plan | **Fix verified live** | Scratch roots recorded per sweep under `/var/folders/.../T/hw-bench.*` (outside the repo) in `transcripts/*/scratch-root.txt`; fatal assert present at `benchmark/run.sh:74-75`; transcript grep re-run by this reviewer: 14/14 files (4 raw + 3 heatwave × agent.json/agent.err) zero hits for `oracle`/`benchmark/corpus` — with the vacuity caveat of finding F-2 below |
| PLAN F-002..F-006 | Resolved in plan | Verified in code | Skill-dir pre-create `run.sh:105`; cumulative breaker `run.sh:58-65,127-134`; process-group kill `run.sh:31-41`; deadline-asymmetry + graded-as-is threats in METHODOLOGY §5 |

Late findings: None.

## Acceptance Status

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | Reviewer re-ran `sh benchmark/check-corpus.sh` → all 8 tasks PASS all 5 legs, `check-corpus: ALL TASKS PASS`, exit 0. Copy surface is structurally `repo/.` + `SPEC.md` only (`run.sh:92-93`) plus fatal leak assert (`run.sh:95-97`) |
| AC-F-02 | Satisfied | Same re-run: `good-oracle` PASS 8/8 (reference-good passes oracle) |
| AC-F-03 | Satisfied | Same re-run: `bad-oracle` PASS 8/8 (oracle rejects planted-bad), `bad-visible` PASS 8/8 (bad escapes the visible check); reviewer fixture-bad re-run: `graded=8 ... escaped_defects=8/8 escape_rate=1.000` |
| AC-F-04 | Satisfied | Corpus-immutability manifest check exercised in reviewer's 3 fixture sweeps (no `FATAL: corpus originals mutated`); fixture-good re-run ×2 → identical summaries |
| AC-F-05 | Satisfied with caveat | 7 rows (4 raw + 3 heatwave), per-row transcripts verified on disk. Caveat: only 1 of 3 HEATWAVE rows is end-to-end/terminal — see F-1 |
| AC-F-06 | **Not satisfied** | `summarize.awk` output matches the CSV and RESULTS table (reviewer re-ran it), and NOT-RUN rows are absent from denominators — but the headline presentation counts non-terminal rows as completed passes: F-1 |
| AC-F-07 | Satisfied | Reviewer ran `run.sh --arm fixture-good` twice: identical `graded=8 oracle_pass=8/8 escaped_defects=0/8` |
| AC-F-08 | Satisfied | Reviewer ran `--arm fixture-good --tasks 2 --trials 2` → `graded=4 oracle_pass=4/4` |
| AC-F-09 | Satisfied | Reviewer ran `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0; diff outside `benchmark/`+E-docs+`.gitignore` is empty (no `protocol/`, no `PROTOCOL.md`, no installer/adapter change) |
| AC-F-10 | Satisfied with caveat | (a) scratch roots outside repo (3 sweeps, recorded); (b) reviewer-re-run grep: zero hits in all 14 transcript files — vacuous for 2 of them (F-2); (c) oracle copy-in is post-arm by control flow (`run.sh:113` after `run_agent` returns) |
| AC-N-01 | Satisfied | Reviewer grep of corpus imports → stdlib only (`json,os,re,tempfile,unittest,datetime` + task modules); harness commands are sh/git/coreutils-equivalents + python3 + claude; network clone suppressed (`run.sh:105`, install.log "skipped companion skill") |
| AC-N-02 | Satisfied | Reviewer: `sh -n` both scripts OK; scripts executed under `/bin/sh` in this review. shellcheck NOT AVAILABLE — declared (R-64) |
| AC-N-03 | Satisfied | Breaker code present and correct (`run.sh:58-65`); pilot 4+3 ≤ 8×1; watchdog fired on hw t01/t02 (walls 3236 s/2709 s in CSV); canary-3× rule inapplicable (cost unreported on killed canary) — disclosed. Overshoot: F-4 |
| AC-N-04 | Satisfied | Reviewer fixture-good sweep completed in seconds (well < 300 s) |
| AC-N-05 | Satisfied | `git ls-files benchmark/results/` → `.gitkeep` + `pilot-20260811.csv` only; after reviewer's 3 fixture sweeps `git status --porcelain benchmark/results/` is empty (gitignore holds); CSV append-only by construction |

## Findings

### F-1 — MAJOR — Watchdog-killed, non-terminal HEATWAVE arms are counted as graded passes in the headline comparison

- **Where:** `benchmark/RESULTS.md:35-42` (headline table "escaped-defect rate 0/3 vs 0/3", "oracle pass rate 3/3 vs 3/3"); echoed in `docs/superpowers/impl/2026-08-11-subproject-E-implementation.md` Change Summary ("escaped-defect rate 0/3 RAW vs 0/3 HEATWAVE") and AC-F-06 section.
- **Facts (verified from artifacts):** HEATWAVE t01 ran 3236 s, was process-group-killed by the watchdog, and produced a 0-byte `agent.json` — no terminal result, no cost. It also tripped the plan's canary rule, whose own trigger text treats "fails to reach terminal state" as a failure condition. HEATWAVE t02: killed at 2709 s, 0-byte `agent.json`. Only t03 reached a terminal state (`subtype`-bearing result JSON, 32 turns, $12.37). The CSV rows are real and note `agent-nonzero-or-timeout`; the on-disk work of t01/t02 did pass visible+oracle (their `visible.log`/`oracle.log` show OK) — nothing is fabricated.
- **Why this is a misleading metric:** the spec (§5.2/G3) defines the HEATWAVE arm as the loop "run headless to a terminal state". A killed, non-terminal run is a run of *2700 s of Heatwave*, not of Heatwave; in real use a watchdog-killed run ships nothing. Counting its intermediate tree as a 0-escape pass credits the protocol arm with completed-run results its process never terminally produced — and on a public credibility benchmark the headline "0/3 vs 0/3" is the number that gets quoted. A skeptical replicator's first observation will be "the protocol arm failed to finish 2 of the 3 tasks it is credited with passing." That is precisely the Devin-class collapse METHODOLOGY §5 warns against. The honest headline is: HEATWAVE has **n=1 terminal row (t03, 0 escapes)**; the delta at matched n is **uncomputable**, not "0/3 vs 0/3". The graded-as-is policy was pre-registered (METHODOLOGY §5 at freeze `cfeaf8f`; plan edge-case list) and the kills are disclosed in the row notes and the "Timeout asymmetry" bullet — so this is a presentation defect, not fabrication, and severity is Major, not Blocker.
- **Required fix (bounded, no re-run needed):** (1) RESULTS.md headline restated: HEATWAVE terminal n=1; t01/t02 reported as NON-TERMINAL (watchdog-killed) rows whose work-on-disk grading is a supplementary observation under the pre-registered graded-as-is policy, not completed-arm passes; delta declared uncomputable at matched terminal n. Add a terminal/non-terminal status marker to the pilot table (the CSV `notes` field already carries it). (2) Impl package Change Summary + AC-F-06 wording aligned. (3) The "Honest reading" bullet already says most of this — promote it so the headline cannot be quoted without it. CSV rows stay as recorded (they are facts with notes).

### F-2 — MINOR — Isolation-evidence claim is vacuous for the two killed rows

- **Where:** `benchmark/RESULTS.md:58-59` ("transcript grep zero hits ... on all 7 rows"); impl package AC-F-10(b) ("all 14 counts = 0").
- **Fact:** for HEATWAVE t01/t02 both `agent.json` and `agent.err` are 0 bytes; a grep over an empty file is vacuously clean. For those two rows the isolation case rests entirely on the preventive control (out-of-repo scratch, no discoverable corpus path) — which this reviewer re-verified — plus the implementer's live scratch-watcher evidence. The claim as written implies detective-control coverage it does not have.
- **Fix:** qualify the claim ("5 of 7 rows have non-empty transcripts, all clean; t01/t02 transcripts are empty due to the kill — preventive control only").

### F-3 — MINOR — `test_visible.py` is gradeable from an agent-modified copy

- **Where:** `benchmark/run.sh:115-116` vs control 8 in `METHODOLOGY.md:115-118`.
- **Fact:** grading re-copies the oracle (overwriting any agent-written `test_oracle.py`) but runs the visible check against the scratch's `test_visible.py`, which the arm may have edited or weakened. Since `escaped_defect = visible_pass AND NOT oracle_pass`, a weakened visible test can manufacture visible passes. Bias direction is toward *more* recorded escapes (either arm), and no pilot row is affected (all oracle passes) — but it is a hole a replicator will poke.
- **Fix:** re-copy `repo/test_visible.py` from the corpus at grading time, same as the oracle; note in METHODOLOGY.

### F-4 — NIT — Watchdog overshoot (+~20%)

`with_deadline` fired at 3236 s on a 2700 s deadline (D-4, disclosed). The 5 s poll plus per-iteration overhead makes the ceiling approximate. Acceptable as disclosed; a monotonic elapsed-time check (`date +%s` delta) instead of iteration counting would tighten it if the harness is reused for a bigger run.

### F-5 — NIT — Impl package diff-scope line is stale

Impl package states "65 files changed, 1300 insertions(+), all under `benchmark/` + `.gitignore`"; the final branch diff is 69 files / +2479 including the four E artifact docs committed at T12. The benchmark-tree numbers themselves are correct. Restate for precision.

## Verification Log

Machine evidence (R-110): all commands below run by this reviewer in this session.

| Item | Method | Result | Evidence |
|---|---|---|---|
| Oracle discrimination (all 8 tasks) | `sh benchmark/check-corpus.sh` re-run | **PASS** | 8/8 tasks PASS all legs (layout, good-oracle, bad-oracle, bad-visible, trace); `check-corpus: ALL TASKS PASS`, exit 0 |
| Full-pipeline self-test | `run.sh --arm fixture-good` ×2, `--arm fixture-bad`, `--tasks 2 --trials 2` | PASS | good: 0/8 escapes ×2 identical; bad: 8/8 escapes, rate 1.000; scaling: 4 rows |
| Protocol drift (A–D untouched) | `sh build-protocol.sh --check` | PASS | `OK: PROTOCOL.md matches protocol/ shards`, exit 0 |
| Diff isolation | `git diff main...HEAD --stat` + name filter | PASS | Only `.gitignore` (+3, results-hygiene hunk), `benchmark/**`, and E docs; zero `protocol/`/`PROTOCOL.md`/installer changes |
| CSV row traceability | diff of `pilot-20260811.csv` vs the 3 run CSVs; transcript dirs listed; timeline check | PASS | Rows byte-identical to `20260811T114738Z-raw.csv`, `20260811T115121Z-heatwave.csv`, `20260811T124604Z-heatwave.csv`; every row has a transcript dir; run-id timestamps + walls + file mtimes mutually consistent (e.g. canary 11:51Z + 3236 s → 18:15 IST copy-back). No fabricated rows |
| Killed-arm status | `wc -c` on transcripts | Confirmed | hw t01/t02 `agent.json` = 0 bytes (killed, non-terminal); hw t03 `agent.json` = 3740 bytes, `total_cost_usd: 12.3666...`; raw t01–t04 `agent.json` 1.9–2.4 KB (non-vacuous greps) |
| Oracle isolation (F-001 fix) | scratch-root records + reviewer grep re-run | PASS (with F-2 caveat) | 3 sweeps rooted under `/var/folders/.../T/hw-bench.*`; grep `oracle`/`benchmark/corpus` over 14 transcript files: 14 × 0 hits |
| Metric recomputation | `awk -f summarize.awk pilot-20260811.csv` | Matches | `heatwave: graded=3 ... 0/3 ... mean_wall=2849.0s`, `raw: graded=4 ... 0/4 ... 32.8s` — arithmetic in RESULTS.md is correct *given* the graded-as-is counting that F-1 disputes at headline level |
| Anti-rigging spot-check (≥2 tasks) | Full read of t01-pagination and t08-dedupe-contacts | PASS | Generic traps (off-by-one; case-insensitive dedupe); every oracle method carries a `# SPEC:` quote traceable to an explicit SPEC sentence; `bad.py` is the natural naive solution and passes the visible check; SPECs state the edge cases openly (if anything this favors RAW — consistent with the null result). RAW scratch receives no protocol files (`run.sh:104`, install only on the heatwave branch) |
| Corpus freeze ordering | `git log` timestamps | PASS | `cfeaf8f` (freeze, incl. METHODOLOGY's graded-as-is text) precedes all paid runs; pilot commits `f887b5d`/`45faec3` postdate them |
| Results hygiene | `git ls-files` + `git status --porcelain` after 3 reviewer sweeps | PASS | Tracked: `.gitkeep` + `pilot-20260811.csv` only; no untracked noise |
| Stdlib-only corpus | grep of all corpus imports | PASS | `json,os,re,tempfile,unittest,datetime` + task modules only |
| POSIX syntax | `sh -n` both scripts | PASS | No output, exit 0 |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Paid-arm re-execution | Cost-bounded; reviewed from committed CSVs, transcripts, and timeline consistency instead | AC-F-05 (accepted on evidence) |
| shellcheck | NOT AVAILABLE on this machine (R-64); `sh -n` + real `/bin/sh` execution substituted | AC-N-02 |
| Implementer's live scratch-watcher and t05-during-arm samples | Ephemeral (scratch trap-deleted); accepted as testimony corroborated by harness control flow (`run.sh:113` post-arm oracle copy) | AC-F-10(c) |

## Summary

The rig is real and sound. This reviewer independently re-ran the discrimination gate (8/8 tasks: reference-good passes the withheld oracle, planted-bad fails it, planted-bad escapes the visible check), reproduced both fixture sweeps and the scaling flags, re-verified out-of-repo scratch isolation and the zero-hit transcript greps, reproduced the drift check (`OK`, exit 0), and traced every pilot CSV row to a run CSV, a transcript directory, and a mutually consistent timeline — no fabricated rows, no rigged tasks (the spot-checked SPECs state their edge cases so plainly that the corpus, if biased, is biased *against* the protocol arm). NOT-RUN tasks are labeled with exact completion commands. The inconclusive pilot number is not a defect — the honest rig is the deliverable.

The gate fails on one Major of presentation honesty: the headline table counts two watchdog-killed, non-terminal HEATWAVE runs (t01 3236 s, t02 2709 s, both with empty result JSON) as graded 0-escape passes, yielding "0/3 vs 0/3". The spec defines the HEATWAVE arm as a loop driven *to a terminal state*; only t03 got there. The data supports "HEATWAVE terminal n=1, delta uncomputable" — the grading-as-is policy is pre-registered and the kills are disclosed further down, so this is a framing fix, not a data fix, but on a public credibility benchmark the quotable headline must not overstate. Two Minors (vacuous grep evidence on the killed rows; visible check gradeable from an agent-modified file) and two Nits round it out. One FIXING pass on RESULTS.md + the impl package wording, plus the small harness hardening, should clear the gate without any new paid runs.

## Gate

**Iteration 1: GATE_NOT_MET (0 Blockers, 1 Major, 2 Minors, 2 Nits) → FIXING.**

---

# Iteration 2 — TARGETED_REVIEW (§4.6)

review_type: TARGETED_REVIEW | iteration: 2 | produced_by: REVIEWER (claude-fable-5, same context as iteration 1) | timestamp: 2026-08-11

## Verdict

**GATE_MET**
Blockers: 0 open | Majors: 0 open | Minor: 0 open | Nit: 0 open | New findings: 0

## Scope Evaluated

Fix delta only (commits `2f9cdd0` reporting/harness fixes + `fc58942` review/fix-report docs) against the iteration-1 findings, plus regression checks. Fix Report: `docs/superpowers/reviews/2026-08-11-fix-report-E.md`. Every closure verified from the actual files and re-run commands, not the report's claims.

## Reconciliation

| Finding ID | Prior status | Current status | Change reason (verified evidence) |
|---|---|---|---|
| F-1 (Major, killed arms counted as passes) | Open | **Closed — verified** | `benchmark/RESULTS.md` now *leads* with the blockquote: "The RAW-vs-HEATWAVE escaped-defect delta is UNCOMPUTABLE from this pilot. RAW completed 4 terminal runs ... (0/4). HEATWAVE completed only 1 terminal run (t03: ... 0/1); its other two arms (t01, t02) were watchdog-killed before reaching a terminal state and are NOT completed runs — they must not be counted as passes." Pilot table gained a `terminal?` column (`NO — watchdog-killed` on hw t01/t02, RESULTS.md:37-38); headline table is terminal-runs-only (RAW n=4 0/4, HEATWAVE n=1 0/1) with delta row "UNCOMPUTABLE — HEATWAVE terminal n=1" (RESULTS.md:41-50); killed rows quarantined as "supplementary observation only" ending "Do not quote '0/3 vs 0/3'" (RESULTS.md:52-60); NOT-RUN ledger adds a `RAN, NON-TERMINAL` row and the completion command re-runs t01/t02 (RESULTS.md:97-108). Impl package: Change Summary restated (terminal-n framing, delta uncomputable), AC-F-06 note explicitly labels `summarize.awk`'s `0/3` line as the graded-as-is aggregate NOT used by the headline, Known Limitations restated. Reviewer grep for `0/3` across both files: remaining occurrences are only (a) verbatim tool output with the F-1 qualification note attached and (b) the do-not-quote warning itself. No summary or AC statement implies a computable delta. Honest. |
| F-2 (Minor, vacuous isolation grep) | Open | **Closed — verified** | RESULTS.md:74-82: grep declared meaningful for the 5 non-empty-transcript rows (all clean); hw t01/t02 marked "N/A — non-terminal" resting on the preventive control + watcher samples. Same qualification block added to impl AC-F-10(b). |
| F-3 (Minor, agent-modifiable visible check) | Open | **Closed — verified** | `benchmark/run.sh:118-122` now re-copies BOTH `test_oracle.py` and `repo/test_visible.py` from the corpus after the arm exits, with a comment citing this finding; METHODOLOGY control 8 updated to match. Reviewer re-ran the gate + fixtures post-change: `check-corpus.sh` → ALL TASKS PASS exit 0; fixture-good `0/8` escapes; fixture-bad `8/8` escapes, rate 1.000. |
| F-4 (Nit, watchdog overshoot) | Open | **Closed — verified** | `with_deadline` (run.sh:33-42) now uses a monotonic `date +%s` elapsed check instead of iteration counting; residual granularity ≤ one 5 s poll. Code read; function exercised in reviewer's fixture sweeps. Historical walls untouched (facts); D-4 disclosure retained. |
| F-5 (Nit, stale diff-scope line) | Open | **Closed — verified** | Impl package restates 69 files / +2479 whole-branch (65 / +1300 under `benchmark/` + `.gitignore`; 4 E docs), noting post-FIXING commits. Matches reviewer's `git diff main...HEAD --stat`. |

Late findings: None. No new findings introduced by the fix delta (the `with_deadline` rewrite and the `test_visible.py` re-copy were read line-by-line; both correct).

## Verification Log (iteration 2, all re-run by this reviewer)

| Item | Method | Result |
|---|---|---|
| Oracle discrimination | `sh benchmark/check-corpus.sh` | 8/8 tasks PASS all legs; `check-corpus: ALL TASKS PASS`; exit 0 |
| Fixture regression after F-3/F-4 harness edits | `run.sh --arm fixture-good` / `--arm fixture-bad` | good: `graded=8 oracle_pass=8/8 escaped_defects=0/8`; bad: `graded=8 ... escaped_defects=8/8 escape_rate=1.000` |
| Protocol drift | `sh build-protocol.sh --check` | `OK: PROTOCOL.md matches protocol/ shards`; exit 0 |
| Diff isolation | `git diff main...HEAD --name-only` filtered | Only `benchmark/`, `.gitignore`, and `docs/` E artifacts; zero `protocol/`/`PROTOCOL.md` changes |
| CSV facts untouched by fixes | `git diff 45faec3..HEAD --stat -- benchmark/results/` | Empty — no result row edited; fixes are reporting + harness only |
| Results hygiene | `git status --porcelain benchmark/results/` after reviewer sweeps | Empty — gitignore holds |

## Gate

**Iteration 2: GATE_MET (0 Blockers, 0 Majors, 0 open findings). All 5 iteration-1 findings verified closed from the artifacts. Sub-project E proceeds.**
