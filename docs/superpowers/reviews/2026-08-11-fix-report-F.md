# Fix Report — Positioning / README Refresh (v4 Sub-project F)

task_id: positioning-readme | artifact_type: fix-report | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5, FIXING) | timestamp: 2026-08-11 | responding_to: FULL_REVIEW iteration 1 (`docs/superpowers/reviews/2026-08-11-full-review-F.md`)

Fix commit: `f8b7622` on `heatwave-v4-subproject-f`.

## Per-finding responses (R-31 — one entry per finding)

### F-FR-1 (Major, verification-integrity / spec §4 overclaim)

- **Response:** Fixed
- **Change:** Both occurrences of the unqualified "physically blocks source edits" rewritten to the honest tool-gate framing:
  - `docs/faq.md:28` (new copy, the flagged line): now reads "…a `PreToolUse` gate mechanically blocks the agent's Edit/Write tool calls while the run state assigns them to another role. It's a tool gate, not a filesystem sandbox — it doesn't stop a raw shell write or a deliberately misbehaving agent; those land in the audit trail instead. Codex and Gemini CLI hooks re-inject the gate text each turn but don't block edits — those adapters rely on the rules plus the audit trail."
  - `README.md:146` (pre-existing same-class phrase, reviewer-scoped ride-along): now reads "…a `PreToolUse` gate blocks the agent's Edit/Write file operations while a run is in a plan/review state — a tool gate, not a filesystem sandbox (Claude Code only; other tools rely on the rules and the audit trail)."
  - `docs/faq.md:50` "edit-blocking hooks": unchanged, per the reviewer's explicit disposition that it is acceptable once L28 is scoped (names the hook class, not a completeness claim).
  - All three coordinator-required elements present: Edit/Write tool-path scope, not-a-sandbox / shell-writes-bypass caveat, Claude-Code-only with other adapters on rules + audit trail. No hard/complete source-edit-prevention claim remains anywhere.
- **Verification (finding's stated method — re-grep):**
  ```
  $ grep -rn "physically block" README.md docs/
  → 3 hits, ALL inside run artifacts quoting the finding/old text
    (docs/superpowers/impl/...-implementation.md:46 — iteration-1 claim table, superseded below;
     docs/superpowers/reviews/...-full-review-F.md:42,78 — the Review Report itself)
  → ZERO hits in rendered copy: README.md, docs/faq.md, docs/getting-started.md
  $ grep -n "blocks source edits\|block source edits" README.md docs/faq.md docs/getting-started.md
  exit=1 (no output)
  ```
- **Evidence:** commit `f8b7622` diff; grep output above (run post-commit, pasted from session).

**Claim-table row 14 superseded** (Implementation Package is an iteration-1 historical artifact; corrected row for FINAL):

| # | Shipped sentence (as fixed) | Backing |
|---|---|---|
| 14 | Claude Code `PreToolUse` gate mechanically blocks the agent's **Edit/Write tool calls** during no-edit states; a tool gate, not a filesystem sandbox — shell writes bypass it and land in the audit trail; Codex/Gemini hooks inject, don't block; other adapters rely on rules + audit trail | `install.sh:110` (`"matcher": "Edit|Write"`), `adapters/claude-code/role-gate.sh` (inspects `tool_input.file_path`, exit-2), `adapters/codex/hooks.json`, `adapters/gemini/gemini-gate.sh` |

### F-FR-2 (Nit, plan-conformance)

- **Response:** Fixed
- **Change:** `README.md:97` "…re-checks only what changed since the last approved pass" → "…since the last full review", matching R-118(c) ("the diff since the last FULL_REVIEW" — a baseline that need not have been approving).
- **Verification:**
  ```
  $ grep -n "last full review\|last approved pass" README.md
  97:…the final review re-checks only what changed since the last full review — plus a full machine-gate re-run.
  ```
- **Evidence:** commit `f8b7622` diff; grep output above.

## Deviation Records

None — no new deviations introduced by the fixes.

## Blast radius (R-53)

Two prose files: `README.md` (2 lines: L97 phrase, L146 clause) and `docs/faq.md` (1 sentence, L28). No consumers — rendered markdown only; no protocol, script, adapter, or benchmark file touched. Boundary reasoning: both edits replace wording in place; no section structure, links, images, or headings changed (AC-F-07 set unaffected).

## Guards re-run post-fix

```
$ sh build-protocol.sh --check
OK: PROTOCOL.md matches protocol/ shards   (exit=0)

$ git diff main...HEAD --stat   (post-commit f8b7622)
README.md, docs/faq.md, docs/getting-started.md + run artifacts under docs/ only — docs-only preserved

$ grep -nE '0/[0-9]|fewer bugs|[0-9]+ ?%([^0-9]|$)|[0-9]+(\.[0-9]+)?[x×] (fewer|faster|better|cheaper)' README.md docs/faq.md docs/getting-started.md
exit=1 (no output — AC-F-02 still holds after the fixes)
```

## Notes

The iteration-1 Implementation Package (`docs/superpowers/impl/2026-08-11-subproject-F-implementation.md`) row 14 describes the pre-fix wording; it is left as the historical audit record, with the corrected row carried here for FINAL_REVIEW consumption.
