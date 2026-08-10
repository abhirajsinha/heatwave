# Review Report

task_id: hw-v4-A-intake-slimdown | artifact_type: review-report | iteration: 1→2 | review_type: FULL_REVIEW + TARGETED_REVIEW (below) | produced_by: REVIEWER (claude-fable-5, fresh context — authored none of the artifacts under review) | timestamp: 2026-08-10

---

## TARGETED_REVIEW — iteration 2 (fix commit `7fb45f5`, Fix Report docs/superpowers/reviews/2026-08-10-fix-report-A.md)

### Verdict

**GATE_MET**
Blockers: 0 open | Majors: 0 open | Minor: 0 open | Nit: 0 open — all four findings Fixed, verified by this reviewer's own re-execution, not the Fix Report's pasted output.

### Reconciliation

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-hw-v4-A-101 (Major) | Open | **Fixed** | Rationale block restored at protocol/implementer.md:89; `diff` against `git show b3044e8:PROTOCOL.md` line 975 → text identical, sole difference the original's missing trailing newline (matches the Fix Report's root cause: v3.1 line 975 had no final newline, so T1's 963,974 range cut it). Census re-run: 17 = 17. Pure restore, no reword. |
| F-hw-v4-A-102 (Minor) | Open | **Fixed** | Allowance now `os.path.realpath(path).startswith(realpath(cwd)/<dd>/)` AND `.endswith(".md")` (role-gate.sh:43-44). All 7 fixture cases re-run myself in a fresh mktemp PLANNING fixture — actual exit codes: design-md=0, nested-src=2, nested-md=2, design-nonmd=2, src=2, custom-notes-md=0, old-default-after-reconfig=2. Every expectation met; the nested-path escape is closed. realpath-both-sides correctly survives the macOS /var→/private symlink (the mktemp fixture itself proves it). |
| F-hw-v4-A-103 (Minor) | Open | **Fixed** | `wc -l PROTOCOL.md` → 1025 (+2 from the restored block); package line 26 now reads "1025 lines at fix-1". |
| F-hw-v4-A-104 (Nit) | Open | **Fixed** | `ponytail:` tag at role-gate.sh:33, naming the ceiling that remains post-F-102 (state-blind allowance) — better than my suggested wording, which named the now-removed substring ceiling. |

Late findings: None — the fix diff introduces no new defects.

### Regression checks (re-run at 7fb45f5)

| Item | Result | Evidence |
|---|---|---|
| Drift check | PASS | `OK: PROTOCOL.md matches protocol/ shards`, exit=0 |
| Injected-drift negative | PASS | `DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh`, exit=1; restored → OK |
| AC-N-01 | PASS | core+implementer = 427 ≤ 450 (+2, only implementer shard grew; all other rows unchanged) |
| AC-N-03 | PASS | loss `comm -23` → 0 lines; duplication `uniq -d` → 0 lines |
| Diff scope | PASS | `git diff 7fb45f5~1 7fb45f5` touches exactly 4 files (implementer shard +2, PROTOCOL.md regen +2, role-gate allowance block, package prose ×2). The Known-Limitations touch-up is the same finding class as F-103 (stale package statement), disclosed inline — accepted, not scope creep; leaving it would have made the package assert a removed limitation. |

### Deferred-with-approval

F-102's remaining state-blind ceiling (allowance applies in every no-edit state, not just PLANNING): **deferral approved by this reviewer (R-6)** — it now admits only root-anchored `.md` files in the design-doc directory, carries the R-93 tag, and is documented in the package.

---

## FULL_REVIEW — iteration 1 (historical, superseded by the verdict above)

### Verdict

GATE_NOT_MET
Blockers: 0 open | Majors: 1 open | Minor: 2 | Nit: 1

## Scope Evaluated

Plan scope (all six declared categories): plan-conformance, verification-integrity, business-logic, error-handling, secure-config, data-integrity. No expansions.

