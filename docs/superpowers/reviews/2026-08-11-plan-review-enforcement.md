# Review Report

task_id: 2026-08-11-enforcement-hardening | artifact_type: review-report | iteration: 2 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-opus-4-8) | timestamp: 2026-08-11

## Verdict

GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 1 | Nit: 0

APPROVED. The iteration-1 Major (redirect leak) and all three Minors + the Nit are genuinely closed, verified adversarially by executing the proposed regex/tokenizer logic against every claimed form. One new narrow Minor (interpreter `r+` update-mode slips the write-indicator) is recorded and deferred — it does not reopen an obvious bypass and does not block the gate.

## Scope Evaluated

Plan scope unchanged from iteration 1: adapter gate (`role-gate.sh`) + `install.sh` matcher/migration + copy (`README.md`, `docs/faq.md`; confirm-only `HEATWAVE.md`/`adapters/README.md`), no protocol shard. Iteration-2 review re-hunted the Major adversarially (full bash redirect operator class + fd-dup exclusions + glued forms), re-checked each Minor's closure by running the proposed regexes, and re-confirmed the preserved-sound items (default-ALLOW matrix, Edit/Write path, allowlist parity, zero deps, adapter+docs-only, migration).

## Scope Changes

None.

## Reconciliation

| Finding ID | Prior status | Current status | Change reason (required if changed) |
|---|---|---|---|
| MAJOR-1 (redirect leak `&>`/`&>>`/`>|`/`>&<path>`) | Open (Major) | **Closed** | Row #1 rewritten to match raw operator tokens via `REDIR = ^(?:>\|?|>>|&>>?|>&)$` with fd-dup excluded via `DIGIT` on the target; verified all six forms + numbered-fd block to an in-project path and both fd-dup forms allow (evidence below). |
| MINOR-1 (interpreter allowlist coarser than FR-4) | Open (Minor) | **Closed** | Row #16 now extracts the write-call path arg (`WRITE_TARGET`) and runs each through `allowed_target`; verified `docs/design/*.md` and `.heatwave/` allow, `src/*` block, read-mode allow. |
| MINOR-2 (`patch --dry-run` unguarded) | Open (Minor) | **Closed** | Row #8 gains a `--dry-run` allow guard symmetric to #9; AC-F-02 adds the allow row, AC-F-01 retains real-`patch` block. |
| MINOR-3 (`sh -c`/`eval` unnamed in ceiling) | Open (Minor) | **Closed** | `ponytail:` comment + README/FAQ copy now name `sh -c`/`bash -c`/`eval`/`xargs "…"` as documented evasions; AC-F-06 demonstrates the `sh -c` bypass live; AC-F-07 greps assert the naming. |
| NIT-1 (no `&>`/`>|` AC rows) | Open (Nit) | **Closed** | AC-F-01 adds `&>`/`&>>`/`>|`/`>&<file>`/`2>` block rows; AC-F-02 adds `&> /tmp`, `>| .heatwave/**`, `2>&1` allow rows. |

Late findings (per R-60): **MINOR-4** (new this iteration — interpreter `r+` update-mode). Surfaced only by executing the refined `WRITE_IND` regex adversarially; not a regression, a residual gap in the newly-tightened row #16.

## Acceptance Status

N/A — PLAN_REVIEW (ACs judged for concreteness/verifiability; execution happens at IMPLEMENTING/FULL_REVIEW).

## Findings

### MINOR

**MINOR-4 — Interpreter write-indicator misses `r+` update mode (`open('src/x','r+').write(...)`).**
`plan §Row #16 / WRITE_IND` (line 204). `WRITE_IND` and `WRITE_TARGET` anchor the mode as `['\"][wax+]` — one char immediately after the opening quote. For `'w+'`/`'a+'`/`'x+'` the first char (`w`/`a`/`x`) matches, so plus-modes are caught; but for `'r+'` the first char is `r`, which is not in `[wax+]`, so the write indicator does not fire and `open('src/app.py','r+').write('x')` is treated as read-mode → ALLOW. Confirmed by executing the regex: `open('src/app.py','r+').write('x') → READ/allow, []`. `r+` opens an existing file for read-and-write, so `.write()` genuinely modifies source. This is a direct, non-obfuscated interpreter write in the class row #16 advertises — narrower and less common than the `'w'` idiom, but the regex visibly intends to cover `+`-modes and half-misses. **Severity Minor, not Major:** `r+` is an uncommon update-mode idiom (not the "obvious" write a reasonable agent reaches for), the core redirect class is now closed, and the gate is explicitly best-effort with a named ceiling — this does not reopen an obvious bypass. **Fix (one char class):** match the mode as `['\"](?:[wax]|r\+)` (i.e. accept `r` only when followed by `+`) in both `WRITE_IND` and `WRITE_TARGET`, and add an `open('src/x','r+')… → 2` row to AC-F-01. Deferrable by the REVIEWER; recommend fixing in the same implementation pass since it is a one-character edit to code the plan already specifies.

