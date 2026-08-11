# Review Report

task_id: 2026-08-11-enforcement-hardening | artifact_type: review-report | iteration: 2 | review_type: TARGETED_REVIEW | produced_by: REVIEWER (claude-opus-4-8) | timestamp: 2026-08-12

## Verdict (iteration 2 — TARGETED_REVIEW)

GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 0

Both FULL_REVIEW Majors are closed, re-verified by re-running the assembled gate (not the fix report). MAJOR-1: `sed --in-place 's/a/b/' src/app.py`→**2**, `sed --in-place=.bak … src/app.py`→**2**, short `sed -i`→**2**; non-writing `sed 's/a/b/' src > /dev/null`→**0** (not over-blocked). MAJOR-2 both directions: quoted operators ALLOW — `grep '>' src/app.py`→**0**, `grep -rn '>>' src/`→**0**, `rg '>' src`→**0**; real redirects BLOCK — `echo x > src/app.py`→**2**, `echo x>src/app.py`→**2**, `&>`/`>|`/`2>`→**2**. Crux edge (quoted op + real redirect together) blocks on the real one: `echo '>' > src/app.py`→**2**, `grep '>' src/app.py > src/out.py`→**2**. NIT-1: `vim -es`/`ex -s` now named in the ceiling comment. No new finding. Deviation (adapters/README.md:21): ACCEPTED. Drift `OK` rc=0; diff scope adapters/+install.sh+docs only; zero new deps. Regression clean.

The iteration-1 FULL_REVIEW findings and verification below are retained for the record.

## Reconciliation (iteration 2)

Scope: fix delta (`role-gate.sh` only this pass) + regression. Fix report: `docs/superpowers/reviews/2026-08-11-fix-report-enforcement.md`.

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| MAJOR-1 (`sed --in-place` FN) | Open (Major) | **Closed** | `inplace_flag()` ORs the short-form regex with `a=="--in-place" or a.startswith("--in-place=")`, applied to sed + perl. Re-ran: long forms→2, short→2, non-writing `sed … > /dev/null`→0 (no over-block). |
| MAJOR-2 (quoted-operator FP) | Open (Major) | **Closed** | Redirect scan now runs on a quote-preserving `shlex(posix=False)` pass; quoted `'>'` keeps its quotes (REDIR misses), unquoted `>` stays bare (REDIR hits). Verified both directions + the mixed-in-one-command crux. |
| NIT-1 (`vim -es`/`ex -s` slip) | Open (Nit) | **Closed** | Named in the `ponytail:` ceiling comment (role-gate.sh:93) per honest-ceiling posture; not chased. Consistent with the other named evasions. |

Late findings (iteration 2): **None.** Adversarially re-probed the `posix=False` change for new false positives/negatives (`echo "x" > src`, `echo 'hello world' > src`, double-quoted paths, `awk '$1>2'`) — all correct.

## Verification Log (iteration 2)

Re-ran the assembled gate on Python 3.14.6 in the scratch project (`state: FULL_REVIEW`), crafted PreToolUse JSON on stdin.

| Item | Method | Result | Evidence |
|---|---|---|---|
| MAJOR-1 closed | run gate | PASS | `sed --in-place 's/a/b/' src/app.py`→2, `sed --in-place=.bak`→2, `sed -i`→2, `perl -pi`→2; `sed 's/a/b/' src > /dev/null`→0, `sed 's/a/b/' src`→0 |
| MAJOR-2 quoted-op allow | run gate | PASS | `grep '>' src/app.py`→0, `grep -rn '>>' src/`→0, `rg '>' src`→0, `grep -F '>&' …`→0, `echo '>' src/app.py`→0 |
| MAJOR-2 real redirect block | run gate | PASS | `echo x > src/app.py`→2, `echo x >> src/app.py`→2, `echo x>src/app.py`→2, `&>`→2, `>|`→2, `2>`→2 |
| MAJOR-2 crux (quoted+real together) | run gate | PASS | `echo '>' > src/app.py`→2, `grep '>' src/app.py > src/out.py`→2 (blocks on the real redirect) |
| NIT-1 named | grep | PASS | role-gate.sh:93 names `vim -es`/`vim -c`/`ex -s` |
| Regression — review matrix | run gate | PASS | pytest/semgrep/git diff·status·log/cat/grep TODO/npm test·install/ls/`2>&1`/`&> /tmp`/`git apply --check`/`patch --dry-run`/allowlisted writes all →0 |
| Regression — writers still block | run gate | PASS | dd/git restore/cp/mv/truncate/ed/tee/python write/`r+` all →2 |
| Edit/Write path byte-identity | diff stderr vs `main` | PASS | `Edit src/app.py`→2/2 block message byte-identical; Write artifact→0 |
| Drift / diff scope / deps | build-protocol.sh --check; git diff; grep import | PASS | drift `OK` rc=0; scope = role-gate.sh, install.sh, README.md, docs/faq.md, adapters/README.md; imports `json,os,re,sys,glob,shlex` stdlib only |