## Scope Changes

None.

## Reconciliation

N/A — iteration 1.

Late findings: None.

## Deviation Adjudication (R-5/R-6 — severity and acceptance are the REVIEWER's)

- **D-1 — ACCEPTED (resolution correct).** R-106 requires the PLANNER to write `docs/design/<task-id>.md` during PLANNING; the pre-fix gate blocked every non-`.heatwave` write in PLANNING, making AC-F-04 unsatisfiable on the claude adapter. The gate change is the right fix at the right layer, and I reproduced the implementer's deterministic proof independently (fixture run in PLANNING: `docs/design/x.md` → exit 0, `src/greet.js` → exit 2, custom `design_doc_path: notes` honored → exit 0 with `docs/design` then blocked → exit 2). The R-106 "conflict" was a plan omission, not a protocol contradiction — the deviation restores conformance with R-106 rather than violating it. Residual looseness is a real but non-gating defect → F-hw-v4-A-102 (Minor) and F-hw-v4-A-103 (Nit) below.
- **D-2 — ACCEPTED.** Encodes plan Edge Case 5 verbatim; verified present in `prompts/orchestrator.md:20`. No scope/threat impact.
- **D-3 — ACCEPTED.** Architecture §D is the plan's authority for R-107/R-108 placement; the task file-list omission was a plan gap. Verified landed in `protocol/orchestrator.md` §9.6 (line 117) and §9.7 (line 121).
- **D-4 — ACCEPTED.** Same-intent cleanup within T2's dedup mandate. Verified: core R-15 (protocol/core.md:220) and the run-dir tree comment + §9.2 (protocol/orchestrator.md:71,95) now point at `templates/run-record.yaml` (normative).

All four deviations were correctly declared per R-21 (not self-approved) — no R-22 exposure from them.

## Acceptance Status

(Not FINAL_REVIEW, but recorded since I re-verified evidence.)

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | Run dir `hw-target/.heatwave/runs/001-button-color-white`: exactly `01-express-change.md` + `02-express-check.md`, no planning/plan-review artifact; `state.yaml` → `state: APPROVED`, `tier: EXPRESS`; `src/button.css` → `color: white`; check verdict PASS with machine gate |
| AC-F-02 | Satisfied | Run 002: `run_config.tier: STANDARD`, justification cites R-102/auth path; first artifact `01-planning-document.md` |
| AC-F-03 | Satisfied | Run 003: `01-express-change.md` `Result: scope_exceeded — R-103 "estimated ≤ 2 files" … (R-105)`; run-record transition `EXPRESS_IMPLEMENTING → PLANNING` with `tier_promotions` EXPRESS→LIGHT, counters 0; promoted LIGHT loop reached APPROVED |
| AC-F-04 | Satisfied | `hw-target3/docs/design/add-stats-subsystem.md` has 7 `## ` sections; planning doc references `design/` twice; deterministic gate-allowance re-test passed (D-1) |
| AC-F-05 | Satisfied | `hw-target4/docs/design` absent (ls exit 1); `design_doc: false` |
| AC-F-06 | Satisfied | Static: `grep -rn 'PROTOCOL.md' prompts/` → 0 hits (re-run). Live: parsed `ac-f-01-stream.json` myself — both `Agent` dispatch payloads (heatwave-implementer, heatwave-reviewer) contain 0 occurrences of `PROTOCOL.md` and reference `protocol/core.md`; the stream's only occurrences are the GATE.md hook injection (a documented "full rendered spec" pointer) and an `ls` result |
| AC-F-07 | Satisfied | Re-run: `OK: PROTOCOL.md matches protocol/ shards` exit 0; injected `printf '\n' >> protocol/fixer.md` → `DRIFT: … run: sh build-protocol.sh` exit 1; restored → OK exit 0 |
| AC-F-08 | Satisfied | Run 004: planning doc → plan review → implementation package → 04-findings-1.yaml + 04-full-review-1.md → 05-final-review-1.md; terminal APPROVED |
| AC-F-09 | Satisfied (method deviation accepted) | Run 004 paired-NN ledgers; run 005: `F-005-version-constant-001` answered in `05-fix-report-1.md`, `06-findings-2.yaml` reconciles to `status: Fixed`, `07-findings-3.yaml` at FINAL. The gating finding came from a fixture rather than a flaw seeded into run 004 — honestly disclosed, and it exercises exactly what the AC asserts (ledger → fixer-by-id → ledger-driven reconciliation). Accepted |
| AC-F-10 | Satisfied | Run 006 (v3.1-format fixture): `grep -c run_config run-record.yaml` → 0 (record not rewritten); resumed in FIXING (`05-fix-report-1.md` first new artifact), never re-entered intake; APPROVED |
| AC-F-11 | Satisfied | Re-run in fresh mktemp dir: 8 shard files, 4 new templates, second run 3 `skipped` lines, `Heatwave protocol (binding)` count = 1 |
| AC-F-12 | Satisfied | Both sweeps re-run at HEAD: packaging grep → empty; invariant grep → every non-run-artifact hit EXPRESS-qualified (14 hits inspected, listed in Verification Log) |
| AC-N-01 | Satisfied | Re-run `wc -l`: core+implementer = **425** ≤ 450; all matrix rows < 974 (core 337; +planner 529; +reviewer 478; +fixer 382; +orchestrator 459; PLAN_REVIEW 670; FINAL 512) |
| AC-N-02 | Satisfied | `sh -n` on all three scripts exit 0; `env PATH=/usr/bin:/bin sh build-protocol.sh --check` OK exit 0; no package manifests in diff |
| AC-N-03 | Satisfied as specified — but see F-hw-v4-A-101 | Loss `comm -23` → empty; duplication `uniq -d` → empty (both re-run at HEAD vs b3044e8). The check preserves every R-number; it is blind to bare `> Rationale` blocks, and one was lost |