## What is genuinely closed (verified by execution)

- **MAJOR-1 (the crux) — CLOSED.** Ran the proposed `shlex(punctuation_chars=True)` tokenizer + `REDIR`/`DIGIT` scan against every form the coordinator named and more:
  - `echo pwned &> src/app.py` → redirect `&>`→`src/app.py` → **block**; `&>> src/app.py` → **block**; `>| src/app.py` → **block**; `>& src/app.py` (both-streams-to-path) → **block**; `2> src/app.py` → tokens `['echo','pwned','2','>','src/app.py']`, operator `>`→`src/app.py` → **block**; `1>>`/`>`/`>>` → **block**.
  - fd-dup NON-writes: `echo x 2>&1` → tokens `[...,'2','>&','1']`, target `1` is a bare digit → **allow**; `cmd >&2` → target `2` digit → **allow**. No false positive.
  - allowlisted/out-of-root redirect targets: `pytest &> /tmp/out.log` → target `/tmp/...` outside ROOT → **allow**; `echo note >| .heatwave/runs/t/notes.md` → allowlisted → **allow**.
  - quoted non-redirect: `awk '$1 > 2' data.txt` → `$1 > 2` is one token → **allow**. Glued forms (`&>src/app.py`, `>|src/app.py`, `x>src/app.py`) split correctly and still block. No advertised-class redirect write slips.
- **MINOR-1 — CLOSED.** `WRITE_TARGET` extracts: `open('src/app.py','w')→['src/app.py']`, `open('docs/design/task.md','w')→['docs/design/task.md']`, `open('.heatwave/…','a')→['.heatwave/…']`, `writeFileSync('src/a.js')→['src/a.js']`, `File.write('src/app.py')→['src/app.py']`; each routed through the shared `allowed_target` (design-doc `.md` and `.heatwave/` allow, `src/*` block). Read-mode `open('src/app.py').read()` → no indicator → allow. FR-4 parity achieved.
- **MINOR-2 — CLOSED.** Row #8 blocks `patch` unless a `--dry-run` token is present; AC-F-02 asserts `patch --dry-run … → 0`, AC-F-01 asserts real `patch … → 2` and `git apply /tmp/x.patch → 2` (with `git apply --check → 0` retained). Symmetric, plausible static logic.
- **MINOR-3 + NIT-1 — CLOSED.** Ceiling `ponytail:` comment and both copy blocks (README:146, faq:28) name `sh -c`/`bash -c`/`eval`/`xargs "…"` string-indirection as a deliberately-unchased evasion; AC-F-06 now demonstrates TWO live bypasses (helper-script `printf > /tmp/w.sh && sh /tmp/w.sh` and `sh -c 'echo pwned > src/app.py'`), both recorded not hidden; AC-F-07 greps assert the indirection is named AND that no overclaim (`physically block|prevent|completely prevent|cannot bypass`) is present. No F-style overclaim reintroduced.

## Preserved-sound items re-confirmed (no change, no finding)

- Default-ALLOW review matrix intact and expanded (AC-F-02 now 22 allow cases incl. the new redirect/interpreter/patch controls); non-matching commands exit 0.
- Edit/Write path unchanged (AC-F-04 identical: `src/app.py→2`, artifacts/`CLAUDE.md`/design-doc→0, `vendor/docs/design/x.md→2` anchor regression, byte-identical stderr).
- Allowlist parity across all three write paths via the single shared `allowed_target`.
- Zero new deps: still `json,os,re,sys,glob,shlex` (stdlib; `punctuation_chars` ≥3.6). No new binaries.
- Adapter+docs only: no protocol shard; `history` reconfirmed in `build-protocol.sh:7` ORDER → left untouched so drift stays `OK`; AC-N-04 asserts `build-protocol.sh --check`=0 and a scoped `git diff --stat`.
- `install.sh` matcher change + migration (needed because the idempotency check keys on `command` only) retained; AC-F-08 triple-run.
- AC rows are concrete JSON-on-stdin + expected exit codes with no placeholders; the MAJOR-1/NIT additions and Minor controls are all present with explicit codes.
- No new contradictions between the iteration-2 edits and the untouched sections.

