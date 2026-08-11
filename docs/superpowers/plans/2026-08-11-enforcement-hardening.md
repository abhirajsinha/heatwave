# Planning Document — Enforcement Hardening (cheap track)

task_id: 2026-08-11-enforcement-hardening | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-opus-4-8) | timestamp: 2026-08-11

Design source of truth: `docs/specs/2026-08-11-enforcement-hardening-design.md` (approved spec; this plan implements it exactly — R-106 satisfied by reference).

## Response to PLAN_REVIEW iteration 1 (R-34)

Responding to `docs/superpowers/reviews/2026-08-11-plan-review-enforcement.md` (GATE_NOT_MET: 1 Major, 3 Minor, 1 Nit). Per-finding schema (§3.5 adapted to plan findings):

```
Finding ID:   MAJOR-1 — redirect denylist (#1) misses &>, &>>, >| (and >&<path>)
Response:     Fixed
Change:       Denylist row #1 no longer tests token equality against '>'/'>>'. It now matches any
              operator token against REDIR = ^(?:>\|?|>>|&>>?|>&)$ — covering >, >>, >|, &>, &>>, >&.
              Numbered-fd forms (2>, 1>>) are covered for free: shlex(punctuation_chars=True) splits
              the leading fd digit into its own word token, leaving the operator token (>/>>) intact
              and matched (verified: 'echo x 2> src/x' -> ['echo','x','2','>','src/x']). fd-dup
              (2>&1, >&2) is excluded by target = next token being a bare digit (DIGIT = ^\d+-?$),
              so '>&' followed by a PATH blocks but '>&' followed by a digit allows. The whitespace-
              split fallback (unbalanced-quote path) regex is broadened the same way, longest-match
              ordered, to catch glued forms (&>src/x). Concrete matching logic now in the "Redirect
              scan" code block below (does NOT rely on shlex collapsing — scans raw operator tokens).
Verification: Method = feed each redirect form as a Bash PreToolUse command in a NO_EDIT state,
              assert exit 2; plus allowlisted-target controls asserting exit 0. New AC-F-01 rows
              (&>, &>>, >|, >&<file>, 2>) and AC-F-02 control rows (&> /tmp, >| .heatwave/**) added.
Evidence:     Tokenizer + REDIR/DIGIT regex behavior verified directly at plan time:
              '&>'/'&>>'/'>|'/'>&' each tokenize as own operator token; REDIR matches all six and
              rejects |,<,&&,; ; '2>&1' -> ['2','>&','1'] (target '1' = digit -> allow).

Finding ID:   MINOR-1 — interpreter branch (#16) allowlist coarser than FR-4 (only .heatwave/)
Response:     Fixed
Change:       Row #16 no longer gates on "code contains '.heatwave/'". It extracts the write call's
              PATH ARGUMENT with WRITE_TARGET (open('p','w'|'a'|'x'|'+'), writeFile[Sync]/appendFile
              [Sync]/createWriteStream('p'), File.write/open/new('p')) and runs each captured target
              through the same allowed_target() the redirect and Edit/Write paths use — so
              docs/design/task.md, CLAUDE.md, out-of-root and .heatwave/** are honored identically.
              Write-indicator present but no target extractable -> block (write-class default).
Verification: New AC row: python3 write to docs/design/*.md exits 0 (allowlist parity); write to
              src/* still exits 2 (AC-F-01 node/ruby rows retained).
Evidence:     WRITE_TARGET extractor verified: open('src/app.py','w')->['src/app.py'],
              open('docs/design/task.md','w')->['docs/design/task.md'], writeFileSync('src/a.js')->
              ['src/a.js'], read-mode open()->[] (no write indicator -> allow).

Finding ID:   MINOR-2 — patch (#8) blocks unconditionally, incl. read-only patch --dry-run
Response:     Fixed
Change:       Row #8 gains a false-positive guard symmetric to #9's git-apply --check: patch is
              allowed when a --dry-run token is present; a real patch (and git apply without
              --check/--stat) still blocks.
Verification: New AC-F-02 row: 'patch --dry-run src/app.py < /tmp/fix.patch' exits 0; AC-F-01
              retains 'patch src/app.py < /tmp/fix.patch' -> exit 2.
Evidence:     Static (command-position patch + presence of literal --dry-run token).

Finding ID:   MINOR-3 — ceiling comment/copy omit sh -c/bash -c/eval/xargs string-indirection
Response:     Fixed
Change:       The ponytail: ceiling comment and the README/FAQ copy now name command-string
              indirection (sh -c / bash -c / eval / xargs "…") as a known, deliberately-unchased
              evasion, alongside helper scripts, here-docs and encoded writes. Catching it is not
              required (FR-6 requires honesty, not capture); it is named, not hidden.
Verification: AC-F-07 grep additionally asserts the copy names the indirection; AC-F-06 unchanged
              (a live bypass is still demonstrated, not hidden).
Evidence:     Confirmed 'sh -c "echo x > src/app.py"' -> ['sh','-c','echo x > src/app.py'] (write
              collapsed into one unscanned quoted token) — hence named as ceiling.

Finding ID:   NIT-1 — AC-F-01/F-02 matrix has no &>/>| rows
Response:     Fixed
Change:       Folded into MAJOR-1: AC-F-01 gains &>, &>>, >|, >&<file>, 2> block rows; AC-F-02 gains
              a benign '&> /tmp/out' allow row and a '>| .heatwave/**' allow row.
Verification: See AC-F-01 / AC-F-02 below.
Evidence:     N/A (matrix rows).
```