## Findings

*(Pre-R-109 meta-run: canonical detail carried inline below, Appendix A schema.)*

```
Finding ID:     F-hw-v4-A-101
Severity:       Major
Category:       plan-conformance
Location:       protocol/implementer.md:88 (end of Appendix G) / PROTOCOL.md (generated) — vs. v3.1 PROTOCOL.md:975 (git show b3044e8:PROTOCOL.md)
Problem:        T1's extraction silently dropped the Appendix G trailing Rationale block: "> **Rationale.** A verification
                protocol this strict invites over-building — an implementer graded on passing review will gold-plate. …"
                v3.1 has 17 `> **Rationale**` blocks; the v4 shards have 16. protocol/implementer.md ends at R-94 with no
                rationale; the block is absent from the generated PROTOCOL.md too.
Why it matters: The plan's T1 is "pure move, zero content change" and states verbatim: sections move "including each
                rule's `> Rationale` block, which travels with its rule." This is the plan's own top-listed risk
                ("Extraction drops … a rule", Medium) realized in the one content class the mechanical guards cannot see:
                the AC-N-03 comm/uniq checks key on R-numbers and the T1 loop keys on §-headings — a bare rationale block
                has neither. The deliverable IS the canonical protocol; silent content loss in the extraction violates the
                locked "extract, don't rewrite" decision, and the Implementation Package's "extracted verbatim (T1, pure
                move)" claim is false in this particular. Classified Major, not Blocker: R-22 (undeclared deviation →
                Blocker) attaches severity to concealment of a *chosen* divergence; this is an accidental omission the
                honestly-run guards were structurally blind to, i.e. a defect, not a concealed decision.
Concrete failure scenario: a future shard consumer (or sub-project B–H) treats the v4 shards as the complete v3.1
                content per the shard map's "pure move" promise; the ponytail-binding rationale — the recorded WHY for
                R-91–R-94 — is gone from the canonical source and every future render, unrecoverable except via git
                archaeology.
Suggested fix:  Append the block verbatim after R-94 in protocol/implementer.md; run `sh build-protocol.sh`; commit both.
Verification method (R-32 — FIXER must run it):
                test "$(git show b3044e8:PROTOCOL.md | grep -c '^> \*\*Rationale')" -eq "$(cat protocol/*.md | grep -c '^> \*\*Rationale')"   # both 17
                sh build-protocol.sh --check   # OK, exit 0
Status:         Open
```

