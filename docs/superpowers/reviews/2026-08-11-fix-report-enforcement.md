# Fix Report — Enforcement Hardening (G1)

task_id: 2026-08-11-enforcement-hardening | artifact_type: fix-report | produced_by: IMPLEMENTER/FIXER (claude-opus-4-8) | timestamp: 2026-08-12 | branch: `heatwave-v4-enforcement-hardening`

Responding to `docs/superpowers/reviews/2026-08-11-full-review-enforcement.md` (GATE_NOT_MET: 2 Majors, 1 Nit). Per-finding schema (§3.5). Fix commit: `fix(v4-G1): catch sed --in-place; stop false-blocking quoted operators (grep '>')`.

---

```
Finding ID:   MAJOR-1 — sed --in-place / --in-place=.bak slip (advertised-class false negative)
Response:     Fixed
Root cause:   scan_tools used `a.startswith("-i")` (sed) / `re.match(r'^-[A-Za-z]*i', a)` (perl),
              which match only the SHORT flag. GNU long form `--in-place` / `--in-place=<suffix>`
              (second char '-', not a letter) matched neither → the in-place branch never fired →
              the command fell through to default-ALLOW (exit 0).
Change:       adapters/claude-code/role-gate.sh — new helper inplace_flag(raw, short_re) that ORs the
              short-form regex with `a == "--in-place" or a.startswith("--in-place=")`. Applied to
              BOTH sed (short `^-i`) and perl (short `^-[A-Za-z]*i`) consistently (perl has no native
              long form, but covering it is harmless and matches the reviewer's consistency ask). The
              downstream rule is unchanged: nonopt args minus the script; any non-allowlisted → block.
              Other denylisted tools reviewed for user-typed long forms: dd (`of=` only), patch
              (`--dry-run` already long), git apply (`--check`/`--stat` already long), cp/mv/install/
              truncate/ex/ed take PATHS not in-place flags — no long-form in-place equivalent to add.
Verification: Method = feed each as Bash PreToolUse JSON in state FULL_REVIEW, assert exit 2.
Evidence:     `sed --in-place 's/a/b/' src/app.py`      → exit 2
              `sed --in-place=.bak 's/a/b/' src/app.py` → exit 2
              (short forms unchanged: `sed -i …` → 2; `perl -pi -e …` → 2; the full 26-row AC-F-01
              battery all exit 2, no regression. Under IMPLEMENTING `sed --in-place` → 0.)

Finding ID:   MAJOR-2 — grep '>' / grep '>>' / rg '>' false-blocked (breaks legit review)
Response:     Fixed
Root cause:   The redirect scan tokenized with shlex posix=True, which DISCARDS quoting. A quoted
              literal operator argument (`grep '>' src`) collapsed to a bare `>` token identical to a
              real unquoted redirect (`echo x > src`) → REDIR matched → block (exit 2).
Change:       adapters/claude-code/role-gate.sh — factor a `lex(s, posix)` helper and run scan_redirects
              on a quote-PRESERVING pass `lex(body_stripped, False)` (posix=False). Non-posix shlex keeps
              the surrounding quotes in the token, so `'>'` tokenizes as `"'>'"` (REDIR does not match)
              while an unquoted `>` tokenizes as a bare `>` (REDIR matches). The tool/interpreter segment
              scan still uses the posix=True token list (it needs quote-stripped args + interpreter code).
              Redirect TARGETS keep quotes under non-posix but allowed_target already strips them.
Verification: Method = feed each as Bash PreToolUse JSON in FULL_REVIEW; assert BOTH directions.
Evidence:     Quoted-operator review commands now ALLOW:
                `grep '>' src/app.py`   → exit 0
                `grep -rn '>>' src/`    → exit 0
                `rg '>' src`            → exit 0
              Real unquoted redirects still BLOCK (regression-guard both directions):
                `echo x > src/app.py`   → exit 2
                `echo x >> src/app.py`  → exit 2
              Glued forms still block (`echo x>src/app.py` tokenizes `['echo','x','>','src/app.py']`);
              fd-dup `2>&1` → 0, `awk '$1 > 2'` → 0, `&> /tmp` → 0, `>| .heatwave/**` → 0 all retained.

Finding ID:   NIT-1 — vim -es / ex scripted edits slip
Response:     Fixed (documented per honest-ceiling posture)
Change:       Added "a scripted-editor invocation (vim -es / vim -c 'w' / ex driven by a -s script)"
              to the `ponytail:` ceiling comment in role-gate.sh. (`ex <file>` / `ed <file>` are already
              BLOCKED by denylist rows 15; the residual gap is `vim` in ex/silent mode, which is an
              editor-scripting evasion — named, consistent with sh -c/eval/here-doc, not chased.)
Verification: grep confirms the line is present in the comment.
Evidence:     role-gate.sh ceiling comment now names vim -es / vim -c / ex -s.
```

---

## Re-run of the full AC battery (post-fix)

| Group | Result |
|---|---|
| AC-F-01 (block, 24 orig + 2 new sed long-form = 26 rows) | all exit **2** — no regression |
| AC-F-02 (allow, 22 orig + 3 new grep/rg = 25 rows) | all exit **0** — review matrix clean, zero false positives |
| AC-F-03 IMPLEMENTING/FIXING allow-all (incl. `sed --in-place`) | exit **0** |
| AC-F-04 Edit/Write path vs pre-G1 (`role-gate-OLD.sh`) | exit + stderr **byte-identical** (IDENTICAL on all rows) |
| AC-F-06 ceiling bypasses (`sh -c …`, `printf>/tmp/w.sh && sh /tmp/w.sh`) | exit **0** — still slip, shown honestly |
| AC-N-01 latency (20×, worst path) | mean **31.7 ms** (≤150) |
| AC-N-02 `sh -n` role-gate.sh + install.sh | **OK** |
| SAST semgrep over role-gate.sh | rc **0**, no findings |
| AC-N-03 zero new deps | imports still `json, os, re, sys, glob, shlex` (stdlib) |
| AC-N-04 drift `sh build-protocol.sh --check` | **OK: PROTOCOL.md matches protocol/ shards** |
| AC-N-04 diff scope `git diff main..HEAD --stat` | `README.md`, `adapters/README.md`, `adapters/claude-code/role-gate.sh`, `docs/faq.md`, `install.sh` (+ `docs/superpowers/**` artifacts) — adapters/ + install.sh + docs only |

Both-directions proof (the reviewer's critical ask): every real unquoted redirect/writer still BLOCKS; every quoted-operator review command (grep/rg) now ALLOWS; fd-dup / awk / patch --dry-run / git apply --check still allow; Edit/Write byte-identical; demonstrated bypasses still slip and are still documented.

## Files changed by this fix

`adapters/claude-code/role-gate.sh` only (commit on branch). Diff scope, drift, and dep-count all unchanged from the implementation package; the earlier AC-F-07c copy deviation (`adapters/README.md`) is unaffected and still stands for REVIEWER judgement.

## Ceiling (unchanged, honest)

Still a best-effort denylist, NOT a filesystem sandbox. Named un-chased evasions now include `vim -es`/`ex -s` scripted editing alongside sh -c/eval/xargs, helper scripts, here-docs, base64, chmod+x&&run, and quoted-program redirects. AC-F-06 demonstrates two live. Not complete enforcement.
