# Fix Report

task_id: 2026-08-11-credibility-benchmark | artifact_type: fix-report | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

Responds to: `docs/superpowers/reviews/2026-08-11-full-review-E.md` (FULL_REVIEW iteration 1, GATE_NOT_MET: 0 Blockers, 1 Major, 2 Minors, 2 Nits). Fix commit: `fix(v4-E): correct RESULTS headline — killed HEATWAVE arms are NOT-RUN not passes; delta uncomputable` on `heatwave-v4-subproject-e`. No arm was re-run; no CSV row was edited (rows are recorded facts; the reviewer's required fix explicitly keeps them, with the `agent-nonzero-or-timeout` notes as the killed-arm markers).

## F-1 | MAJOR | verification-integrity — killed non-terminal HEATWAVE arms counted as graded passes in the headline

**Response: Accepted. Fixed as specified — presentation only, no data changed.**

What changed:
1. `benchmark/RESULTS.md` — rewritten. It now **leads** with a blockquote headline: delta **UNCOMPUTABLE**; RAW terminal n=4 (0/4 escaped), HEATWAVE terminal **n=1** (t03: 0/1 escaped); t01/t02 are watchdog-killed, non-terminal, **not** completed runs and not counted as passes anywhere. The pilot table gained a `terminal?` column (`NO — watchdog-killed` on t01/t02, sourced from the notes field + empty result JSON). The old "Headline (3-task subset) 0/3 vs 0/3" table is replaced by a terminal-runs-only table whose delta row reads "UNCOMPUTABLE — HEATWAVE terminal n=1". The graded-as-is result for the killed arms is quarantined in an explicitly labeled "supplementary observation only" paragraph that ends: *"Do not quote '0/3 vs 0/3' — that framing counts killed runs as passes."* The NOT-RUN ledger now has a `RAN, NON-TERMINAL` row for heatwave t01/t02 and the completion command includes their re-run.
2. `docs/superpowers/impl/2026-08-11-subproject-E-implementation.md` — Change Summary restated (terminal n framing, delta uncomputable); AC-F-06 section now notes that `summarize.awk`'s `heatwave: graded=3 ... 0/3` line is the graded-as-is aggregate and is **not** used by the headline; Known Limitations bullet 1 restated.
3. CSV: unchanged per the reviewer's fix instruction — `pilot-20260811.csv` rows stay verbatim as recorded, killed arms marked by their existing `agent-nonzero-or-timeout` notes, now surfaced as the `terminal?` column's source in RESULTS.md.

Evidence (from the committed files):
```
$ sed -n '4,11p' benchmark/RESULTS.md
> **The RAW-vs-HEATWAVE escaped-defect delta is UNCOMPUTABLE from this pilot.**
> RAW completed 4 terminal runs with 0 escaped defects (0/4). HEATWAVE completed
> only **1 terminal run** (t03: 0 escaped defects, 0/1); its other two arms
> (t01, t02) were **watchdog-killed before reaching a terminal state** and are
> NOT completed runs — they must not be counted as passes. ...
$ grep -c '0/3 vs 0/3' benchmark/RESULTS.md → appears only inside the "Do not quote" warning
```

## F-2 | MINOR | verification-integrity — vacuous isolation grep on the two killed rows

**Response: Accepted. Fixed.**

- `benchmark/RESULTS.md` "Honest reading" now states the grep is meaningful for the **5 rows with non-empty transcripts** (all clean) and that heatwave t01/t02's transcripts are 0-byte files, so their check is **"N/A — non-terminal"**, resting on the preventive control + during-arm watcher samples.
- Impl package AC-F-10(b) gained the same qualification block verbatim ("Qualification (review F-2): ...").

## F-3 | MINOR | data-integrity — visible check gradeable from an agent-modified `test_visible.py`

**Response: Accepted. Fixed in the harness.**

- `benchmark/run.sh`: grading now re-copies **both** files from the corpus after the arm exits:
  ```sh
  cp "$TASK_DIR/oracle/test_oracle.py" "$SCRATCH/"
  cp "$TASK_DIR/repo/test_visible.py" "$SCRATCH/"
  ```
  with a comment citing this finding.
- `benchmark/METHODOLOGY.md` control 8 updated: "the harness re-copies **both** files from the corpus at grading time — the graded checks are always the corpus's, even if the agent edited, weakened, or replaced them."
- Verified after the change (actual output): `sh -n benchmark/run.sh` → OK; `fixture-good: graded=8 oracle_pass=8/8 escaped_defects=0/8`; `fixture-bad: graded=8 oracle_pass=0/8 escaped_defects=8/8 escape_rate=1.000`.
- No pilot row is affected (reviewer's own finding: all rows oracle-passed); pilot data left as-is.

## F-4 | NIT | timeouts — watchdog overshoot (+~20%)

**Response: Accepted. Fixed.**

- `with_deadline`'s watchdog now uses a monotonic elapsed check (`t0=$(date +%s)`; kill when `now - t0 >= secs`) instead of iteration counting, eliminating per-iteration overhead drift (residual granularity ≤ one 5 s poll).
- Verified (actual output, hung dummy under /bin/sh, 5 s deadline): `elapsed=5s exit=143`, `(no survivors)` — previously the same test fired at ~15 s pattern and the canary overshot 2700 s → 3236 s.
- Historical rows keep their recorded walls (facts); D-4 in the impl package remains as the disclosure of the overshoot that occurred during the pilot.

## F-5 | NIT | documentation — stale diff-scope line in the impl package

**Response: Accepted. Fixed.** Files Changed total restated: 69 files / +2479 for the whole branch at T12 (65 / +1300 under `benchmark/` + `.gitignore`; remainder = the 4 E artifact docs), with a note that post-FIXING commits add the review/fix-report docs and the F-3/F-4 harness lines.

## Post-fix verification (actual output)

```
$ sh build-protocol.sh --check
OK: PROTOCOL.md matches protocol/ shards
$ git diff main...HEAD --name-only | grep -v -e '^benchmark/' -e '^\.gitignore$' -e '^docs/'
SCOPE CLEAN   (only benchmark/, .gitignore, docs E artifacts)
$ sh benchmark/run.sh --arm fixture-good  → graded=8 oracle_pass=8/8 escaped_defects=0/8
$ sh benchmark/run.sh --arm fixture-bad   → graded=8 oracle_pass=0/8 escaped_defects=8/8
```

No finding disputed; no deferrals requested. All 5 findings addressed: 1 Major (presentation), 2 Minors (1 doc qualification, 1 harness hardening), 2 Nits (1 harness, 1 doc).
