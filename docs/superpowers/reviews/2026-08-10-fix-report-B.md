# Fix Report

task_id: hw-v4-B-machine-evidence | artifact_type: fix-report | iteration: 1 | responding to: FULL_REVIEW iteration 1 (docs/superpowers/reviews/2026-08-10-full-review-B.md) | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

## Per-Finding Responses

```
Finding ID:            F-hwB-013
Response:              Fixed
Change:                R-115's write mechanism is now set-not-append at all four sites.
                       protocol/core.md R-115: the sentence "the driver recomputes and
                       appends the updated value" replaced with — "The advisory is written
                       by SETTING the record's `hetero_reviewer` field — the scalar key the
                       run-record template already carries — never by appending a line
                       mid-file or duplicating the key, so the record remains valid YAML;
                       timing is evidenced by record snapshots at dispatch, not by insertion
                       position. If either role's resolved model subsequently changes (R-11
                       substitution), the driver recomputes and sets the field to the
                       updated value (the substitution entry R-11 already requires preserves
                       the history)." protocol/orchestrator.md §9.1 and prompts/orchestrator.md
                       reworded to match (set in place, valid YAML, never a mid-file append or
                       duplicate key); templates/run-record.yaml field comment gains "SET this
                       field in place (never append a new line or duplicate key — R-115)".
                       All four battery run-records repaired to the corrected mechanism
                       (field moved to template position; .before-013 copies preserved).
Verification:          (1) grep the amended R-115 for set-not-append wording:
                       `grep -c "SETTING the record" protocol/core.md` → 1;
                       `grep -c "appends" protocol/core.md protocol/orchestrator.md` → 0, 0.
                       (2) Machine parse before/after with ruby psych (YAML.parse_file =
                       pure structural validity; no new dependency — macOS/homebrew ruby):
                       BEFORE  l2 record: INVALID — "did not find expected key while parsing
                               a block mapping" (scalar key between transitions list items)
                       BEFORE  l3 record: INVALID — same error class
                       BEFORE  h1/l4 records: VALID only by luck (append landed at EOF) —
                               same fragile mechanism
                       AFTER   all four: VALID; loaded values intact —
                               l2 hetero_reviewer="false (self-preference bias not mitigated)",
                               transitions=5; h1 "true", transitions=4; l3 "false (...)",
                               transitions=6; l4 "false (...)", transitions=5.
Evidence:              Before/after snippet (l2):
                       BEFORE (lines 20-23):
                         - { from: IMPLEMENTING, to: FULL_REVIEW, ... }
                         hetero_reviewer: "false (self-preference bias not mitigated)" ...
                         - { from: FULL_REVIEW, to: APPROVED, ... }   <- orphaned item
                       AFTER (lines 14-18):
                         reviewer:    { configured: session, resolved: claude-fable-5, ... }
                         hetero_reviewer: "false (self-preference bias not mitigated)" ...
                         counters: { ... }
                         transitions:  <- contiguous list, APPROVED entry now inside it
                       Parser output archived above; .before-013 files kept beside each
                       record under /private/tmp/hw-b-verify/ for the reviewer's re-run.
```

```
Finding ID:            F-hwB-014
Response:              Deferral requested
Change:                none (reviewer-approved deferral to backlog per R-6/R-78 — recorded
                       here for the ledger; per instruction this finding was not touched)
Verification:          n/a
Evidence:              Review Report marks it Status: Deferred (approved) with the backlog
                       recipe (one controlled N3-style reconciliation dispatch on a future
                       B-follow-up or D run).
Argument:              Both R-112 directions are proven at authorship; the untested surface
                       is only the R-58 trigger context. The reviewer's own deferral applies.
```

```
Finding ID:            F-hwB-015
Response:              Fixed
Change:                Resume-compat check redone in /private/tmp/hw-b-verify/resume-check:
                       the duplicate FULL_REVIEW→FINAL_REVIEW line removed; the resumed
                       driver now appends the ADVANCING transition (FINAL_REVIEW → APPROVED).
Verification:          diff record.before2 run-record.yaml → exactly one appended line:
                       "21a22 > - { from: FINAL_REVIEW, to: APPROVED, ... }";
                       stripped fields still absent (grep count 0 for
                       change_class|hetero_reviewer); record parses VALID (ruby psych).
Evidence:              Command output pasted in the session log; files record.before2 /
                       run-record.yaml preserved in the resume-check dir. AC-N-03 substance
                       unchanged: no error, no rewrite, append-only under defaults.
```

```
Finding ID:            F-hwB-016
Response:              Fixed
Change:                prompts/fixer.md bullet now reads "**Every finding gets exactly one
                       response** (R-31, R-40; refuted findings excepted, R-31/R-112) — ..."
Verification:          grep prompts/fixer.md for the exception →
                       line 7 contains "refuted findings excepted, R-31/R-112".
Evidence:              grep output pasted in the session log; matches protocol/fixer.md R-31's
                       carve-out clause verbatim in substance.
```

## New Deviation Records

None.

## Blast Radius (fixes)

Touched: protocol/core.md (one sentence in R-115), protocol/orchestrator.md (one clause in the §9.1 driver-duties paragraph), prompts/orchestrator.md (one parenthetical), prompts/fixer.md (one parenthetical), templates/run-record.yaml (one comment clause), regenerated PROTOCOL.md; battery evidence files under /private/tmp/hw-b-verify/ (records repaired to the corrected mechanism, .before copies preserved). Consumers: future drivers (write mechanism clarified — same field, same values, same timing rule; only the write shape changed) and future FIXER dispatches (prompt now mirrors the shard). No state, gate, schema key, or EXPRESS surface changed. Reasoning: pure wording/mechanism fix confined to the R-115 write path plus one prompt parenthetical.

## Notes

Post-fix regression evidence (all run this session):

```
$ sh build-protocol.sh && sh build-protocol.sh --check
generated PROTOCOL.md from protocol/ shards
OK: PROTOCOL.md matches protocol/ shards        (exit 0)

A regression — EXPRESS surface: git diff --quiet main...HEAD -- prompts/express-checker.md
templates/express-change.md templates/express-check.md → exit 0 (byte-identical);
ladder-vocabulary grep of the three files → 0 hits each.

A regression — dispatch line count: wc -l protocol/core.md protocol/implementer.md → 445 total (≤ 450).
```

F-hwB-013's rule-text change keeps R-115 a single line in core.md, so no dispatch-size drift.