## Verification Log

Machine evidence (R-110): plan-review — no implementation to execute; the Major/Minor closures were verified by running the plan's own proposed `shlex` tokenizer and `REDIR`/`DIGIT`/`WRITE_IND`/`WRITE_TARGET`/`FB` regexes directly against the enumerated command forms (evidence in "What is genuinely closed").

| Item | Method | Result | Evidence |
|---|---|---|---|
| MAJOR-1 all redirect forms block | run `REDIR`/`DIGIT` scan | Closed | `&>`,`&>>`,`>|`,`>&`,`2>`,`>`,`>>` → redirect to `src/app.py`; fd-dup `2>&1`/`>&2` → digit target → allow |
| Redirect allow controls | run scan | Correct | `&> /tmp`, `>| .heatwave/**` → allowed_target True |
| MINOR-1 interpreter parity | run `WRITE_TARGET`+allowed_target | Closed | `src/*`→block, `docs/design/*.md`/`.heatwave`→allow, read→allow |
| MINOR-4 `r+` slip | run `WRITE_IND` | Open (Minor) | `open('src/app.py','r+').write('x')` → no indicator → allow |
| MINOR-2 patch guard | read row #8 + AC-F-02 | Closed | `--dry-run` allow row + real-patch block row |
| MINOR-3/NIT ceiling+copy | read `ponytail:` comment, README:146, faq:28, AC-F-06/07 | Closed | `sh -c`/`eval`/`xargs` named; two live bypasses demoed; overclaim grep negative |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Runtime exit codes of the assembled gate | No implementation yet | AC-F-01…F-09, AC-N-01 — execute at IMPLEMENTING/FULL_REVIEW |
| AC-N-01 latency ≤150 ms | No code to time | AC-N-01 |
| MINOR-4 fix (if applied) | Deferred to implementer | AC-F-01 (recommend an `r+` row) |

## Summary

Iteration 2 closes the blocking Major and every Minor from iteration 1, and I verified each closure by executing the plan's own proposed logic rather than trusting the prose. The redirect Major is genuinely fixed: row #1 no longer keys on token equality against `>`/`>>` but matches the full bash output-redirect operator class (`>`, `>>`, `&>`, `&>>`, `>|`, `>&`, numbered-fd) against a raw-token regex, with fd-duplication (`2>&1`, `>&2`) correctly excluded by a bare-digit target test — I re-tested all six operator forms plus `2>` (block) and both fd-dup forms (allow) and confirmed the advertised class no longer leaks, including glued and pipeline-segment forms. MINOR-1's interpreter branch now extracts the write path and runs it through the same `allowed_target` as every other path (design-doc/`.heatwave` allow, `src` block, read-mode allow); MINOR-2 guards `patch --dry-run`; MINOR-3/NIT name `sh -c`/`eval`/`xargs` in both the in-code ceiling and the user copy, and AC-F-06 now demonstrates two live bypasses honestly. The default-ALLOW review matrix, the untouched Edit/Write path, allowlist parity, zero-dependency posture, install migration, and the no-protocol-shard/drift scope all remain sound with concrete, placeholder-free AC rows.

One new narrow Minor surfaced from the adversarial run: the interpreter write-indicator anchors the file mode as `['\"][wax+]`, so `'r+'` update-mode (`open('src/x','r+').write()`) is read as read-mode and slips. It is an uncommon idiom, not the obvious write, and the gate is explicitly best-effort — so it is Minor, not a reopening of the Major, and does not block APPROVED. Recommend the one-character regex fix (`['\"](?:[wax]|r\+)`) plus an `r+` AC row in the same implementation pass. Gate met: 0 Blockers, 0 Majors → APPROVED, MINOR-4 deferred to implementation.