Everything the review judged sound is preserved unchanged: the honest ceiling (`ponytail:` comment + "not a filesystem sandbox / bypasses land in the audit trail" copy + AC-F-06 live-bypass demo), default-ALLOW with the 17-command review matrix, command-position discipline, the Edit/Write path, allowlist parity, matcher `Edit|Write`→`Edit|Write|Bash` + migration, zero new deps, adapter+docs only (no protocol shard — reconfirmed §"install.sh change"/"Copy changes").

## Tier

**FULL** — security-relevant enforcement change: the gate is the mechanical guarantee behind the protocol's no-edit states, and both failure modes are costly (a false negative silently re-opens the bypass the spec exists to close; a false positive breaks every reviewer's legitimate shell use on every gated project). The REVIEWER must actively hunt **bypasses** (commands that write source yet exit 0) and **false positives** (legitimate review-stage commands that exit 2) beyond the enumerated matrix.

Change class: **feature** — the current gate correctly implements its documented design ("blocks Edit/Write tool calls … a tool gate, not a filesystem sandbox", F's copy); the Bash gap is a design ceiling being raised, not a defect against spec. A red→green demonstration of the closed bypass is still included as AC-F-09 because it is cheap and is the strongest evidence the hardening does anything.

## Problem Statement

During no-edit states (PLANNING, PLAN_REVIEW, FULL_REVIEW, TARGETED_REVIEW, FINAL_REVIEW, EXPRESS_CHECK) the Claude Code `PreToolUse` gate blocks Edit/Write tool calls but not source modification through the Bash tool (`sed -i src/x`, `echo … > src/x`, `echo … &> src/x`, `python3 -c 'open("src/x","w")…'`). The `heatwave-planner` subagent carries Bash, so the externally-verified bypass is live in every installed project. G1 extends the gate to also match Bash and block *common* shell source-writes — best-effort by design, honestly documented as still not a sandbox. For: every Heatwave-on-Claude-Code user.

## Functional Requirements

- FR-1: `install.sh` registers the `PreToolUse` gate with matcher `Edit|Write|Bash`; re-running install on a project holding the old `Edit|Write` entry upgrades the matcher exactly once; install stays idempotent.
- FR-2: `role-gate.sh` gains a Bash branch: when `tool_input.command` is present AND an active run is in a NO_EDIT state, commands matching the source-write denylist with a non-allowlisted target exit 2 with a message naming run/state; everything else exits 0.
- FR-3: The Edit/Write path (`tool_input.file_path` present) behaves exactly as today — same allowlist, same design-doc anchor, same message, same exit codes.
- FR-4: The existing allowlist governs Bash write targets too: `.heatwave/**`, `CLAUDE.md`/`AGENTS.md`/`GEMINI.md`, `design_doc_path/*.md` (config-read, default `docs/design`), plus any path outside the project root (`/tmp`, `/dev/null`, …) — writes outside the repo are not project source. The **redirect** class covers all bash output-redirect operators writing to a path: `>`, `>>`, `&>`, `&>>`, `>|`, `>&<file>`, and numbered-fd forms (`2>`, `1>>`). The **interpreter** class checks the write call's path argument against the same allowlist.
- FR-5: No active run, or active run in IMPLEMENTING/FIXING/EXPRESS_IMPLEMENTING (any non-NO_EDIT state): all Bash commands exit 0.
- FR-6: The ceiling is marked in-code (`ponytail:` comment naming known evasions + pointing at the OS-sandbox track) and the README/FAQ copy says "hardened, still **not a filesystem sandbox**; bypasses land in the audit trail". Named evasions include command-string indirection (`sh -c`/`bash -c`/`eval`/`xargs "…"`), helper scripts, here-docs, and encoded writes.
- FR-7: Errs toward ALLOW for non-write commands: `pytest`, `semgrep`, `git diff/status/log`, `cat`, `grep`, `npm test`, `npm install`, read-mode interpreter one-liners all pass untouched.

## Non-Functional Requirements

- NFR-1 (latency): the gate now fires on **every** Bash call; added evaluation must stay imperceptible — see AC-N-01 (≤150 ms mean).
- NFR-2 (zero new deps): POSIX sh + the python3 the gate already uses (stdlib only: `json, os, re, sys, glob, shlex`). No new binaries, no pip packages.
- NFR-3 (fail-safe direction): malformed hook JSON, unreadable `state.yaml`, missing `heatwave.config.yaml`, or an unparseable command string must never crash the hook into a spurious block — degrade toward allow (matching the current gate's malformed-input behavior) except where a write-class pattern has already matched.

## Architecture

Two files carry the change; two files carry copy.

```
install.sh ──registers──▶ .claude/settings.json PreToolUse {matcher: "Edit|Write|Bash", cmd: sh .heatwave/role-gate.sh}
                                                    │
Claude Code tool call ──PreToolUse JSON (stdin)──▶ role-gate.sh ──▶ python3 heredoc
                                                    │
                      tool_input.file_path present? ├─ yes → EXISTING Edit/Write logic (unchanged)
                      tool_input.command present?   ├─ yes → NEW Bash branch:
                                                    │         no NO_EDIT run → exit 0
                                                    │         denylist match + non-allowlisted target → exit 2
                                                    │         otherwise → exit 0
                      neither                       └─ exit 0
```

The NO_EDIT-run scan (`glob .heatwave/runs/*/state.yaml`, parse `state:`) is factored into one function used by both branches — behavior-identical to today's inline scan for the Edit/Write path (same states set, same first-match-wins, same OSError-continue). The `design_doc_path` config read is likewise shared (it already runs unconditionally today).

### The Bash branch, concretely (goes into `role-gate.sh`)

**Order of evaluation:** (1) NO_EDIT run check first — no active gated run means zero parsing cost and unconditional allow; (2) heredoc-body strip; (3) tokenize; (4) redirect scan; (5) command-position tool scan; (6) interpreter one-liner scan; (7) default allow.

**Tokenization.** `shlex.shlex(cmd, posix=True, punctuation_chars=True)` with `whitespace_split=True` — stdlib, quote-aware (so `awk '$1 > 2' f` yields ONE token `$1 > 2`, not a redirect), and emits shell operators (`>`, `>>`, `&>`, `>|`, `|`, `;`, `&&`, `(`…) as separate tokens. Heredoc bodies are stripped first with `re.sub(r"<<-?\s*['\"]?(\w+)['\"]?.*?\n\1(\n|$)", " ", cmd, flags=re.S)` — a here-doc piped to an interpreter is a *named evasion*, deliberately not chased. On `ValueError` (unbalanced quotes) fall back to `cmd.split()` and the broadened prefix-redirect scan below (best effort, err toward allow).

**Target allowlist test:**

```python
def allowed_target(tok):
    tok = tok.strip("'\"")
    if not tok or tok.startswith(("&", "-")):      # fd dup (2>&1) or option flag
        return True
    if ".heatwave/" in tok or tok.startswith(".heatwave"):
        return True
    if os.path.basename(tok) in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        return True
    rp = os.path.realpath(tok)
    if not rp.startswith(ROOT):                     # outside the project: /tmp, /dev/null…
        return True                                 # not project source
    if rp.startswith(dd_root) and tok.endswith(".md"):
        return True
    return False
```

(`ROOT = os.path.realpath(os.getcwd()) + os.sep`; `dd_root` computed exactly as today.)

**Redirect scan (row #1) — covers ALL bash output-redirect operators (MAJOR-1 fix).** This does NOT rely on shlex collapsing operators, nor on equality against `>`/`>>`. It matches each raw operator token against a regex covering the full redirect class, and reads the target from the next token:

```python
REDIR = re.compile(r'^(?:>\|?|>>|&>>?|>&)$')   #  >  >|  >>  &>  &>>  >&
DIGIT = re.compile(r'^\d+-?$')                  #  fd number: '2>&1' target '1', '>&2' target '2'

def scan_redirects(toks):
    for i, t in enumerate(toks):
        if REDIR.match(t):
            tgt = toks[i + 1] if i + 1 < len(toks) else ""
            if not tgt or DIGIT.match(tgt):        # dangling, or fd-dup (2>&1, >&2) → not a path
                continue
            if not allowed_target(tgt):
                return True                        # block
    return False
```

Numbered-fd redirects (`2>`, `1>>`, `2>>`) need no special case: `shlex(punctuation_chars=True)` splits the leading fd digit into its own word token, leaving the operator token (`>`/`>>`) intact and matched — verified `echo x 2> src/x` → `['echo','x','2','>','src/x']`. `>&` followed by a bare digit is fd-duplication (allowed); `>&` followed by a path (`>& src/app.py`, both-streams-to-file) blocks.

**Unbalanced-quote fallback** (on `shlex` ValueError only), broadened to the same operator class, longest-match ordered, catching glued forms (`&>src/x`); err toward allow:

```python
FB = re.compile(r'^\d*(&>>?|>>|>\|?|>&)(.*)$')
def scan_redirects_fallback(parts):
    for j, t in enumerate(parts):
        m = FB.match(t)
        if m:
            tgt = m.group(2) or (parts[j + 1] if j + 1 < len(parts) else "")
            if tgt and not DIGIT.match(tgt) and not allowed_target(tgt):
                return True
    return False
```

**Denylist — the enumerated patterns and their matching:**

| # | Pattern (spec §3.2) | Detection on the token stream | Block condition |
|---|---|---|---|
| 1 | redirection `>` `>>` `&>` `&>>` `>|` `>&<file>` (incl. `2>`/`1>>`) | operator token matching `REDIR` (or the fallback `FB` prefix); target = next token, fd-dup (bare digit) excluded via `DIGIT` | target present, non-digit, and not `allowed_target` |
| 2 | `tee` | command-position word `tee` (basename match) | any non-option arg word before the next operator fails `allowed_target`; no file args → allow (stdout only) |
| 3 | `sed -i` | command-position `sed` + any arg matching `^-i` | non-option args minus the first (the script): any fails allowlist → block; none identifiable → block (write-class, no allowlisted target) |
| 4 | `perl -i` | command-position `perl` + any arg matching `^-[A-Za-z]*i` | same rule as sed |
| 5 | `awk … > file` | shell-level redirect → covered by #1; a redirect *inside* the quoted awk program is a documented miss (ceiling) | — |
| 6 | `dd of=` | command-position `dd` + arg starting `of=` | `of=` target fails allowlist |
| 7 | `install` | command-position word `install` only (so `npm install` is NOT matched — `install` is not in command position) | any non-option arg fails allowlist |
| 8 | `patch` | command-position `patch` | block, **UNLESS a `--dry-run` token is present** (read-only trial — false-positive guard symmetric to #9) |
| 9 | `git apply` | command-position `git` + next word `apply` | block, UNLESS `--check` or `--stat` present (read-only modes — false-positive guard) |
| 10 | `git restore` | command-position `git` + next word `restore` | block (reverts working tree) |
| 11 | `git checkout -- <path>` | command-position `git` + `checkout` + a later `--` token | block |
| 12 | `cp` | command-position `cp` | last non-option arg (dest) fails allowlist |
| 13 | `mv` | command-position `mv` | ANY non-option arg fails allowlist (moving a source file OUT is also a source modification) |
| 14 | `truncate` | command-position `truncate` | any non-option arg fails allowlist |
| 15 | `ex` / `ed` | command-position `ex` or `ed` | any non-option arg fails allowlist; none → block (write-class) |
| 16 | interpreter one-liners | command-position `python`/`python3`/`perl`/`ruby`/`node` + a `-c`/`-e` flag token (incl. combined `-pe`/`-ne`); code = the token after the flag | a write indicator matches AND at least one extracted path fails `allowed_target`, OR a write indicator matches but no path is extractable (write-class default). See below. |

**Row #16, concretely (MINOR-1 fix).** A write indicator is detected, then the write call's PATH ARGUMENT(s) are extracted and each run through the same `allowed_target` used everywhere else — not a `.heatwave/` substring test:

```python
WRITE_IND = re.compile(r"open\s*\([^)]*,\s*['\"][wax+]|writeFile|appendFile|createWriteStream|File\.write|File\.(open|new)\s*\([^)]*['\"][wax]")
WRITE_TARGET = re.compile(
    r"(?:open|File\.open|File\.new)\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"][wax+]"
    r"|(?:writeFile|writeFileSync|appendFile|appendFileSync|createWriteStream|File\.write)\s*\(\s*['\"]([^'\"]+)['\"]")

def scan_interpreter(code):
    if not WRITE_IND.search(code):
        return False                                          # read-mode / no write → allow
    targets = [g for m in WRITE_TARGET.finditer(code) for g in m.groups() if g]
    if not targets:
        return True                                           # write-class default → block
    return any(not allowed_target(t) for t in targets)        # allowlist parity with FR-4
```

So `python3 -c "open('docs/design/task.md','w')…"` and `…open('.heatwave/runs/t/n','a')…` now ALLOW (allowlist parity), `…open('src/app.py','w')…` / `node -e writeFileSync('src/a.js',…)` still BLOCK, and read-mode `open('src/app.py').read()` ALLOWS.

"Command position" = the first word token, or the first word after an operator token (`;`, `|`, `&&`, `||`, `&`, `(`) — so pipelines and `&&` chains are scanned per segment, and `$(sed -i …)` command substitutions get caught for free by the punctuation split. Tool names match on `os.path.basename(tok)` so `/usr/bin/sed` doesn't slip.

**Write-class default:** when a write-class tool matches but no target is extractable, block. The err-toward-ALLOW rule applies to commands that match *no* denylist pattern — those always exit 0.

**Block message** (parallel to the existing one):

```
Heatwave gate: run '<run>' is in <STATE> — this Bash command matches a source-write
pattern targeting a non-allowlisted path (R-1/R-37). Reads, tests and linters run
freely; project source is written by the owning role in IMPLEMENTING/FIXING.
Artifacts under .heatwave/ are always writable. (Best-effort denylist — bypasses
land in the audit trail.)
```

**The marked ceiling** (verbatim comment to land in `role-gate.sh`):

```python
# ponytail: best-effort string/token matching, NOT a filesystem sandbox. Known
# evasions, deliberately not chased: command-string indirection (sh -c / bash -c /
# eval / xargs "echo x > src/y" — the write collapses into one unscanned quoted
# token); a helper script that writes (printf > /tmp/w.sh && sh /tmp/w.sh); a
# here-doc piped to an interpreter; base64-decoded content; chmod +x && ./writer;
# a redirect inside a quoted awk/interpreter program. The real fix is the OS-sandbox
# track (read-only bind mounts / seccomp) — this gate is a speed bump against casual
# drift; bypass attempts land in the audit trail.
```

### install.sh change

Line 110: matcher `"Edit|Write"` → `"Edit|Write|Bash"` in the `wanted` entry. **Plus a migration** the current idempotency check would otherwise skip (it matches on `command` only — `install.sh:118` `any(want_cmd == h.get("command") …)` — so an existing project would keep the old matcher forever): after the `wanted` loop validates `hooks.PreToolUse` is a list, walk its entries — any entry whose hooks contain `gate_cmd` and whose `matcher == "Edit|Write"` gets `matcher = "Edit|Write|Bash"` and sets `changed`. Fresh install, re-run, and upgrade-from-old are then all single-pass idempotent.

### Copy changes

- `README.md:146` — "…a `PreToolUse` gate blocks the agent's Edit/Write file operations **and common shell source-writes** while a run is in a plan/review state — hardened, but still **not a filesystem sandbox**: a determined agent can bypass it (a helper script, a here-doc, or a `sh -c`/`eval` string), and the attempt lands in the audit trail (Claude Code only; other tools rely on the rules and the audit trail)."
- `docs/faq.md:28` — rewrite the same sentence pair: gate "mechanically blocks the agent's Edit/Write tool calls **and common shell source-writes (a best-effort denylist)** while the run state assigns them to another role. It is hardened, still not a filesystem sandbox — helper scripts, here-docs, encoded writes, or `sh -c`/`eval` string-indirection can bypass it; those land in the audit trail instead." Codex/Gemini sentence unchanged.
- `adapters/claude-code/HEATWAVE.md` — **verified fact:** contains no gate-scope copy (grepped for gate/block/Edit/Write/sandbox; only orchestrator-role text). No change.
- `adapters/README.md:9` — "`PreToolUse` write-gate" remains accurate as written. No change.
- `protocol/history.md` — **not touched.** Verified fact: `history` is a shard in `build-protocol.sh` ORDER (line 7), so touching it forces PROTOCOL.md regeneration; this is adapter hardening, no new R-number, no shard change → drift stays `OK` untouched.

## API Design

N/A — no programmatic API; the "contract" is the hook's stdin JSON and exit code, specified above (0 allow / 2 block, message on stderr).

## Data Design

N/A — no schema or persisted data; the gate reads existing `state.yaml`/`heatwave.config.yaml` read-only, formats unchanged.

## State Management

N/A — stateless hook; run state is read from existing `state.yaml` files exactly as today (same NO_EDIT_STATES set, first match wins).

## Error Handling Strategy

| Failure | Response |
|---|---|
| Malformed/absent hook JSON | exit 0 (unchanged from today) |
| Neither `file_path` nor `command` in tool_input | exit 0 |
| `state.yaml` unreadable | skip that run (OSError-continue, unchanged) |
| `heatwave.config.yaml` missing/odd | default `docs/design` (unchanged) |
| `shlex` ValueError (unbalanced quotes/heredocs) | whitespace-split fallback + broadened prefix redirect scan (`FB`); err toward allow |
| python3 missing at runtime | hook errors non-2 → Claude Code does not block; identical exposure to the current gate (install.sh already warns when python3 is absent) |

## Security Considerations

This change IS the threat-surface work. Introduced surface: the gate now parses attacker-shaped input (arbitrary command strings from the agent) with regex/shlex — parsing bugs become either bypasses (FN) or DoS-by-false-positive (FP). Mitigations: quote-aware stdlib tokenizer (not hand-rolled regex over raw strings) for the redirect class; the redirect test matches the FULL operator class (`>`/`>>`/`&>`/`&>>`/`>|`/`>&`/numbered-fd), not just `>`/`>>`, closing MAJOR-1; command-position discipline for tool names; interpreter targets run through the same `allowed_target` as every other path (allowlist parity, MINOR-1); write-class-defaults-to-block only after a pattern match; the FN ceiling is *accepted, named (now incl. `sh -c`/`eval` string-indirection), and demonstrated* (AC-F-06) rather than papered over. The gate never executes any part of the command. Honest-copy requirement (FR-6) is itself a security control: overclaiming "prevented" invites misplaced trust.

## Edge Cases

Enumerated (each appears in the AC matrix or the ceiling list):

1. `2>&1` / `>&2` — fd dup (target is a bare digit) → allow.
2. `cmd > /dev/null`, `pytest > /tmp/out.log`, `pytest &> /tmp/out.log` — outside project root → allow.
3. `awk '$1 > 2' f` — `>` inside quotes → one token, not a redirect → allow.
4. `foo 2> err.log` — stderr redirected INTO the project → block (it is a project write; numbered-fd covered by #1).
5. `npm install` — `install` not in command position → allow.
6. `sed -n 1,10p src/x` — no `-i` → allow.
7. `python3 -c 'print(open("src/x").read())'` — read mode → allow.
8. `git apply --check p.patch` / `patch --dry-run … src/x` — read-only modes → allow.
9. Quoted targets with spaces (`> "my file"`) — shlex handles → blocked if in-project.
10. `echo x > .heatwave/runs/r/notes`, `echo x &> .heatwave/runs/r/notes`, `echo x >| .heatwave/runs/r/notes`, `tee docs/design/t.md` — allowlisted → allow.
11. Pipelines/chains (`a && sed -i … src/x`, `$(sed -i …)`) — per-segment command position → caught.
12. Redirect variants `&>`, `&>>`, `>|`, `>& src/x` to a project path — block (MAJOR-1); `&>&1` fd-dup form → allow.
13. Heredoc bodies (`cat <<EOF … EOF`) — stripped; literal `>` in body is not a false positive; interpreter-fed heredocs are a named evasion.
14. `sh -c "echo x > src/x"` / `eval "…"` / `xargs "…"` — write collapses into one unscanned quoted token → slips (named ceiling, MINOR-3), lands in audit trail.
15. Multiple runs, only one in NO_EDIT — first NO_EDIT match gates (unchanged semantics).
16. Symlinked target into the project — `os.path.realpath` resolves; symlink tricks beyond that are ceiling.
17. Nested same-named design dir (`vendor/docs/design/x.md`) — still gated (existing anchor, regression-tested).
18. Interpreter write to an allowlisted path (`open('docs/design/x.md','w')`, `open('.heatwave/…','a')`) — allow (MINOR-1 parity).

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| False positive breaks legitimate review shell | Medium (the expensive one) | quote-aware tokenizer; command-position matching; outside-project targets allowed; `--check`/`--dry-run` guards; interpreter allowlist parity; AC-F-02's 19-command allow matrix; reviewer hunts more |
| False negative (bypass) via a redirect variant | Closed for the advertised class | `REDIR`/`FB` cover `>`/`>>`/`&>`/`&>>`/`>|`/`>&`/numbered-fd; AC-F-01 feeds each; residual FNs are only the named ceiling evasions |
| False negative (bypass) via named ceiling evasion | Certain — by design | documented + demonstrated ceiling (AC-F-06); copy says best-effort; audit trail |
| Edit/Write regression from the refactor | Low | shared functions are behavior-identical; AC-F-04 regression matrix |
| Existing installs never get the new matcher | High without migration | install.sh migration step; AC-F-08 |
| Latency on every Bash call | Low | NO_EDIT check first (no gated run → near-zero work); AC-N-01 measured |
| Copy overclaims | Low | AC-F-07 grep gate reusing F's honesty bar |
| macOS/BSD sh portability | Low | POSIX sh only; logic lives in python3; `sh -n` both files |

## Dependencies

- python3 — **confirmed** (existing gate dependency; `/opt/homebrew/bin/python3` verified on this machine; `shlex.punctuation_chars` is stdlib since 3.6).
- POSIX sh — confirmed (unchanged).
- No new dependencies (NFR-2). Nothing external.
- Internal: A–F merged behavior on `main` — confirmed by reading current `role-gate.sh`/`install.sh`/copy at plan time.

## Testing Strategy

All verification is deterministic: feed `role-gate.sh` crafted PreToolUse JSON on stdin inside a **scratch project dir** (never the real repo's `.heatwave/`), assert exit codes. Harness sketch:

```sh
S=$(mktemp -d); cd "$S"
mkdir -p .heatwave/runs/t src docs/design
cp <repo>/adapters/claude-code/role-gate.sh .heatwave/role-gate.sh
echo 'state: FULL_REVIEW' > .heatwave/runs/t/state.yaml
echo 'x' > src/app.py
gate() { printf '%s' "$1" | sh .heatwave/role-gate.sh; echo "exit=$?"; }
gate '{"tool_name":"Bash","tool_input":{"command":"echo pwned &> src/app.py"}}'   # expect exit=2
```

Executed by the IMPLEMENTER (full matrix, outputs pasted into the impl package), re-run by the REVIEWER (machine-evidence ladder), plus reviewer-authored adversarial cases. Also: `sh -n` on both files, semgrep over the diff, gitleaks at FINAL, fresh-install + re-install + upgrade-install runs against a scratch target, `sh build-protocol.sh --check` for drift.

## Rollout Plan

Single commit to `main`. Takes effect in a project only when `install.sh` is re-run there (which copies the new gate and migrates the matcher). No flags, no phasing — the change is additive-restrictive only during NO_EDIT states, and existing installs simply keep old behavior until reinstalled.

## Rollback Plan

`git revert <G1-commit>` on `main`, then re-run `install.sh` in any project that upgraded (restores the old `role-gate.sh`). Projects left with the `Edit|Write|Bash` matcher but the old gate are safe: the old gate exits 0 whenever `file_path` is absent, so Bash calls pass — behavior degrades exactly to pre-G1, never to over-blocking. No data to migrate back.

---

## Task-by-task plan

- **T1 — `adapters/claude-code/role-gate.sh`:** update header comment (matcher now `Edit|Write|Bash`); factor NO_EDIT-run scan + dd_root into shared code (behavior-identical); add Bash branch per Architecture (tokenizer, `REDIR`/`DIGIT`/`FB` redirect scan covering the full operator class, denylist table #1–#16 incl. `patch --dry-run` guard and interpreter `allowed_target` parity, `allowed_target`, block message); add the ceiling `ponytail:` comment verbatim (names `sh -c`/`eval`/`xargs`). Satisfies FR-2/3/4/5/6-part.
- **T2 — `install.sh`:** matcher string change + existing-entry migration. Satisfies FR-1.
- **T3 — copy:** `README.md:146`, `docs/faq.md:28` per Copy changes (incl. `sh -c`/`eval` indirection named); confirm-and-leave `HEATWAVE.md`, `adapters/README.md`; do NOT touch `protocol/history.md`. Satisfies FR-6-part.
- **T4 — verification harness run:** scratch-dir matrix for AC-F-01…05, AC-F-09; paste outputs.
- **T5 — ceiling demonstration:** run the AC-F-06 bypass, record it slipping through — in the impl package, not hidden.
- **T6 — machine gates:** `sh -n`, semgrep, latency loop (AC-N-01), install idempotency triple-run (AC-F-08), `build-protocol.sh --check` drift, scoped `git diff` (AC-N-04).

---

## Acceptance Criteria

Scratch-dir setup as in Testing Strategy; `STATE` below means the content of `.heatwave/runs/t/state.yaml`.

### Functional

**AC-F-01 | Bash source-writes blocked in a NO_EDIT state** | Verification: with `STATE=state: FULL_REVIEW`, each JSON below fed on stdin exits **2** (and once each spot-checked under `PLANNING` and `EXPRESS_CHECK`):

```json
{"tool_name":"Bash","tool_input":{"command":"sed -i 's/a/b/' src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo hacked > src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo more >> src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo pwned &> src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo pwned &>> src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo pwned >| src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo pwned >& src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"echo pwned 2> src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"python3 -c \"open('src/app.py','w').write('x')\""}}
{"tool_name":"Bash","tool_input":{"command":"cat /tmp/x | tee src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"perl -pi -e 's/a/b/' src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"dd if=/tmp/x of=src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"patch src/app.py < /tmp/fix.patch"}}
{"tool_name":"Bash","tool_input":{"command":"git apply /tmp/x.patch"}}
{"tool_name":"Bash","tool_input":{"command":"git restore src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"git checkout -- src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"cp /tmp/evil.py src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"mv src/app.py /tmp/"}}
{"tool_name":"Bash","tool_input":{"command":"truncate -s 0 src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"ed src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"node -e \"require('fs').writeFileSync('src/a.js','x')\""}}
{"tool_name":"Bash","tool_input":{"command":"ruby -e \"File.write('src/app.py','x')\""}}
{"tool_name":"Bash","tool_input":{"command":"true && echo x > src/app.py"}}
```

(The `&>`, `&>>`, `>|`, `>& <file>`, `2>` rows are the MAJOR-1 / NIT-1 additions — each is an ordinary bash output redirect to a project path and MUST block.)

**AC-F-02 | Legitimate review-stage commands allowed in the same NO_EDIT state** | Verification: each exits **0**:

```json
{"tool_name":"Bash","tool_input":{"command":"pytest -q"}}
{"tool_name":"Bash","tool_input":{"command":"semgrep scan --config auto"}}
{"tool_name":"Bash","tool_input":{"command":"git diff"}}
{"tool_name":"Bash","tool_input":{"command":"git status && git log --oneline -5"}}
{"tool_name":"Bash","tool_input":{"command":"cat src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"grep -rn TODO src/"}}
{"tool_name":"Bash","tool_input":{"command":"npm test"}}
{"tool_name":"Bash","tool_input":{"command":"npm install"}}
{"tool_name":"Bash","tool_input":{"command":"echo note > .heatwave/runs/t/notes.md"}}
{"tool_name":"Bash","tool_input":{"command":"echo note >| .heatwave/runs/t/notes.md"}}
{"tool_name":"Bash","tool_input":{"command":"pytest -q | tee .heatwave/runs/t/out.log"}}
{"tool_name":"Bash","tool_input":{"command":"echo plan > docs/design/task.md"}}
{"tool_name":"Bash","tool_input":{"command":"python3 -c \"open('docs/design/task.md','w').write('x')\""}}
{"tool_name":"Bash","tool_input":{"command":"pytest > /tmp/out.log 2>&1"}}
{"tool_name":"Bash","tool_input":{"command":"pytest &> /tmp/out.log"}}
{"tool_name":"Bash","tool_input":{"command":"ls > /dev/null"}}
{"tool_name":"Bash","tool_input":{"command":"awk '$1 > 2' data.txt"}}
{"tool_name":"Bash","tool_input":{"command":"sed -n '1,10p' src/app.py"}}
{"tool_name":"Bash","tool_input":{"command":"python3 -c 'print(open(\"src/app.py\").read())'"}}
{"tool_name":"Bash","tool_input":{"command":"git apply --check /tmp/x.patch"}}
{"tool_name":"Bash","tool_input":{"command":"patch --dry-run src/app.py < /tmp/fix.patch"}}
{"tool_name":"Bash","tool_input":{"command":"echo x 2>&1"}}
```

(Controls added: `>| .heatwave/**` and `&> /tmp` redirects allow — MAJOR-1/NIT-1; `python3 …open('docs/design/task.md','w')` allows — MINOR-1 parity; `patch --dry-run` allows — MINOR-2; `2>&1` fd-dup allows.)

**AC-F-03 | IMPLEMENTING (and FIXING) allow everything** | Verification: with `STATE=state: IMPLEMENTING` (then `state: FIXING`), the AC-F-01 `sed -i`, `echo >`, `echo &>`, `python3 -c` and `git restore` JSONs each exit **0**.

**AC-F-04 | Edit/Write path unchanged (regression)** | Verification: with `STATE=state: FULL_REVIEW`, exits as noted:

```json
{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}                     → 2
{"tool_name":"Write","tool_input":{"file_path":".heatwave/runs/t/plan.md"}}       → 0
{"tool_name":"Edit","tool_input":{"file_path":"CLAUDE.md"}}                       → 0
{"tool_name":"Write","tool_input":{"file_path":"docs/design/task.md"}}            → 0   (cwd-resolved)
{"tool_name":"Write","tool_input":{"file_path":"vendor/docs/design/x.md"}}        → 2   (anchor regression)
{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}  with STATE=IMPLEMENTING → 0
```

Block message for the exit-2 cases is byte-identical to the current one (diff the stderr).

**AC-F-05 | No active run → allow** | Verification: with `.heatwave/runs/` empty, the AC-F-01 `sed -i`, `echo >` and `echo &>` JSONs and the AC-F-04 Edit JSON each exit **0**.

**AC-F-06 | Ceiling bypass demonstrated honestly** | Verification: with `STATE=state: FULL_REVIEW`, `{"tool_name":"Bash","tool_input":{"command":"printf 'echo pwned > src/app.py' > /tmp/w.sh && sh /tmp/w.sh"}}` exits **0** (slips through: the redirect target is outside the project; `sh /tmp/w.sh` matches no pattern). Additionally `{"tool_name":"Bash","tool_input":{"command":"sh -c 'echo pwned > src/app.py'"}}` exits **0** (string-indirection — the named MINOR-3 evasion). Both outputs recorded in the implementation package as the documented ceiling, matching the copy's caveat and the `ponytail:` comment — NOT hidden or "fixed".

**AC-F-07 | Copy honest** | Verification: `grep -n "sandbox\|shell source-writes" README.md docs/faq.md` shows the hardened wording AND the retained "not a filesystem sandbox" caveat in both files; `grep -niE "sh -c|eval|helper script|here-doc" README.md docs/faq.md` shows the named indirection/ceiling evasions (MINOR-3); `grep -inE "physically (block|prevent)|completely prevent|cannot bypass" README.md docs/faq.md adapters/` returns nothing.

**AC-F-08 | Install idempotent + migration** | Verification: in a scratch target: (a) fresh `./install.sh <target> claude` → settings.json PreToolUse gate entry has matcher `Edit|Write|Bash`; (b) immediate re-run → prints "skipped hooks (already installed)", file unchanged (diff empty); (c) seed settings.json with the OLD `Edit|Write` gate entry, run install → matcher upgraded to `Edit|Write|Bash`, run again → "skipped hooks", no further diff.

**AC-F-09 | Bypass closure red→green** | Verification: run the AC-F-01 `sed -i`/`echo >`/`echo &>`/`python3 -c` JSONs against the **pre-change** `role-gate.sh` (from `git stash`/`git show HEAD:…`) in the same scratch setup → each exits **0** (red: bypass live, incl. `&>` which the old gate never saw); against the changed gate → each exits **2** (green). Both outputs pasted.

### Non-functional

**AC-N-01 | Gate latency ≤ 150 ms mean per invocation** | Verification: shell loop timing 20 invocations of the gate with a benign Bash JSON in the scratch dir (NO_EDIT state present — worst path), `time` total / 20 ≤ 150 ms on the dev machine.

**AC-N-02 | POSIX-sh valid** | Verification: `sh -n adapters/claude-code/role-gate.sh && sh -n install.sh` exit 0. (shellcheck NOT AVAILABLE — see Tooling.)

**AC-N-03 | Zero new dependencies** | Verification: `git diff` inspection confirms only `sh` builtins + `python3` stdlib imports (`json,os,re,sys,glob,shlex`); no new `command -v`/binary/package references introduced.

**AC-N-04 | No regression / drift / scope** | Verification: `sh build-protocol.sh --check` exits 0 (no shard touched, PROTOCOL.md untouched); `git diff --stat` names ONLY `adapters/claude-code/role-gate.sh`, `install.sh`, `README.md`, `docs/faq.md` (+ run artifacts under `docs/superpowers/`, `.heatwave/`); AC-F-04/05 pass (A–F gate behavior intact).

## Review Scope

Applicable
✓ business-logic — the allow/block decision tree IS the feature; hunt bypasses and false positives beyond the AC matrix
✓ input-validation — gate parses agent-shaped JSON + arbitrary command strings; malformed input must degrade per Error Handling
✓ injection — regex/tokenizer over hostile command strings; quoting/heredoc/substitution/redirect-variant corners are the bypass surface
✓ secure-config — hook registration in `.claude/settings.json`: matcher correctness, migration, never corrupting user settings
✓ error-handling — every failure row in the table exits the safe direction, never a crash-block
✓ cpu — hook now fires on every Bash call; AC-N-01 path
✓ plan-conformance — always applicable
✓ verification-integrity — always applicable; especially AC-F-06 (the bypass must be shown, not hidden) and AC-F-09 red/green

Not applicable
✗ all Frontend categories (ui-rendering … visual-regression) — no UI surface; shell/docs only
✗ api-contracts, request/response-validation, status-codes, versioning — no HTTP/API surface
✗ schema, migrations, transactions, indexes, query-performance, data-integrity — no database
✗ authentication, authorization, rbac, output-encoding, xss, csrf, ssrf, secret-management, encryption, secure-headers — no auth/web/secret surface; gate handles no credentials
✗ api-latency, db-latency, memory, cache, concurrency, scalability — single short-lived local process; cpu covers the only perf concern
✗ retry, circuit-breakers, timeouts, recovery, rate-limiting — no network or long-lived process
✗ logging, metrics, tracing, monitoring, alerting — hook stderr + audit trail are the observability, unchanged by design

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Unit/behavioral | direct execution: `sh` + crafted stdin JSON (no framework exists in this repo — verified: no package.json/pytest.ini/go.mod test config) | IMPLEMENTER (re-run by REVIEWER) | confirmed — the gate itself runs on sh+python3 |
| Shell lint | shellcheck | REVIEWER | **NOT AVAILABLE** — verified `command -v shellcheck` rc=1 on this machine; substitute `sh -n` + the execution matrix; affected: style-only, no AC blocked (R-64) |
| SAST (FULL) | semgrep | REVIEWER | confirmed — `/opt/homebrew/bin/semgrep` (verified `command -v`) |
| Mutation (FULL, timeout 10 min) | — | REVIEWER | **NOT AVAILABLE** — no shell/embedded-python mutation tool in repo or environment (no stryker/mutmut/cargo-mutants evidence); affected: AC-F-01/02 denylist robustness rests on the enumerated matrix + reviewer adversarial cases instead (R-110/R-64) |
| Secrets (FINAL rung) | gitleaks | REVIEWER | confirmed — `/opt/homebrew/bin/gitleaks` (verified `command -v`) (R-121) |
| UI evidence | — | — | NOT AVAILABLE / not applicable — no UI surface (R-120) |

change_surface: **external-input** — the gate parses untrusted agent-generated command strings and hook JSON; no auth/payments/endpoint/ui/deps/secrets/api surface touched (R-122).
