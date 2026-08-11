# Review Report — FINAL_REVIEW

task_id: 2026-08-11-enforcement-hardening | artifact_type: review-report | review_type: FINAL_REVIEW | produced_by: REVIEWER (claude-opus-4-8, FRESH context) | timestamp: 2026-08-12 | branch: `heatwave-v4-enforcement-hardening` (base `main` = A–F + E2)

## Verdict

**APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 0
Every AC (13/13) VERIFIED with my own machine evidence (R-66). Completion gate met (R-77).

I did not write or previously review this. All results below come from re-running the assembled gate (`adapters/claude-code/role-gate.sh`, Python 3.14.6) on crafted PreToolUse stdin JSON in a scratch project — not from trusting the impl/fix packages.

## Independent bypass hunt (my own forms, beyond the AC matrix)

17 ordinary advertised-class source-writes to `src/app.py` in `state: FULL_REVIEW`, **all → exit 2**: `>|`, numbered-fd `1>>`, glued `&>src`, `sed --in-place`, `sed -i.bak`, `python open(...,'r+')`, `python open(...,'a')`, `dd of=`, `tee`, real `patch`, `git apply`, `node writeFileSync`, `cp` into src, `mv` src out, `true && sed -i`, pipeline-segment `tee`, command-substitution `$(sed -i …)`. **Nothing in the advertised class slipped.** The two FULL_REVIEW Majors are confirmed closed: `sed --in-place`/`--in-place=.bak` block; quoted-operator FP fixed.

Known documented evasions confirmed still slipping AND named in the `ponytail:` ceiling (role-gate.sh:88–96): `sh -c 'echo x > src'`→0, `printf>/tmp/w.sh && sh w.sh`→0, `vim -es`→0. Honest ceiling intact.

## False-positive check

20 legitimate commands → **all exit 0**, zero false blocks: `grep '>'`, `rg '>'`, `grep -rn '>>'`, fd-dup `2>&1`, `awk '$1>2'`, `patch --dry-run`, `git apply --check`, pytest/semgrep/git diff/cat/npm test/npm install/ls, allowlisted `.heatwave/**` + `docs/design/*.md` writes, out-of-repo `&>/tmp`, read-mode `open().read()`, `sed -n`, interpreter write to `docs/design`. The review matrix is clean.

## §8.3 production-readiness (each PASS with evidence)

| Item | Result | Evidence |
|---|---|---|
| Edit/Write path byte-identical (regression) | PASS | `Edit src/app.py` stderr byte-identical to `main` gate; Edit→2, Write artifact→0, Write design.md→0, vendor/docs/design→2 |
| Matcher `Edit\|Write`→`Edit\|Write\|Bash` | PASS | install.sh:110 diff |
| Install idempotent + migration re-runnable | PASS | isolated hook block: fresh→`Edit\|Write\|Bash`; re-run→SKIPPED/unchanged; seed old `Edit\|Write`→migrated; re-run→SKIPPED/unchanged |
| Zero new deps | PASS | imports `json,os,re,sys,glob,shlex` (stdlib); POSIX sh + existing python3 |
| protocol/ + PROTOCOL.md UNTOUCHED | PASS | diff name-only excludes them; `build-protocol.sh --check` → `OK` rc=0 |
| Diff scope | PASS | code+copy = role-gate.sh, install.sh, README.md, docs/faq.md, adapters/README.md (+ docs/superpowers artifacts) |
| Other adapters' gating unchanged | PASS | no codex/gemini/cursor/aider/generic file touched |
| No secrets | PASS | gitleaks over the diff → no leaks found |
| POSIX-sh valid | PASS | `sh -n` both files → OK |
| Latency (AC-N-01) | PASS | 20× worst-path (tee+redir, NO_EDIT active) mean **32.2 ms** ≤150 |

## Ceiling honesty (no re-overclaim)

No surviving unscoped "physically block / prevent / cannot bypass / complete enforcement" on the branch (grep over README.md, docs/faq.md, adapters/ → empty; the only hit is the pre-existing overclaim on `main:adapters/README.md:21`, correctly softened on branch). "not a filesystem sandbox" present in all three copy files; `sh -c`/`eval` string-indirection named in README + faq; AC-F-06 demonstrates two live bypasses rather than hiding them. Deviation (adapters/README.md 5th file) accepted — reverting reintroduces an overclaim.

## Acceptance status

| AC | Status | Evidence |
|---|---|---|
| AC-F-01 block writes | VERIFIED | 17/17 advertised-class forms → 2 |
| AC-F-02 allow review cmds | VERIFIED | 20/20 → 0 |
| AC-F-03 IMPLEMENTING/FIXING allow | VERIFIED | sed -i / Edit → 0 under IMPLEMENTING |
| AC-F-04 Edit/Write byte-identical | VERIFIED | stderr identical vs main |
| AC-F-05 no run → allow | VERIFIED | DONE state echo>src → 0 |
| AC-F-06 ceiling shown | VERIFIED | sh -c / helper-script / vim -es slip, named |
| AC-F-07 copy honest | VERIFIED | greps above |
| AC-F-08 install idempotent+migration | VERIFIED | 4-run cycle |
| AC-F-09 red→green | VERIFIED | OLD echo>src → 0, NEW → 2 |
| AC-N-01 latency ≤150ms | VERIFIED | 32.2 ms |
| AC-N-02 sh -n | VERIFIED | both OK |
| AC-N-03 zero deps | VERIFIED | stdlib imports only |
| AC-N-04 drift/scope | VERIFIED | drift OK, scope clean |

## Not verified

None material. shellcheck NOT AVAILABLE (declared, `sh -n` + execution matrix substituted, R-64); mutation testing NOT AVAILABLE (declared, adversarial matrix substituted). Neither blocks an AC.

## Summary

G1 closes the verified Bash source-write bypass as a best-effort, honestly-documented denylist. My fresh independent hunt found nothing in the advertised class slipping and no legitimate review command false-blocked; the two prior Majors are genuinely closed; Edit/Write is byte-identical; install migrates once and stays idempotent; drift `OK`; diff scoped to adapters+install+docs; protocol untouched; zero new deps; no secrets; ceiling honesty holds with two live bypasses demonstrated. Completion gate met.
