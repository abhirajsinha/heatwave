# Planning Document — Machine-Evidence Rigor (Heatwave v4, Sub-project B)

task_id: hw-v4-B-machine-evidence | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Source of truth: `/Users/abhirajsinha/Projects/heatwave/docs/specs/2026-08-10-machine-evidence-rigor-design.md` (approved design spec). This plan implements that spec exactly — sub-project B only; C–H are out of scope per spec §2. Sub-project A is merged to `main` (verified: `git log` head `0cecd88`, all eight `protocol/` shards present, `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0).

---

## Responses to PLAN_REVIEW iteration 1 (R-34)

Responding to: `docs/superpowers/reviews/2026-08-10-plan-review-B.md` (0 Blockers, 3 Majors, 5 Minors, 2 Nits).

```
Finding ID:   F-hwB-001 (Major)
Response:     Fixed
Change:       T2 gains edit 3 — Appendix A itself is amended: Status enum extended with `Refuted`;
              new `Origin` and `Refutation` schema rows added (exact text in T2); R-109's "Appendix A
              field semantics are unchanged" sentence is amended so the schema and the ledger cannot
              contradict (exact replacement in T2 edit 4). The full enumeration of places that state
              or consume the Status enum was re-derived this iteration by grep
              (grep -rn "Deferred\|Disputed\|status:" protocol/ templates/): (1) Appendix A
              (reviewer.md:133-134) → T2 edit 3; (2) R-77's "open excludes" list (core.md:294) →
              now edited in T1 edit 4 (also closes F-hwB-004); (3) templates/findings-ledger.yaml
              status comment → already in T6; (4) fixer.md R-31 ("every finding … MUST have exactly
              one response") would oblige the FIXER to answer refuted findings — R-112's text now
              carries one clarifying clause scoping R-31 to open findings (T2 edit 1). No other
              enumeration exists (run-record `final_status` and review-report AC-status are
              free-text/unrelated enums — verified by reading both templates).
Verification: sed -n '/Appendix A/,$p' protocol/reviewer.md | grep -c "Refuted\|Origin:\|Refutation:"
              → 3; grep -n "compact carrier" protocol/reviewer.md shows the amended R-109 sentence;
              drift check exit 0. Adopted into T2's verification block.
Evidence:     Revised T2 (edits 3-4), revised T1 (edit 4), revised R-112 text.
```

```
Finding ID:   F-hwB-002 (Major)
Response:     Fixed
Change:       T1 edit 3(c) now ALSO rewrites the core §2.5 sentence, exactly as the finding
              recommends: "Only `tier`, `tier_justification`, `design_doc`, and `change_class` drive
              behavior." (full replacement text in T1). The RESERVED sentence for autonomy/scope is
              untouched, so change_class cannot be mistaken for a recorded-only field.
Verification: The finding's stated method, adopted verbatim into T1's verification block:
              grep -n "drive behavior" protocol/core.md → the four-field sentence; drift check exit 0.
Evidence:     Revised T1 edit 3(c).
```

```
Finding ID:   F-hwB-003 (Major)
Response:     Fixed
Change:       R-115 reworded (full normative text in T1 edit 2): the advisory is computed when BOTH
              roles have resolved — at the first FULL_REVIEW (or LIGHT combined-pass) dispatch — and
              recomputed/appended if either role's resolved model later changes via R-11 substitution.
              T5's orchestrator sentence and T9's orchestrator prompt line reworded to the same timing.
              T11's L2 checks gain the ordering assertion the finding requires: the transitions log
              shows hetero_reviewer recorded no earlier than the FULL_REVIEW dispatch (deterministic —
              the run-record is append-only, so entry order proves timing). AC-F-05's verification
              method now includes that assertion.
Verification: grep -n "BOTH" protocol/core.md (R-115 text); L2 run-record append order — the
              hetero_reviewer entry follows the implementation-package transition; adopted into T11/AC-F-05.
Evidence:     Revised T1 edit 2, T5, T9, T11 L2 checks, AC-F-05.
```

```
Finding ID:   F-hwB-004 (Minor)
Response:     Fixed
Change:       T1 gains edit 4: R-77's exclusion list extended — "Where 'open' excludes findings with
              `Status: Deferred (approved)`, `Status: Waived (OWNER)`, or `Status: Refuted` (R-112)."
              Exact replacement text in T1. (Companion to F-hwB-001, as the finding notes.)
Verification: grep -n "Refuted (R-112)" protocol/core.md → 1 hit inside §8.1; drift check exit 0.
Evidence:     Revised T1 edit 4.
```

```
Finding ID:   F-hwB-005 (Minor)
Response:     Fixed
Change:       Architecture table row corrected to "new §3.4.2" only — the phantom "§5.7" reference is
              deleted. T2's placement note stands (one home, smaller diff); the implementer now has
              exactly one instruction.
Verification: grep -c "5.7" on this document → 0 hits outside this response block.
Evidence:     Revised Architecture table.
```

```
Finding ID:   F-hwB-006 (Minor)
Response:     Fixed
Change:       R-110's carry-forward sentence operationalized per the recommended clause (full text in
              T1 edit 1): carry-forward is permitted only when the run's diff since the verdict was
              recorded is empty for the rung's scope (the files that rung scanned/mutated), and the
              carry-forward entry names the prior verdict's `evidence_ref`. Tests always re-run,
              unchanged. D-7 restated to match.
Verification: grep -n "evidence_ref" protocol/core.md → 1 hit inside R-110; drift check exit 0.
Evidence:     Revised T1 edit 1, revised D-7.
```

```
Finding ID:   F-hwB-007 (Minor)
Response:     Fixed
Change:       R-111 now assigns default categories, closing the schema gap (full text in T2 edit 1):
              failing test → the category of the acceptance criterion it verifies, else
              `verification-integrity`; SAST hit → the matching Security category from Appendix C;
              surviving mutant → `verification-integrity`. REVIEWER MAY override per R-5 with reason.
Verification: grep -n "verification-integrity" protocol/reviewer.md → hits include R-111's defaults;
              drift check exit 0.
Evidence:     Revised T2 edit 1 (R-111 text).
```

```
Finding ID:   F-hwB-008 (Minor)
Response:     Fixed
Change:       Rollback step 2 corrected to the working range form: `git revert <first>^..<last>`
              (the empty-range form deleted; per-commit alternative retained).
Verification: Read Rollback Plan step 2 — range syntax is <first>^..<last>.
Evidence:     Revised Rollback Plan.
```

```
Finding ID:   F-hwB-009 (Nit)
Response:     Fixed
Change:       T10 check 4 now uses a pattern that matches the halves:
              grep -rEn "R-11[0-5]\.|R-113 \((planner|implementer|reviewer) half\)\." protocol/
              with expected counts: R-110/R-111/R-112/R-114/R-115 defined once each, R-113 exactly
              three named halves — and cross-references AC-F-09's `grep -c "R-113 ("` = 3.
Verification: The revised T10 command itself.
Evidence:     Revised T10 check 4.
```

```
Finding ID:   F-hwB-010 (Nit)
Response:     Acknowledged — no action
Change:       None. The review accepted D-2 (single computed hetero_reviewer field; no duplicate
              reviewer_model/implementer_model fields) as a declared, justified deviation from spec
              §5's wording. D-2 retained verbatim.
Verification: N/A.
Evidence:     Review Report F-hwB-010 disposition: "Accepted by this review. … No action."
```

---

## Tier

**FULL** — this change rewrites the review gate itself (machine-evidence ladder before LLM findings), the planner contract (§3.2.2, §6.1), the implementer flow (red→green for bugfixes), the ledger and run-record schemas, and the example config — a cross-cutting change to the protocol every future run obeys. §0.5's own definition of FULL ("cross-cutting changes … anything touching the core guarantees") applies to the protocol's source the same way it applies to code.

Change class: **feature** — new protocol capability, not a defect correction (R-114 does not yet exist; this line models the field this very plan introduces).

## Problem Statement

Heatwave's review rigor rests entirely on an LLM reviewer reading code and asserting findings. Four measured weaknesses (spec §1): (1) same-model self-preference bias is invisible; (2) review is judge-prose with no machine verdicts (no SAST, no mutation adequacy); (3) no refutation gate — false-positive Majors each cost a full FIXING round-trip, the dominant hidden cost; (4) "verified" for bug fixes is a narrative claim, not a red→green bit. Sub-project B adds tool-agnostic machine-evidence gates, a refute-or-promote gate for Major+, mandatory reproduce-then-fix for bugfix-class runs, and hetero-reviewer visibility — scaled by tier so EXPRESS stays instant.

**For whom:** every Heatwave OWNER and every future run in any adapted repo.

## Functional Requirements

- FR-1. A machine-evidence ladder runs at FULL_REVIEW (and the LIGHT combined pass, and FINAL_REVIEW per R-44) *before* any LLM finding is authored, tier-scaled exactly per spec §3: EXPRESS none; LIGHT tests; STANDARD +SAST-of-diff; FULL +mutation-adequacy-of-changed-modules. Verdicts are recorded in the findings ledger as machine evidence.
- FR-2. A ladder rung with no declared/available tool records an explicit `NOT_AVAILABLE` verdict naming the acceptance criteria it leaves unverified (R-64). Never a silent skip. Tool-agnostic: the protocol names checks; specific tools are sub-project D.
- FR-3. Refute-or-promote: every candidate Major/Blocker finding carries a recorded refutation attempt before it enters the ledger as `open`; refuted findings get `status: refuted` + reason and never enter FIXING. Minor/Nit exempt. The normative finding schema (Appendix A) permits everything this requires.
- FR-4. Reproduce-then-fix for `change_class: bugfix` (LIGHT+): the plan carries a failing-reproduction AC; the implementer captures red on pre-fix code, then green; the reviewer confirms both; a bugfix without red evidence is a Major.
- FR-5. Hetero-reviewer is RECOMMENDED + configurable, never mandated. The run record makes the gap visible: `hetero_reviewer: "false (self-preference bias not mitigated)"` when reviewer and implementer resolve to the same model, `"true"` otherwise — computed only once both roles have actually resolved. Advisory only; zero-config stays valid.
- FR-6. `change_class` enters `run_config` (driver initial guess at intake, PLANNER authoritative in the Planning Document); `sast`/`mutation` become tooling-declaration entries (STANDARD+/FULL) detected per R-99 or declared NOT AVAILABLE per R-64.
- FR-7. All rules land in `protocol/` shards, numbered **R-110 … R-115** (verified: the highest live rule is R-109; repo-wide grep finds no collision). PROTOCOL.md is regenerated via `build-protocol.sh`; drift check stays green.

## Non-Functional Requirements

- NFR-1. Zero new runtime dependencies: Markdown + POSIX sh + YAML templates only; no new executables, no new scripts.
- NFR-2. EXPRESS stays instant: the EXPRESS dispatch surface (`prompts/express-checker.md`, `templates/express-change.md`, `templates/express-check.md`) is byte-identical after B.
- NFR-3. Resume compatibility: every new run-record/ledger field is optional with a defined default; a pre-B run directory resumes without record rewriting (extends the existing §9.2 pre-v4 clause).
- NFR-4. Ponytail: extend existing shards/templates in place; no shard is rewritten; no new shard, state, or artifact type is created (the ladder is a review sub-phase, not a state).

Measured per AC-N-01..03 below.

## Architecture

No new components. Six rules across four shards, using A's structure:

| Concern | Home | Why there |
|---|---|---|
| Tier-rigor table + R-110 (ladder, tier scaling, NOT_AVAILABLE degradation) | `protocol/core.md` §0.5 | Tier scaling is a tier property; core is loaded by every dispatch, so every role knows what rigor its tier implies |
| R-115 (hetero-reviewer SHOULD + run-record flag) | `protocol/core.md` §1.4 | Role-configuration section; the driver and every role see it |
| R-114 (`change_class` in run_config) + §2.5 drive-behavior sentence + R-77 `Refuted` exclusion | `protocol/core.md` §2.5 / §8.1 | run_config and the gate are defined there; drives R-113 / keeps R-77 consistent with R-112 |
| R-111 (machine-finding semantics), R-112 (refute-or-promote) — new §3.4.2; Appendix A schema extension | `protocol/reviewer.md` | Review execution detail + the normative finding schema live there; loaded by all review states |
| R-113 in three halves — planner / implementer / reviewer | `planner.md` §3.2.2 / `implementer.md` §4.3 / `reviewer.md` §4.4 | Same precedent as R-106's driver/planner halves in A |
| §6.1 sast/mutation declaration entries | `protocol/planner.md` | Tooling declaration lives there (R-62/R-99) |
| Driver duties (record change_class at intake; hetero_reviewer once both roles resolved) | `protocol/orchestrator.md` intake/§9 cross-refs | No new rule numbers; R-114/R-115 name the duties, orchestrator points at them |

Data flow: plan tooling declaration (§6.1) → reviewer executes ladder rungs itself → verdicts into `machine_evidence` in the findings ledger → machine findings (R-111) + LLM findings, all Major+ passing refute-or-promote (R-112) → FIXING driven from ledger `status` exactly as today (R-109's carrier role unchanged).

**Design decisions (decided here, per the no-confirmation-gates rule; the plan reviewer tests them):**

- **D-1. No new states.** The ladder is a sub-phase inside existing review states. `state.yaml`, §2.1/§2.2, and resume are untouched — the cheapest way to satisfy "must not break resume of in-flight runs".
- **D-2. `hetero_reviewer` is one string field computed from the existing `roles.*.resolved` fields** — not duplicate `reviewer_model`/`implementer_model` fields. Spec §4.4's intent is "models recorded + equality visible"; the run record's `roles:` block *already* records resolved models per role (schema line 14–17 of `templates/run-record.yaml`). Duplicating them creates a second copy that can drift. Deliberate ponytail refinement of spec §5's wording, satisfying spec §4.4's requirements exactly. *(Accepted at PLAN_REVIEW iteration 1, F-hwB-010.)*
- **D-3. `change_class` is binary: `bugfix | feature`.** Only `bugfix` drives behavior (R-113); every non-bugfix value would behave identically, so more enum values are YAGNI. Driver guesses at intake; PLANNER is authoritative (it has read the code); REVIEWER may find against misclassification; and per spec §7, a "fix" with no repro is a Major regardless of the label.
- **D-4. Machine-finding severities:** failing declared test → Blocker (it already fails the gate in spirit today); high-severity SAST hit on changed lines and surviving mutant on changed lines → default Major, reviewer MAY reclassify with recorded reason. Default categories per R-111 (F-hwB-007): failing test → the verified AC's category else `verification-integrity`; SAST → the matching Security category; mutant → `verification-integrity`. Preserves R-5 while making the default mechanical.
- **D-5. The REVIEWER executes rungs itself** rather than trusting the Implementation Package's attached outputs — that is the entire point of machine evidence (R-65 hygiene: a verdict you ran, not a verdict you read).
- **D-6. R-112 scope:** ledger-producing reviews only (FULL/TARGETED/FINAL, per R-109). PLAN_REVIEW findings loop back to PLANNING, which is already cheap; spec §4.2 targets the FIXING round-trip cost. Refuted findings are outside the set R-31 obliges the FIXER to answer (stated in R-112's text).
- **D-7. FINAL_REVIEW ladder economy:** a rung's verdict may be carried forward by reference only when the run's diff since that verdict was recorded is empty for the rung's scope (the files it scanned/mutated), and the carry-forward names the prior `evidence_ref`; the tests rung always re-runs. Keeps R-44's "equivalent to FULL_REVIEW" without paying mutation twice on unchanged code.

## API Design

N/A — no code API. The "interfaces" are artifact schemas (see Data Design) and rule text (given verbatim in the task list).

## Data Design

Schema additions (exact text in T2/T6/T7; all fields optional-with-default for pre-B artifacts):

- `protocol/reviewer.md` Appendix A (normative finding schema): Status enum gains `Refuted`; new `Origin` (reviewer | machine) and `Refutation` (required Major+) rows — so the schema permits what R-111/R-112 mandate (F-hwB-001).
- `templates/findings-ledger.yaml`: top-level `machine_evidence: []` block (rung, tool, verdict `pass|fail|NOT_AVAILABLE`, evidence_ref, unverified_acs); per-finding `origin: reviewer|machine` (absent = reviewer), `refutation:` (required Major+), status enum + `refuted`.
- `templates/run-record.yaml`: `run_config.change_class` (absent = `feature`); top-level `hetero_reviewer: ""` (absent = pre-B record, advisory only).
- No migrations: run dirs are per-task and immutable; old records read under defaults (extends the §9.2 pre-v4 clause).

## State Management

N/A — no new workflow states, no `state.yaml` change (D-1). The only new persisted values live in append-only YAML artifacts.

## Error Handling Strategy

- Absent tool at any rung → `verdict: NOT_AVAILABLE` + named unverified ACs (R-64); if that leaves an AC unverifiable, R-66 blocks APPROVED absent an OWNER waiver — the existing escalation path, no new machinery.
- Pre-existing baseline test failure (not caused by the change) → the machine finding's refutation attempt (re-run + attribution check, R-112) is the designed channel: attributable-to-baseline → refuted with reason, visible in the ledger.
- Misclassified change_class → reviewer finding; and the "no repro ⇒ Major" rule holds regardless of label (spec §7).
- Mutation runtime blowout → rung is scoped to changed modules only and FULL-only by construction; the plan's tooling declaration states the timeout ceiling (template prompt line, T7).
- Late role substitution (R-11) after the hetero advisory is recorded → the driver recomputes and appends the updated value (R-115); the record is append-only, so the history stays visible.

## Security Considerations

No new threat surface: no executable code added, no network calls, no secrets. The ladder *reduces* risk by forcing declared-tool provenance for every machine verdict (R-63 already makes a false tool claim a Blocker). SAST as a first-class rung raises the security floor of every STANDARD+ run once D wires real tools.

## Edge Cases

1. **Bugfix at EXPRESS tier** (typo-class bug): no repro required — spec tier table says EXPRESS: none; R-102/R-103 already push anything riskier upward. R-114 states EXPRESS never sees change_class (no plan exists).
2. **Bugfix in a repo with no test tooling**: reproduction check is any *executable* check (a script, a curl, a CLI invocation), not necessarily a framework test; if truly nothing executable exists, R-113 (planner half) requires the plan to say so per R-64 → unverifiable AC → R-66 gate. Stated in the rule text.
3. **Refuted finding that was actually real** (spec §7 risk): refutation reason is recorded and reconciled (5.6); refuted findings stay in the ledger and are reopenable per R-59; reproduce-then-fix independently catches the bug class; FINAL_REVIEW re-confirms every AC.
4. **LIGHT combined pass**: the ladder (tests rung) runs at the combined FULL_FINAL pass — R-110 names the combined pass explicitly.
5. **TARGETED_REVIEW**: no ladder re-run mandated — R-32 already forces execution of each finding's verification method; a fix whose blast radius invalidates a prior rung verdict is caught at FINAL_REVIEW (D-7's diff-empty condition forces re-run when scoped files changed; tests always re-run). R-112 applies to any *new* Major+ raised there.
6. **Machine finding on a pre-existing issue outside the diff** (SAST scans the diff only per spec §4.1): out-of-diff hits are not machine findings; the reviewer MAY still raise an LLM finding per normal rules.
7. **Same model, different versions** (e.g. fable-5 vs fable-5.1): R-115 compares resolved model identity strings; equal strings → false. Family-level nuance is D/C territory; the recorded strings make any gap auditable.
8. **Pre-B in-flight run resumed post-B**: no `change_class`/`hetero_reviewer`/`machine_evidence` → defaults apply (`feature`, blank-advisory, absent block); driver MUST NOT rewrite records (existing §9.2 clause, extended in wording only).
9. **Reviewer cannot execute the declared test command** (sandbox, missing env): that is the R-64 path — `NOT_AVAILABLE` naming ACs, not a guessed verdict.
10. **stub/fake tools declared by a project**: allowed by construction (tool-agnostic); a *false* claim of access remains a Blocker (R-63). Our own verification harness uses declared stub tools legitimately (see Testing Strategy).
11. **Implementer not yet resolved when a review runs** (PLAN_REVIEW): the hetero advisory is NOT computed there — R-115 fires at the first FULL_REVIEW/combined dispatch, when both operands exist (F-hwB-003).

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Rule text ambiguity → future reviewers skip rungs silently | Medium | R-110 wording makes NOT_AVAILABLE recording a MUST; AC-F-01 verifies the degradation path live |
| Refute-or-promote refutes away a real bug | Low | Edge case 3; ledger visibility + R-59 reopen + FINAL re-confirmation |
| change_class misdetection | Medium | Planner authoritative + reviewer finding + "no repro ⇒ Major regardless" backstop |
| Live verification runs are nondeterministic (LLM reviewer behavior) | Medium | Each AC has a deterministic schema/grep component; live runs are seeded so at least one deterministic trigger exists (failing test → machine Blocker); controlled reviewer-only dispatches as fallback (Testing Strategy) |
| Different-model live run infeasible in harness | Medium | AC-F-05b degrades to explicit NOT AVAILABLE (R-64) → OWNER waiver decision per R-66, not silent pass |
| Drift between shards and PROTOCOL.md | Low | Every shard-editing task ends with regenerate + `--check` (exit 0 required per task) |

## Dependencies

- Sub-project A merged to main — **verified** (fact: `git log` + drift check run, both green).
- Git working tree clean except the untracked spec file — **verified** (fact: `git status --porcelain` shows only `?? docs/specs/...`).
- Claude Code adapter for live verification runs — **verified available** (fact: A's T11 live battery ran in this environment 2026-08-10 per the committed A trail; the adapter files exist under `adapters/claude-code/`).
- No external/network dependencies.

## Testing Strategy

Two layers, both executed by the IMPLEMENTER per task and re-executed/spot-checked by the REVIEWER:

1. **Deterministic self-checks** (every task): `sh build-protocol.sh --check` exit 0 after each shard edit; `grep` assertions on exact rule text/fields; `git diff --name-only` audits; byte-identity checks (`git diff --quiet -- <path>`) for must-not-touch files.
2. **Live-adapter battery (T11)**: scratch target repos under `/private/tmp/hw-b-verify/` with Heatwave installed via `install.sh`, run through the claude-code adapter. Tool-agnosticism is proven with *declared stub tools in the scratch targets* (a `sast-stub.sh` / `mut-stub.sh` the scratch project declares in its `heatwave.config.yaml` — legitimate under the tooling-declaration contract, and exactly how B stays tool-agnostic without wiring D's tools). Runs: L1 EXPRESS (no ladder), L2 LIGHT bugfix (red→green, tests-only rung, same-model advisory recorded at review time), L3 STANDARD feature to APPROVED (tests+SAST verdicts pre-LLM), L4 FULL (mutation stub → surviving-mutant machine finding; seeded real defect → promoted Major; seeded bait → refuted). Controlled reviewer-only dispatches cover the negative branches (missing-repro package ⇒ Major; undeclared sast ⇒ NOT_AVAILABLE; prior-ledger false-positive ⇒ refuted via reconciliation). Full mapping in Acceptance Criteria; exact commands in T11.

## Rollout Plan

Single repo, docs+templates only, no flags, no build artifacts beyond the regenerated PROTOCOL.md. Work lands as per-task commits on `main` after APPROVED (per the owner's push-to-main workflow). Nothing deploys; consumers pick up B on their next `install.sh` run. N/A beyond that — no staging/phasing surface exists.

## Rollback Plan

1. `git log --oneline` — identify the B commit range (first: T1 core.md commit; last: T11 evidence commit).
2. `git revert <first>^..<last>` on `main` (or `git revert <sha>` per commit, newest first).
3. `sh build-protocol.sh` to regenerate PROTOCOL.md from the reverted shards; `sh build-protocol.sh --check` must exit 0.
4. `grep -rn "R-11[0-5]" protocol/ templates/ prompts/ heatwave.config.example.yaml` must return only history-shard mentions if any revert was partial — if non-empty elsewhere, revert missed a file; repeat for that file.
5. In-flight runs are unaffected either way: new fields were optional, old defaults still apply.

---

## Task-by-task implementation plan

**Global constraints (apply to EVERY task, restated here once and binding throughout):**
- **G-1** Zero new runtime deps: edits to existing `.md`/`.yaml` files only; no new scripts, no new executables; `build-protocol.sh` itself is not modified.
- **G-2** Ponytail: extend in place; do not restructure or renumber anything that exists; shortest diff that satisfies the rule text below.
- **G-3** Resume safety: every new field optional + defaulted; never touch `state.yaml` schema, §2.1/§2.2 states, or the §9.2 resume clause except the one wording extension in T1.
- **G-4** A-regression safety: `prompts/express-checker.md`, `templates/express-change.md`, `templates/express-check.md` are byte-untouched; EXPRESS pipeline text is untouched except the explicit "EXPRESS runs no ladder" clause inside R-110.
- **G-5** Every task that edits `protocol/*.md` ends with `sh build-protocol.sh && sh build-protocol.sh --check` → must print `OK: PROTOCOL.md matches protocol/ shards`, exit 0. Never hand-edit PROTOCOL.md.

New-rule text below is **normative** — the IMPLEMENTER inserts it verbatim (typo fixes via Deviation Record).

---

### T1 — core.md: tier-rigor table, R-110, R-114, R-115, §2.5 drive-behavior sentence, R-77 `Refuted`

**File:** `protocol/core.md` (+ regenerated `PROTOCOL.md`).
**Produces (interface):** rules R-110/R-114/R-115 + rigor table + consistent §2.5/§8.1, consumed by T2–T5, T6–T9.

Edits:

1. **§0.5, immediately after R-103 (currently line 78):** insert:

   > **Machine-evidence rigor by tier** *(v4)* — review is machine-first and scales with tier:
   >
   > | Tier | Machine-evidence ladder (R-110) | Refute-or-promote (R-112) | Reproduce-then-fix, bugfix class (R-113) |
   > |---|---|---|---|
   > | EXPRESS | none — R-104's machine gate is unchanged | no | no |
   > | LIGHT | declared test command(s) | yes (Major+) | yes |
   > | STANDARD | tests + SAST scan of the diff | yes (Major+) | yes |
   > | FULL | tests + SAST + mutation adequacy on changed modules | yes (Major+) | yes |
   >
   > **R-110.** *(v4)* At FULL_REVIEW (including the LIGHT combined pass, and FINAL_REVIEW per R-44) the REVIEWER MUST run the machine-evidence ladder for the run's tier — executing each rung itself, not trusting outputs attached by other roles — and record every rung's verdict in the findings ledger (`machine_evidence`) BEFORE authoring any LLM finding. Rungs consume the plan's tooling declaration (§6.1): `tests` = the declared test command(s); `sast` (STANDARD and FULL) = a static scan of the diff with the declared `sast` tool; `mutation` (FULL only) = mutation adequacy of the changed modules with the declared `mutation` tool, scoped to changed modules and bounded by the declared timeout. A rung whose tool is undeclared or unavailable records `verdict: NOT_AVAILABLE` naming the acceptance criteria it leaves unverified (R-64) — never a silent skip. The protocol names the checks, never specific tools. At FINAL_REVIEW a rung's prior verdict MAY be carried forward by reference only when the run's diff since that verdict was recorded is empty for the rung's scope (the files it scanned or mutated), and the carry-forward entry names the prior verdict's `evidence_ref`; the `tests` rung is always re-run.

2. **§1.4, after R-12:** insert:

   > **R-115.** *(v4)* The reviewer role SHOULD resolve to a different model family from the implementer — a same-model reviewer under-critiques work in its own style, and uncorrelated blind spots are the cheapest review upgrade — but this is never required: zero-config (the session model in all roles) remains fully valid. When BOTH the implementer and reviewer roles have resolved for the run — at the first FULL_REVIEW (or LIGHT combined-pass) dispatch — the driver MUST compare the resolved models and record in the Run Record `hetero_reviewer: "true"` when they differ, or `hetero_reviewer: "false (self-preference bias not mitigated)"` when they are the same. If either role's resolved model subsequently changes (R-11 substitution), the driver recomputes and appends the updated value. Advisory only — it never gates and changes no workflow step.

3. **§2.5:** (a) add to the `run_config` block, after the `design_doc` line:
   `  change_class: feature    # v4: bugfix | feature — driver initial, PLANNER authoritative (R-114) — active`
   (b) after the R-106 (driver half) paragraph, insert:

   > **R-114.** *(v4)* At intake the driver records `change_class` in `run_config`: `bugfix` when the task's purpose is to correct defective existing behavior, else `feature`. The PLANNER declares the authoritative class in the Planning Document with one line of justification and MAY correct the driver's value (the correction is recorded in the Run Record). EXPRESS runs never carry a change class — EXPRESS has no plan. Misclassification is a valid REVIEWER finding. Only `bugfix` alters behavior (R-113); a record without the field reads `feature`.

   (c) rewrite the paragraph after the run_config block: the sentence `Only `tier`, `tier_justification`, and `design_doc` drive behavior.` becomes `Only `tier`, `tier_justification`, `design_doc`, and `change_class` drive behavior.` (the RESERVED sentence for `autonomy`/`scope` is untouched); and extend the pre-v4 defaults sentence at the end of §2.5: after `scope: single_repo`, append `, change_class: feature`.

4. **§8.1, R-77:** replace the line `Where "open" excludes findings with `Status: Deferred (approved)` or `Status: Waived (OWNER)`.` with `Where "open" excludes findings with `Status: Deferred (approved)`, `Status: Waived (OWNER)`, or `Status: Refuted` (R-112).`

**Verification (deterministic):**
```
grep -c "R-110\." protocol/core.md            # expect 1
grep -c "R-114\." protocol/core.md            # expect 1
grep -c "R-115\." protocol/core.md            # expect 1
grep -n "change_class: feature" protocol/core.md   # expect 2 hits (block + defaults sentence)
grep -n "Machine-evidence rigor by tier" protocol/core.md  # expect 1
grep -n "drive behavior" protocol/core.md     # the four-field sentence (F-hwB-002)
grep -n "Refuted\` (R-112)" protocol/core.md  # expect 1, inside §8.1 (F-hwB-004)
grep -n "evidence_ref" protocol/core.md       # expect 1, inside R-110 (F-hwB-006)
grep -n "BOTH" protocol/core.md               # expect 1, inside R-115 (F-hwB-003)
sh build-protocol.sh && sh build-protocol.sh --check       # expect OK, exit 0
```

### T2 — reviewer.md: §3.4.2 (R-111, R-112), ladder-first in §4.4, R-113 reviewer half, Appendix A extension, R-109 amendment

**File:** `protocol/reviewer.md` (+ regenerated `PROTOCOL.md`).
**Consumes:** R-110/R-114 (T1). **Produces:** R-111/R-112/R-113(reviewer half) + extended Appendix A, consumed by T6/T7/T9/T11.

Edits:

1. **After §3.4.1 (after the R-109 paragraph):** insert:

   > #### 3.4.2 Machine evidence & refutation *(v4)*
   >
   > **R-111.** *(v4)* Ladder verdicts (R-110) convert to findings mechanically, recorded in the ledger with `origin: machine` and their `rung`: a failing declared test is a machine finding of severity Blocker; a high-severity SAST result on changed lines is a machine finding, default Major; a surviving mutant on changed lines is a machine finding — `tests inadequate for <file>`, naming what to cover — default Major. Default categories: a failing test takes the category of the acceptance criterion it verifies, else `verification-integrity`; a SAST hit takes the matching Security category from Appendix C; a surviving mutant takes `verification-integrity`. The REVIEWER MAY reclassify a machine finding's default severity or category per R-5 with recorded reason; it MUST NOT discard one silently. All other Appendix A semantics apply, including stable IDs (R-55). The LLM review that follows covers what machines cannot — logic, design, plan conformance — and MUST NOT restate as prose findings what a rung already verified.
   >
   > **R-112.** *(v4)* Refute-or-promote: before any candidate finding of severity Major or Blocker enters the ledger as `open`, the REVIEWER MUST attempt to refute it — is it actually reachable, actually wrong, not already handled? — and record the attempt and outcome in the finding's `refutation` field. A finding that survives is promoted (`status: open`) and gates per Section 8; one that is refuted is recorded with `status: refuted` and the refuting reason, MUST NOT enter FIXING, and MUST NOT gate (R-77 excludes it from "open"). Minors and Nits are exempt. A machine finding's refutation attempt is re-running its rung and checking the result is attributable to the change under review rather than a pre-existing baseline failure. Refuted findings remain in the ledger — visible, reconciled per 5.6, reopenable per R-59 — and are outside the set of findings R-31 obliges the FIXER to answer. Applies to ledger-producing reviews (R-109); PLAN_REVIEW findings are unaffected.

2. **§4.4, after R-39:** insert:

   > FULL_REVIEW opens with the machine-evidence ladder for the run's tier (R-110); LLM findings follow it.
   >
   > **R-113 (reviewer half).** *(v4)* For a `change_class: bugfix` run (R-114), the REVIEWER MUST confirm the reproduction: red evidence captured on pre-fix code, and the same check re-run green after the fix. A bugfix with no reproducing check, or with no red-run evidence, is a Major (`Category: verification-integrity`) regardless of how plausible the fix reads.

3. **Appendix A (F-hwB-001):** in the schema block, (a) after the `Category:` line insert:
   ```
   Origin:               reviewer | machine (R-111; absent = reviewer)
   ```
   (b) after the `Verification method:` lines insert:
   ```
   Refutation:           <refutation attempt + outcome — REQUIRED for
                          Major/Blocker (R-112)>
   ```
   (c) replace the `Status:` line's enum with:
   ```
   Status:               Open | Fixed | Deferred (approved) | Waived (OWNER) |
                         Disputed | Refuted
   ```

4. **§3.4.1, R-109 (F-hwB-001):** replace the final sentence `Appendix A field semantics are unchanged — the ledger is their compact carrier.` with `Appendix A field semantics are the ledger's field semantics — the ledger is their compact carrier (the v4 machine-evidence additions `Origin`, `Refutation`, and the `Refuted` status live in both; §3.4.2).`

5. Placement note: R-112 lives in §3.4.2 with the artifact it governs — no separate §5.7 heading (one home, smaller diff).

**Verification:**
```
grep -c "R-111\." protocol/reviewer.md        # expect 1
grep -c "R-112\." protocol/reviewer.md        # expect 1
grep -c "R-113 (reviewer half)" protocol/reviewer.md   # expect 1
grep -n "3.4.2 Machine evidence" protocol/reviewer.md  # expect 1
sed -n '/Appendix A/,$p' protocol/reviewer.md | grep -c "Refuted\|Origin:\|Refutation:"   # expect 3 (F-hwB-001)
grep -n "compact carrier" protocol/reviewer.md         # amended R-109 sentence (F-hwB-001)
sh build-protocol.sh && sh build-protocol.sh --check   # OK, exit 0
```

### T3 — planner.md: R-113 planner half + §6.1 sast/mutation entries

**File:** `protocol/planner.md` (+ regenerated `PROTOCOL.md`).
**Consumes:** R-110/R-114 (T1). **Produces:** R-113(planner half) + §6.1 contract, consumed by T7/T9/T11.

Edits:

1. **§3.2.2, after R-27:** insert:

   > **R-113 (planner half).** *(v4)* When the run is `change_class: bugfix` (R-114), the acceptance criteria MUST include a failing reproduction: a functional criterion whose verification method is an executable check demonstrated red on the pre-fix code and re-run green after the fix (captured by the IMPLEMENTER, R-113 implementer half). The check is any executable reproduction — a framework test, a script, a CLI invocation — not necessarily a formal test. A bugfix plan without a reproduction criterion MUST be rejected at PLAN_REVIEW. Where nothing executable can express the reproduction, the plan states so explicitly (R-64) and the criterion is unverifiable — which blocks APPROVED absent an OWNER waiver (R-66).

2. **§6.1, after the R-99 paragraph:** insert:

   > *(v4)* For STANDARD and FULL runs the declaration MUST also carry a `sast` entry, and for FULL runs a `mutation` entry — the REVIEWER's ladder rungs consume them (R-110). Detect them from project evidence like any other tool (a Semgrep/CodeQL config, `stryker.conf.*`, `mutmut`/`cargo-mutants` in dev-dependencies, CI workflows); `tooling.sast` / `tooling.mutation` in `heatwave.config.yaml` override detection. A mutation entry states its timeout ceiling. No evidence and no config entry → the entry reads `NOT AVAILABLE`, naming the acceptance criteria left unverified (R-64) — the rung then degrades per R-110, never silently.

3. **§6.1 example block:** append two lines to the existing example:
   ```
   SAST         | <per detection/config> | REVIEWER | access: NOT AVAILABLE — rung degrades per R-110/R-64
   Mutation     | <per detection/config> | REVIEWER | access: confirmed — stryker.conf.mjs; timeout 10m
   ```

**Verification:**
```
grep -c "R-113 (planner half)" protocol/planner.md   # expect 1
grep -n "sast" protocol/planner.md | wc -l           # expect >= 2 (rule text + example)
grep -n "mutation" protocol/planner.md | wc -l       # expect >= 2
sh build-protocol.sh && sh build-protocol.sh --check # OK, exit 0
```

### T4 — implementer.md: R-113 implementer half

**File:** `protocol/implementer.md` (+ regenerated `PROTOCOL.md`).

Edits:

1. **§4.3, after R-38:** insert:

   > **R-113 (implementer half).** *(v4)* For a `change_class: bugfix` run (R-114), the IMPLEMENTER MUST capture the failing reproduction FIRST: run the plan's reproduction check against unmodified code and attach the red output to the Implementation Package, then fix, then re-run the same check and attach the green output. Red-then-green is the verification evidence for the reproduction criterion; a fix authored before the red run is captured is a deviation (3.2.1).

2. **§3.3 table, `Test results` row:** change the Detail cell from `Per 6.4 — evidence, not assertion` to `Per 6.4 — evidence, not assertion; bugfix runs attach the red-then-green reproduction pair (R-113)`.

**Verification:**
```
grep -c "R-113 (implementer half)" protocol/implementer.md   # expect 1
grep -n "red-then-green" protocol/implementer.md             # expect >= 1
sh build-protocol.sh && sh build-protocol.sh --check         # OK, exit 0
```

### T5 — orchestrator.md: driver duties (change_class at intake, hetero_reviewer once both roles resolved)

**File:** `protocol/orchestrator.md` (+ regenerated `PROTOCOL.md`). No new rule numbers — cross-references only.

Edits:

1. **§9.2:** no edit — the existing "resumes with the §2.5 defaults" clause already covers the extended defaults (verified at review iteration 1); read-only confirmation.
2. **§9.1, after R-85:** insert:

   > *(v4)* Two recording duties ride the driver's existing steps: at intake it records `change_class` in `run_config` (R-114 — the PLANNER may correct it, and the correction is recorded); at the first FULL_REVIEW (or LIGHT combined-pass) dispatch — once both the implementer and reviewer roles have resolved — it records the `hetero_reviewer` advisory computed from the resolved models (R-115), recomputing and appending if a later substitution changes either. Neither duty adds a state or a gate.

**Verification:**
```
grep -c "R-114" protocol/orchestrator.md   # expect 1
grep -c "R-115" protocol/orchestrator.md   # expect 1
grep -n "both the implementer and reviewer roles have resolved" protocol/orchestrator.md  # expect 1 (F-hwB-003)
sh build-protocol.sh && sh build-protocol.sh --check   # OK, exit 0
```

### T6 — templates: findings-ledger.yaml + run-record.yaml field additions

**Files:** `templates/findings-ledger.yaml`, `templates/run-record.yaml`.
**Consumes:** R-110/R-111/R-112/R-114/R-115 texts. **Produces:** schemas consumed by T9 prompts and T11 runs.

Exact additions — `findings-ledger.yaml`: after the `verdict:` line insert:

```yaml
machine_evidence: []   # v4 (R-110/R-111) — ladder rung verdicts, recorded BEFORE any LLM finding; [] on EXPRESS and plan reviews; absent = pre-v4-B ledger
  # - rung: tests              # tests | sast | mutation — per the tier rigor table (core §0.5)
  #   tool: "npm test"         # as declared in the plan's tooling declaration (§6.1)
  #   verdict: pass            # pass | fail | NOT_AVAILABLE
  #   evidence_ref: <command output reference>
  #   unverified_acs: []       # REQUIRED when verdict is NOT_AVAILABLE (R-64)
```

and in the finding comment block: after the `category:` line add
```yaml
  #   origin: reviewer           # reviewer | machine (R-111); absent = reviewer
```
after the `verification:` line add
```yaml
  #   refutation: <refutation attempt + outcome — REQUIRED for Major/Blocker (R-112)>
```
and change the `status:` comment to
```yaml
  #   status: open               # open | fixed | deferred_approved | waived_owner | disputed | refuted (R-112)
```

`run-record.yaml`: in the `run_config` block after the `design_doc` line add
```yaml
  change_class: feature    # v4: bugfix | feature — driver initial, PLANNER authoritative (R-114); absent = feature
```
and after the `roles:` block add
```yaml
hetero_reviewer: ""      # v4 (R-115): "true" | "false (self-preference bias not mitigated)" — computed from roles.*.resolved once both implementer and reviewer have resolved (first FULL_REVIEW dispatch); blank/absent = pre-v4-B record or not yet computed; advisory, never gates
```

**Verification:**
```
grep -n "machine_evidence" templates/findings-ledger.yaml   # expect 1
grep -n "refutation" templates/findings-ledger.yaml         # expect 1
grep -n "| refuted" templates/findings-ledger.yaml          # expect 1
grep -n "change_class" templates/run-record.yaml            # expect 1
grep -n "hetero_reviewer" templates/run-record.yaml         # expect 1
git diff --quiet -- templates/express-change.md templates/express-check.md && echo EXPRESS-UNTOUCHED   # expect EXPRESS-UNTOUCHED
```

### T7 — templates: planning-document.md + review-report.md

**Files:** `templates/planning-document.md`, `templates/review-report.md`.

`planning-document.md`:
1. **## Tier section** — add a second line:
   `Change class: <bugfix | feature> — <one-line justification> (R-114; bugfix triggers R-113)`
2. **### Functional (acceptance criteria)** — add the guidance line under the AC-F example:
   `<bugfix runs: one functional criterion MUST be the failing reproduction — red on pre-fix code, green after (R-113)>`
3. **## Tooling Declaration table** — append two rows:
   ```
   | SAST (STANDARD+) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE — <affected ACs> (R-110) |
   | Mutation (FULL, with timeout ceiling) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE — <affected ACs> (R-110) |
   ```

`review-report.md`: at the top of **## Verification Log**, add the line:
`Machine evidence (R-110): <rung | tool | verdict | evidence — mirrors the ledger's machine_evidence block; NOT_AVAILABLE rungs name the unverified ACs>`

**Verification:**
```
grep -n "Change class" templates/planning-document.md    # expect 1
grep -n "R-113" templates/planning-document.md           # expect >= 1
grep -cn "R-110" templates/planning-document.md          # expect 2 (two tooling rows)
grep -n "Machine evidence (R-110)" templates/review-report.md   # expect 1
```

### T8 — heatwave.config.example.yaml: hetero recommendation + sast/mutation keys

**File:** `heatwave.config.example.yaml`.

1. In the **Models per role** comment block, after the "uncorrelated blind spots" line, add:
   ```
   # RECOMMENDED (R-115): give the reviewer a different model FAMILY from the
   # implementer — a same-model reviewer under-critiques its own style. The run
   # record flags the gap either way: hetero_reviewer: "false (self-preference
   # bias not mitigated)" when they match. Advisory only — zero-config stays valid.
   ```
2. In the **Test tooling** block, append:
   ```
   #   sast: "semgrep --config auto"    # STANDARD+ ladder rung (R-110); unset + undetected → NOT AVAILABLE, never silent
   #   mutation: "npx stryker run"      # FULL ladder rung (R-110); scoped to changed modules; state a timeout
   ```

**Verification:**
```
grep -n "R-115" heatwave.config.example.yaml    # expect 1
grep -n "sast:" heatwave.config.example.yaml    # expect 1
grep -n "mutation:" heatwave.config.example.yaml # expect 1
```
(Everything added is commented — config remains all-optional; zero-config behavior unchanged.)

### T9 — prompts: reviewer, planner, implementer, orchestrator

**Files:** `prompts/reviewer.md`, `prompts/planner.md`, `prompts/implementer.md`, `prompts/orchestrator.md`. (`prompts/express-checker.md`, `prompts/plan-reviewer.md`, `prompts/fixer.md`, `prompts/final-reviewer.md` untouched — final-reviewer inherits ladder via R-44 through the reviewer shard it already loads; verify no contradiction, edit only if one is found, as a recorded deviation.)

Minimal additions, one place each:

- `prompts/reviewer.md`, top of the FULL_REVIEW section: "**Open with the machine-evidence ladder (R-110):** run the tier's rungs yourself — tests (LIGHT+), SAST of the diff (STANDARD+), mutation on changed modules (FULL) — from the plan's tooling declaration, and record verdicts in the ledger's `machine_evidence` block BEFORE writing any LLM finding. Absent tool → `verdict: NOT_AVAILABLE` naming the unverified ACs (R-64), never a silent skip. Then review what machines cannot." Plus two bullets in **Always**: "Major/Blocker candidates pass refute-or-promote (R-112): record the refutation attempt in the finding's `refutation` field; refuted findings get `status: refuted` + reason and never enter FIXING. Minors/Nits exempt." and "Bugfix runs (`change_class: bugfix`): confirm red-before/green-after reproduction evidence; a bugfix without it is a Major (R-113)."
- `prompts/planner.md`, in **Get right**: "**Change class** (R-114): declare `bugfix` or `feature` with one line; for bugfix, one AC-F MUST be the failing reproduction (red pre-fix, green post-fix — R-113)." and extend the tooling bullet with: "STANDARD+: also declare `sast`; FULL: also `mutation` (with timeout) — detected from evidence (semgrep/CodeQL config, stryker/mutmut/cargo-mutants in deps, CI) or `NOT AVAILABLE` with affected ACs (R-110/R-64)."
- `prompts/implementer.md`, in **Evidence**: "Bugfix runs (R-113): capture the failing reproduction FIRST — red output on unmodified code attached to the package — then fix, then attach the green re-run. Fixing before the red run is captured is a deviation."
- `prompts/orchestrator.md`, in **Intake** after tier classification: "Record `change_class: bugfix | feature` in `run_config` (R-114) — the PLANNER may correct it; record the correction." And in **The loop** after step 2: "At the first FULL_REVIEW (or LIGHT combined-pass) dispatch — once both implementer and reviewer have resolved — record the `hetero_reviewer` advisory in `run-record.yaml` per R-115 (compare the resolved models; recompute on any later substitution)."

**Verification:**
```
grep -n "R-110" prompts/reviewer.md          # expect >= 1
grep -n "R-112" prompts/reviewer.md          # expect >= 1
grep -n "R-114" prompts/planner.md prompts/orchestrator.md   # expect >= 1 each
grep -n "R-113" prompts/planner.md prompts/implementer.md prompts/reviewer.md  # expect >= 1 each
grep -n "R-115" prompts/orchestrator.md      # expect >= 1
grep -n "both implementer and reviewer have resolved" prompts/orchestrator.md  # expect 1 (F-hwB-003)
git diff --quiet -- prompts/express-checker.md && echo EXPRESS-PROMPT-UNTOUCHED  # expect output
```

### T10 — history shard, final regenerate, repo-wide consistency sweep

**Files:** `protocol/history.md` (+ regenerated `PROTOCOL.md`); adapters only if the sweep finds a contradiction.

1. Append one row to Appendix F.1:
   `| Machine-evidence ladder, refute-or-promote, reproduce-then-fix, hetero-reviewer visibility | R-110–R-115 | Rigor rested on LLM prose; false-positive Majors cost full fix cycles; "verified" bugfixes were claims; same-model self-preference was invisible |`
2. `sh build-protocol.sh && sh build-protocol.sh --check` → OK, exit 0.
3. **Repo-wide sweep** (the A lesson): `grep -rniE "ladder|refut|mutation|sast|change_class|hetero" adapters/ prompts/ README.md COMPANIONS.md docs/faq.md install.sh` and `grep -rn "evidence, not assertion\|reviewer owns severity" adapters/` — read every hit; the pre-planning sweep found the adapter shims carry only role/tier/evidence invariants, all *compatible* with B (machine evidence strengthens "evidence, not assertion"; nothing asserts review is LLM-prose-only). Expected result: zero contradictions, zero adapter edits. If a hit contradicts (e.g. text implying findings go straight to FIXING), fix that file with the minimal qualifier and record it in the Implementation Package.
4. Confirm rule-number uniqueness with a pattern that matches the named halves (F-hwB-009): `grep -rEn "R-11[0-5]\.|R-113 \((planner|implementer|reviewer) half\)\." protocol/` — expected: R-110, R-111, R-112, R-114, R-115 defined exactly once each; R-113 exactly three named halves (cross-check: AC-F-09's `grep -c "R-113 (" PROTOCOL.md` = 3).
5. Also sweep the Status enum for stragglers (F-hwB-001 companion): `grep -rn "Deferred (approved)" protocol/ templates/` — every enum hit lists `Refuted`/`refuted` where it enumerates statuses (Appendix A, R-77, ledger template) or is a non-enum mention (R-6, §8.2 table — deferral prose, no change).

**Verification:** commands above; sweep output attached verbatim as evidence (AC-F-08).

### T11 — live verification battery (scratch targets)

**Files produced:** evidence bundle only (scratch dirs + captured outputs referenced from the Implementation Package). Nothing new lands in the repo except evidence references. Scratch root: `/private/tmp/hw-b-verify/`.

Setup per target: `mkdir -p /private/tmp/hw-b-verify/<t> && cd /private/tmp/hw-b-verify/<t> && git init && sh /Users/abhirajsinha/Projects/heatwave/install.sh` (per the installer's documented usage), then seed the tiny project.

- **L1 — EXPRESS regression + tier scaling (none):** scratch repo with `README.md` typo; run "fix the typo in README" through the claude-code adapter. Checks: run dir has exactly `01-express-change.md` + `02-express-check.md` → APPROVED; `grep -ri "machine_evidence\|ladder" .heatwave/runs/<id>/` → 0 hits.
- **L2 — LIGHT bugfix, red→green + tests-only rung + same-model advisory:** scratch repo with `calc.sh` (off-by-one bug) and declared test command `sh test.sh` in `heatwave.config.yaml` (`tooling.unit`). Run "fix the off-by-one in calc.sh". Checks: plan AC includes reproduction; Implementation Package contains red output then green output; ledger `machine_evidence` has exactly one rung (`tests`); every Major+ finding (if any) has non-empty `refutation`; run-record has `run_config.change_class: bugfix` and `hetero_reviewer: "false (self-preference bias not mitigated)"`; **timing assertion (F-hwB-003): the run-record is append-only, so entry order proves timing — the `hetero_reviewer` entry appears after the implementation-package transition and no earlier than the review dispatch, and is absent from the record before IMPLEMENTING completes** (checked by diffing the record captured at PLAN_REVIEW-time vs final).
- **L3 — STANDARD feature to APPROVED, ladder pre-LLM:** scratch repo declaring `tooling.sast: "sh ./sast-stub.sh"` (stub prints a clean scan) + unit command. Run a small feature. Checks: ledger `machine_evidence` carries `tests` and `sast` rungs with verdicts; transcript shows rung commands executed before findings were authored; run reaches APPROVED (A-regression evidence).
- **L4 — FULL: mutation finding, promote, refute:** scratch declaring sast stub + `tooling.mutation: "sh ./mut-stub.sh"` where the stub prints one surviving mutant for the changed file, and the seeded implementation leaves one AC genuinely unmet (deterministic real Major via failing declared test → machine Blocker/Major that MUST survive refutation and enter FIXING). Checks: ledger has a `origin: machine, rung: mutation` finding reading `tests inadequate for <file>`; the real finding is `status: open` with a `refutation` field and appears in the fix report; run-record `change_class: feature`.
- **Controlled reviewer-only dispatches** (negative branches; each = one fresh reviewer context given crafted artifacts, protocol-legal per R-3):
  - **N1 missing-repro bugfix:** hand a reviewer a bugfix-class plan + Implementation Package with no red evidence → expect a Major, `Category: verification-integrity` (AC-F-04b).
  - **N2 undeclared sast on STANDARD:** same artifacts as L3 but tooling declaration without `sast` → expect `machine_evidence` entry `rung: sast, verdict: NOT_AVAILABLE` naming ACs (AC-F-01b).
  - **N3 seeded false positive:** reviewer dispatched with a prior-iteration ledger containing one seeded plausible-but-wrong open Major (code path demonstrably guarded) → reconciliation (R-58) forces addressing it; expect `status: refuted` + reason, absent from any fix cycle (AC-F-03a). *(Primary path: if L4's bait — an apparently-unguarded division that is in fact guarded — draws a candidate Major organically, that evidence is used instead and N3 is skipped.)*
  - **H1 different-model reviewer:** re-run L2's review with the scratch `.claude/agents/heatwave-reviewer.md` frontmatter `model:` set to the Opus 4.8 family (access **assumed** — verified at task start; if the harness cannot switch models, AC-F-05b is declared NOT AVAILABLE per R-64 and goes to the OWNER per R-66, not silently passed). Expect run-record `hetero_reviewer: "true"` with differing `roles.*.resolved`.
- **Resume-compat check (AC-N-03):** in L3's run dir mid-flight (after 01/02 exist), strip `change_class`/`hetero_reviewer` from `run-record.yaml` copy → resume the run → driver proceeds without error and without rewriting the record (diff of record before/after resume shows only appended transitions).

All commands, outputs, and run-dir listings are captured verbatim into the evidence bundle. Every check above is pass/fail on file contents (grep-able), not on narrative.

---

## Acceptance Criteria

### Functional

Each maps a spec §8 verification item; every method is independently executable.

- **AC-F-01 | Ladder runs pre-LLM, absent tool → explicit NOT AVAILABLE (spec 8.1)** | Verification: (a) L3 ledger `machine_evidence` contains `tests` + `sast` verdicts and the transcript shows rung execution before finding authorship; (b) N2 ledger contains `rung: sast, verdict: NOT_AVAILABLE` with non-empty `unverified_acs`. Evidence: ledger files + transcript excerpts.
- **AC-F-02 | Mutation on FULL (spec 8.2)** | Verification: L4 ledger contains a finding with `origin: machine`, `rung: mutation`, problem text `tests inadequate for <file>`. Evidence: ledger entry.
- **AC-F-03 | Refute-or-promote, both directions (spec 8.3)** | Verification: (a) a seeded false-positive Major ends `status: refuted` with recorded reason and appears in no Fix Report (L4 bait or N3); (b) L4's real Major/Blocker is `status: open` with a non-empty `refutation` field and enters FIXING; (c) deterministic schema check: `awk`/grep over all battery ledgers — every `severity: Blocker|Major` entry has a non-empty `refutation`. Evidence: ledgers + fix-report absence/presence.
- **AC-F-04 | Reproduce-then-fix, both directions (spec 8.4)** | Verification: (a) L2 package contains red output captured pre-fix and green output post-fix for the plan's reproduction AC; (b) N1 review raises a Major `verification-integrity` against the no-repro package. Evidence: package excerpts + N1 ledger.
- **AC-F-05 | Hetero-reviewer visibility, computed when both roles resolved (spec 8.5 + F-hwB-003)** | Verification: (a) L2 run-record contains exactly `hetero_reviewer: "false (self-preference bias not mitigated)"` AND the timing assertion holds (entry absent from the record captured before IMPLEMENTING completed; present after the review dispatch — append order proves it); (b) H1 run-record contains `hetero_reviewer: "true"` with differing resolved models — or, if model switching is unavailable, an explicit R-64 NOT AVAILABLE declaration escalated per R-66. Evidence: run-record snapshots (mid-run + final).
- **AC-F-06 | Tier scaling (spec 8.6)** | Verification: grep across battery run dirs — L1 (EXPRESS): zero `machine_evidence`/ladder mentions; L2 (LIGHT): `machine_evidence` rungs == {tests}; L3 (STANDARD): == {tests, sast}; L4 (FULL): == {tests, sast, mutation}. Evidence: grep output per run dir.
- **AC-F-07 | Regression + drift (spec 8.7)** | Verification: L3 reaches APPROVED through the full state machine; L1 EXPRESS reaches APPROVED with the two-artifact pipeline; `sh build-protocol.sh --check` exits 0 on the final tree. Evidence: run records + check output.
- **AC-F-08 | Adapter/prompt consistency (spec 8.8)** | Verification: T10's repo-wide grep sweep output attached; zero hits contradicting ladder/refutation/repro behavior; T10 check 4's rule-uniqueness grep passes; T10 check 5's Status-enum sweep shows no straggler enum. Evidence: sweep output verbatim.
- **AC-F-09 | New rules present, schema consistent, PROTOCOL.md regenerated** | Verification: `for r in 110 111 112 114 115; do grep -c "R-$r\." PROTOCOL.md; done` → 1 each; `grep -c "R-113 (" PROTOCOL.md` → 3 (three halves); `sed -n '/Appendix A/,$p' PROTOCOL.md | grep -c "Refuted"` ≥ 1; generated header line intact. Evidence: command output.

### Non-functional

- **AC-N-01 | Zero new runtime deps** | Metric: `git diff --name-only <base>..HEAD` contains only existing `.md`/`.yaml` files (plus this plan/review trail under `docs/`); no new `.sh`, no mode changes; `build-protocol.sh` byte-identical | Verification: diff-name audit + `git diff --quiet -- build-protocol.sh`.
- **AC-N-02 | EXPRESS unchanged** | Metric: `git diff --quiet -- prompts/express-checker.md templates/express-change.md templates/express-check.md` exits 0; L1 EXPRESS run produces the identical artifact set as under A | Verification: byte check + L1 run-dir listing.
- **AC-N-03 | Resume compatibility** | Metric: a run-record lacking every new field resumes with defaults, no error, no record rewrite | Verification: T11 resume-compat check — record diff before/after resume shows appended transitions only.

## Review Scope

Applicable
✓ plan-conformance — always applicable
✓ verification-integrity — always applicable; the whole sub-project is about it
✓ data-integrity — the YAML schema changes and the Appendix A schema extension must stay backward-readable (NFR-3/AC-N-03)

Not applicable
✗ all Frontend categories — docs/spec repo; no UI surface
✗ Backend: business-logic · api-contracts · request-validation · response-validation · status-codes · versioning · schema* · migrations · transactions · indexes · query-performance — no runtime code; (*schema of YAML templates is covered under data-integrity above)
✗ all Security categories — no executable surface added; secure-config N/A (config additions are comments)
✗ all Performance categories — no runtime; the only "performance" concern (EXPRESS latency, dispatch size) is AC-N-02's byte checks
✗ Reliability: error-handling · retry · circuit-breakers · timeouts · recovery · rate-limiting — no runtime code
✗ all Observability categories — N/A, no services

(`plan-conformance` and `verification-integrity` are never N/A.)

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Drift check | `sh build-protocol.sh --check` | IMPLEMENTER (per task) + REVIEWER | confirmed — run this session, output `OK: PROTOCOL.md matches protocol/ shards`, exit 0 |
| Deterministic text checks | POSIX sh: grep/awk/cmp/git | IMPLEMENTER + REVIEWER | confirmed — used throughout this session |
| Live adapter runs | Claude Code + `adapters/claude-code`, scratch targets under `/private/tmp/hw-b-verify/` | IMPLEMENTER (battery) + REVIEWER (spot re-run) | confirmed — A's T11 battery ran live in this environment 2026-08-10 (committed A trail); `/private/tmp` writable |
| SAST (real tool) | semgrep / CodeQL | — | **NOT AVAILABLE** — `command -v semgrep` empty this session. Substituted: declared stub tools in scratch targets (legitimate under the tool-agnostic contract; B defines the gate, D wires real tools). ACs affected: none left unverified — AC-F-01/02 verify the *contract* (verdict recording + degradation), which stubs exercise fully |
| Mutation (real tool) | stryker / mutmut / cargo-mutants | — | **NOT AVAILABLE** — `command -v mutmut stryker` empty this session. Same stub substitution; same AC coverage argument |
| Different-model reviewer dispatch | Claude Code agent `model:` frontmatter (Opus 4.8 family fallback) | IMPLEMENTER (H1) | **assumed** — verified at T11 start; if unavailable, AC-F-05b degrades to an explicit NOT AVAILABLE (R-64) and the unverified criterion goes to the OWNER (R-66). Never silently passed |

---

*Fact/inference labeling:* every "verified" in Dependencies and Tooling above is a fact from commands run this session or the prior planning session (outputs quoted). The A-battery-precedent claim is a fact from the committed A trail (`git log` `16320d6`). The H1 model-switch capability is an assumption, labeled as such and carried in Risks + Tooling.
