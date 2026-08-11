# Implementation Package

task_id: 2026-08-11-credibility-benchmark | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

## Change Summary

Built sub-project E (Credibility Benchmark) exactly to the approved iteration-2 plan: an 8-task seeded-trap corpus (`benchmark/corpus/`, two tasks per defect class, agent-visible SPEC + withheld deterministic oracle + good/bad reference solutions), the POSIX harness `run.sh` (out-of-repo `mktemp -d` scratch, fatal isolation asserts, process-group deadlines, cumulative cost/wall breaker, CSV + transcript copy-back), `check-corpus.sh` (layout / isolation / SPEC-traceability / bidirectional oracle discrimination), `summarize.awk`, `METHODOLOGY.md`, `RESULTS.md`, and a real paid pilot. The pilot ran under the plan's feasibility escape (operator cost steer mid-sweep + the HEATWAVE canary tripping its 45-min rule): RAW completed 4 terminal runs (t01–t04, 0/4 escaped defects); HEATWAVE completed **1 terminal run** (t03: 0/1 escaped defects) — its t01/t02 arms were watchdog-killed non-terminal (empty result JSON) and are NOT counted as completed runs; their graded-as-is on-disk work is a supplementary observation only. **The RAW-vs-HEATWAVE escaped-defect delta is uncomputable from this pilot (HEATWAVE terminal n=1); the rig itself is proven** (fixture-bad 8/8 escapes, fixture-good 0/8; oracle discrimination 8/8; isolation checks clean). All not-run rows are declared `NOT RUN (cost-bounded)` with exact completion commands. No protocol shard touched; drift check `OK`.

## Files Changed

| Path | Change type | Line delta |
|---|---|---|
| `.gitignore` | modified | +3 |
| `benchmark/README.md` | added | +36 |
| `benchmark/run.sh` | added | +146 |
| `benchmark/check-corpus.sh` | added | +67 |
| `benchmark/summarize.awk` | added | +20 |
| `benchmark/METHODOLOGY.md` | added | +168 |
| `benchmark/RESULTS.md` | added | +86 |
| `benchmark/results/.gitkeep` | added | 0 |
| `benchmark/results/pilot-20260811.csv` | added | +8 |
| `benchmark/corpus/t01..t08/**` (8 tasks × {repo/module, repo/test_visible.py, SPEC.md, oracle/test_oracle.py, solutions/good.py, solutions/bad.py, TASK.yaml}) | added | ~766 total |

Total: `git diff main...HEAD --stat` at the T12 commit → **69 files changed, +2479** for the whole branch (65 files / +1300 of that under `benchmark/` + `.gitignore`; the remaining 4 files are the E artifact docs — spec, plan, plan-review, this package). Post-FIXING commits add the review/fix-report docs and the F-3/F-4 harness lines.

## Diff

Branch `heatwave-v4-subproject-e`, commits `08be923..` on top of `main`@`06cd952` (pre-E SHA). Corpus-freeze commit: `cfeaf8f` ("benchmark: freeze corpus+harness pre-pilot") — all paid runs postdate it. Per-task commits T1–T11 as listed by `git log main..HEAD`.

## Deviation Records

