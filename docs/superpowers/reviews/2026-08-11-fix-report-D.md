# Fix Report

task_id: 2026-08-11-ecosystem-companions | artifact_type: fix-report | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | responding to: FULL_REVIEW iteration 1 (`docs/superpowers/reviews/2026-08-11-full-review-D.md`)

## Per-finding responses

```
Finding ID:   F-2026-08-11-ecosystem-companions-005
Response:     Fixed
Change:       Both of the finding's offered remedies applied.
              (1) The §9.1 (v4-D) driver copy-duty was executed for real on the scratch
              record: companions in hw-d-strix/.heatwave/runs/add-auth-check/run-record.yaml
              now carry strix: run, strix_docker_up: "2026-08-11T08:04:56Z",
              strix_docker_down: "2026-08-11T08:05:23Z", plus fired[] entries for
              semgrep/mutmut/strix-stub and detected: [semgrep, gitleaks, mutmut, strix] —
              all values copied verbatim from the already-recorded review artifacts
              (04-review-report-1.md / 04-findings-1.yaml); NO new scan or Docker activity
              was performed, and none was needed: the timestamps are the review's real
              recorded events, not fresh ones.
              (2) The Implementation Package AC-F-05 bullet was rewritten to state the
              provenance precisely: markers originated in the reviewer's artifacts as
              driver instructions; the driver's first copy attempt silently no-op'd (an
              unverified str.replace against a block that no longer matched, with an
              unconditional success print — the root cause); the copy was re-executed
              during FIXING with read-back assertions. Package no longer overstates.
Verification: Read the record back and assert (the finding's ambiguity scenario —
              "an auditor reading the run record alone concludes the scan never ran" —
              must be gone).
Evidence:     $ grep -n -A9 "^companions:" .../hw-d-strix/.heatwave/runs/add-auth-check/run-record.yaml
                26:companions:
                27:  detected: [semgrep, gitleaks, mutmut, strix]   # strix = declared stub ...
                28:  fired:
                29:    - { tool: semgrep, stage: FULL_REVIEW, verdict: pass, ... }
                30:    - { tool: mutmut, stage: FULL_REVIEW, verdict: fail, ... }
                31:    - { tool: strix, stage: FULL_REVIEW, verdict: pass, evidence: "declared stub, clean scan exit 0, ..." }
                32:  strix: run             # R-119: all three legs held under the active dynamic_security block
                33:  strix_docker_up: "2026-08-11T08:04:56Z"
                34:  strix_docker_down: "2026-08-11T08:05:23Z"
              Python read-back assertions passed ("copy-duty applied and read-back
              verified"; a replace-seam doubled quote on line 34 was caught by a second
              assertion pass and fixed — final state single-quoted, asserted).
              Package diff: commit on branch (see below), AC-F-05 bullet now carries the
              provenance paragraph citing run-record.yaml:32–34.
```

```
Finding ID:   F-2026-08-11-ecosystem-companions-006
Response:     Fixed
Change:       The exemplar driver instruction in hw-d-strix/.heatwave/runs/add-auth-check/
              04-review-report-1.md now reads `companions.strix: run` (the shipped enum
              token) with the stub/clean detail explicitly routed to companions.fired[]
              ("enum value per templates/run-record.yaml; the stub/clean detail belongs
              in `companions.fired[]`, not the enum field"). The applied record (F-005
              fix) models the same split: enum field `run`, stub annotation in fired[]
              and a comment.
Verification: No non-enum strix marker token remains anywhere in the evidence tree.
Evidence:     $ grep -rn "ran (stub" scratchpad/ docs/superpowers/impl/
              → zero occurrences ("zero 'ran (stub' occurrences remain anywhere");
              replace script asserted 'ran (stub, clean)' absent post-write.
```

## Deviation Records

None. No shard, template, prompt, config, or adapter file was touched — the fixes change one scratch run-record, one scratch review-report exemplar line, and the Implementation Package's own prose. (Note: the exemplar edit touches a completed scratch review artifact; it is made under the reviewer's explicit F-006 direction — "fix the exemplar" — not unilaterally.)

## Blast radius

Files touched: `docs/superpowers/impl/2026-08-11-subproject-D-implementation.md` (package prose), plus two scratchpad evidence files outside the repo. Consumers: FINAL_REVIEW (reads the package and the scratch evidence). Shared state/schema/contracts: none — protocol text, templates, and PROTOCOL.md untouched, so no regenerate was required; drift check re-run anyway as a guard: `OK: PROTOCOL.md matches protocol/ shards` (exit 0). No other run's record was modified; `hw-d-clean`'s AC-F-04 record deliberately untouched.

## Notes

Root cause of F-005, for the record: the hw-d-strix run-record was seeded by copying hw-d-clean's already-annotated record, so the later marker-update script's `str.replace` — written against the pristine template block — matched nothing and returned the string unchanged; the script printed success unconditionally. Class fix applied to conduct, not code (no reusable script exists to fix): every record mutation in this FIXING pass asserts the pre-image exists and asserts the post-image on read-back.
