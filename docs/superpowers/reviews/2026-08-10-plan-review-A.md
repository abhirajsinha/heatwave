# Review Report

task_id: hw-v4-A-intake-slimdown | artifact_type: review-report | iteration: 1 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-10

## Verdict

**GATE_NOT_MET — REJECTED → back to PLANNER**
Blockers: 0 open | Majors: 3 open | Minor: 4 | Nit: 2

## Scope Evaluated

PLAN_REVIEW per PROTOCOL.md §4.2 (R-35): completeness against §3.2, AC conformance against §3.2.2, review-scope justification against §5.1, tooling-declaration realism against §6.1, internal consistency — plus conformance to the approved design spec (`docs/specs/2026-08-10-adaptive-intake-slimdown-design.md`) and ground-truthing of every file path, section number, and interface the plan cites against the actual repo.

## Scope Changes

None.

## Reconciliation

N/A — iteration 1.

## Acceptance Status

N/A — PLAN_REVIEW (assessed for quality, not satisfaction). AC quality summary: all 11 AC-F and 3 AC-N are independently verifiable with concrete methods, except AC-F-06 whose method is unsatisfiable as written (F-hw-v4-A-003) and AC-F-03 whose setup is non-deterministic (F-hw-v4-A-007).

## Findings

```
Finding ID:           F-hw-v4-A-001
Severity:             Major
Category:             plan-conformance
Location:             Plan Task 9 (docs/superpowers/plans/2026-08-10-adaptive-intake-slimdown.md:420); adapters/claude-code/HEATWAVE.md:15
Problem:              Task 9 says references are "found by grep -rn 'PROTOCOL.md' prompts/ adapters/" then enumerates a SUBSET of that grep's actual hits. Omitted entirely: adapters/claude-code/HEATWAVE.md — the block installed into every target's CLAUDE.md — whose line 15 instructs the driver to "Pass each subagent only its prompt file, `PROTOCOL.md`, the permitted artifacts (R-3), and heatwave.config.yaml", whose state→subagent map lists no EXPRESS states, and whose Hard boundary says "Small tasks use the LIGHT tier, not a skipped protocol". Also omitted: gemini/GEMINI.md:10, cursor/heatwave.mdc:13, copilot/copilot-instructions.md:10, windsurf/heatwave.md:10, cline/heatwave.md:5, zed/rules:5, aider/CONVENTIONS.md:5 — all still directing tools to read the full PROTOCOL.md.
Why it matters:       The primary adapter's binding instructions would mandate attaching the full 974-line doc (contradicting new R-107) and forbid the EXPRESS path outright ("Small tasks use the LIGHT tier"). The T11 battery runs through this exact adapter — AC-F-01 and AC-F-06 are jeopardized by an instruction file the plan never touches. The plan's own risk table claims "Task 9 greps every reference and updates each"; the task list does not. Also unresolved: which subagent runs EXPRESS_CHECK in the claude-code adapter (heatwave-reviewer? a new agent?) — the dispatch matrix names the prompt but no agent mapping exists.
Recommended fix:      Add adapters/claude-code/HEATWAVE.md to Task 9 with exact edits: shard-based dispatch line, EXPRESS_IMPLEMENTING/EXPRESS_CHECK rows in the subagent map (naming the agent for the checker), EXPRESS carve-out in the Hard boundary. Either update the seven remaining adapter shims to core+shard reading or explicitly declare them out of scope with the token-savings consequence stated.
Verification method:  After revision: `grep -rn "PROTOCOL.md" prompts/ adapters/ | grep -v "full rendered spec"` — every remaining hit is either a stable §-citation or explicitly declared out of scope in the plan; HEATWAVE.md contains EXPRESS state mappings (`grep -n EXPRESS adapters/claude-code/HEATWAVE.md` non-empty).
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-002
Severity:             Major
Category:             business-logic
Location:             Plan Task 3 (plan:263-272) + Task 9 (plan:420); PROTOCOL.md:40; adapters/claude-code/GATE.md:1; adapters/generic/HEATWAVE-AGENT.md; adapters/codex/AGENTS.md
Problem:              The "plan-first" invariant statements are nowhere scheduled for amendment, yet EXPRESS makes each one false. (a) PROTOCOL.md §0.5 preamble — "Every tier keeps all four gates: a plan reviewed by a separate context … What a tier changes is how much of the Planning Document must be written out" — moves verbatim into protocol/core.md in T1 (pure move) and T3's exhaustive "exact additions" list (items 1–5) never amends it, so the core spine would contradict the EXPRESS row in the table directly beneath it. (b) GATE.md (injected on every prompt via hook): "No code before a Planning Document passes PLAN_REVIEW at 0 Blockers / 0 Majors". (c) HEATWAVE-AGENT.md and codex/AGENTS.md: "no implementation before an approved plan". Task 9 explicitly asserts "only *attachment/reading* instructions change", locking these sentences in.
Why it matters:       These are the most-loaded instructions in the system (GATE.md fires on every user prompt). A driver reading a binding gate that forbids code-before-plan while state.yaml says EXPRESS_IMPLEMENTING has contradictory normative inputs; a compliant model refuses the EXPRESS path and AC-F-01 fails — or worse, learns that binding text is ignorable. Internal consistency is an explicit R-35 evaluation axis.
Recommended fix:      Add to T3: amend the §0.5 preamble ("Every tier except EXPRESS keeps…" plus one sentence stating EXPRESS's substitute gate: independent machine-gated check, R-104). Add to T9: exact replacement sentences for GATE.md, HEATWAVE-AGENT.md, AGENTS.md ("no implementation before an approved plan — except the EXPRESS tier, where one independent machine-gated check gates APPROVED (R-104)"), and delete the "only attachment/reading instructions change" claim.
Verification method:  `grep -rn "before a Planning Document\|before an approved plan\|keeps all four gates" PROTOCOL.md protocol/ adapters/` — every hit carries an EXPRESS qualifier or lives in history.md.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-003
Severity:             Major
Category:             verification-integrity
Location:             Plan AC-F-06 (plan:452) vs Task 9 (plan:420, "Prompts' inline 'per PROTOCOL.md §x' citations stay valid … only attachment/reading instructions change")
Problem:              AC-F-06's method — "`grep -c 'PROTOCOL.md'` over a dispatch payload = 0" — cannot pass under the plan's own decisions. Every dispatch payload includes the role prompt (dispatch matrix: [shards][config][role prompt][artifacts]), and Task 9 deliberately keeps citations like "a Review Report per PROTOCOL.md §3.4" in prompts/reviewer.md:3, planner.md:7, fixer.md:3, implementer.md:3, final-reviewer.md:3, plan-reviewer.md:3. The grep would count ≥ 1 on every dispatch. Separately, those citations invite a shard-dispatched subagent to open .heatwave/PROTOCOL.md (it exists in the target), silently defeating G4's token savings with no detection.
Why it matters:       An acceptance criterion that is unsatisfiable as specified either fails honestly (blocking a correct implementation) or gets quietly reinterpreted by the implementer — the exact evidence-integrity failure mode Heatwave exists to prevent. This is a defect in the criterion, not the design.
Recommended fix:      Pick one and encode it: (a) reword prompts' citations to shard-relative form ("per protocol §3.4 — in your attached shards") in Task 9, keeping AC-F-06's grep strict; or (b) respecify AC-F-06 to assert on the attachment list only ("no dispatch attaches the file PROTOCOL.md; grep for `.heatwave/PROTOCOL.md` as an attachment path = 0") plus AC-N-01's size measurement as the substantive check.
Verification method:  Re-run the revised AC-F-06 method against a real T11 dispatch payload; it must be executable and pass/fail unambiguously.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-004
Severity:             Minor
Category:             business-logic
Location:             Plan shard map (plan:57-63): §5.1 and §5.4 → protocol/reviewer.md; R-106 → protocol/planner.md
Problem:              Rules binding one role are mapped into shards that role never loads. (a) §5.1 R-46/R-47 ("The PLANNER MUST declare … review categories") sit in the reviewer shard; the PLANNING dispatch (core + planner.md) never sees them, and the planner shard's §3.2 table dangles a "See 5.1" it cannot resolve. (b) §5.4 R-53 ("The IMPLEMENTER MUST declare blast radius … in every Fix Report") sits in the reviewer shard; IMPLEMENTING and FIXING dispatches never load it. (c) R-106's first half is driver behavior (resolve design_doc at intake) but lives in the planner shard; the intake dispatch (core + orchestrator.md) never loads it. Prompts restate these duties, which is why this is Minor not Major — but the spec's own principle is shards "carrying only that role's normative rules", and a MUST enforced only by prompt prose is one prompt edit away from silent loss.
Why it matters:       The normative force of a shard-dispatched protocol is exactly the rules the role receives; misassigned rules degrade to unenforced prose.
Recommended fix:      Move §5.4 to core.md (R-53 binds the implementer, R-54 the reviewer — core is the shared home; ~15 lines). Move §5.1 to the planner shard or core. Split R-106: driver-resolution sentence into orchestrator shard (or core §2.5), planner-emission sentences stay in §3.2.3. Update the shard map table and Task 1 accordingly.
Verification method:  For each MUST in the shards, the bound role's dispatch-matrix row includes the shard containing it: spot-check R-46, R-53, R-106 against the matrix.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-005
Severity:             Minor
Category:             business-logic
Location:             Plan Task 6 (plan:399) and R-109 (plan:110) vs PROTOCOL.md §3.4 structure item 6 and R-29 (PROTOCOL.md:284-301)
Problem:              R-109 makes the YAML ledger the "machine artifact of record" and the Review Report a rendered summary, but §3.4's report structure ("6. Findings — per Appendix A") and R-29 ("Findings MUST use the Appendix A schema") move into the reviewer shard unamended. A reviewer holding both is told full Appendix-A findings belong in the report AND that the report only summarizes.
Why it matters:       Two coexisting instructions about where canonical findings live will produce inconsistent artifacts across runs (some reviewers duplicating full blocks in both files, some not), which frustrates the ledger's token-saving purpose.
Recommended fix:      Task 6 amends §3.4 item 6 to "Findings — summary per finding; canonical Appendix-A detail in the findings ledger (R-109)" and appends one clause to R-29 ("…schema, carried in the findings ledger from v4").
Verification method:  `grep -n 'per Appendix A' protocol/reviewer.md` — the report-structure line references the ledger.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-006
Severity:             Minor
Category:             verification-integrity
Location:             Plan Task 1 verification (plan:204-213); AC-N-03 (plan:465)
Problem:              The disjointness constraint is stated as MUST ("no section appears in two shards") but verified by a 16-heading spot-check out of ~40 §-headings, and the R-number check (`comm -23` on `sort -u` output) detects loss only — a rule duplicated into two shards passes both checks and lands duplicated in the generated PROTOCOL.md.
Why it matters:       Extraction-by-hand of a 974-line doc is exactly where a duplicated or half-moved block slips in; the plan's risk table names this risk and points at these checks as the mitigation.
Recommended fix:      Enumerate all §-headings mechanically instead of a hand list (`grep -oE '^#{2,4} [0-9]+\.[0-9.]+ ' PROTOCOL.md` as the loop source), and add a duplicate check: `cat protocol/*.md | grep -oE '^\*\*R-[0-9]+[ab]?\.\*\*' | sort | uniq -d` → expected empty.
Verification method:  Run the strengthened checks after T1; both emit nothing.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-007
Severity:             Minor
Category:             verification-integrity
Location:             Plan AC-F-03 (plan:449) / Task 11 (plan:437)
Problem:              AC-F-03's setup relies on the driver misclassifying a multi-file rename as EXPRESS "via seeded task phrasing". Classification is the driver's judgment; there is no guaranteed phrasing that produces the misclassification, so the scenario may be unexerciseable on any given attempt (the driver correctly picks STANDARD and scope_exceeded never fires).
Why it matters:       An AC whose precondition cannot be reliably established invites a narrated pass or an unbounded retry loop during the battery.
Recommended fix:      Add a deterministic fallback fixture: hand-write state.yaml (`state: EXPRESS_IMPLEMENTING`, `tier: EXPRESS`) + run_config for the multi-file task and resume — this directly and reproducibly exercises the R-105 implementer path and the promotion transition, which is what AC-F-03 actually asserts.
Verification method:  The fixture-driven run produces `Result: scope_exceeded` and the EXPRESS_IMPLEMENTING → PLANNING transition on the first attempt.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-008
Severity:             Nit
Category:             verification-integrity
Location:             Plan Task 1 (`grep -lc`, plan:211) and Task 8 (`grep -n '^\s*- .PROTOCOL.md.$'`, plan:416)
Problem:              `-lc` combines conflicting grep flags (-l silently wins) and `\s` is not POSIX BRE. Both verified working on this machine's BSD grep (tested live), so this is portability/clarity only.
Why it matters:       Verification commands in a plan that claims POSIX-only should themselves be POSIX-clean.
Recommended fix:      `-l` alone; `[[:space:]]*` for `\s*`.
Verification method:  Commands behave identically; `sh`-portable.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hw-v4-A-009
Severity:             Nit
Category:             data-integrity
Location:             R-109 (plan:110) vs PROTOCOL.md §9.2 run-dir numbering
Problem:              Two artifacts sharing one sequence number (`NN-findings-K.yaml` + `NN-review-report-K.md`) bends §9.2's "numbered sequentially in transition order" without saying so.
Why it matters:       Drivers and resume logic key off sequence numbers; an undocumented convention invites inconsistent numbering across runs.
Recommended fix:      One sentence in R-109 or §9.2: "a review transition produces a ledger and its rendered report under the same NN; the pair counts as one artifact for numbering."
Verification method:  Grep the amended text; AC-F-09's run dir shows the paired numbering.
Introduced in:        1
Status:               Open
```

## Verification Log

| Item | Method | Result | Evidence |
|---|---|---|---|
| Shard map completeness + disjointness | Traced every rule R-0a–R-100 in PROTOCOL.md (read in full, 974 lines) against the plan's map table | Map is accurate, complete, and disjoint — all 102 rules assigned exactly once | Manual trace; §-by-§ against PROTOCOL.md:1-974 |
| Cited file paths and line claims | Opened every claimed file | All real: orchestrator step 2 attaches PROTOCOL.md (prompts/orchestrator.md:21); install.sh refresh block (install.sh:28) matches; role-gate NO_EDIT_STATES is the claimed Python set (role-gate.sh); run-record tier comment (templates/run-record.yaml:6); config keys absent as claimed; README.md:85, docs/faq.md:7, docs/loop.md:49 all as cited | Read output in this review session |
| Appendix D/E R-number-free claim | Read both appendices | Confirmed: no R-numbers — dedup-to-pointer is AC-N-03-safe | PROTOCOL.md:809-935 |
| Tooling declaration honesty (R-63) | Probed this machine | Accurate: shellcheck and yamllint genuinely absent; claude 2.1.226 at the claimed path; cmp/comm/awk/git present | `which` output captured in session |
| Plan's own verification commands | Executed Task 1's `grep -lc` heading check and Task 8's `\s` grep against synthetic fixtures | Both behave as the plan expects on this machine's grep (portability nit F-008) | Live command output |
| Repo-wide PROTOCOL.md reference sweep | `grep -rn "PROTOCOL.md" prompts/ adapters/` | 26 hits; Task 9's enumeration covers a subset — basis of F-001 | grep output in session |
| Spec §2 goals → tasks/ACs | Mapped G1–G6 | All mapped: G1→T3/T8, G2→T3/T4/T8/T9, G3→T5, G4→T1/T2/T8/T9, G5→T6, G6→T3/T7 | Cross-reference |
| Spec §8 items 1–8 → ACs | Mapped | All mapped: 1→AC-F-01, 2→AC-F-02, 3→AC-F-03, 4→AC-F-04/05, 5→AC-F-06+AC-N-01, 6→AC-F-07, 7→AC-F-08, 8→AC-F-09; resume/packaging add AC-F-10/11 beyond spec | AC table plan:445-457 |
| Scope containment (no B–H leakage) | Read plan against spec §2 non-goals | Clean — reserved run-config fields declared inert, no branching; no Semgrep/tiering/MCP/benchmark work | Plan §Functional Req 6, Task list |
| §3.2 required sections present | Checked all 18 | All present, none silently omitted | Plan body |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Live EXPRESS/regression runs (AC-F-01, AC-F-08 spot re-runs) | These verify the implementation, not the plan; deferred to FULL/FINAL review per the plan's own Testing Strategy | None at PLAN_REVIEW |
| YAML parse-validation of proposed schemas | yamllint/PyYAML NOT AVAILABLE (probed) — matches the plan's declaration; grep-structural review performed instead | None (plan declares the same gap) |

## Summary

This is a strong plan built on an accurate foundation: the shard extraction map — the riskiest part of the work — was traced rule-by-rule against the real 974-line protocol and is complete, correct, and disjoint. Tooling claims are honest (probed), verification commands are real and mostly runnable (two were executed), tasks are ordered, placeholder-free, and carry exact texts and paths. Spec conformance is complete: every goal and every §8 evidence item maps to tasks and ACs, and scope discipline holds — reserved fields stay inert, nothing from sub-projects B–H leaks in.

The rejection rests on one blind spot with three faces: the plan updated where roles *read* the protocol but not where the old protocol's *assumptions* are asserted. The primary adapter's CLAUDE.md block still mandates attaching the full PROTOCOL.md and explicitly forbids skipping the planner for small tasks (F-001); the "no code before an approved plan" invariant survives unamended in the core spine's own §0.5 preamble and three injected instruction files (F-002); and AC-F-06's grep-zero criterion is unsatisfiable while the plan simultaneously decides to keep "per PROTOCOL.md §x" citations in the very prompts each dispatch payload contains (F-003). All three would surface as live-battery failures or, worse, as instructions the driver learns to ignore. Each fix is small and exactly specified in the findings; a revision addressing F-001–F-003 (and ideally the four Minors) should pass cleanly.

**Verdict: GATE_NOT_MET — PLAN_REVIEW REJECTED (0 Blockers, 3 Majors). Returns to PLANNER per §2.2; increments plan_iterations.**

---

# Iteration 2 — PLAN_REVIEW of revised Planning Document

task_id: hw-v4-A-intake-slimdown | artifact_type: review-report | iteration: 2 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-10

## Verdict (iteration 2)

**GATE_MET — PLAN_REVIEW APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 2 (new, non-gating) | Nit: 1 (new)

## Reconciliation (R-58)

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-hw-v4-A-001 | Open (Major) | Fixed — verified | Task 9 rewritten as complete enumeration. Re-ran the repo-wide sweep myself: all 7 shims + HEATWAVE.md now have exact per-line edits, and every cited line number verified against the actual files (HEATWAVE.md 5/15/17/27; gemini 10/12; cursor 13/15; copilot 10/12; windsurf 10/12; cline/zed/aider 5/7; GATE.md; HEATWAVE-AGENT.md 6/23; codex 10/12; adapters/README.md 3/29). EXPRESS_CHECK → heatwave-reviewer mapping added (dispatch matrix note + T9) — reusing the existing reviewer agent satisfies R-1/R-2 with no new file. Note: the sweep counts 29 hits, not 26; the 3 extra (README.md:159 link table, docs/loop.md:46 §-pointer, plus one) are legitimate human-doc pointers to the rendered spec needing no edit — the discrepancy is counting scope, not a missed offender. |
| F-hw-v4-A-002 | Open (Major) | Fixed — verified | T3 item 0 replaces the §0.5 preamble with exact text ("Every tier except EXPRESS keeps all four gates … No tier, including EXPRESS, ever lets a context approve its own work" — internally consistent with R-104). GATE.md, HEATWAVE-AGENT.md:23, codex:12, and the five sibling shims all get the EXPRESS exception clause; the "only attachment/reading instructions change" claim is deleted; the planner's own sweep caught docs/faq.md:7, which my iteration-1 report had missed. Re-ran the invariant sweep: every hit of the stated patterns is now covered. One differently-phrased residual found → new F-010 (Minor). Edge Case 10 added. |
| F-hw-v4-A-003 | Open (Major) | Fixed — verified | Option (a) adopted: all six role-prompt citations reworded (T9), orchestrator's in T8; AC-F-06 respecified as two-part (static grep over prompts/ = 0; live payload grep = 0). Satisfiable as written for the prompt/config/artifact components; one unspecified-content risk in core.md's shard-map table caption → new F-011 (Minor). |
| F-hw-v4-A-004 | Open (Minor) | Fixed — verified | Shard map corrected: §5.4 (R-53/R-54) → core; §5.1 (R-46/R-47) → planner (PLAN_REVIEW loads planner shard per matrix, so the plan-reviewer still receives it); R-106 split into driver half (core §2.5, loaded at intake) + planner half (§3.2.3). Placement principle stated in the map header. Verified each bound role's dispatch row now loads the shard holding its rule. |
| F-hw-v4-A-005 | Open (Minor) | Fixed — verified | T6 carries exact amendment texts for §3.4 item 6 and R-29's first sentence; verification grep included. |
| F-hw-v4-A-006 | Open (Minor) | Fixed — verified | T1 heading loop now mechanically enumerated from PROTOCOL.md (`grep -E` source, `grep -F -l` match); duplicate-definition check (`uniq -d` on `^\*\*R-N.` definitions) added; AC-N-03 carries both guards. (The heading pattern skips top-level `## N.` and Appendix headers — acceptable: their rule content is covered by the R-number guards, and the pattern matches my own recommended form.) |
| F-hw-v4-A-007 | Open (Minor) | Fixed — verified | AC-F-03 is now fixture-driven as primary method (hand-written EXPRESS_IMPLEMENTING state.yaml + run_config for a 3+-file task); first-attempt reproducible; organic misclassification demoted to bonus observation. |
| F-hw-v4-A-008 | Open (Nit) | Fixed — verified | `grep -F -l` + `wc -l` replaces `-lc`; `\s` eliminated (T8 check is now a plain-string grep). |
| F-hw-v4-A-009 | Open (Nit) | Fixed — verified | R-109 carries the paired-NN sentence verbatim; referenced in API Design §4 and AC-F-09. |

Late findings: F-010 is a late catch against README.md:85, a line my iteration-1 sweep patterns also missed (the clause phrases the invariant differently); visible here per R-60 as a review-quality note against iteration 1's pattern list, not a reopening.

## New Findings (iteration 2)

```
Finding ID:           F-hw-v4-A-010
Severity:             Minor
Category:             business-logic
Location:             Plan Task 10 (plan:616) / AC-F-12 (plan:642); README.md:85
Problem:              README.md:85's closing clause — "What never changes: the plan is reviewed before
                      code" — is the same plan-first invariant in different words. T10 edits this exact
                      line (adds the EXPRESS sentence) but does not reword the clause, and AC-F-12's
                      sweep patterns ("before a Planning Document|before an approved plan|keeps all four
                      gates|before any code is written") do not match this phrasing, so the exit gate
                      would pass with the contradiction intact — an EXPRESS sentence and a
                      "plan-reviewed-before-code always" claim in one paragraph.
Why it matters:       Human-facing FAQ prose only (not injected into any role context), so Minor — but
                      it is the one surviving instance of the F-002 class.
Recommended fix:      In T10, reword the clause ("What never changes: independent verification before
                      merge, and claims need evidence") and add "plan is reviewed before|reviewed before
                      code" to AC-F-12's sweep pattern.
Verification method:  AC-F-12 sweep with the widened pattern → README.md:85 hit is EXPRESS-consistent.
Introduced in:        2 (late catch per R-60 — phrasing escaped iteration 1's patterns too)
Status:               Open
```

```
Finding ID:           F-hw-v4-A-011
Severity:             Minor
Category:             verification-integrity
Location:             Plan Task 2 (plan:401, shard-map table into core.md) vs AC-F-06 part 2 (plan:636)
Problem:              core.md is part of every dispatch payload, and T2 places the shard-map table in it
                      with unspecified caption text. The natural caption ("PROTOCOL.md is generated from
                      these shards") would contain the literal string and fail AC-F-06's live
                      grep-count-zero. The generated-file banner is safe (emitted by build-protocol.sh's
                      printf, not present in core.md), but the table caption is unconstrained.
Why it matters:       The AC is satisfiable but not guaranteed by the task specs; an implementer following
                      T2 naturally could make AC-F-06(2) fail spuriously.
Recommended fix:      One sentence in T2: the shard-map table and its caption must not contain the literal
                      string "PROTOCOL.md" (say "the generated rendered spec"); or emit the table from
                      build-protocol.sh into the generated output only.
Verification method:  After T2: `grep -c 'PROTOCOL.md' protocol/core.md` = 0.
Introduced in:        2
Status:               Open
```

```
Finding ID:           F-hw-v4-A-012
Severity:             Nit
Category:             verification-integrity
Location:             Plan Task 9 exit sweep (plan:602) vs shim edits (plan:595)
Problem:              The exit sweep filters survivors with `grep -v "full rendered spec"` and
                      `grep -v "generated"`, but the seven shim edits leave the original "(full spec)"
                      wording in place — those lines fail both filters, so the exit check as written
                      flags the plan's own intended end-state. Self-detecting (fails loudly at T9), not
                      a shipped defect.
Recommended fix:      Have the shim edit reword "(full spec)" to "(full rendered spec)" — one word —
                      or widen the filter.
Verification method:  T9 exit sweep returns empty on the intended end-state.
Introduced in:        2
Status:               Open
```

## Verification Log (iteration 2)

| Item | Method | Result | Evidence |
|---|---|---|---|
| Sweep A completeness (F-001) | Re-ran `grep -rn "PROTOCOL.md" prompts/ adapters/ README.md docs/ COMPANIONS.md install.sh` myself | 29 non-spec hits; every role-facing attach/read instruction assigned an exact edit in T8/T9; 3 uncovered hits are legitimate human-doc pointers | grep output this session |
| Sweep B completeness (F-002) | Re-ran invariant grep with the plan's patterns PLUS widened ones (`reviewed before`, `plan is reviewed`, `no code before`) | All 14 hits of the plan's patterns covered by T3/T9/T10; one differently-phrased residual (README.md:85) → F-010 | grep output this session |
| Cited line numbers in T9 | Checked every per-file line claim against the actual files | All accurate (HEATWAVE.md 5/15/17/27, GATE.md:1, shims, agents, HEATWAVE-AGENT.md:23, codex:12) | Reads this session |
| F-004 map correctness | Re-traced revised shard map: §5.4→core, §5.1→planner, §5.2/5.3/5.5/5.6→reviewer; R-106 halves vs dispatch matrix | Disjoint, complete, every bound role loads its rules | Manual trace |
| AC-F-06 satisfiability | Traced every payload component (shards, config, prompt, artifacts) for the literal string post-T8/T9 | Satisfiable except the unspecified core.md table caption → F-011 | Analysis + file reads |
| Scope creep / new contradictions | Read revised plan in full against spec §2 non-goals; checked revised preamble text against R-104, Edge Cases 1–10, AC-F-12 | No B–H leakage; AC-F-12 is in-scope consistency; preamble internally consistent; EXPRESS_CHECK→heatwave-reviewer reuse preserves R-1/R-2 | Full read this session |

## Summary (iteration 2)

All nine iteration-1 findings are genuinely resolved, not merely acknowledged: I reproduced both sweeps against the live repo, verified every per-file line number the revised Task 9 cites, and re-traced the corrected shard map end-to-end. The planner's revision also caught an offender my own iteration-1 report missed (docs/faq.md:7) — the sweep-as-exit-gate approach is working. Three small residuals remain (README.md:85's differently-phrased invariant clause, the unconstrained core.md table caption vs AC-F-06, and a filter/wording mismatch in T9's exit sweep); all are Minor or Nit, none gate (R-36/R-77), and each has a one-line fix the IMPLEMENTER can fold into the task it belongs to — subject to reviewer verification at FULL_REVIEW against the updated AC-F-12 pattern.

**Verdict: GATE_MET — PLAN_REVIEW APPROVED (0 Blockers, 0 Majors; 2 Minors + 1 Nit recorded for the run backlog). Proceed to IMPLEMENTING per §2.2.**
