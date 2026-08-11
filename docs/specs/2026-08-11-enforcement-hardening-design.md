# Design Spec — Enforcement Hardening (cheap track) (Heatwave Protocol v4, Sub-project G1)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Close the verified Bash bypass in the Claude Code role-gate. Cheap track only (no OS sandbox). Security-relevant → FULL tier.
- **Depends on:** A–F merged to main. Motivated by a verified external-critique finding.

---

## 1. Context & problem

The Claude Code role-gate (`adapters/claude-code/role-gate.sh`) is registered on `PreToolUse` with matcher `Edit|Write` (`install.sh:110`) and only inspects `tool_input.file_path`. So during no-edit states (PLANNING, *_REVIEW, EXPRESS_CHECK) it blocks the agent's **Edit/Write tool calls** but NOT source modification via the **Bash** tool (`sed -i src/x`, `echo ... > src/x`, `python3 -c 'open("src/x","w")...'`). The `heatwave-planner` subagent even carries Bash. F's README was corrected to say so honestly ("a tool gate, not a filesystem sandbox"). G1 raises the bar cheaply: extend the gate to also catch common shell source-writes — without pretending to become a sandbox.

## 2. Goals / non-goals

**Goals:**
- G1. Extend the Claude Code `PreToolUse` hook to also match `Bash`, and have `role-gate.sh` block a Bash command during a no-edit state when it would write project source, using a best-effort source-write pattern denylist.
- G2. Preserve every current allow: reads, test/lint/build runs, writes under `.heatwave/**`, `CLAUDE.md`/`AGENTS.md`/`GEMINI.md`, and the configured `design_doc_path` `.md`; and full freedom during IMPLEMENTING/FIXING.
- G3. Document the ceiling honestly: this is a **best-effort denylist (string-matching), still not a filesystem sandbox** — a determined agent can still bypass (helper scripts, here-docs, encoded writes), and those land in the audit trail. Update the FAQ/README enforcement copy to match, and mark the ceiling with a `ponytail:` comment in the gate.
- G4. Zero new runtime dependencies (POSIX sh + the existing python3 the gate already uses). Claude-Code-only, like the current gate.

**Non-goals (deferred):**
- OS-level hard enforcement (container / read-only bind mounts / seccomp-Landlock / FUSE) — the heavy, dependency-bearing, opt-in track. Not here.
- Extending mechanical gating to non-Claude adapters (they have no blocking hook; unchanged).
- The three-arm benchmark — future, and depends on the #2 benchmark-runtime fix.

## 3. Design

### 3.1 Hook registration (`install.sh`)

Change the `PreToolUse` matcher from `Edit|Write` to `Edit|Write|Bash`. Existing Edit/Write behavior is unchanged (same code path). Idempotent install preserved.

### 3.2 Gate logic (`adapters/claude-code/role-gate.sh`)

Branch on tool input shape:
- **Edit/Write path (unchanged):** `tool_input.file_path` present → existing allowlist + no-edit-state check. No behavior change.
- **Bash path (new):** `tool_input.command` present → only evaluated when an active run is in a NO_EDIT state. Then:
  1. If the command does not match any source-write pattern → allow (exit 0). Reads, `pytest`/`npm test`/`semgrep`/`git status|diff|log`, etc. run freely.
  2. If it matches a source-write pattern AND the write target is outside the allowlist (`.heatwave/**`, the CLAUDE/AGENTS/GEMINI files, `design_doc_path/*.md`) → block (exit 2) with a message naming the run/state and pointing to dispatch-the-owning-role.
- **No active run / no NO_EDIT state → allow** (unchanged).

**Best-effort source-write denylist** (documented, incomplete by nature):
- redirections to a path: `>`/`>>`/`tee` whose target is not allowlisted
- in-place / file-writing tools: `sed -i`, `perl -i`, `awk ... > file`, `dd of=`, `install `, `patch`, `git apply`, `git restore`/`git checkout -- ` (can revert source), `cp`/`mv` into a non-allowlisted path, `truncate`, `ex`/`ed` scripts
- interpreter one-liners that open a file for writing: `python`/`python3 -c`, `perl -e`, `ruby -e`, `node -e` containing an `open(...,'w'|'a')`/`writeFile`/`>` write
Allowlisted targets and pure-read commands always pass. When in doubt the gate errs toward **allow** for non-matching commands (to avoid breaking legitimate review-stage shell use) — the denylist catches the obvious writes, not every conceivable one.