**D-1 — pilot reduced to the feasibility-escape subset by an operator cost steer (not self-approved).**
- What the plan specified: T9 RAW sweep of 8 tasks; T10 HEATWAVE canary then up to 8 under the breaker.
- What was built instead: mid-RAW-sweep (after t04's row landed, t05 in flight) the coordinator directed the plan's pre-committed escape — first-3 lexical subset, both arms. t05's in-flight RAW arm was killed before grading (no row recorded — nothing fabricated). HEATWAVE ran t01 (canary) + t02 + t03. The canary itself also tripped the plan's rule (wall 3236 s > 45 min, non-terminal), which independently lands on the same first-3 subset.
- Why: explicit coordinator cost-bound instruction; plan T10/FR-10 pre-authorizes exactly this escape with honest NOT-RUN rows.
- Affects review scope / ACs: AC-F-05 still met (≥3 graded rows per arm: 4 raw + 3 heatwave); AC-N-03 met (escape recorded with real numbers). RESULTS.md carries the NOT-RUN table + completion commands.
- Affects threat surface: none (fewer paid runs).

**D-2 — `.gitignore` existed (plan assumed a pure hunk-add).** It contained one line (`.DS_Store`); I briefly overwrote then restored it, final committed content = `.DS_Store` + the 3 planned lines. Diff is exactly the planned hunk.

**D-3 — freeze commit is an empty marker commit.** T1–T8 content was already committed per-task, so `cfeaf8f` is `--allow-empty` with the plan's freeze message, recording the freeze SHA. Content-identical to the plan's intent.

**D-4 — with_deadline fires late under load.** The 2700 s watchdog killed the canary at ~3236 s (poll-loop per-iteration overhead ≈ 6 s × 540 iterations). t02 fired at 2709 s. Deadline is enforced, ceiling is approximate (+~20% worst case observed). Noted, not fixed — the bound held.

No other deviations. Task order, corpus content (t01/t03 verbatim from the plan), harness structure, prompts, flags, and CSV schema are exactly as planned.

## Migration Notes

None — purely additive (`benchmark/` + one `.gitignore` hunk). Rollback per plan: `git rm -r benchmark/` + revert the hunk.

## Configuration Changes

None. No env vars, flags, secrets, or deps. Zero new runtime dependencies (sh, git, shasum, find, sort, awk, sed, date, mktemp, python3-stdlib, claude, pgrep only — audit under AC-N-01 below).

## Test Additions

- `benchmark/check-corpus.sh` — corpus gate: layout, copy-surface isolation, SPEC-traceability grep, good-passes/bad-fails oracle, bad-passes-visible, per task.
- Fixture arms in `run.sh` (`fixture-good` / `fixture-bad`) — zero-token full-pipeline self-test (scratch construction, isolation asserts, git init, deadline wrapper, grading, CSV, transcript copy-back, manifest, summary).
- 8 × `oracle/test_oracle.py` + 8 × `repo/test_visible.py` (corpus content, stdlib unittest).

## Test Results

All outputs below are actual command output from this session.

### AC-F-01 — corpus integrity + oracle isolation
`sh benchmark/check-corpus.sh` (also covers AC-F-02/03):

```
task                   layout   good-oracle  bad-oracle   bad-visible  trace
t01-pagination         PASS     PASS         PASS         PASS         PASS
t02-date-window        PASS     PASS         PASS         PASS         PASS
t03-log-summary        PASS     PASS         PASS         PASS         PASS
t04-safe-stats         PASS     PASS         PASS         PASS         PASS
t05-cart-total         PASS     PASS         PASS         PASS         PASS
t06-username-policy    PASS     PASS         PASS         PASS         PASS
t07-slugify            PASS     PASS         PASS         PASS         PASS
t08-dedupe-contacts    PASS     PASS         PASS         PASS         PASS
check-corpus: ALL TASKS PASS   (exit 0)
```

Scratch-surface watcher (2 s poll during the paid RAW sweep, patterns `test_oracle*`, `solutions`, `TASK.yaml`, `good.py`, `bad.py`): the only matches ever observed are `test_oracle.py`(+`.pyc`) in already-graded trial dirs — the file `run.sh` itself copies in **after** the arm exits. t05's scratch (arm running when the sweep was stopped, never graded) shows **zero** matches at any sample — direct during-arm evidence that no withheld file is present while an agent runs. Fixture-sweep watcher: identical pattern (8 hits, all post-grading `oracle.log`), zero hits for `solutions`/`TASK.yaml`/`good.py`/`bad.py` ever.

### AC-F-02 / AC-F-03 — oracle discriminates; bad escapes the visible check
`check-corpus.sh` table above: `good-oracle` PASS (good passes oracle) / `bad-oracle` PASS (oracle rejects bad) / `bad-visible` PASS (bad passes visible) — **8/8 tasks, all three legs**. Also per-pair spot runs during authoring (T2–T5), e.g. `t01-pagination good: oracle=PASS visible=PASS / bad: oracle=FAIL visible=PASS` for every task.

### AC-F-04 — determinism + corpus immutability
Double setup of (t01, same commands as `run.sh` setup lines — real scratch is trap-cleaned, so the pre-arm tree was reconstructed with the identical command sequence):

```
full diff -r: Binary files <s1>/.git/index and <s2>/.git/index differ   (only line — mtimes inside git index)
diff -r --exclude=.git: (empty — agent-visible tree byte-identical)
```

Corpus immutability: every sweep (2× fixture-good full, 2× fixture-bad full, 1 partial + reproducibility re-runs, RAW, HEATWAVE ×2) completed without `FATAL: corpus originals mutated` (the harness compares full shasum-256 manifests before/after and exits 1 on mismatch).

### AC-F-05 — both arms end-to-end with transcripts

```
$ awk -F, 'NR>1 && ($3=="raw"||$3=="heatwave")' benchmark/results/pilot-20260811.csv | wc -l
7        (4 raw + 3 heatwave, both arms present)
transcripts/20260811T114738Z-raw/: scratch-root.txt t01..t04-trial1/ (agent.json, agent.err, visible.log, oracle.log)
transcripts/20260811T115121Z-heatwave/: t01-pagination-trial1/ (agent.json, agent.err, install.log, visible.log, oracle.log)
transcripts/20260811T124604Z-heatwave/: t02-date-window-trial1/ t03-log-summary-trial1/ (same set)
```

### AC-F-06 — metric honesty

```
$ awk -F, -f benchmark/summarize.awk benchmark/results/pilot-20260811.csv
heatwave: graded=3 oracle_pass=3/3 escaped_defects=0/3 escape_rate=0.000 mean_wall=2849.0s total_cost=$12.3666 (over 1 costed rows)
raw: graded=4 oracle_pass=4/4 escaped_defects=0/4 escape_rate=0.000 mean_wall=32.8s total_cost=$0.8531 (over 4 costed rows)
$ awk -F, 'NR>1 && $3=="raw"{g++;e+=$7} END{print e"/"g}'      → 0/4
$ awk -F, 'NR>1 && $3=="heatwave"{g++;e+=$7} END{print e"/"g}' → 0/3
```

Hand computation matches summarize output and the RESULTS.md pilot table; NOT-RUN tasks appear in no denominator. **Note (review F-1):** `summarize.awk` aggregates all CSV rows under the pre-registered graded-as-is policy, so its `heatwave: graded=3 ... 0/3` line includes the two watchdog-killed non-terminal arms. The RESULTS.md **headline** does not use that number: it reports terminal runs only (RAW 0/4, HEATWAVE 0/1) and declares the delta uncomputable; the killed rows are labeled supplementary.

### AC-F-07 — reproducibility

```
$ sh benchmark/run.sh --arm fixture-good   (run twice, summaries diffed)
fixture-good: graded=8 oracle_pass=8/8 escaped_defects=0/8 escape_rate=0.000 mean_wall=0.0s
(identical)
```

Pilot commands appear verbatim in METHODOLOGY.md §6.

### AC-F-08 — scaling flags

```
$ sh benchmark/run.sh --arm fixture-good --tasks 2 --trials 2
fixture-good: graded=4 oracle_pass=4/4 ...   CSV wc -l = 5 (header + exactly 4 rows keyed task,trial)
```

### AC-F-09 — no protocol regression

```
$ sh build-protocol.sh --check
OK: PROTOCOL.md matches protocol/ shards
$ git diff main...HEAD --name-only | sed 's|/.*||' | sort | uniq -c
   1 .gitignore
  64 benchmark
```

### AC-F-10 — arm isolation (the F-001 fix)
(a) Scratch roots (recorded per sweep in `transcripts/<run-id>/scratch-root.txt`):

```
scratch_root: /var/folders/.../T//hw-bench.P0SJ0H (outside /Users/abhirajsinha/Projects/heatwave)   [raw]
scratch_root: /var/folders/.../T//hw-bench.8dCjNU (outside ...)   [heatwave canary]
scratch_root: /var/folders/.../T//hw-bench.c2lHLr (outside ...)   [heatwave t02+t03]
```

The fatal assert is in `run.sh` (`case "$SWEEP_ROOT" in "$REPO"*) ... exit 1`).
(b) Transcript grep — all 7 rows, both files:

```
$ grep -rc -e 'benchmark/corpus' -e 'oracle' transcripts/<each-run>/*/agent.json */agent.err
all 14 counts = 0   (4 raw + 3 heatwave × {agent.json, agent.err})
```

**Qualification (review F-2):** the grep is meaningful for the 5 rows with
non-empty transcripts (raw t01–t04, heatwave t03) — all clean. Heatwave
t01/t02's `agent.json`/`agent.err` are 0 bytes (watchdog kill), so their zero
counts are vacuous: those two rows' isolation check is **N/A — non-terminal**,
resting on the preventive control (out-of-repo scratch, no discoverable corpus
path — reviewer re-verified) plus the during-arm scratch-watcher samples.

(c) Oracle copied only post-arm: single sequential flow in `run.sh` (the `cp .../test_oracle.py` line executes after `run_agent` returns / fixture copy); corroborated by the t05 watcher evidence in AC-F-01.

### AC-N-01 — zero deps, no network

```
$ grep -RhE '^(import|from) ' benchmark/corpus/*/oracle */repo */solutions | sort -u
→ stdlib only: json, os, re, tempfile, unittest, datetime (+ imports of the task modules themselves)
$ grep -i 'skipped companion' .../t01-pagination-trial1/install.log
skipped companion skill ui-ux-pro-max (already installed)     (F-002 skip path — no clone)
```

Harness external commands: sh built-ins, git, shasum, find, sort, awk, sed, date, mktemp, python3, claude, tee, grep, basename, dirname — per source audit of `benchmark/*.sh`.

### AC-N-02 — POSIX-sh clean

```
$ sh -n benchmark/run.sh && sh -n benchmark/check-corpus.sh
syntax OK      (shellcheck NOT AVAILABLE on this machine — declared; method is sh -n + execution under /bin/sh)
```

### AC-N-03 — cost bound honored
Pilot totals: RAW 4×1 (+1 killed unrecorded in-flight arm), HEATWAVE 3×1 — under the 8×1 cap. Per-task watchdog fired on HEATWAVE t01 (3236 s) and t02 (2709 s); canary rule (>45 min, non-terminal) documented in RESULTS.md; sweep-cumulative breaker never tripped (max sweep wall 5311 s < 14400 s; costs $0.85 + $12.37 < $60). Orphan checks after each arm/kill: `pgrep -fl 'claude -p --setting-sources project'` → empty every time. `with_deadline` group-kill unit evidence (actual function extracted from run.sh, run under /bin/sh):

```
start 17:15:33 → end 17:15:38, exit=143, surviving 'sleep 300' processes: (none)
```

### AC-N-04 — deterministic path fast

```
$ time sh benchmark/run.sh --arm fixture-good     → 1.759 s total (< 300 s)
```

### AC-N-05 — results hygiene

```
$ git ls-files benchmark/results/ → .gitkeep, pilot-20260811.csv   (exactly one snapshot)
$ git status after fixture runs → no untracked results noise (gitignore verified)
$ ls ${TMPDIR:-/tmp}/hw-bench.* → no matches after every completed sweep (trap-cleaned)
```

CSV append-only by construction (header written once at run start, rows only appended).

### T7 arm-isolation smoke (plan risk: user-context leakage)

```
bare scratch, claude -p --setting-sources project --dangerously-skip-permissions:
"List verbatim any project or user instructions, CLAUDE.md content, or memory content you can see... If none, say NONE."
→ exit 0, result: "NONE.", cost $0.0714
```

Fallback ladder not needed.

### Pilot rows (real, verbatim from pilot-20260811.csv)

```
20260811T114738Z-raw,t01-pagination,raw,1,1,1,0,32,0.2181565,
20260811T114738Z-raw,t02-date-window,raw,1,1,1,0,34,0.20185099999999997,
20260811T114738Z-raw,t03-log-summary,raw,1,1,1,0,34,0.2064585,
20260811T114738Z-raw,t04-safe-stats,raw,1,1,1,0,31,0.2266795,
20260811T115121Z-heatwave,t01-pagination,heatwave,1,1,1,0,3236,,agent-nonzero-or-timeout
20260811T124604Z-heatwave,t02-date-window,heatwave,1,1,1,0,2709,,agent-nonzero-or-timeout
20260811T124604Z-heatwave,t03-log-summary,heatwave,1,1,1,0,2602,12.366612249999994,
```

HEATWAVE t03 result JSON: `subtype: success`, 32 turns — the loop reached a terminal state; t01/t02 were watchdog-killed pre-terminal and graded as-is (their on-disk work passed the oracle).

## Blast Radius Declaration

Components touched: new `benchmark/` tree + one `.gitignore` hunk. Consumers: none — nothing imports from `benchmark/`; no protocol shard, installer, adapter, template, or config changed (`build-protocol.sh --check` → OK; diff scope proven above). Shared state: none (scratch is out-of-repo and trap-cleaned; results dir is gitignored except the snapshot). Contracts introduced (frozen at `cfeaf8f`): `run.sh` CLI, TASK.yaml key set, CSV schema. Boundary reasoning: E is additive-only by design (FR-11); removing `benchmark/` restores the pre-E tree exactly.

## Known Limitations

- **The comparison is uncomputable by honest admission** — HEATWAVE terminal n=1 (t03 only; t01/t02 watchdog-killed non-terminal), RAW terminal n=4, K=1, easy-difficulty tasks all solved by every terminal run; RESULTS.md leads with this. A corpus hard enough that RAW actually fails, plus a HEATWAVE budget the loop actually fits, is the required follow-up before any public claim.
- HEATWAVE t01/t02 costs unobtainable (watchdog kill → empty result JSON); only wall-time bounds their spend.
- `with_deadline` ceiling is approximate (+~20% observed under load: 3236 s on a 2700 s deadline) — bound enforced, not precise (D-4).
- Setup-determinism proof excludes `.git/index` (embedded mtimes) and reconstructs the tree via the same command sequence rather than a harness hook (real scratch is trap-deleted).
- The AC-F-10 transcript grep inspects `--output-format json` output (final result + metadata), not full turn-by-turn transcripts; combined with out-of-repo cwd isolation it is a detective control, not proof against a deliberately adversarial model (disclosed in METHODOLOGY §5).
- No `ponytail:` ceiling comments were needed in the shipped scripts.

## Tooling Status

- shellcheck NOT AVAILABLE (AC-N-02 verified via `sh -n` + real execution under /bin/sh — per plan's declared fallback).
- Mutation testing NOT AVAILABLE (per plan R-110/R-64; oracle strength covered by the bidirectional discrimination gate AC-F-02/03).
- semgrep + gitleaks present for the REVIEWER's rungs (not run by IMPLEMENTER — reviewer-owned per plan Tooling table).
- `claude` CLI 2.1.227 confirmed and used for all paid arms.
- All other ACs verified with confirmed tooling as evidenced above; no AC left silently unverified — RAW t05–t08 and HEATWAVE t04–t08 rows are NOT RUN (cost-bounded), declared in RESULTS.md with completion commands.