```
Finding ID:     F-hw-v4-A-102
Severity:       Minor
Category:       secure-config
Location:       adapters/claude-code/role-gate.sh:41
Problem:        The D-1 design-doc allowance matches the substring "/<design_doc_path>/" anywhere in the absolute path and
                runs before the state check, unconditional on state and file extension.
Why it matters: Verified live with a PLANNING fixture: `<proj>/src/docs/design/evil.js` → exit 0 (a source file in any
                same-named directory is writable during every no-edit state, including all review states where no role
                should write design docs at all). The gate is drift protection, not an adversarial boundary, the default
                path never holds executable source, and the ceiling is disclosed in Known Limitations — hence Minor, and
                D-1 itself stands accepted.
Suggested fix:  Anchor to project-root-relative prefix (path starts with `<cwd>/<dd>/`) and/or restrict to `.md`;
                optionally scope to PLANNING only.
Verification:   Re-run the fixture: nested `src/docs/design/evil.js` → exit 2; `docs/design/x.md` in PLANNING → exit 0.
Status:         Open — may be deferred by this reviewer's approval if the FIXER proposes it (R-6); fixing alongside 101 is
                cheap and preferred.
```

```
Finding ID:     F-hw-v4-A-103
Severity:       Minor
Category:       verification-integrity
Location:       docs/superpowers/impl/2026-08-10-subproject-A-implementation.md:26
Problem:        Files Changed table states PROTOCOL.md is "951 lines"; at the package's own commit (16320d6) it is 1023.
                951 was the T2-era value, stale by T3–T10 growth.
Why it matters: A quantitative evidence figure in the package is wrong. No AC keys on this number (AC-N-01 uses shard
                sums, which I re-verified independently), so it is an inaccuracy, not evidence dishonesty — Minor.
Suggested fix:  Correct to the current generated line count when revising the package.
Verification:   `wc -l PROTOCOL.md` matches the figure in the revised package.
Status:         Open
```

```
Finding ID:     F-hw-v4-A-104
Severity:       Nit
Category:       plan-conformance
Location:       adapters/claude-code/role-gate.sh:30–31
Problem:        The substring-match ceiling is listed in Known Limitations with ponytail phrasing, but the code comment
                lacks the `ponytail:` tag R-93 requires for deliberate simplifications with a known ceiling.
Suggested fix:  Change the comment to include `ponytail: substring match; tighten to root-relative if it ever matters`.
Status:         Open
```

## Verification Log