**Ceiling (honest, marked):** a `ponytail:` comment states this is string-matching best-effort, names known evasions (a script file that writes; a here-doc piped to an interpreter; base64-decoded content; `chmod +x && ./writer`), and points at the OS-sandbox track as the real fix. The gate is a speed-bump against casual/self-serving drift, not a boundary against a determined adversary.

### 3.3 Copy (`docs/faq.md`, `README.md`)

Update the enforcement caveat from "blocks Edit/Write tool calls … not a filesystem sandbox" to: "blocks the agent's Edit/Write tool calls **and common shell source-writes** during plan/review states on Claude Code; it is still **not a filesystem sandbox** — a determined agent can bypass it (and that attempt is recorded in the audit trail)." No overclaim (F's honesty bar holds).

## 4. Affected files

**Modified:**
- `adapters/claude-code/role-gate.sh` — Bash branch + denylist + ceiling comment
- `install.sh` — matcher `Edit|Write` → `Edit|Write|Bash`
- `docs/faq.md`, `README.md` — honest hardened-but-not-sandbox wording
- `adapters/claude-code/HEATWAVE.md` — if it describes the gate scope, align
- optionally `protocol/history.md` — a one-line changelog entry (no new rule needed; this is an adapter hardening, not a protocol rule — but if the reviewer wants it referenced, a note is fine)

**No protocol shard rule change required** (the enforcement is adapter-level; the protocol already says source must not be edited in no-edit states — this makes the Claude Code gate enforce more of that). `PROTOCOL.md` regeneration only if a shard is touched; otherwise drift stays `OK` untouched.

**No new runtime dependencies.**

## 5. Alternatives considered

1. **OS sandbox now.** Deferred by owner (this is the cheap track). Real "physically denied" but a dependency + heavier; opt-in future sub-project.
2. **Remove Bash from planner/reviewer subagents.** Rejected: the planner needs Bash for tooling detection (R-99) and the reviewer needs it for the machine-evidence ladder (B). Can't remove; gate the writes instead.
3. **Allowlist commands instead of denylist writes.** Rejected: a command allowlist would break the open-ended legitimate shell use reviewers need; denylisting obvious writes is the lower-friction cut.
4. **Claim complete prevention.** Forbidden — it's best-effort; the copy and a ponytail comment state the ceiling.

## 6. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Denylist blocks a legitimate review-stage command (false positive) | err toward allow for non-write commands; only block clear writes to non-allowlisted paths; test the common review commands (pytest/semgrep/git-read) stay allowed |
| Denylist misses a write (false negative) | expected and documented (ceiling); not sold as complete; audit trail records the run |
| Breaking the existing Edit/Write path | Edit/Write code path untouched; regression test both paths |
| Copy overclaims again | reuse F's honesty bar: "hardened, still not a sandbox"; reviewer greps for unscoped "block"/"prevent" |
| install idempotency / other adapters | only the Claude Code matcher changes; other adapters untouched; re-run install is idempotent |

## 7. Verification strategy (evidence, not assertion)

Deterministic shell tests against a scratch run in a NO_EDIT state (feed role-gate.sh crafted PreToolUse JSON on stdin, assert exit code):
1. **Bash source-write blocked in no-edit state:** `sed -i ... src/x`, `echo x > src/x`, `python3 -c 'open("src/x","w")...'`, `tee src/x` → exit 2 each. Paste outputs.
2. **Legit review commands allowed in no-edit state:** `pytest`, `semgrep scan`, `git diff`, `cat src/x`, `echo x > .heatwave/runs/r/notes`, a `design_doc_path/*.md` write → exit 0 each.
3. **IMPLEMENTING allows everything:** same writes → exit 0 when state=IMPLEMENTING.
4. **Edit/Write path unchanged:** the existing Edit-blocked / artifact-allowed cases still behave (regression).
5. **No active run → allow** (unchanged).
6. **Ceiling demonstrated honestly:** one documented bypass (e.g. `printf '...' > /tmp/w.sh && sh /tmp/w.sh` writing source) is shown to slip through, proving the gate is best-effort — recorded in the impl package and matching the copy's caveat (do NOT hide it).
7. **Copy honest:** grep README/FAQ — no unscoped "physically block/prevent"; the hardened-not-sandbox caveat present.
8. **No regression / drift:** A–F behavior intact; `git diff` scoped; if no shard touched, drift stays `OK`; install idempotent.

## 8. Open questions

None blocking. The denylist's exact pattern set is an implementation detail the plan will enumerate concretely; its incompleteness is a documented property, not a bug.
