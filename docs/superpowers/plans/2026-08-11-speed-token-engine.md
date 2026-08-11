# Planning Document — Speed / Token Engine (Heatwave v4, Sub-project C)

task_id: hw-v4-C-speed-token | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Source of truth: `/Users/abhirajsinha/Projects/heatwave/docs/specs/2026-08-11-speed-token-engine-design.md` (approved design spec). This plan implements that spec exactly — sub-project C only; D–H are out of scope per spec §2. Sub-projects A and B are merged to `main` (**fact**, verified this session: `git log` head `2492d55`, `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0). Highest existing rule is **R-115** (**fact**: `grep -rn "R-11[6-9]|R-12[0-9]"` across `protocol/ prompts/ templates/ adapters/ PROTOCOL.md heatwave.config.example.yaml` returns zero hits beyond R-110–R-115) — the new rules are **R-116, R-117, R-118**, exactly as the spec proposes. No collision.

---

## Responses to PLAN_REVIEW iteration 1 (R-34)

Responding to: `docs/superpowers/reviews/2026-08-11-plan-review-C.md` (0 Blockers, 3 Majors, 1 Minor, 1 Nit).

```
Finding ID:   F-hwC-001 (Major)
Response:     Fixed
Change:       T1.5's normative replacement sentence reworded so it no longer contains the string
              "carried forward": it now reads "no prior verdict survives by reference … v4-C
              supersedes B's carry-forward allowance" ("carry-forward" does not match the grep).
              The check and the text are now mutually consistent: with the new sentence in place,
              `grep -c "carried forward" protocol/core.md` → 0 is achievable. T1's verification
              gains a positive grep for the new phrase. Rollback step 4 unchanged and still
              consistent (revert restores B's sentence → 1 hit). R-118(b)'s body already used
              "carry-forward", not "carried forward" — re-checked, no other task inserts the
              string into protocol/.
Verification: grep -c "carried forward" <T1.5 replacement text as written in this plan> → 0;
              AC-F-09's method re-run against the plan's own normative texts → satisfiable.
Evidence:     Revised T1.5, revised T1 verification block.
```

```
Finding ID:   F-hwC-002 (Major)
Response:     Fixed
Change:       Both occurrences of "equivalent to FULL_REVIEW" inside T2.1's new R-44 are gone:
              the superseding parenthetical now reads "supersedes the pre-C full-equivalence
              wording", and the degrade sentence now reads "the evaluation is complete at full
              scope, as before". T2's own verification is aligned with the gating AC: the
              backticked-variant grep is replaced by the exact AC-F-08 command
              (`grep -c "equivalent to FULL_REVIEW" protocol/final-reviewer.md` → 0), so the two
              checks can no longer diverge. T7.3's new prompt item 1 was re-checked: it never
              contained the string.
Verification: grep -c "equivalent to FULL_REVIEW" <T2.1 replacement text in this plan> → 0;
              AC-F-08's `0 0` expectation now achievable by construction.
Evidence:     Revised T2.1, revised T2 verification block.
```

```
Finding ID:   F-hwC-003 (Major)
Response:     Fixed
Change:       R-118(c) (T1.4) gains a reconciling clause adopting the review's floor-not-gag
              resolution: the delta is FINAL's required reading scope; R-8/R-54 discretion
              survives at FINAL only as a RECORDED scope expansion (R-49) that reads the specific
              unchanged file(s) needed to substantiate a suspected delta-caused regression —
              blanket re-reading stays forbidden, so the LOCKED "never re-read unchanged files"
              decision is honored as the default/required scope while no MAY/MUST-NOT pair
              survives unqualified. T2.2's mirror paragraph and T7.3's prompt item 1(c) carry the
              same clause. T8 gains an explicit SEMANTIC check step (read R-8, R-43, R-53–R-55
              against the final R-118 text; string sweeps cannot catch this class — the review is
              right that this identical class caused the A and B rejections). New AC-F-10
              verifies the reconciliation with a concrete grep + the attached semantic-check
              output.
Verification: grep -n "R-54" protocol/core.md → a hit INSIDE R-118's text (the reconciling
              clause) in addition to R-54 itself; T8.5 semantic-check output attached; AC-F-10.
Evidence:     Revised T1.4, T2.2, T7.3; new T8.5; new AC-F-10.
```

```
Finding ID:   F-hwC-004 (Minor)
Response:     Fixed
Change:       T4's driver duty (3) gains the commit precondition: at FINAL dispatch the driver
              verifies the working tree is clean for tracked source (`git status --porcelain`
              empty); a dirty tree is treated as the existing explicit full-scope degrade,
              recorded. L4 gains the matching dirty-tree sub-check (branch run: dirty the tree
              before FINAL → record shows the explicit degrade). Edge case 11 added. Rule text
              untouched — this is driver mechanics, same home as the SHA capture.
Verification: T4 text contains "git status --porcelain"; L4 sub-check listed; AC-F-06's method
              extended to cover the dirty-tree branch.
Evidence:     Revised T4, T10-L4, Edge Cases, AC-F-06.
```

```
Finding ID:   F-hwC-005 (Nit)
Response:     Fixed
Change:       T1.3 names exactly one anchor: "§1.4, immediately after R-12 (i.e. before R-115)".
              The stray "after the closing line of the R-10 YAML block" phrasing is deleted; the
              placement note is folded into the single anchor.
Verification: Read T1.3 — one anchor.
Evidence:     Revised T1.3.
```

---

## Tier

**FULL** — this change alters how every future run is dispatched (per-stage model selection), amends the review gate's own scope (R-44 / FINAL_REVIEW becomes delta-scoped), amends an existing core rule (R-110's FINAL carry-forward), adds three core rules, and touches config, templates, prompts, and adapters. §0.5's definition of FULL ("cross-cutting changes … anything touching the core guarantees") applies to the protocol's source exactly as it did for sub-project B.

Change class: **feature** — new protocol capability (dispatch economics), not a defect correction (R-114).

## Problem Statement

A slimmed contexts; B added machine evidence. The dispatch economics are untouched: every stage runs the frontier model, every review stage spawns a cold context that re-reads the stable prefix, and FINAL_REVIEW re-reads files unchanged since the last FULL_REVIEW. Spec §1 cites the three proven savings (RouteLLM-style tiering ≈85% cost cut on mechanical stages; prompt-cache reuse 41–80%; delta-only final verification). C captures all three **without changing what any gate requires** — the same gates, run cheaper.

**For whom:** every Heatwave OWNER and every future run in any adapted repo.

## Functional Requirements

- FR-1 (spec G1, LOCKED §3): config-driven stage model-tiering. Cheap model permitted for MECHANICAL stages ONLY: EXPRESS_CHECK, artifact summarization, PLAN_REVIEW of EXPRESS/LIGHT tiers, TARGETED_REVIEW of a small delta. Frontier ALWAYS for FULL_REVIEW, FINAL_REVIEW, PLAN_REVIEW of STANDARD/FULL; a config downgrading these is **rejected with a one-line warning** and falls back to the session/preferred model. Zero-config: unset → session model everywhere, byte-for-byte today's behavior.
- FR-2 (spec G2, LOCKED §3): persistent reviewer session across one task's FULL_REVIEW → TARGETED_REVIEW → FINAL_REVIEW where the host tool can resume a context; explicit (recorded, never silent) degrade to fresh where it cannot. The IMPLEMENTER context is never shared or resumed as the reviewer (R-1/R-2 untouched).
- FR-3 (spec G3, LOCKED §3): delta-only FINAL_REVIEW = (a) ledger closure of every open finding, (b) re-run ALL machine gates for the tier, (c) LLM review of only `git diff <last-full-review-sha>..HEAD`, never re-reading unchanged files as required scope, (d) re-confirm every AC with evidence.
- FR-4 (spec §3, LOCKED safety clause): FINAL_REVIEW re-runs machine evidence from scratch and re-confirms ACs even in a persistent session — persistence reuses *context*, never a *prior verdict*. `fresh_final_reviewer: true` forces a cold FINAL context.
- FR-5 (spec G4): run-record records `stage_model` per dispatched stage, `review_session` mode, and `final_delta_range` — savings auditable, nothing gates on them.

## Non-Functional Requirements

- NFR-1: zero new runtime dependencies — Markdown + POSIX sh only; edits to existing `.md`/`.yaml` files; `build-protocol.sh` unmodified.
- NFR-2: A and B not regressed — EXPRESS pipeline instant and unchanged; B's ladder/refute/reproduce/hetero mechanics intact; drift check green after every protocol edit.
- NFR-3: resume compatibility — every new field optional with a defined absent-reading; pre-C run records resume without error or rewrite.

## Architecture

Three rules in `protocol/core.md` (loaded by every dispatch — both the driver, which selects models and computes deltas, and the reviewer, which obeys the FINAL scope, see them), operational text in the role shards they govern, mechanics in the driver docs, measurement in the run-record template:

| Piece | Home | Consumed by |
|---|---|---|
| R-116 tiering rule + eligible/required table + §1.4 config note | `core.md` §1.4 (after R-115) | driver (selection), reviewer (awareness) |
| R-117 reviewer session + safety clause | `core.md` §1.2 (after R-4 — it operationalizes R-4's continuity preference) | driver (session mgmt), reviewer |
| R-118 delta-FINAL scope incl. R-8/R-54 reconciliation | `core.md` §2.3 (after R-14 — its cross-pass backstop) | driver (delta computation), final reviewer |
| R-110 amendment (FINAL carry-forward → superseded by R-118(b)) | `core.md` §0.5 | reviewer |
| R-44 amendment + delta/degrade text | `final-reviewer.md` §4.7 | FINAL_REVIEW |
| Persistent-session ledger retention note | `reviewer.md` §4.6 | TARGETED_REVIEW |
| Selection algorithm, session reuse/degrade, `head_sha` capture + delta computation + clean-tree precondition | `orchestrator.md` §9.1 *(v4-C driver duties paragraph)* | driver |
| `cheap_model`, `small_diff_threshold`, `stage_models`, `fresh_final_reviewer` | `heatwave.config.example.yaml` | driver |
| `stage_model`/`head_sha` per transition, `review_session`, `final_delta_range` | `templates/run-record.yaml` | driver, auditors |
| Prompt updates | `prompts/orchestrator.md`, `prompts/reviewer.md`, `prompts/final-reviewer.md` | dispatches |
| Adapter/docs consistency | `adapters/claude-code/HEATWAVE.md`, `adapters/generic/HEATWAVE-AGENT.md`, `docs/faq.md` | tool shims |
| History row | `protocol/history.md` F.1 | rendered spec |

**Three internal-consistency consequences the spec's file list (§5) does not name explicitly, resolved here** (the third was surfaced by PLAN_REVIEW iteration 1, F-hwC-003):

1. **R-110's last sentence conflicts with the LOCKED safety clause.** B's R-110 permits carrying a rung's prior verdict forward at FINAL_REVIEW when the diff is empty for its scope. Spec §3/§4.2 LOCK "FINAL re-runs all machine evidence from scratch … regardless of session continuity" and §4.3(b) "re-run all machine gates … these are cheap and catch regressions". The locked decision wins: T1 amends R-110's final sentence so every rung re-runs at FINAL. Smallest edit that removes the contradiction; leaving both texts standing would let a reviewer cite whichever is convenient.
2. **R-44 asserts "complete evaluation equivalent to FULL_REVIEW"** — the exact "FINAL re-reviews everything" assertion R-118 changes. T2 rewrites R-44 to the R-118 scope. `prompts/final-reviewer.md` step 1 carries the same assertion (T7).
3. **R-8/R-54 grant the REVIEWER discretionary reading beyond any declared boundary; an unconditional R-118(c) "MUST NOT re-read" would contradict them.** Reconciled inside R-118 itself (one home): the delta is FINAL's *required* reading scope — the floor, not a gag. A reviewer with a grounded suspicion that a delta change regressed a specific unchanged file exercises R-8/R-54 as a **recorded scope expansion (R-49)** reading exactly what substantiates it; blanket re-reading of unchanged files remains forbidden. This honors the LOCKED "never re-reads unchanged files" decision as the default scope while leaving no unqualified MAY/MUST-NOT pair (T1.4, mirrored in T2.2/T7.3; semantic check in T8.5; gated by AC-F-10).

**Delta-range mechanics (resume-safe by construction):** the driver captures `git rev-parse HEAD` into the FULL_REVIEW transition entry (`head_sha`) when recording that transition (R-87 already forces the record write before the next dispatch, so the SHA survives any resume). At FINAL_REVIEW dispatch the driver verifies the working tree is clean for tracked source and computes `final_delta_range: <that-sha>..<current HEAD>`, supplying the diff. If no `head_sha` is recorded (pre-C record, unresolvable repo state) **or the tree is dirty** (uncommitted work would be invisible to a range diff — F-hwC-004), FINAL **degrades to full scope explicitly** — recorded in the run record, never a guessed range. The LIGHT combined FULL+FINAL pass has no prior FULL_REVIEW by definition: delta scope never applies to it; it reviews everything (unchanged from B).

**Frontier-required rejection is string-mechanical:** the detectable downgrade is a `stage_models` entry mapping a frontier-required stage to the configured `cheap_model` (string equality) — no model-ranking oracle is needed or possible in a Markdown protocol. `stage_models` MAY narrow (route a cheap-eligible stage back to the role's model); it MUST NOT widen.

**"Artifact summarization"** names no state in §2.1 and none is added: it is the driver-side act of condensing artifacts for a dispatch, listed in the eligible set per the LOCKED decision so that *when* a driver summarizes, the cheap model is permitted. "PLAN_REVIEW when tier = EXPRESS" is vacuous (EXPRESS has no PLAN_REVIEW, §0.5) — kept in the table verbatim per the LOCKED wording, footnoted as vacuous.

## API Design

N/A — no runtime API. The "interfaces" are the rule texts, config keys, and YAML fields, all normative in the tasks below.

## Data Design

Field additions only, all optional, all backward-readable (exact text in T5/T6):

- `templates/run-record.yaml`: transitions entry gains `stage_model` and `head_sha` (comment schema); new top-level `review_session: ""` and `final_delta_range: ""`. Absent/blank = pre-C record: session model, no session tracking, full-scope FINAL.
- `heatwave.config.example.yaml`: commented-out `cheap_model`, `small_diff_threshold` (default 150 changed lines when `cheap_model` is set but the threshold is not — one value had to be picked; 150 keeps "small delta" honest and is config-overridable), `stage_models`, `fresh_final_reviewer`.
- `state.yaml` schema: **untouched.**

## State Management

N/A — no client/server state. Run state (`state.yaml`, §2.1/§2.2 states, counters) is untouched; C adds no state, no transition, no gate.

## Error Handling Strategy

- Config downgrades a frontier-required stage → rejected: one-line warning recorded in the Run Record; stage runs on the role's preferred/session model (R-116).
- Host tool cannot resume the reviewer context → explicit degrade: `review_session: fresh-degraded`, prior Review Reports + ledgers supplied, reconciliation per R-4 (R-117). Correctness unaffected; only cache is lost.
- No recorded `head_sha` for the last FULL_REVIEW, or dirty working tree at FINAL dispatch → FINAL degrades to full scope, recorded (R-118 / T4). Never a guessed range.
- `cheap_model` unset → every stage on the role's/session model (zero-config, R-116).
- FINAL failure → FIXING → next review is FULL_REVIEW (existing R-14) — the cross-pass regression backstop for anything a delta scope could miss; the R-118(b) machine re-run is the in-pass backstop.
- FINAL reviewer suspects a delta-caused regression in an unchanged file → recorded R-49 scope expansion reading exactly that file (R-118(c) reconciling clause), never silent extra reading and never a gag.

## Security Considerations

No executable surface added (Markdown/YAML edits; no change to `build-protocol.sh` or `install.sh`). The rigor-relevant threat is *process* security: a cheap model gating a real review. Mitigated structurally — the frontier-required set is fixed **by rule**, config MUST NOT widen the eligible set, and the rejection path is mechanical (LOCKED §3). The reviewer-session change cannot leak implementer context: R-117 forbids sharing/resuming the implementer context as reviewer; R-1/R-2 are untouched.

## Edge Cases

1. FULL_REVIEW gate met → FINAL directly (no FIXING): delta = empty diff; FINAL = ledger closure (nothing open) + machine gates + AC re-confirmation. Exactly the cheap FINAL the design wants; R-118(c) with an empty file set is a no-op, not an error.
2. LIGHT combined FULL+FINAL pass: no prior FULL SHA → delta scope inapplicable; full evaluation as under B (stated in R-118 and T2 text).
3. R-14 re-entry (FINAL fail → FIXING → FULL_REVIEW): the new FULL_REVIEW records a new `head_sha`; the next FINAL's delta is against the *latest* FULL_REVIEW.
4. `stage_models` names an unknown stage or a model for a stage outside both sets → ignored with warning (narrowing only; nothing to widen into).
5. TARGETED_REVIEW delta exactly at `small_diff_threshold` → cheap-eligible ("≤" per spec §4.1).
6. `cheap_model` set, `small_diff_threshold` unset → default 150 (T6).
7. `fresh_final_reviewer: true` with a tool that cannot persist anyway → `fresh-configured` takes precedence in the record (the config asked for it; the degrade is moot).
8. Pre-C run record (no new fields) resumed mid-run → §2.5-style defaults: session model, no persistent session claim, full-scope FINAL; record never rewritten (NFR-3).
9. EXPRESS run with `cheap_model` set → EXPRESS_CHECK may run cheap; the EXPRESS machine gate itself (build/lint/tests) is deterministic and model-independent — rigor unchanged.
10. R-115 hetero advisory with a persistent reviewer: unaffected — the advisory compares *resolved role models*, which persistence does not change.
11. Dirty working tree at FINAL dispatch (uncommitted FIXING output): a range diff would silently show nothing → the driver treats it as the explicit full-scope degrade (T4, F-hwC-004); the uncommitted work is still reviewed, at full scope.
12. FINAL reviewer suspects an out-of-delta regression: R-118(c)'s reconciling clause — recorded R-49 expansion, read the specific file, finding if substantiated (which fails the gate and routes to FULL per R-14). No unqualified conflict with R-8/R-54.

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Cheap model misses something in a review it gates | Low | mechanical-only eligibility; frontier-required set not downgradable; FULL/FINAL/STANDARD+ plan review always frontier (LOCKED §3) |
| Persistent reviewer rubber-stamps its prior verdict at FINAL | Medium | R-117 safety clause: machine evidence re-run from scratch + per-AC re-confirmation; `fresh_final_reviewer` escape hatch; verified live (AC-F-05) |
| Delta-only FINAL misses a regression in an unchanged file | Medium | R-118(b) full machine-gate re-run every FINAL; R-14 full pass on any FINAL failure; R-110 carry-forward removed at FINAL (T1); R-118(c) recorded-expansion escape for grounded suspicions |
| R-110 amendment breaks a B behavior some text still relies on | Low | repo-wide grep for carry-forward references in T8; B's carry-forward existed *only* in that R-110 sentence + B-plan prose (fact: grep "carried forward\|carry-forward" → protocol/core.md:89 + docs/superpowers only) |
| Claude Code cannot resume a subagent → persistent path untestable there | High (expected) | that IS the degrade path: claude-code records `fresh-degraded` (AC-F-04b); the persistent path is verified on the generic single-context adapter where one session legitimately holds the reviewer role across passes (AC-F-04a). If neither yields a persistent record, R-64 declaration + R-66 escalation — never silently passed |
| Driver forgets `head_sha` at FULL_REVIEW → every FINAL degrades to full scope | Low | degrade is explicit and visible in `final_delta_range` (blank + recorded reason); L4 asserts the happy path |
| Regenerated PROTOCOL.md drift | Low | G-5: every protocol-editing task ends with build + `--check` exit 0 |

**Assumption (labeled):** the Claude Code harness can set a different model per subagent dispatch (needed for cheap-model routing evidence, L2/L3). Precedent: B's H1 exercised per-agent `model:` frontmatter live. Verified at T10 start; if unavailable, the affected ACs are declared NOT AVAILABLE (R-64) and go to the OWNER (R-66).

## Dependencies

- Sub-projects A + B merged to `main` — **fact** (git log `2492d55`; all eight shards present; drift check exit 0, run this session).
- `build-protocol.sh` — present, working (**fact**: executed this session).
- Claude Code adapter + scratch dirs under `/private/tmp` — **fact**: A/B batteries ran live in this environment (committed trails, `16320d6`, `6d0e3b7`).
- A second (cheap) model reachable from the harness — **assumption**, see Risks.
- No external/network dependencies.

## Testing Strategy

Deterministic text checks (grep/cmp/git over shards, templates, config, rendered spec) per task, one explicit semantic-consistency check (T8.5 — string sweeps cannot catch MAY/MUST-NOT conflicts, per F-hwC-003), plus a live adapter battery (T10) on scratch targets mirroring A/B's batteries: zero-config regression, cheap-routing, downgrade-rejection, persistent + degraded + forced-fresh sessions, delta-FINAL scope incl. the dirty-tree degrade, and A/B regression. Every check is pass/fail on file contents or transcript facts, not narrative. Invoking roles per the Tooling Declaration below.

## Rollout Plan

Single-repo docs/protocol change: merge to `main` when APPROVED (per the repo's push-to-main workflow). No flags, no staging, no phased rollout — the protocol version row in history F.1 is the release note. Downstream repos pick C up on their next `install.sh` refresh; zero-config means they see no behavior change until they opt in.

## Rollback Plan

1. Identify the C commit range: `git log --oneline` from the first `feat(v4-C)` commit `<first>` to the last `<last>`.
2. `git revert <first>^..<last>` (or per-commit reverts in reverse order).
3. `sh build-protocol.sh && sh build-protocol.sh --check` → exit 0 (PROTOCOL.md regenerated to pre-C).
4. Verify: `grep -rn "R-116\|R-117\|R-118" protocol/ PROTOCOL.md prompts/ templates/ adapters/` → 0 hits; `grep -n "carried forward" protocol/core.md` → 1 hit (B's sentence restored).
5. Pre-C run records were never rewritten (NFR-3), so no data migration exists to undo.

---

## Task-by-task implementation plan

**Global constraints (binding for EVERY task):**

- **G-1** Zero new runtime deps: edits to existing `.md`/`.yaml` files only; no new scripts or executables; `build-protocol.sh` and `install.sh` byte-untouched.
- **G-2** Ponytail: extend in place, never restructure or renumber; shortest diff satisfying the normative text below.
- **G-3** Resume safety: every new field optional + default-read when absent; `state.yaml` schema, §2.1/§2.2 states, counters, and the §9.3 resume clause untouched.
- **G-4** A/B regression safety: `prompts/express-checker.md`, `templates/express-change.md`, `templates/express-check.md`, `templates/findings-ledger.yaml` byte-untouched; R-101–R-115 texts untouched except the single R-110 sentence amendment in T1 (mandated by the LOCKED safety clause) — no other B rule text changes.
- **G-5** Every task that edits `protocol/*.md` ends with `sh build-protocol.sh && sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0. PROTOCOL.md is never hand-edited.

New-rule text below is **normative** — inserted verbatim (typo fixes via Deviation Record).

---

### T1 — core.md: R-116 (§1.4), R-117 (§1.2), R-118 (§2.3), R-110 FINAL-carry-forward amendment

**File:** `protocol/core.md` (+ regenerated `PROTOCOL.md`).
**Produces:** the three rules every other task consumes.

Edits:

1. **§1.2, after the R-2 rationale blockquote (currently line 116) — i.e. following R-4's section block:** insert:

   > **R-117.** *(v4)* **Persistent reviewer session.** For one task, the REVIEWER context SHOULD persist across FULL_REVIEW → TARGETED_REVIEW → FINAL_REVIEW where the host tool can resume a context (this operationalizes R-4's continuity preference); where it cannot, the driver degrades to a fresh context **explicitly** — recorded in the Run Record, never silent. A persistent reviewer retains its findings ledger and finding memory between passes. The IMPLEMENTER context is never shared with, or resumed as, the reviewer — R-1/R-2 are unchanged: the isolation boundary is authorship, and the reviewer authored no code. **Safety clause:** FINAL_REVIEW MUST re-run all machine evidence for the tier from scratch (R-110, R-118(b)) and re-confirm every acceptance criterion with fresh evidence regardless of session continuity — a persistent session reuses *context*, never a *prior verdict*. Config `fresh_final_reviewer: true` forces a cold FINAL_REVIEW context. The driver records `review_session: persistent | fresh-degraded | fresh-configured` in the Run Record.

2. **§1.4, after R-115:** insert:

   > **R-116.** *(v4)* **Stage model-tiering.** A run MAY route mechanical stages to a configured cheap model (`cheap_model` in `heatwave.config.yaml`). With no tiering config, every stage runs on the role's configured/preferred model, else the session model — zero-config behavior is unchanged. At each dispatch the driver selects the stage's model: a cheap-eligible stage with `cheap_model` configured runs on the cheap model unless `stage_models` routes it back; every other stage runs on the role's preferred/session model. The two sets are fixed by this rule — configuration MAY narrow the eligible set, it MUST NOT widen it:
   >
   > | Cheap-eligible (mechanical) | Frontier-required (rigor) |
   > |---|---|
   > | EXPRESS_CHECK | FULL_REVIEW |
   > | Artifact summarization performed by the driver | FINAL_REVIEW (including the LIGHT combined pass) |
   > | PLAN_REVIEW when tier ∈ {EXPRESS†, LIGHT} | PLAN_REVIEW when tier ∈ {STANDARD, FULL} |
   > | TARGETED_REVIEW when the fix delta ≤ `small_diff_threshold` changed lines | TARGETED_REVIEW above the threshold |
   >
   > † vacuous — EXPRESS has no PLAN_REVIEW (§0.5); listed for completeness of the eligible set.
   >
   > A `stage_models` entry that routes a frontier-required stage to the configured cheap model is **rejected**: the driver records a one-line warning in the Run Record and dispatches that stage on the role's preferred/session model. An entry naming an unknown stage is ignored with the same warning. The model that served each stage is recorded per dispatch (`stage_model` in the Run Record transitions). Model identity never changes what a gate requires — tiering changes how cheaply the same gates run, never the gates.

3. **§1.4, immediately after R-12 (i.e. before R-115) — single anchor:** insert:

   > *(v4)* Stage-level model selection — `cheap_model`, `stage_models`, `small_diff_threshold`, `fresh_final_reviewer` — is likewise configuration, never workflow-body prose: see R-116/R-117 and `heatwave.config.example.yaml`. Unset, all of it, reproduces the R-10 role resolution exactly.

4. **§2.3, after R-14:** insert:

   > **R-118.** *(v4)* **Delta-only FINAL_REVIEW.** FINAL_REVIEW scope is exactly: **(a)** confirm every open finding from prior reviews is closed in the findings ledger; **(b)** re-run ALL machine gates for the run's tier (build/drift, tests, SAST, mutation per R-110) — regardless of any prior verdict, carry-forward, or session continuity; **(c)** LLM review of only the **delta** — the diff since the last FULL_REVIEW, `git diff <last-full-review-sha>..HEAD`, where the driver captured `<last-full-review-sha>` at that FULL_REVIEW's transition. The delta is FINAL_REVIEW's required reading scope: the REVIEWER MUST NOT re-read files unchanged since that SHA as routine re-review. R-8/R-54 discretion survives at FINAL only as a **recorded scope expansion (R-49)**: a reviewer with grounds to suspect a delta change regressed a specific unchanged file MAY read exactly what substantiates that suspicion — the delta is the floor of FINAL reading, not a gag on a grounded suspicion; blanket re-reading of unchanged files remains forbidden. **(d)** re-confirm every acceptance criterion with evidence (R-27). The driver computes the range, supplies the diff, and records it in the Run Record (`final_delta_range`). Where no last-FULL_REVIEW SHA is recorded (pre-v4-C record, unresolvable repo state) or the working tree is dirty at dispatch, FINAL_REVIEW degrades to full scope **explicitly** — recorded, never a guessed range. The LIGHT combined FULL+FINAL pass has no prior FULL_REVIEW and always evaluates in full. A FINAL_REVIEW failure still routes to FIXING with the next review a FULL_REVIEW (R-14) — (b) is the in-pass regression backstop, R-14 the cross-pass one.

5. **§0.5, R-110, final sentence** — replace:
   `At FINAL_REVIEW a rung's prior verdict MAY be carried forward by reference only when the run's diff since that verdict was recorded is empty for the rung's scope (the files it scanned or mutated), and the carry-forward entry names the prior verdict's `evidence_ref`; the `tests` rung is always re-run.`
   with:
   `At FINAL_REVIEW every rung is re-run from scratch — no prior verdict survives by reference (R-118(b), R-117 safety clause; *v4-C supersedes B's carry-forward allowance*).`

   *(The replacement contains "carry-forward", never "carried forward" — the T1/AC-F-09 grep below is satisfiable by construction; F-hwC-001.)*

**Verification (deterministic):**
```
grep -c "R-116\." protocol/core.md                      # expect 1
grep -c "R-117\." protocol/core.md                      # expect 1
grep -c "R-118\." protocol/core.md                      # expect 1
grep -n "Cheap-eligible (mechanical)" protocol/core.md   # expect 1 (the table)
grep -n "vacuous" protocol/core.md                       # expect 1 (EXPRESS footnote)
grep -c "carried forward" protocol/core.md               # expect 0 (amendment landed; F-hwC-001)
grep -n "no prior verdict survives by reference" protocol/core.md   # expect 1, inside R-110
grep -n "fresh-degraded" protocol/core.md                # expect 1, inside R-117
grep -n "final_delta_range" protocol/core.md             # expect 1, inside R-118
grep -n "scope expansion (R-49)" protocol/core.md        # expect 1, inside R-118 (F-hwC-003)
sh build-protocol.sh && sh build-protocol.sh --check     # OK, exit 0
```

### T2 — final-reviewer.md: R-44 amendment + §4.7 delta text

**File:** `protocol/final-reviewer.md` (+ regenerated `PROTOCOL.md`). **Consumes:** R-117/R-118 (T1).

Edits:

1. **§4.7, R-44** — replace the whole rule:
   `**R-44.** The REVIEWER MUST perform a complete evaluation equivalent to `FULL_REVIEW`, plus per-criterion acceptance status (R-27), plus the production readiness checklist (Section 8.3).`
   with:
   `**R-44.** The REVIEWER MUST perform the FINAL_REVIEW scope of R-118 — ledger closure, the full machine-gate re-run for the tier, LLM review of the delta since the last FULL_REVIEW — plus per-criterion acceptance status (R-27), plus the production readiness checklist (Section 8.3). *(v4: supersedes the pre-C full-equivalence wording — within the delta, evaluation depth is unchanged; outside it, machine gates and AC re-confirmation carry the regression load, R-118.)* Where R-118's degrade condition holds (no recorded last-FULL SHA, dirty tree, or the LIGHT combined pass), the evaluation is complete at full scope, as before.`

   *(Neither sentence contains "equivalent to FULL_REVIEW" — AC-F-08's `0 0` is satisfiable by construction; F-hwC-002.)*

2. **After R-45, insert:**

   > *(v4)* Session continuity never shrinks (b) or (d): a persistent reviewer (R-117) re-runs every machine rung from scratch and re-confirms every criterion with fresh evidence — reuse of context, never of a prior verdict. Files unchanged since the last FULL_REVIEW are outside the required reading scope (R-118(c)); reading one is done only as a recorded R-49 scope expansion substantiating a suspected delta-caused regression. Reconciliation (5.6) and the checklist (8.3) still cover the whole task from the artifacts already held.

**Verification:**
```
grep -c "equivalent to FULL_REVIEW" protocol/final-reviewer.md   # expect 0 (exact AC-F-08 command; F-hwC-002)
grep -n "R-118" protocol/final-reviewer.md                        # ≥ 2 (R-44 + the new paragraph)
grep -n "never of a prior verdict" protocol/final-reviewer.md     # expect 1
grep -n "R-49 scope expansion" protocol/final-reviewer.md         # expect 1 (F-hwC-003 mirror)
sh build-protocol.sh && sh build-protocol.sh --check              # OK, exit 0
```

### T3 — reviewer.md: persistent-session ledger retention at TARGETED_REVIEW

**File:** `protocol/reviewer.md` (+ regenerated `PROTOCOL.md`). **Consumes:** R-117 (T1).

Edit — **§4.6, after R-43,** insert:

> *(v4)* In a persistent session (R-117) the REVIEWER arrives at TARGETED_REVIEW already holding its ledger and finding memory — that is the economy of persistence. The recorded artifacts remain authoritative: reconciliation (5.6) is still written from the ledger, and a degraded fresh context (R-117) performs it from the supplied prior reports exactly as R-4 provides.

**Verification:**
```
grep -c "R-117" protocol/reviewer.md                   # expect 1
sh build-protocol.sh && sh build-protocol.sh --check   # OK, exit 0
```

### T4 — orchestrator.md: driver duties — model selection, session management, delta computation

**File:** `protocol/orchestrator.md` (+ regenerated `PROTOCOL.md`). No new rule numbers — cross-references only. **Consumes:** R-116/R-117/R-118 (T1).

Edit — **§9.1, after the existing *(v4)* two-duties paragraph (after R-85),** insert:

> *(v4)* Three speed duties likewise ride the driver's existing dispatch step, none adding a state or a gate: **(1) model selection (R-116)** — at each dispatch, pick the stage's model per R-116's sets and the config (`cheap_model`, `stage_models`, `small_diff_threshold`); reject frontier-required downgrades with a one-line recorded warning; record the serving model as `stage_model` in the transition entry. **(2) reviewer session (R-117)** — dispatch FULL_REVIEW, TARGETED_REVIEW, and FINAL_REVIEW into one persistent reviewer context where the tool can resume one; otherwise degrade to fresh explicitly, supplying prior reports and ledgers (R-4); never resume the implementer's context as reviewer; honor `fresh_final_reviewer: true` with a cold FINAL context; record `review_session` in the Run Record. **(3) delta range (R-118)** — capture `git rev-parse HEAD` as `head_sha` in each FULL_REVIEW transition entry; at FINAL_REVIEW dispatch, first verify the working tree is clean for tracked source (`git status --porcelain` empty) — a dirty tree is the explicit full-scope degrade, recorded (uncommitted fix work is invisible to a range diff); then compute and record `final_delta_range: <last-full-head_sha>..<HEAD>` and supply that diff to the reviewer; with no recorded SHA, record the explicit full-scope degrade instead.

**Verification:**
```
grep -c "R-116" protocol/orchestrator.md               # expect 1
grep -c "R-117" protocol/orchestrator.md               # expect 1
grep -c "R-118" protocol/orchestrator.md               # expect 1
grep -n "head_sha" protocol/orchestrator.md            # ≥ 1
grep -n "git status --porcelain" protocol/orchestrator.md   # expect 1 (F-hwC-004)
sh build-protocol.sh && sh build-protocol.sh --check   # OK, exit 0
```

### T5 — templates/run-record.yaml: measurement fields

**File:** `templates/run-record.yaml` only (normative schema; no shard edit, no rebuild needed — but run the drift check anyway per G-5 habit: it must stay green).

Edits:

1. After the `hetero_reviewer:` line, insert:
   ```yaml
   review_session: ""       # v4-C (R-117): persistent | fresh-degraded | fresh-configured — set by the driver at the first post-implementation review dispatch; blank/absent = pre-C record (no session tracking)
   final_delta_range: ""    # v4-C (R-118): "<last-full-sha>..<head-sha>" reviewed at FINAL_REVIEW; blank/absent = pre-C record or explicit full-scope degrade (degrade reason recorded in transitions)
   ```
2. Replace the transitions comment line:
   `  # - { from: , to: , artifact: , timestamp: }`
   with:
   `  # - { from: , to: , artifact: , timestamp: , stage_model: , head_sha: }   # stage_model v4-C (R-116): model that served the dispatch; head_sha v4-C (R-118): recorded on FULL_REVIEW transitions; both optional — absent = session model / no delta anchor`

**Verification:**
```
grep -n "review_session" templates/run-record.yaml     # expect 1
grep -n "final_delta_range" templates/run-record.yaml  # expect 1
grep -n "stage_model" templates/run-record.yaml        # expect 1
python3 -c "import yaml,sys; yaml.safe_load(open('templates/run-record.yaml'))" 2>/dev/null || ruby -ryaml -e "YAML.load_file('templates/run-record.yaml')"   # parses (whichever is present; both absent → declare per R-64 and rely on visual + grep)
sh build-protocol.sh --check                           # still OK (no shard touched)
```

### T6 — heatwave.config.example.yaml: speed keys

**File:** `heatwave.config.example.yaml` only.

Edit — after the `# --- Technical design docs` block, append:

```yaml
# --- Speed / token engine (v4, R-116–R-118) — ALL optional; unset = today's ---
# --- behavior: every stage on the session/role model, fresh contexts.      ---
# cheap_model: ""              # opt-in second model for MECHANICAL stages ONLY (R-116):
#                              # EXPRESS_CHECK, driver-side summarization, PLAN_REVIEW of
#                              # EXPRESS/LIGHT, TARGETED_REVIEW of a small delta. FULL_REVIEW,
#                              # FINAL_REVIEW, and PLAN_REVIEW of STANDARD/FULL always run the
#                              # frontier/role model — a config routing them to cheap_model is
#                              # rejected with a warning, never honored.
# small_diff_threshold: 150    # changed lines; TARGETED_REVIEW at/below this is cheap-eligible
#                              # (R-116). Default 150 when cheap_model is set and this is not.
# stage_models: {}             # per-stage overrides WITHIN R-116's sets — may narrow (route an
#                              # eligible stage back to the role model), never widen.
#   # EXPRESS_CHECK: <model-id>
#   # TARGETED_REVIEW: <model-id>
# fresh_final_reviewer: false  # true = always a cold FINAL_REVIEW context (R-117 escape hatch);
#                              # the R-117 safety clause holds either way: FINAL re-runs machine
#                              # evidence from scratch and re-confirms every AC.
```

**Verification:**
```
grep -c "cheap_model" heatwave.config.example.yaml            # ≥ 1
grep -n "small_diff_threshold: 150" heatwave.config.example.yaml  # expect 1
grep -n "fresh_final_reviewer" heatwave.config.example.yaml   # ≥ 1
grep -n "rejected with a warning" heatwave.config.example.yaml # expect 1
```

### T7 — prompts: orchestrator, reviewer, final-reviewer

**Files:** `prompts/orchestrator.md`, `prompts/reviewer.md`, `prompts/final-reviewer.md`. (`prompts/express-checker.md`, `prompts/plan-reviewer.md`, `prompts/planner.md`, `prompts/implementer.md`, `prompts/fixer.md` untouched — model choice is driver-side; their behavior is unchanged.)

Edits:

1. **`prompts/orchestrator.md`, "The loop" step 2** — amend the opening sentence `Dispatch that role in a **fresh context**.` to `Dispatch that role in a **fresh context** — except review stages, which reuse the task's persistent reviewer session where your tool can resume one (R-117; degrade to fresh explicitly and record `review_session`, never resume the implementer's context).` Then append to the same step: `Select each dispatch's model per R-116 (cheap model for mechanical stages only when configured; reject frontier-required downgrades with a recorded warning) and record it as `stage_model` in the transition. On FULL_REVIEW transitions record `head_sha`; at FINAL_REVIEW verify the tree is clean (`git status --porcelain` empty — dirty = explicit full-scope degrade), then compute, record, and supply `final_delta_range` (R-118) — or record the explicit full-scope degrade when no SHA exists.`
2. **`prompts/reviewer.md`, "Always" list** — add one bullet: `- Persistent sessions (R-117): if you are the same context that ran earlier passes, you already hold your ledger — still write reconciliation from it (R-58); if you are fresh (degraded), reconcile from the supplied prior reports (R-4).`
3. **`prompts/final-reviewer.md`** — replace `## Perform (R-44)` item 1, `A complete evaluation equivalent to FULL_REVIEW (see `reviewer.md`).`, with: `1. The R-118 scope: (a) every open prior finding confirmed closed in the ledger; (b) ALL machine gates for the tier re-run from scratch — no carried-over verdicts, whatever your session continuity (R-117 safety clause); (c) LLM review of ONLY the supplied delta (`final_delta_range`) — unchanged files are outside your required reading; read one only as a recorded R-49 scope expansion substantiating a suspected delta-caused regression (R-118(c)); (d) full-scope evaluation instead when the driver signals the degrade (no recorded SHA, dirty tree) or this is the LIGHT combined pass.` Keep items 2–3 (per-criterion status, checklist) unchanged.

**Verification:**
```
grep -n "R-117" prompts/orchestrator.md prompts/reviewer.md      # ≥ 1 each
grep -n "R-118" prompts/orchestrator.md prompts/final-reviewer.md # ≥ 1 each
grep -c "equivalent to FULL_REVIEW" prompts/final-reviewer.md     # expect 0
grep -n "R-49 scope expansion" prompts/final-reviewer.md          # expect 1 (F-hwC-003 mirror)
grep -n "stage_model" prompts/orchestrator.md                     # ≥ 1
git diff --quiet -- prompts/express-checker.md prompts/plan-reviewer.md prompts/planner.md prompts/implementer.md prompts/fixer.md   # exit 0
```

### T8 — adapters + docs: consistency sweep with named dispositions

**Files:** `adapters/claude-code/HEATWAVE.md`, `adapters/generic/HEATWAVE-AGENT.md`, `docs/faq.md`; others only if the sweep finds a contradiction.

The pre-planning sweep (**fact**, run this session: `grep -rniE "fresh (context|subagent|session)|re-review|re-read|entire feature|complete evaluation" adapters/ prompts/ README.md docs/*.md`) found these hits needing edits — every other hit is compatible (one-role-per-session summaries remain true: a reviewer persisting across review stages is still one role):

1. **`adapters/claude-code/HEATWAVE.md` line 9** — `you dispatch each role as a **subagent** with a fresh context:` → append after the dispatch list (after line 15): `Review stages and R-117: where your harness can resume a subagent session, reuse the task's reviewer session across FULL→TARGETED→FINAL; where it cannot (one-shot Task subagents), dispatch fresh and record `review_session: fresh-degraded` — explicit, never silent. Either way FINAL re-runs machine gates from scratch and re-confirms every AC (R-117 safety clause). Select each subagent's model per R-116; frontier-required stages never run the cheap model.`
2. **`adapters/generic/HEATWAVE-AGENT.md` line 12** — after the one-role-per-session sentence, append: `One role may span stages: the session acting as REVIEWER for a task SHOULD stay the reviewer for that task's later review passes (R-117 — persistent session, warm context); it must simply never have implemented or planned that task. FINAL_REVIEW still re-runs machine gates from scratch and re-confirms every AC (R-117 safety clause) and reviews only the delta since the last FULL_REVIEW (R-118).`
3. **`docs/faq.md` line 13** — `the orchestrator dispatches each role as a fresh subagent` → qualify: append `— review passes for one task reuse a persistent reviewer session where the tool supports it (R-117); the reviewer still never authored what it judges.`
4. **Repo-wide re-sweep after edits:** `grep -rniE "fresh context per review|re-reviews everything|equivalent to FULL_REVIEW|carried forward" adapters/ prompts/ protocol/ README.md COMPANIONS.md docs/faq.md docs/loop.md docs/getting-started.md install.sh` — read every hit; expected: zero contradictions with R-116/R-117/R-118 (docs/loop.md's "a fresh REVIEWER given the artifacts has everything" stays — it is the degrade path, compatible). Any contradicting hit gets the minimal qualifier and is recorded in the Implementation Package.
5. **Semantic consistency check (F-hwC-003 — string sweeps cannot see MAY/MUST-NOT conflicts):** read R-8, R-43, R-53–R-55 in the final tree against the final R-118 text and confirm no MAY/MUST-NOT pair survives unqualified — R-8/R-54's "MAY read beyond" must resolve at FINAL through R-118(c)'s recorded-R-49-expansion clause, and R-43's no-re-litigation rule must not conflict with the delta floor. The reading and its verdict (per rule, one line each) are attached verbatim to the Implementation Package as evidence (feeds AC-F-10).

**Verification:** the re-sweep output and the T8.5 semantic-check notes attached verbatim as evidence (feed AC-F-08/AC-F-10); `grep -n "R-117" adapters/claude-code/HEATWAVE.md adapters/generic/HEATWAVE-AGENT.md docs/faq.md` → ≥ 1 each.

### T9 — history shard, rule uniqueness, final regenerate

**File:** `protocol/history.md` (+ regenerated `PROTOCOL.md`).

1. Append one row to Appendix F.1:
   `| Stage model-tiering, persistent reviewer session, delta-only FINAL_REVIEW | R-116–R-118 | Every stage paid the frontier price; cold review spawns forfeited prompt cache; FINAL re-read files unchanged since the last full review |`
2. Rule uniqueness: `grep -rEn "R-11[0-8]\.|R-113 \((planner|implementer|reviewer) half\)\." protocol/` — R-110/R-111/R-112/R-114/R-115/R-116/R-117/R-118 defined exactly once each; R-113 exactly three named halves.
3. `sh build-protocol.sh && sh build-protocol.sh --check` → OK, exit 0. Also: `for r in 116 117 118; do grep -c "R-$r\." PROTOCOL.md; done` → each ≥ 1 with the definition exactly once.

### T10 — live verification battery (scratch targets)

**Produces:** evidence bundle only (scratch dirs + captured outputs referenced from the Implementation Package). Scratch root: `/private/tmp/hw-c-verify/`. Setup per target as in A/B: `git init` + `sh /Users/abhirajsinha/Projects/heatwave/install.sh`, seed a tiny project. First step: probe the cheap-model assumption (attempt a subagent dispatch with a non-session `model:`; on failure, R-64 declarations for AC-F-01/02 and OWNER escalation per R-66).

- **L1 — zero-config regression (spec 8.3, 8.7):** STANDARD feature run, `heatwave.config.yaml` untouched (no speed keys). Checks: every transition's `stage_model` equals the session model (or is absent-with-default — either reading proves no routing happened); run reaches APPROVED through the full state machine; ledger `machine_evidence` carries B's tests+sast rungs (stub sast as in B). EXPRESS sibling: "fix the typo" run → exactly `01-express-change.md` + `02-express-check.md`, APPROVED (A regression).
- **L2 — cheap routing (spec 8.1):** LIGHT run with `cheap_model: <cheap-id>` set. Checks: PLAN_REVIEW transition records `stage_model: <cheap-id>`; the FULL/FINAL (LIGHT combined) pass records the frontier/session model; run-record greps attached.
- **L3 — downgrade rejection (spec 8.2):** same target, config gains `stage_models: {FULL_REVIEW: <cheap-id>}`. Checks: transcript contains the one-line warning; Run Record records it; the FULL_REVIEW transition's `stage_model` is the session/preferred model, not the cheap one.
- **L4 — delta FINAL (spec 8.6):** STANDARD run seeded so FULL_REVIEW raises ≥ 1 real Major (deterministic failing declared test, as B's L4) → FIXING → TARGETED → FINAL. Checks: FULL_REVIEW transition carries `head_sha`; run-record `final_delta_range` = `<that-sha>..<head>` and `git diff` of that range lists only fix-touched files; the FINAL report's verification log shows every machine rung re-executed (fresh command output, not carried references); per-AC table complete; **no-unchanged-file-reads evidence:** the FINAL context's tool-use log shows file reads confined to the delta files + run artifacts (transcript grep; if the harness does not expose per-subagent tool logs, this sub-check is declared NOT AVAILABLE per R-64 and the scope claim rests on the report's own scope statement + delta range — stated, not silently passed). **Dirty-tree branch (F-hwC-004):** re-drive the FINAL dispatch with an uncommitted tracked-file edit present → the driver records the explicit full-scope degrade (`final_delta_range` blank + recorded reason) instead of an empty-range delta review.
- **L5 — session modes (spec 8.4, 8.5):**
  (a) *persistent:* generic-adapter flow driven in this environment — one session performs FULL_REVIEW, then TARGETED_REVIEW, then FINAL_REVIEW for the task (it authored nothing); Run Record `review_session: persistent`; the TARGETED pass references its prior findings by ID without re-derivation (transcript evidence); the FINAL pass still re-runs every machine rung (command outputs in-report).
  (b) *degraded:* the claude-code run (L4) records `review_session: fresh-degraded` (one-shot subagents).
  (c) *forced fresh:* re-run a FINAL with `fresh_final_reviewer: true` → `review_session: fresh-configured` and a cold context (no prior-session memory referenced).
- **L6 — resume compatibility (NFR-3):** copy a pre-C-shaped run record (strip `review_session`/`final_delta_range`/`stage_model`/`head_sha`) mid-run → resume → driver proceeds, FINAL degrades to full scope explicitly, record diff shows appends only.

All commands, outputs, and run-dir listings captured verbatim; every check is grep-able pass/fail.

---

## Acceptance Criteria

### Functional

Each maps a spec §8 verification item; every method is independently executable.

- **AC-F-01 | Tiering routes correctly (spec 8.1)** | Verification: L2 — `grep "stage_model" run-record.yaml` shows `<cheap-id>` on the PLAN_REVIEW (LIGHT) transition and the session/frontier model on the combined FULL_FINAL pass. Evidence: run-record excerpt. (Cheap model unavailable → R-64 declaration + R-66 escalation, never a silent pass.)
- **AC-F-02 | Frontier-required not downgradable (spec 8.2)** | Verification: L3 — transcript contains the rejection warning; Run Record records it; FULL_REVIEW transition `stage_model` ≠ `<cheap-id>`. Evidence: transcript excerpt + run-record.
- **AC-F-03 | Zero-config unchanged (spec 8.3)** | Verification: L1 — no speed keys set; every `stage_model` is the session model (or absent); run APPROVED via the full A/B state machine. Evidence: run-record + config file listing.
- **AC-F-04 | Persistent session + degrade (spec 8.4)** | Verification: (a) L5a Run Record `review_session: persistent` + transcript shows the TARGETED pass citing its own prior finding IDs; (b) L5b Run Record `review_session: fresh-degraded` on the one-shot-subagent path. Evidence: run-records + transcript excerpts.
- **AC-F-05 | FINAL safety clause (spec 8.5)** | Verification: (a) L5a's persistent-session FINAL report's verification log shows every machine rung executed fresh (command outputs dated in-pass) and the per-AC table complete; (b) L5c with `fresh_final_reviewer: true` → `review_session: fresh-configured`, cold context. Evidence: final report + run-record.
- **AC-F-06 | Delta FINAL scope + machine re-run (spec 8.6)** | Verification: L4 — `final_delta_range` present and equal to `<full-review head_sha>..<head>`; `git diff --name-only <range>` = fix-touched files only; FINAL report reviews exactly those files; machine rungs re-executed; per-AC statuses present; unchanged-file-read check per L4 (or its explicit R-64 declaration); **the dirty-tree branch records the explicit full-scope degrade, never an empty-range delta review (F-hwC-004)**. Evidence: run-record + report + diff listing + dirty-branch record excerpt.
- **AC-F-07 | Regression + drift + A/B preserved (spec 8.7)** | Verification: L1 EXPRESS sibling → two-artifact APPROVED; L1 STANDARD → APPROVED with B's `machine_evidence` rungs present; `sh build-protocol.sh --check` exit 0 on the final tree; L4's Major survives refute-or-promote and round-trips through FIXING (B mechanics live). Evidence: run-records + check output + ledgers.
- **AC-F-08 | Adapter consistency (spec 8.8)** | Verification: T8's re-sweep grep output attached; zero hits asserting fresh-per-review-always or FINAL-re-reviews-everything (`grep -c "equivalent to FULL_REVIEW" prompts/final-reviewer.md protocol/final-reviewer.md` → `0 0` — satisfiable: T2.1/T7.3's replacement texts do not contain the string); T9's rule-uniqueness grep passes. Evidence: sweep output verbatim.
- **AC-F-09 | New rules present, spec regenerated** | Verification: `for r in 116 117 118; do grep -c "R-$r\." PROTOCOL.md; done` → definition exactly once each (plus cross-references); `grep -c "carried forward" protocol/core.md` → 0 (satisfiable: T1.5's replacement says "carry-forward", never "carried forward") with `grep -c "no prior verdict survives by reference" protocol/core.md` → 1; generated header line intact. Evidence: command output.
- **AC-F-10 | R-8/R-54 vs R-118 reconciled (F-hwC-003)** | Verification: (a) `grep -n "scope expansion (R-49)" protocol/core.md` → 1 hit inside R-118 and `grep -n "R-49 scope expansion" protocol/final-reviewer.md prompts/final-reviewer.md` → 1 hit each (the reconciling clause present in all three homes); (b) T8.5's semantic-check notes (R-8, R-43, R-53–R-55 each read against final R-118; one-line verdict per rule, no unqualified MAY/MUST-NOT pair) attached verbatim. Evidence: grep output + attached notes.

### Non-functional

- **AC-N-01 | Zero new runtime deps** | Metric: `git diff --name-only <base>..HEAD` contains only existing `.md`/`.yaml` files (plus the C plan/review trail under `docs/`); `git diff --quiet -- build-protocol.sh install.sh` exit 0; no new executables or mode changes | Verification: diff-name audit.
- **AC-N-02 | EXPRESS + B artifacts untouched** | Metric: `git diff --quiet -- prompts/express-checker.md templates/express-change.md templates/express-check.md templates/findings-ledger.yaml` exit 0 | Verification: byte check + L1 EXPRESS run-dir listing.
- **AC-N-03 | Resume compatibility** | Metric: a run record lacking every new field resumes with defaults, no error, no rewrite; FINAL degrade is explicit | Verification: L6 — record diff before/after resume shows appends only + the recorded degrade.

## Review Scope

Applicable
✓ plan-conformance — always applicable
✓ verification-integrity — always applicable; the safety clause and delta scope live or die on it
✓ data-integrity — run-record/config field additions must stay backward-readable (NFR-3/AC-N-03)

Not applicable
✗ all Frontend categories — docs/protocol repo; no UI surface
✗ Backend: business-logic · api-contracts · request-validation · response-validation · status-codes · versioning · schema* · migrations · transactions · indexes · query-performance — no runtime code (*YAML-template schema covered by data-integrity)
✗ all Security categories — no executable surface; config additions are comments; process-security risk is handled structurally by R-116's fixed sets (see Security Considerations)
✗ all Performance categories — the change IS a cost optimization, but its "performance" claims (cache reuse %, cost cuts) are the research's, not gated here; C's gates are behavioral (routing, scope, records), covered by AC-F-01..06
✗ Reliability: error-handling · retry · circuit-breakers · timeouts · recovery · rate-limiting — no runtime code; degrade paths are covered under verification-integrity
✗ all Observability categories — N/A, no services (the run-record fields are the observability, verified functionally)

(`plan-conformance` and `verification-integrity` are never N/A.)

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Drift check | `sh build-protocol.sh --check` | IMPLEMENTER (per task) + REVIEWER | confirmed — run this session: `OK: PROTOCOL.md matches protocol/ shards`, exit 0 |
| Deterministic text checks | POSIX sh: grep/cmp/git/awk | IMPLEMENTER + REVIEWER | confirmed — used throughout this session |
| Live adapter runs | Claude Code + `adapters/claude-code` + generic-adapter flow, scratch targets under `/private/tmp/hw-c-verify/` | IMPLEMENTER (battery) + REVIEWER (spot re-run) | confirmed — A and B batteries ran live in this environment (committed trails `16320d6`, `6d0e3b7`); `/private/tmp` writable |
| YAML parse check | `python3 -c "import yaml,…"` or ruby fallback | IMPLEMENTER | **assumed** — probed at T5; both absent → declared per R-64, grep + visual inspection substitute (schema is comments + scalars) |
| Cheap-model subagent dispatch | Claude Code per-agent `model:` selection | IMPLEMENTER (L2/L3) | **assumed** — precedent: B's H1 switched reviewer models live; probed at T10 start; unavailable → AC-F-01/02 declared NOT AVAILABLE (R-64), escalated (R-66) |
| Persistent-context resume (claude-code) | Task-subagent resume | — | **NOT AVAILABLE** (expected) — one-shot subagents; this is by design the R-117 degrade path and is itself the AC-F-04b evidence. The persistent path is verified via the generic-adapter flow (L5a), access confirmed (it is this environment) |
| SAST / mutation (real tools) | semgrep / stryker etc. | — | **NOT AVAILABLE** — as in B: declared stub tools in scratch targets exercise the rung *contract* (re-run at FINAL), which is what C verifies; D wires real tools. ACs affected: none left unverified — AC-F-05/06 verify re-execution + recording, which stubs demonstrate fully |

| Test type (protocol taxonomy) | Status |
|---|---|
| SAST entry (STANDARD+ plan requirement, R-110) | This plan governs a docs/YAML repo with no runtime code: `sast` = NOT AVAILABLE for the repo itself (no scannable diff language; declared per R-64 — affects no AC, since every AC is text/behavioral). Scratch-target stubs cover the ladder-contract checks above |
| Mutation entry (FULL plan requirement, R-110) | NOT AVAILABLE for the same reason (no mutable runtime modules in this repo; declared per R-64 — affects no AC). Tier-FULL ceremony otherwise applied in full |

---

*Fact/inference labeling:* every "confirmed" above is a fact from commands run this session (outputs quoted in the planning transcript); the two "assumed" entries are labeled assumptions carried in Risks; the R-115-is-highest-rule and zero-R-116-collision claims are facts from the quoted greps; the adapter-hit inventory in T8 is a fact from the quoted sweep; the claude-code one-shot-subagent limitation is an inference from the harness's documented dispatch model, treated as the expected degrade case and never as a pass. The iteration-1 → iteration-2 changes are confined to the findings above; no LOCKED decision, task boundary, or rule number changed.
