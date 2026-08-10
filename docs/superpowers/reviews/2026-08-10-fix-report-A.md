# Fix Report

task_id: hw-v4-A-intake-slimdown | artifact_type: fix-report | iteration: 1 | responding to: docs/superpowers/reviews/2026-08-10-full-review-A.md (FULL_REVIEW, iteration 1) | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-10

Fix commit: `7fb45f5` on `heatwave-v4-subproject-a`.

## Per-Finding Responses

```
Finding ID:   F-hw-v4-A-101 (Major)
Response:     Fixed
Change:       protocol/implementer.md — the Appendix G trailing "> **Rationale.**" block restored verbatim
              (byte-identical to git show b3044e8:PROTOCOL.md line 975) immediately after R-94, at
              protocol/implementer.md:89-90. PROTOCOL.md regenerated (sh build-protocol.sh) in the same commit.
              Root cause for the record: v3.1's PROTOCOL.md had no trailing newline, so `wc -l` reported 974
              while the rationale sat on line 975; T1's sed range `963,974p` cut exactly that line. No reword,
              pure move completed.
Verification: The finding's stated method, executed:
              test "$(git show b3044e8:PROTOCOL.md | grep -c '^> \*\*Rationale')" -eq "$(cat protocol/*.md | grep -c '^> \*\*Rationale')"
                → true; census 17 = 17
              sh build-protocol.sh --check → "OK: PROTOCOL.md matches protocol/ shards", exit 0
Evidence:     Census output "rationale census equal: 17 = 17"; drift-exit=0 (this session). AC-N-03 guards
              re-run at the fix commit: comm -23 empty, uniq -d empty. AC-N-01 re-run since shard content
              changed: core+implementer = 427 (was 425; +2 for the restored block) — still ≤ 450; no other
              shard touched, so all other matrix rows unchanged.
```

```
Finding ID:   F-hw-v4-A-102 (Minor)
Response:     Fixed
Change:       adapters/claude-code/role-gate.sh:34-36 — the design-doc allowance is now anchored AND
              extension-restricted per the suggested fix: a path is allowed only when
              os.path.realpath(path) starts with os.path.realpath(os.getcwd()) + "/<design_doc_path>/" and
              the path ends with ".md". realpath on BOTH sides (not abspath) because macOS /var and /tmp are
              symlinks into /private — a getcwd()-only resolution broke the legitimate case, caught by the
              fixture on first run and corrected. PLANNING-only scoping not added (reviewer marked it
              optional); the remaining state-blind ceiling carries the R-93 tag (see F-104) and the updated
              Known Limitations bullet in the Implementation Package.
Verification: The finding's stated method plus the reviewer's D-1 case set, executed against a fresh
              mktemp install with a PLANNING fixture run:
              design-md-exit=0 (expect 0) · nested-src-exit=2 (expect 2) · nested-md-exit=2 (expect 2) ·
              design-nonmd-exit=2 (expect 2) · src-exit=2 (expect 2) · custom-notes-md-exit=0 (expect 0) ·
              old-default-after-reconfig-exit=2 (expect 2)
Evidence:     All seven exit codes above, verbatim from this session; sh -n role-gate.sh exit 0.
```

```
Finding ID:   F-hw-v4-A-103 (Minor)
Response:     Fixed
Change:       docs/superpowers/impl/2026-08-10-subproject-A-implementation.md:26 — "951 lines" corrected to
              "1025 lines at fix-1" (the count at the fix commit, i.e. post-F-101 regeneration; the
              reviewer's 1023 was correct at 16320d6, +2 from the restored rationale block). The package's
              Known Limitations bullet on the gate ceiling was also updated to describe the post-F-102
              behavior — leaving it would have made the package assert a limitation that no longer exists.
Verification: The finding's stated method: wc -l PROTOCOL.md → 1025; grep '1025' in the revised package →
              line 26 matches.
Evidence:     "1025 PROTOCOL.md" and the matching table row, both from this session.
```

```
Finding ID:   F-hw-v4-A-104 (Nit)
Response:     Fixed
Change:       adapters/claude-code/role-gate.sh:33 — the allowance comment now carries the R-93 tag,
              updated to name the post-F-102 ceiling: "# ponytail: prefix+.md anchor; scope to
              PLANNING-only if the gate ever needs role awareness." (The reviewer's suggested wording named
              the substring ceiling, which F-102 removed; the tag names the ceiling that actually remains.)
Verification: grep -n 'ponytail:' adapters/claude-code/role-gate.sh → line 33, tag present.
Evidence:     Grep output above, this session.
```

## New Deviation Records

None. (The F-102 realpath detail is part of the finding's own suggested fix, not a divergence; the F-103
Known-Limitations touch-up is the same finding class — stale package statement — disclosed inline above.)

## Blast Radius (fixes)

Files touched: protocol/implementer.md (+2 lines, Appendix G tail), PROTOCOL.md (regenerated, +2),
adapters/claude-code/role-gate.sh (allowance block only), the Implementation Package (two prose lines).
Consumers: PROTOCOL.md/implementer-shard consumers get strictly more content (a restored rationale — no rule
text changed, R-number set unchanged, comm/uniq guards re-run clean); role-gate consumers get a strictly
narrower allowance (everything newly blocked was outside R-106's intent; the one legitimate flow —
`<root>/<design_doc_path>/*.md` — is fixture-proven open, including a custom `design_doc_path`).
No other adapter, prompt, template, or script touched. Reasoning: all four fixes are leaf edits with
mechanical guards re-run at the fix commit (drift check OK, AC-N-01 = 427 ≤ 450, AC-N-03 clean).

## Notes

Fix commit `7fb45f5`, local branch only, no push — per run constraints.