Deviation (adapters/README.md:21): **ACCEPTED** — unchanged ruling from iteration 1 (in-scope honesty fix; reverting reintroduces an overclaim). Not a finding.

---

## Verdict (iteration 1 — FULL_REVIEW, superseded)

GATE_NOT_MET
Blockers: 0 open | Majors: 2 open | Minor: 0 | Nit: 1

Two Majors, each independently reproduced by re-running the gate (not trusting the impl package): one advertised-class **false negative** (`sed --in-place` slips) and one **false positive** blocking a legitimate read-only review command (`grep '>' src/`). Both are the exact failure modes the FULL tier dispatch told me to hunt beyond the AC matrix; both have narrow, low-risk fixes. Everything else — the redirect crux, the 22-command allow matrix, the ceiling honesty, Edit/Write byte-identity, install migration, drift/scope — verified clean.

## Scope Evaluated

Implementation of G1 enforcement hardening: `adapters/claude-code/role-gate.sh` (Bash denylist branch), `install.sh` (matcher + migration), copy in `README.md`, `docs/faq.md`, and the deviation file `adapters/README.md`. Re-ran the gate against the full AC-F-01/02 matrix plus reviewer-authored adversarial cases (advertised-class FN hunt + quoted-operator FP hunt). Verified drift, diff scope, install idempotency/migration, Edit/Write regression byte-identity, ceiling comment + AC-F-06 live bypasses, overclaim grep.

## Scope Changes

