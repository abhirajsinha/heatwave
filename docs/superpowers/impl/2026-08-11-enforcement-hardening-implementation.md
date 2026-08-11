# Implementation Package — Enforcement Hardening (G1, cheap track)

task_id: 2026-08-11-enforcement-hardening | artifact_type: implementation-package | produced_by: IMPLEMENTER (claude-opus-4-8) | timestamp: 2026-08-12 | branch: `heatwave-v4-enforcement-hardening` (off `main` @ d614d19)

Spec: `docs/superpowers/plans/2026-08-11-enforcement-hardening.md` (APPROVED, PLAN_REVIEW-passed). Design: `docs/specs/2026-08-11-enforcement-hardening-design.md`. Review: `docs/superpowers/reviews/2026-08-11-plan-review-enforcement.md` (MINOR-4 folded in — see below).

## Summary

The Claude Code `PreToolUse` gate now also intercepts Bash. In a NO_EDIT state (PLANNING, PLAN_REVIEW, FULL_REVIEW, TARGETED_REVIEW, FINAL_REVIEW, EXPRESS_CHECK) it exits 2 on shell source-writes to a non-allowlisted path; everything else exits 0. Edit/Write path is byte-identical to HEAD. Adapter + docs only; no protocol shard; drift `OK`.

**MINOR-4 folded in (broader than the review's one-char fix):** the interpreter write-indicator now matches any file mode containing `w`, `a`, `x`, OR `+` (`['\"][^'\"]*[wax+]` in both `WRITE_IND` and `WRITE_TARGET`), so `r+`, `w+`, `a+`, `rb+`, `r+b` all classify as writes. New AC-F-01 row `open('src/app.py','r+').write('x')` → exit 2 (evidence below).

## Files changed (committed, `git diff main..HEAD --stat`)

```
 README.md                         |   2 +-
 adapters/README.md                |   2 +-
 adapters/claude-code/role-gate.sh | 260 +++++++++++++++++++++++++++++--
 docs/faq.md                       |   2 +-
 install.sh                        |   9 +-
 5 files changed, 247 insertions(+), 28 deletions(-)
```
- `protocol/` + `PROTOCOL.md` untouched (`grep` name-only empty). Other adapters untouched (only `claude-code/role-gate.sh` + `adapters/README.md`).
- Commits: `23e8f58` (T1 role-gate.sh), `746b302` (T2 install.sh), `f52bd38` (T3 copy).

## Blast radius

The gate now runs on **every** Bash call in every installed Claude Code project. Fail-safe: no NO_EDIT run → immediate exit 0 (before any parsing). Malformed JSON / unreadable state / `shlex` ValueError all degrade toward allow. Worst case of a bug is a false-positive block of a reviewer's shell command (recoverable: state→IMPLEMENTING) — never data loss. Takes effect only when `install.sh` is re-run in a project (copies new gate + migrates matcher). Rollback: `git revert` + reinstall; old-matcher-but-old-gate projects degrade to pre-G1 (old gate exits 0 when `file_path` absent).

## Test harness (reproducible)

Scratch dir `gt/`: `.heatwave/role-gate.sh` = the changed gate, `.heatwave/role-gate-OLD.sh` = `git show HEAD:…` (pre-change), `.heatwave/runs/t/state.yaml` sets the state, `src/app.py` seeded, `docs/design/` present. JSON fed on stdin; exit code asserted. Full commands + outputs pasted per AC.

---

## Acceptance Criteria → evidence

### AC-F-01 | Bash source-writes blocked in NO_EDIT (expect exit 2) — PASS

All 24 forms exit **2** under `state: FULL_REVIEW` (and `sed`/`&>` spot-checked exit 2 under PLANNING and EXPRESS_CHECK):

| command | exit |
|---|---|
| `sed -i 's/a/b/' src/app.py` | 2 |
| `echo hacked > src/app.py` | 2 |
| `echo more >> src/app.py` | 2 |
| `echo pwned &> src/app.py` | 2 |
| `echo pwned &>> src/app.py` | 2 |
| `echo pwned >| src/app.py` | 2 |
| `echo pwned >& src/app.py` | 2 |
| `echo pwned 2> src/app.py` | 2 |
| `python3 -c "open('src/app.py','w').write('x')"` | 2 |
| `cat /tmp/x \| tee src/app.py` | 2 |
| `perl -pi -e 's/a/b/' src/app.py` | 2 |
| `dd if=/tmp/x of=src/app.py` | 2 |
| `patch src/app.py < /tmp/fix.patch` | 2 |
| `git apply /tmp/x.patch` | 2 |
| `git restore src/app.py` | 2 |
| `git checkout -- src/app.py` | 2 |
| `cp /tmp/evil.py src/app.py` | 2 |
| `mv src/app.py /tmp/` | 2 |
| `truncate -s 0 src/app.py` | 2 |
| `ed src/app.py` | 2 |
| `node -e "require('fs').writeFileSync('src/a.js','x')"` | 2 |
| `ruby -e "File.write('src/app.py','x')"` | 2 |
| `true && echo x > src/app.py` | 2 |
| **`python3 -c "open('src/app.py','r+').write('x')"` (MINOR-4)** | **2** |

Redirect forms blocked: `>`, `>>`, `&>`, `&>>`, `>|`, `>&<file>`, numbered-fd `2>`. Spot-check: `PLANNING sed=2`, `PLANNING &>=2`, `EXPRESS_CHECK sed=2`, `EXPRESS_CHECK &>=2`.

### AC-F-02 | Legitimate review-stage commands allowed (expect exit 0) — PASS

All 22 exit **0** under `state: FULL_REVIEW`: `pytest -q`, `semgrep scan --config auto`, `git diff`, `git status && git log --oneline -5`, `cat src/app.py`, `grep -rn TODO src/`, `npm test`, `npm install`, `echo note > .heatwave/runs/t/notes.md`, `echo note >| .heatwave/runs/t/notes.md`, `pytest -q | tee .heatwave/runs/t/out.log`, `echo plan > docs/design/task.md`, `python3 -c "open('docs/design/task.md','w').write('x')"`, `pytest > /tmp/out.log 2>&1`, `pytest &> /tmp/out.log`, `ls > /dev/null`, `awk '$1 > 2' data.txt`, `sed -n '1,10p' src/app.py`, `python3 -c 'print(open("src/app.py").read())'`, `git apply --check /tmp/x.patch`, `patch --dry-run src/app.py < /tmp/fix.patch`, `echo x 2>&1`.

Key controls confirmed: fd-dup `2>&1`=0; `&> /tmp` and `>| .heatwave/**`=0; interpreter write to `docs/design/*.md`=0 (allowlist parity, MINOR-1); `patch --dry-run`=0 (MINOR-2); read-mode `open(...).read()`=0; `awk '$1 > 2'` (quoted `>`)=0. **17+ command review matrix: clean, zero false positives.**

### AC-F-03 | IMPLEMENTING/FIXING allow everything (expect 0) — PASS

Under `state: IMPLEMENTING` then `state: FIXING`, each of `sed -i`, `echo >`, `echo &>`, `python3 -c open(...'w')`, `git restore` → exit **0** (all 10 = 0).

### AC-F-04 | Edit/Write path unchanged — PASS (proved byte-identical vs HEAD)

Compared OLD (`git show HEAD:…`) vs NEW on identical inputs — same exit code AND same stderr (`diff -q`):

| input | OLD | NEW | result |
|---|---|---|---|
| `Edit src/app.py` (FULL_REVIEW) | 2 | 2 | IDENTICAL |
| `Write .heatwave/runs/t/plan.md` | 0 | 0 | IDENTICAL |
| `Edit CLAUDE.md` (bare) | 2 | 2 | IDENTICAL |
| `Edit ./CLAUDE.md` | 0 | 0 | IDENTICAL |
| `Edit <abs>/CLAUDE.md` | 0 | 0 | IDENTICAL |
| `Write docs/design/task.md` | 0 | 0 | IDENTICAL |
| `Write vendor/docs/design/x.md` | 2 | 2 | IDENTICAL |
| `Edit src/app.py` (IMPLEMENTING) | 0 | 0 | IDENTICAL |

Note: the plan's AC-F-04 shorthand `Edit CLAUDE.md → 0` holds for `./CLAUDE.md` and absolute paths (how Claude Code passes them); the **bare** string `CLAUDE.md` returns 2 in BOTH old and new gate (the pre-existing allowlist matches `/CLAUDE.md`). Behaviour is unchanged either way — the mandate is met. Block message byte-identical (stderr diff empty).

### AC-F-05 | No active run → allow (expect 0) — PASS

`.heatwave/runs/` with no NO_EDIT state: `sed -i`=0, `echo >`=0, `echo &>`=0, `Edit src/app.py`=0.

### AC-F-06 | Ceiling bypass demonstrated honestly (expect 0 — slips) — PASS

Under `state: FULL_REVIEW`, both DEMONSTRATED LIVE, shown not hidden:

| bypass | exit | why it slips |
|---|---|---|
| `printf 'echo pwned > src/app.py' > /tmp/w.sh && sh /tmp/w.sh` | **0** | write is to `/tmp` (outside root); `sh /tmp/w.sh` matches no pattern |
| `sh -c 'echo pwned > src/app.py'` | **0** | string-indirection — the write collapses into one unscanned quoted token (named MINOR-3 evasion) |

Matches the `ponytail:` ceiling comment and the README/faq "not a filesystem sandbox / lands in the audit trail" copy. NOT fixed, NOT hidden — this is the honest ceiling.

### AC-F-07 | Copy honest — PASS

- `grep -n "sandbox\|shell source-writes" README.md docs/faq.md` → both files show hardened wording + retained "not a filesystem sandbox".
- `grep -niE "sh -c|eval|helper script|here-doc" README.md docs/faq.md` → both name the indirection/ceiling evasions.
- `grep -inE "physically (block|prevent)|completely prevent|cannot bypass" README.md docs/faq.md adapters/ -r` → **(none)**. (Required softening a pre-existing overclaim in `adapters/README.md:21` — see Deviations.)

### AC-F-08 | Install idempotent + migration — PASS

Scratch target: (a) fresh install → `installed protocol gate hooks`, PreToolUse gate matcher `['Edit|Write|Bash']`; (b) immediate re-run → `skipped hooks (already installed)`, `diff` of settings.json empty; (c) seed OLD `Edit|Write` gate entry + install → `after migrate: ['Edit|Write|Bash']`; (c2) re-run → `skipped hooks`, no further diff.

### AC-F-09 | Bypass closure red→green — PASS

Same scratch, OLD gate (red) vs NEW gate (green), FULL_REVIEW:

| command | OLD (pre-change) | NEW |
|---|---|---|
| `sed -i s/a/b/ src/app.py` | 0 | 2 |
| `echo x > src/app.py` | 0 | 2 |
| `echo x &> src/app.py` | 0 | 2 |
| `python3 -c "open('src/app.py','w').write('x')"` (valid-JSON fed) | 0 | 2 |

### AC-N-01 | Latency ≤150 ms mean — PASS

20 invocations, worst path (NO_EDIT active, redirect+tee command): **mean = 33.5 ms** per invocation.

### AC-N-02 | POSIX-sh valid — PASS

`sh -n adapters/claude-code/role-gate.sh` → OK; `sh -n install.sh` → OK. (shellcheck NOT AVAILABLE per Tooling Declaration — substituted `sh -n` + execution matrix, R-64.)

### AC-N-03 | Zero new dependencies — PASS

`role-gate.sh` interpreter imports: `import json, os, re, sys, glob, shlex` — all stdlib. No new `command -v`/binary/package references. POSIX sh + existing python3 only.

### AC-N-04 | No regression / drift / scope — PASS (one scope deviation, flagged)

- `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, rc=0.
- `git diff main..HEAD --stat`: `README.md`, `docs/faq.md`, `install.sh`, `adapters/claude-code/role-gate.sh`, **`adapters/README.md`**. The 5th file (`adapters/README.md`) is the AC-F-07c honesty fix — beyond AC-N-04's enumerated 4-file list but within the dispatch's stated "adapters/ + install.sh + docs" scope. See Deviations.
- AC-F-04/AC-F-05 pass → A–F gate behaviour intact.

### SAST (FULL tier)

`semgrep --error --config auto adapters/claude-code/role-gate.sh install.sh` → rc=0, no findings. (Mutation testing NOT AVAILABLE per Tooling Declaration — robustness rests on the enumerated matrix + reviewer adversarial cases, R-110/R-64.)

---

## Deviations (NOT self-approved — REVIEWER decides)

1. **`adapters/README.md:21` softened (1 clause).** Pre-existing line read "…on Claude Code, physically blocks source edits during plan/review states". AC-F-07c's overclaim grep scans `adapters/` and this line matched `physically (block|prevent)`. The plan asserted adapters/README.md needed no change (it checked only line 9), but this line is (a) caught by the honesty AC and (b) now more of an overclaim given the newly-documented bypass ceiling. Reworded to "…blocks the agent's Edit/Write and common shell source-writes at the tool layer during plan/review states — best-effort, not a filesystem sandbox". This makes AC-F-07c pass but adds a 5th file to AC-N-04's expected diff set (within the dispatch's "adapters/ + docs" scope). Reviewer may revert if they judge the original wording acceptable under F's honesty bar.

## Ponytail note

No standalone test file added: the repo has no test framework (verified — no package.json/pytest.ini/go.mod test config), the mandated diff scope is 4 named files, and the reproducible scratch-dir matrix above is the runnable check (re-run by the REVIEWER per the Testing Strategy). The gate's non-trivial parser is exercised by 24 block + 22 allow + red/green + fd-dup/quoted-`>` edge cases.

## Honest ceiling (not overclaimed)

This gate is a best-effort denylist, NOT a filesystem sandbox. Named, un-chased evasions (in the `ponytail:` comment + copy): `sh -c`/`bash -c`/`eval`/`xargs` string-indirection, helper scripts, here-docs piped to interpreters, base64-decoded content, `chmod +x && ./writer`, redirects inside quoted awk/interpreter programs, symlink tricks beyond `realpath`. AC-F-06 demonstrates two live. The real fix is the OS-sandbox track. The gate is NOT complete enforcement — it raises the ceiling and leaves bypasses in the audit trail.