| Item | Method | Result | Evidence |
|---|---|---|---|
| Drift check (AC-F-07) | `sh build-protocol.sh --check`, re-run myself | PASS | `OK: PROTOCOL.md matches protocol/ shards`, exit=0 |
| Injected-drift negative | `printf '\n' >> protocol/fixer.md` then `--check`; restore | PASS | `DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh`, exit=1; after restore OK exit=0 |
| AC-N-01 | `wc -l` on shards, re-run | PASS | core+implementer 425 ≤ 450; every matrix row < 974 |
| AC-F-06 static | `grep -rn 'PROTOCOL.md' prompts/` | PASS | empty, exit 1 |
| AC-F-12 packaging | plan's exact pipeline over prompts/ + adapters/ | PASS | empty |
| AC-F-12 invariants | plan's grep over PROTOCOL.md/protocol/adapters/prompts/docs/README | PASS | 14 hits, each EXPRESS-qualified (§0.5 preamble ×2, GATE.md, HEATWAVE.md:29, generic:23, codex/gemini/cursor/copilot/windsurf/cline/zed/aider summaries) |
| AC-N-03 | `comm -23` old/new R-numbers; `uniq -d` on shard rule definitions | PASS | both empty |
| Extraction completeness beyond R-numbers | sorted-line diff, v3.1 (b3044e8) vs T1 shards and vs HEAD shards | 1 FAIL | every removed line maps to a planned amendment (Appendix D/E dedup, R-15/R-29/§0.5/headers/T7 comments) **except** the Appendix G rationale → F-101; Rationale census 17 → 16 |
| AC-N-02 | `sh -n` ×3; restricted-PATH build | PASS | exit 0 all |
| AC-F-11 | fresh mktemp install ×2 | PASS | 8 shards, 4 templates, 3 skipped-lines, 1 gate block |
| D-1 gate behavior | hand-built PLANNING fixture piped into role-gate.sh | PASS (+ ceiling confirmed) | design-doc 0 / src 2 / nested-src 0 / custom-path 0 / old-default-after-reconfig 2 |
| Live-battery artifacts (AC-F-01…05, 08, 09, 10) | direct inspection of the four scratchpad targets' run dirs | PASS | see Acceptance Status rows — state.yaml/run-record/ledger contents matched every package claim I checked |
| AC-F-06 live | parsed `ac-f-01-stream.json` (python3 json) for Agent tool_use inputs | PASS | 2 dispatches, 0 `PROTOCOL.md` occurrences in payloads, `protocol/core.md` present |
| Reserved-field inertness | `grep -rn 'autonomy\|single_repo'` over prompts/adapters/scripts | PASS | only recording instructions and RESERVED comments; no branching consumer |
| R-1/R-2 under EXPRESS | inspection: matrix, express-checker.md, HEATWAVE.md map, heatwave-reviewer agent def | PASS | checker is a fresh reviewer-agent context; implementer never checks own change |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Non-Claude adapter shims live | codex/gemini/cursor/copilot/windsurf/cline/zed/aider CLIs NOT AVAILABLE (honest R-64 declaration in package, matches plan's Tooling Declaration) | None — AC-F-11/12 cover them by inspection + install assertions, as planned |
| shellcheck / yamllint | NOT AVAILABLE, declared in plan and package | None — no AC depends on them |
| Full re-run of live CLI battery | Costly; package evidence verified instead by direct inspection of the persisted run dirs and stream JSON, which are on disk and internally consistent | None — spot-verification satisfied the plan's "REVIEWER re-runs deterministic checks + spot-re-runs" mandate for AC-F-01 (artifacts + stream) with AC-F-08 verified from artifacts |

## Summary

The implementation is high-fidelity to the plan. Every deterministic check the package claims, I re-ran and reproduced: drift guard both directions, POSIX/no-dep checks, AC-N-01 sizes (core+implementer 425), AC-N-03 loss/duplication, both AC-F-12 sweeps, the idempotent double-install, and the D-1 gate proof. The live-battery evidence is real — the four scratch targets' run directories exist and their state files, run records, EXPRESS artifacts, ledgers, and promotion transitions match the package's claims, including the parsed dispatch payloads for AC-F-06. The R-64 declarations (non-Claude adapters, shellcheck, yamllint) are honest limitations, not silent skips, and block nothing. All four deviations are accepted; D-1 in particular is the correct resolution of a genuine plan omission, deterministically re-proven here.

One Major stands: the T1 "pure move" dropped the Appendix G trailing Rationale block — the only content in v3.1 not carried into the canonical shards, found by a rationale census (17 → 16) and a sorted-line differential the plan's own guards don't perform. It is a two-line fix plus regenerate. Two Minors (gate-allowance substring ceiling, a stale line-count figure in the package) and one Nit accompany it. Gate not met; → FIXING.