None. (The implementer's 5th-file deviation, `adapters/README.md:21`, is dispositioned below — accepted, not a finding.)

## Reconciliation

Prior report: PLAN_REVIEW iteration 2 (GATE_MET, 1 deferred Minor).

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| MINOR-4 (interpreter `r+` update-mode slips) | Deferred to impl | **Closed** | Implementer folded in broader than recommended: `WRITE_IND`/`WRITE_TARGET` mode class is now `['\"][^'\"]*[wax+]`. Re-ran: `open('src/app.py','r+').write('x')` → exit 2. Verified. |

Late findings (per R-60): **MAJOR-1** (`sed --in-place` FN) and **MAJOR-2** (`grep '>'` FP) — both surfaced only by executing the assembled gate adversarially; neither is a regression, both are gaps in the newly-added Bash branch.

## Acceptance Status

N/A — FULL_REVIEW (not FINAL). All plan ACs re-executed; results in Verification Log. AC-F-01/02 pass as written; the two Majors live OUTSIDE the enumerated matrix, in the reviewer's mandated beyond-matrix hunt.

## Findings

### MAJOR

**MAJOR-1 — `sed --in-place` (GNU long option) bypasses the advertised `sed -i` denylist row.**
`role-gate.sh:204` — `if cmd == "sed" and any(a.startswith("-i") for a in raw)`. GNU sed's documented long form of `-i` is `--in-place`, and `"--in-place".startswith("-i")` is **False**, so it is never matched.
Reproduced (state=FULL_REVIEW): `sed --in-place s/a/b/ src/app.py` → **exit 0**; `sed --in-place=.bak s/a/b/ src/app.py` → **exit 0** (both should be 2). Controls confirm the class is otherwise closed: `sed -i.bak … src/app.py`→2, `sed -i '' … src/app.py`→2, `sed -e … -i src/app.py`→2.
This is not a named-ceiling evasion (the ceiling names `sh -c`/helper-scripts/here-docs/encoded/awk-internal — not this). It is the identical in-place edit of the row's headline example, spelled with the long option, silently writing project source in a NO_EDIT state on any GNU/Linux box (where installed projects run CI). A model reaching for `--in-place` is not evading — it is an ordinary alternate spelling. Per the dispatch ("an ORDINARY source-write still slipping through the ADVERTISED class → Major"), Major. Fix: `any(a == "-i" or a.startswith("-i") or a.startswith("--in-place") for a in raw)`, plus an AC-F-01 `sed --in-place` row.

**MAJOR-2 — Quoted redirect-operator argument false-positives; blocks legitimate `grep '>'` review commands.**
`role-gate.sh:253` tokenizes with `shlex(posix=True, punctuation_chars=True)`, which **discards quote information**: an argument that is exactly a redirect operator collapses to a bare operator token indistinguishable from a real redirect. `scan_redirects` (line 123) then reads the *following* argument as a redirect target.
Reproduced (state=FULL_REVIEW, all should be 0): `grep -rn '>' src/` → **exit 2**; `grep -n '>>' src/app.py` → **2**; `grep '>' src/app.py` → **2**; `rg '>' src` → **2**; `grep -F '>&' src/app.py` → **2**; `echo '>' src/app.py` → **2**. Proof: `shlex(...)` of `grep -rn '>' src/` yields `['grep','-rn','>','src/']` — the quoted literal is gone. The block emits the spurious "matches a source-write pattern" message on a read-only grep. (Narrow: only when the quoted arg reduces to exactly `>`/`>>`/`>&`/`&>`/`&>>`/`>|` AND the next token is an in-project path — `grep '2>' …`→0, `grep 'foo > bar' …`→0, `grep 'TODO' …`→0 all pass.)
`grep` is in the dispatch's review matrix; grepping source for `>`/`>>` (comparisons, C++ shift/generics, shell redirects) is a genuine review action. Dispatch rule: "A blocked legit review command = Major." Fix requires distinguishing quoted operators from real ones — e.g. scan the raw command for operators only in unquoted positions before relying on the stripped token stream, or reject a REDIR token as a redirect when the following token is a plain path but the operator originated inside quotes. Not a one-liner; the shlex-posix approach inherently loses this distinction.

### NIT

**NIT-1 — `vim -es src/app.py` (ex-mode scripted edit) slips.**
`role-gate.sh:240` enumerates `ex`/`ed` but not `vim`/`nvim -es`, which perform the same scripted in-place edit. `vim -es src/app.py` → exit 0. Outside the advertised class (denylist lists ex/ed only), so Nit not Major; consider adding `vim`/`nvim` to the editor row. Deferrable.

## Verification Log

Machine evidence (R-110): re-ran the assembled `adapters/claude-code/role-gate.sh` on Python 3.14.6 in a scratch project (`.heatwave/runs/t/state.yaml`, seeded `src/app.py`, `docs/design/`), feeding crafted PreToolUse JSON on stdin and asserting exit codes. shellcheck NOT AVAILABLE (`command -v` rc=1) — substituted `sh -n` + execution matrix per Tooling Declaration (R-64).

| Item | Method | Result | Evidence |
|---|---|---|---|
| Redirect crux (`>`,`>>`,`&>`,`&>>`,`>|`,`>&`,`2>`,`1>>`) block to in-project path | run gate | PASS | all → exit 2 |
| Denylist writes (sed -i, perl -i, dd of=, patch, git apply/restore/checkout --, cp, mv, tee, truncate, ed, install, python/node/ruby writes incl. `r+`/`a`) | run gate | PASS | all → exit 2 (24/24) |
| **Advertised-class FN hunt** | adversarial run | **FAIL (MAJOR-1)** | `sed --in-place`→0, `sed --in-place=.bak`→0 |
| False positives — review matrix + fd-dup + allowlisted/out-of-root writes | run gate | PASS (22/22) | pytest/semgrep/git diff·log·status/cat/npm test·install/ls/`2>&1`/`awk '$1>2'`/`patch --dry-run`/`git apply --check`/read-mode open/`&> /tmp`/`>| .heatwave/**`/`docs/design/*.md` all →0 |
| **Quoted-operator FP hunt** | adversarial run | **FAIL (MAJOR-2)** | `grep '>' src/`→2, `grep '>>' src/app.py`→2, `rg '>' src`→2, `grep -F '>&' …`→2 |
| Editor coverage | adversarial run | NIT-1 | `vim -es src/app.py`→0 |
| IMPLEMENTING/FIXING + no-active-run allow | run gate | PASS | sed/echo>/python-write →0; DONE state →0 |
| AC-F-06 ceiling bypasses shown, not hidden | run gate | PASS | helper-script→0, `sh -c`→0; ponytail: comment names them; copy caveats present |
| Edit/Write path byte-identical vs `main` gate | diff stderr | PASS | `Edit src/app.py`→2/2 block message byte-identical; artifacts/design-doc→0; `vendor/docs/design/x.md`→2 |
| Install idempotent + old→new migration | run install.sh ×4 | PASS | fresh→`Edit\|Write\|Bash`; re-run→"skipped", diff empty; seed old→migrated; re-run→no diff |
| Drift + diff scope | `build-protocol.sh --check`; `git diff --name-only` | PASS | drift `OK` rc=0; scope = role-gate.sh, install.sh, README.md, docs/faq.md, adapters/README.md; protocol/+PROTOCOL.md untouched; other adapters untouched |
| Overclaim grep / zero deps | grep; import inspection | PASS | `physically block\|prevent\|cannot bypass` → none; imports `json,os,re,sys,glob,shlex` stdlib only |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| AC-N-01 latency ≤150 ms | Trusted impl (33.5 ms); NO_EDIT-first short-circuit confirmed by reading — not re-timed | AC-N-01 |
| MAJOR-1/2 fixes | Not yet implemented — deferred to FIXING | AC-F-01 (`sed --in-place` row), AC-F-02 (`grep '>'` row) |

## Deviation disposition (adapters/README.md:21)

**Accepted — not a scope finding.** The implementer softened a PRE-EXISTING overclaim ("physically blocks source edits") to "blocks the agent's Edit/Write and common shell source-writes at the tool layer … best-effort, not a filesystem sandbox." It is a 5th file beyond the plan's enumerated four, but (a) squarely within the dispatch's "adapters/ + docs" scope, (b) fixes a genuine honesty defect — the original claim is made more wrong by G1's newly-documented bypass ceiling, and AC-F-07's own `physically block` grep would otherwise flag it, (c) flagged transparently as a deviation for the reviewer, not self-approved, (d) drift stays `OK`, protocol untouched. Reverting would reintroduce an overclaim. Keep it.

## Summary

The core of G1 is sound. The redirect crux — the MAJOR-1 the plan-review fixed — is genuinely closed: I re-ran every operator form (`>` `>>` `&>` `&>>` `>|` `>&` `2>` `1>>`) to an in-project path and all block, while fd-dup (`2>&1`, `>&2`), out-of-root (`&> /tmp`), and allowlisted (`>| .heatwave/**`) targets all allow. The 22-command review matrix is clean, the interpreter `r+` gap from plan-review is closed, the Edit/Write path is byte-identical to `main` (block message included), install migrates the old `Edit|Write` matcher exactly once and stays idempotent, drift is `OK`, the diff is scoped, and the honesty ceiling is real — the `ponytail:` comment names the evasions and AC-F-06 demonstrates two live bypasses (`sh -c` and helper-script) rather than hiding them, with no surviving "physically block/prevent/cannot bypass" copy anywhere.

But the FULL tier exists precisely to hunt the two failure modes past the matrix, and both are present. MAJOR-1: `sed --in-place`, the GNU long spelling of the denylist's own headline `sed -i` example, slips to exit 0 and writes source in a NO_EDIT state — an ordinary, non-evasive command, not a named ceiling item. MAJOR-2: because `shlex` posix mode discards quotes, a quoted argument that is exactly a redirect operator (`grep '>' src/`) collapses into a real-redirect token and false-blocks a read-only review command with a spurious source-write message — the expensive failure the plan itself flagged as the one to avoid. Neither reopens the redirect crux and both are low-risk, but each independently trips the dispatch's stated Major bar (advertised-class FN; blocked legit review command). MAJOR-1's fix is one clause; MAJOR-2's needs quote-aware operator detection, which the current shlex-posix approach cannot express as-is. GATE_NOT_MET → FIXING. NIT-1 (`vim -es`) is deferrable. The deviation is accepted.
