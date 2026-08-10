# Planning Document — Adaptive Intake + Slimdown (Heatwave v4, Sub-project A)

task_id: hw-v4-A-intake-slimdown | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-10

Source of truth: `/Users/abhirajsinha/Projects/heatwave/docs/specs/2026-08-10-adaptive-intake-slimdown-design.md` (approved design spec). This plan implements that spec exactly — sub-project A only; B–H are out of scope per spec §2.

---

## Responses to PLAN_REVIEW iteration 1 (R-34)

Responding to: `docs/superpowers/reviews/2026-08-10-plan-review-A.md` (0 Blockers, 3 Majors, 4 Minors, 2 Nits).

```
Finding ID:   F-hw-v4-A-001 (Major)
Response:     Fixed
Change:       Task 9 rewritten from a subset list to the complete enumeration produced by a fresh
              repo-wide grep this iteration (grep -rn "PROTOCOL.md" prompts/ adapters/ README.md docs/
              COMPANIONS.md install.sh — 26 non-spec hits, all assigned per-file edits in Task 9).
              adapters/claude-code/HEATWAVE.md now has exact edits for line 5 (read target), line 15
              (shard-based subagent attachment), the state→subagent map (EXPRESS_IMPLEMENTING →
              heatwave-implementer in EXPRESS mode; EXPRESS_CHECK → heatwave-reviewer dispatched with
              prompts/express-checker.md — reusing the existing reviewer agent, whose fresh context
              satisfies R-1/R-2; no new agent file), and line 17 ("Small tasks use the EXPRESS or LIGHT
              tier, not a skipped protocol"). All seven remaining shims (gemini, cursor, copilot,
              windsurf, cline, zed, aider) are updated in place with the same two-line pattern — not
              declared out of scope, since each is a 2-line diff and leaving them would keep directing
              those tools at the full doc. adapters/README.md lines 3/29/30 updated too.
Verification: The finding's stated method, adopted verbatim as Task 9's exit check and AC-F-12:
              grep -rn "PROTOCOL.md" prompts/ adapters/ | grep -v "full rendered spec" → every remaining
              hit is a documented pointer, none an attach/read instruction;
              grep -n EXPRESS adapters/claude-code/HEATWAVE.md → non-empty.
Evidence:     Revised Task 9 (complete per-file enumeration); sweep output captured this session.
```

```
Finding ID:   F-hw-v4-A-002 (Major)
Response:     Fixed
Change:       (a) Task 3 gains item 0: amend the §0.5 preamble in protocol/core.md, exact replacement
              text given in Task 3 — "Every tier except EXPRESS keeps all four gates …; EXPRESS
              substitutes its own gate: a deterministic machine check plus a confirmation glance by a
              fresh context that did not make the change (R-104). No tier ever lets a context approve
              its own work." (b) Task 9 carries exact replacement sentences for GATE.md,
              adapters/generic/HEATWAVE-AGENT.md:23, adapters/codex/AGENTS.md:12, and the five sibling
              shims with the same summary sentence — all now read "no implementation before an approved
              plan (EXPRESS tier excepted: one independent machine-gated check gates APPROVED, R-104)".
              (c) The "only attachment/reading instructions change" claim is deleted; Task 9's scope is
              now explicitly "attachment instructions, reading instructions, AND invariant statements".
              (d) My own sweep found one hit the report did not list: docs/faq.md:7 ("the plan is still
              reviewed before any code is written") — added to Task 10 with an EXPRESS carve-out.
Verification: The finding's stated method, adopted as a Task 9/10 exit check and AC-F-12:
              grep -rn "before a Planning Document\|before an approved plan\|keeps all four gates"
              PROTOCOL.md protocol/ adapters/ docs/ README.md → every hit carries an EXPRESS qualifier
              or lives in protocol/history.md.
Evidence:     Revised Tasks 3, 9, 10; Edge Case 10 added; sweep output captured this session.
```

```
Finding ID:   F-hw-v4-A-003 (Major)
Response:     Fixed
Change:       Adopted recommended option (a) and kept the strict grep: Task 9 rewords every prompt
              citation from "per PROTOCOL.md §x" to "per protocol §x (in your attached shards)" across
              the six role prompts (prompts/orchestrator.md handled inside Task 8's rewrite, same rule),
              which also closes the token leak of shard-dispatched subagents opening
              .heatwave/PROTOCOL.md. AC-F-06 respecified with a satisfiable two-part method:
              (1) static — after T8+T9, grep -rn 'PROTOCOL.md' prompts/ returns 0 hits; (2) live — a
              T11 dispatch payload contains .heatwave/protocol/core.md plus the matrix shard(s) and
              zero occurrences of the string "PROTOCOL.md". AC-N-01 remains the substantive size check.
Verification: The revised AC-F-06 method executed against a real T11 dispatch payload; grep count is 0
              or it is not — executable and unambiguous.
Evidence:     Revised AC-F-06, Task 8 verification, Task 9 prompts block.
```

```
Finding ID:   F-hw-v4-A-004 (Minor)
Response:     Fixed
Change:       Shard map corrected per the recommendation: §5.4 (R-53/R-54) → protocol/core.md (binds
              implementer and reviewer; core is the shared home); §5.1 (R-46/R-47) → protocol/planner.md
              (the PLANNER declares scope, and PLAN_REVIEW loads the planner shard per the matrix, so
              the plan-reviewer still receives it); reviewer shard now carries §5.2/5.3/5.5/5.6 only.
              R-106 split: the driver-resolution half moves into core §2.5 (loaded by the intake
              dispatch); the planner-emission half stays in planner §3.2.3 referencing §2.5. Shard map
              table, dispatch matrix note, Task 1, Task 3 item 5, and Task 5 updated consistently.
Verification: The finding's method: for each of R-46, R-53, R-106, the bound role's dispatch-matrix row
              includes the shard holding it — R-46: PLANNING = core+planner ✓; R-53: IMPLEMENTING/FIXING
              = core+implementer / core+fixer with the rule now in core ✓; R-106 resolution: intake =
              core+orchestrator with the sentence in core §2.5 ✓; R-106 emission: PLANNING =
              core+planner ✓.
Evidence:     Revised shard map + Architecture §D (R-106 split into two placed halves).
```

```
Finding ID:   F-hw-v4-A-005 (Minor)
Response:     Fixed
Change:       Task 6 now amends the reviewer shard with exact texts: §3.4 structure item 6 becomes
              "6. Findings — summary per finding; canonical Appendix-A detail lives in the findings
              ledger (R-109)", and R-29's first sentence becomes "Findings MUST use the Appendix A
              schema, carried in the findings ledger from v4 (R-109); the report's Findings section
              summarizes and references it." (rest of R-29 unchanged).
Verification: The finding's method: grep -n 'per Appendix A' protocol/reviewer.md → the report-structure
              line references the ledger.
Evidence:     Revised Task 6.
```

```
Finding ID:   F-hw-v4-A-006 (Minor)
Response:     Fixed
Change:       Task 1 verification strengthened exactly as recommended: the §-heading uniqueness loop now
              enumerates ALL headings mechanically from the source doc (grep -E over PROTOCOL.md is the
              loop source — the 16-item hand list is gone), and a duplicate-definition check is added:
              cat protocol/*.md | grep -oE '^\*\*R-[0-9]+[ab]?\.' | sort | uniq -d → expected empty.
              AC-N-03 now carries both guards (loss via comm -23, duplication via uniq -d).
Verification: Both strengthened checks run after T1 and emit nothing.
Evidence:     Revised Task 1 verification block; revised AC-N-03.
```

```
Finding ID:   F-hw-v4-A-007 (Minor)
Response:     Fixed
Change:       AC-F-03 / Task 11 now use the recommended deterministic fixture as the PRIMARY method:
              hand-write .heatwave/runs/<id>/state.yaml (state: EXPRESS_IMPLEMENTING, tier: EXPRESS) +
              run-record.yaml run_config for a task that in truth needs 3+ files, then resume via the
              CLI. This reproducibly exercises the R-105 implementer path and the EXPRESS_IMPLEMENTING →
              PLANNING promotion — which is what AC-F-03 asserts. An organically misclassified live run
              is a bonus observation, not the criterion.
Verification: The fixture-driven run produces Result: scope_exceeded and the promotion transition on the
              first attempt.
Evidence:     Revised AC-F-03 and Task 11 fixtures.
```

```
Finding ID:   F-hw-v4-A-008 (Nit)
Response:     Fixed
Change:       grep -lc replaced (-l with the count taken by wc -l); \s replaced by [[:space:]] — and the
              Task 8 check simplified to a plain-string grep that needs neither. All plan verification
              commands re-audited for POSIX cleanliness in the same pass.
Verification: Commands behave identically; sh-portable.
Evidence:     Revised Task 1 / Task 8 verification blocks.
```

```
Finding ID:   F-hw-v4-A-009 (Nit)
Response:     Fixed
Change:       R-109 gains the exact recommended sentence: "A review transition produces the ledger and
              its rendered report under the same sequence number NN; the pair counts as one artifact for
              §9.2 numbering." Placed in R-109 (where the pairing is defined), landed by Task 6.
Verification: Grep the amended R-109 text; AC-F-09's run dir shows paired NN numbering.
Evidence:     Revised Architecture §D (R-109) and Task 6.
```

---

## Tier

**FULL** — this change rewrites the driver (`prompts/orchestrator.md`), inverts protocol packaging (`PROTOCOL.md` becomes generated), and extends the state machine with new states and a new intake stage. It is cross-cutting by the protocol's own definition (§0.5: "cross-cutting changes … full state machine; FINAL_REVIEW checklist item-by-item"). No section below is collapsed.

## Problem Statement

Heatwave runs the same heavyweight loop for every task: even LIGHT spawns PLANNER + PLAN_REVIEW + IMPLEMENTER + REVIEWER, and every role dispatch attaches the entire 974-line `PROTOCOL.md` (`prompts/orchestrator.md`, loop step 2). Two costs: (1) no "just do it" path for trivial edits — and tier selection happens *inside* the PLANNER (R-0a), so a run pays for a planner context just to learn it didn't need one; (2) each of 5+ cold role spawns reloads the full protocol, forfeiting prompt-cache savings and making the doc itself the largest recurring token cost. Solved for: Heatwave users (the OWNER running any adapter) and the protocol's own token/latency budget.

## Functional Requirements

Per spec §4 (locked decisions honored verbatim):

1. **Intake triage** (spec §4.1): the driver classifies every new task into EXPRESS / LIGHT / STANDARD / FULL *before* any fleet spawns; sensitive paths (auth, payments/money, user data, schema/migrations, public API) force ≥ STANDARD; EXPRESS requires: no sensitive path, ≤ 2 files, no new dependency, no new public surface, single locatable edit. Tier + one-line justification recorded in run-config and run record. PLANNER may still raise (never lower); REVIEWER may raise at review (existing R-0a).
2. **EXPRESS pipeline** (spec §4.2): `EXPRESS_IMPLEMENTING → EXPRESS_CHECK → APPROVED`; the check is one cheap INDEPENDENT pass = deterministic machine gate (build + lint + relevant tests, ~0 LLM tokens) + fresh-context confirmation glance (diff matches request, nothing sensitive). Check failure or `scope_exceeded` promotes (never loops). R-1/R-2 preserved: checker is a fresh context.
3. **Design-doc gate** (spec §4.3): config `design_doc: ask | always | never`; STANDARD/FULL only; default OFF for existing repos (`never` unless asked), `ask` for greenfield; styled-Markdown template → `docs/design/<task-id>.md`; an *input to* the Planning Document, never a replacement; plan gates unchanged.
4. **Slimdown + shard** (spec §4.4): `protocol/` shards become canonical; `PROTOCOL.md` is generated by `build-protocol.sh` with a byte-equality drift self-check; each dispatch gets core + role shard(s), context ordered `[core][shard][config]` stable-prefix-first, `[artifacts]` last (cache ordering is best-effort, documented, never a correctness dependency). **Every place in the repo that asserts the old packaging or the unconditional plan-first invariant is amended in the same change** (Tasks 3, 9, 10 — complete enumeration; F-001/F-002).
5. **Findings ledger** (spec §4.5): `findings.yaml` is the machine-passed REVIEWER→FIXER→REVIEWER artifact; the prose Review Report is retained as the rendered human view.
6. **Run-config** (spec §4.6): `run_config` block in `run-record.yaml` with `tier`, `design_doc` (active) and `autonomy: autopilot`, `scope: single_repo` (RESERVED — declared, defaulted, documented; **no branching logic built** — YAGNI).

## Non-Functional Requirements

- Token/latency first-class: per-dispatch protocol payload materially smaller than 974 lines (AC-N-01); stable-prefix ordering documented in the orchestrator.
- Zero runtime dependencies: Markdown + POSIX shell only; `build-protocol.sh` uses only `sh` builtins + `cat`/`cmp`/`printf`/`mv` (AC-N-02).
- No rule lost **or duplicated** in extraction: every R-number in v3.1 survives into generated v4 exactly once (AC-N-03).
- Resume of in-flight runs unbroken: pre-v4 run dirs (no `run_config`, tier ∈ {LIGHT,STANDARD,FULL}) resume unchanged; all new run-record fields optional + defaulted (AC-F-10).

## Architecture

### A. Canonical inversion (the packaging change)

```
protocol/                      ← CANONICAL (new dir)
├── core.md                    shared spine, every dispatch
├── planner.md                 role shards, one per role
├── implementer.md
├── reviewer.md
├── fixer.md
├── final-reviewer.md
├── orchestrator.md
└── history.md                 Appendix F etc. — rendered into PROTOCOL.md, never dispatched
build-protocol.sh              concatenates shards → PROTOCOL.md; --check = drift guard
PROTOCOL.md                    ← GENERATED artifact (kept for humans, adapters, GATE.md)
```

**Locked structural decision — stable numbering:** shards keep their v3.1 section numbers and R-numbers verbatim (e.g. the planner shard contains "### 3.2 Planning Document" literally). The generated `PROTOCOL.md` therefore reads core-then-roles rather than in strict numeric order, and gains a top-of-file shard map table. Rationale (ponytail — extract, don't rewrite): every existing cross-reference in prompts, adapters, GATE.md, gate scripts, and users' heads (§3.2, R-88…) stays valid; renumbering would touch every file in the repo for zero behavior. New rules get **R-101…R-109**; new sections get new subsection numbers (§2.5, §3.2.3, §3.4.1, §4.8, §9.6, §9.7).

**Shard → v3.1 section map (exact; extraction is a pure move, MUST be disjoint — no section appears in two shards). Placement principle (F-004): a rule lives in a shard its bound role's dispatch actually loads; a rule binding two roles lives in core.**

| Shard | v3.1 sections moved in |
|---|---|
| `protocol/core.md` | Doc header; §0.1–0.4; §0.5 (tiers, R-0a/R-0b); §1.1–1.4 (R-1–R-12); §2.1–2.4 (R-13–R-15); §3.1 (R-16–R-18); **§5.4 (R-53, R-54 — implementer declares, reviewer judges; shared home, F-004)**; §6.2 (R-64–R-66); §6.4 (R-68–R-70); §8.1, §8.2, §8.4 (R-77–R-82); §9.3 (R-88–R-90) |
| `protocol/planner.md` | §3.2 excl. 3.2.1 (R-19, R-20); §3.2.2 (R-23–R-27); §4.1 (R-33, R-34); **§5.1 (R-46, R-47 — the PLANNER declares scope; PLAN_REVIEW loads this shard too per the matrix, F-004)**; §6.1 (R-62, R-63, R-98, R-99); Appendix B; Appendix C |
| `protocol/implementer.md` | §3.2.1 (R-21, R-22); §3.3 (R-28); §4.3 (R-37, R-38); §6.3 (R-67); Appendix G (R-91–R-94) |
| `protocol/reviewer.md` | §3.4 (R-29, R-30); §4.2 (R-35, R-36); §4.4 (R-39); §4.6 (R-42, R-43); §5.2 (R-48–R-50); §5.3 (R-51, R-52); §5.5 (R-55–R-57); §5.6 (R-58–R-61); §7.2 (R-71, R-72); Appendix A |
| `protocol/fixer.md` | §3.5 (R-31, R-32); §4.5 (R-40, R-41) |
| `protocol/final-reviewer.md` | §4.7 (R-44, R-45); §8.3 |
| `protocol/orchestrator.md` | §3.6; §7.1; §7.3 (R-73–R-76); §9.1 (R-83–R-85); §9.2 (R-86, R-87); §9.4 (R-95–R-97); §9.5 (R-100) |
| `protocol/history.md` | Appendix F (changes from v2) + a "changes in v4" table added by this work |

**Deduplication (deliberate slimdown, recorded here as the plan's authority):** Appendix D (report skeletons) and Appendix E (run-record schema) duplicate `templates/*.md` / `templates/run-record.yaml` byte-for-nearly-byte. In v4 they are replaced by one pointer line each — Appendix D pointer in `protocol/core.md` §3.1 ("Artifact skeletons are the files in `templates/`; they are normative"), Appendix E pointer in `protocol/orchestrator.md` §9.2 ("Run Record schema is `templates/run-record.yaml`; it is normative"). Neither appendix contains an R-number, so AC-N-03 (rule preservation) is unaffected. Appendix C (review categories) lives in the **planner** shard because the PLANNER declares scope from it; the reviewer receives the effective category list inside the Planning Document artifact itself, and PLAN_REVIEW is dispatched with the planner shard attached (dispatch matrix below).

### B. State machine extension (EXPRESS + intake)

```
START → intake (driver, R-101; writes run_config)
  ├─ EXPRESS → EXPRESS_IMPLEMENTING
  │              ├─ change made      → EXPRESS_CHECK
  │              └─ scope_exceeded   → PLANNING   [tier promoted per R-105]
  │            EXPRESS_CHECK
  │              ├─ pass → APPROVED
  │              └─ fail → PLANNING              [tier promoted to ≥ LIGHT, R-104; no fix loop]
  └─ LIGHT | STANDARD | FULL → PLANNING (existing machine, unchanged)
```

No new counters: EXPRESS never loops — any failure promotes into the normal machine, whose counters start at 0. `role-gate.sh` interaction: `EXPRESS_CHECK` joins `NO_EDIT_STATES`; `EXPRESS_IMPLEMENTING` allows edits by omission (Task 9).

### C. Dispatch matrix (replaces "attach PROTOCOL.md" in orchestrator loop step 2)

Context assembly order per dispatch — stable prefix first, dynamic last: `[protocol shards, in matrix order] [heatwave.config.yaml] [role prompt] [task artifacts]`.

| State | Prompt | Protocol context |
|---|---|---|
| intake (driver itself) | — | `core.md` + `orchestrator.md` |
| EXPRESS_IMPLEMENTING | `prompts/implementer.md` (§EXPRESS mode) | `core.md` + `implementer.md` |
| EXPRESS_CHECK | `prompts/express-checker.md` (new) | `core.md` only |
| PLANNING | `prompts/planner.md` | `core.md` + `planner.md` |
| PLAN_REVIEW | `prompts/plan-reviewer.md` | `core.md` + `reviewer.md` + `planner.md` (the contract under review, incl. §5.1/Appendix C) |
| IMPLEMENTING | `prompts/implementer.md` | `core.md` + `implementer.md` |
| FULL/TARGETED_REVIEW | `prompts/reviewer.md` | `core.md` + `reviewer.md` |
| FIXING | `prompts/fixer.md` | `core.md` + `fixer.md` |
| FINAL_REVIEW | `prompts/final-reviewer.md` | `core.md` + `reviewer.md` + `final-reviewer.md` |
| ESCALATED (report) | `prompts/reviewer.md` + escalation template | `core.md` + `reviewer.md` |

Claude Code adapter mapping (F-001): EXPRESS_IMPLEMENTING → `heatwave-implementer` subagent (EXPRESS mode); EXPRESS_CHECK → `heatwave-reviewer` subagent dispatched with `prompts/express-checker.md` — a fresh reviewer context satisfies R-1/R-2; no new agent file needed.

### D. New normative rules (exact text to be placed; Task references below)

- **R-101** (core §0.5) — *Intake classification.* The driver classifies every new task into a tier at intake, before dispatching any role, and records the tier plus a one-line justification in `run_config` and the Run Record. When a PLANNER is spawned (LIGHT+), it MAY raise the tier, never lower it; the REVIEWER MAY raise it at review (R-0a).
- **R-102** (core §0.5) — *Sensitive-path floor.* A task touching authentication, payments/money, user data, schema/migrations, or public API surface MUST be classified STANDARD or higher. EXPRESS is forbidden on these paths.
- **R-103** (core §0.5) — *EXPRESS eligibility.* EXPRESS applies only when ALL hold: no sensitive path (R-102); estimated ≤ 2 files; no new dependency; no new public surface; the change is a single, locatable edit. Any doubt resolves upward.
- **R-104** (core §2.2) — *EXPRESS pipeline.* EXPRESS runs `EXPRESS_IMPLEMENTING → EXPRESS_CHECK`. The check is performed by a context that did not make the change (R-1/R-2) and consists of (1) a deterministic machine gate — the project's build, lint, and tests relevant to the touched files — and (2) a confirmation glance — the diff does what was asked, touches ≤ 2 non-sensitive files, adds no dependency or public surface. Pass → `APPROVED`. Any failure → the driver promotes the run to LIGHT (or higher per R-102/R-103) and enters `PLANNING` with counters at 0. EXPRESS has no fix loop.
- **R-105** (implementer shard, new §4.8) — *scope_exceeded.* If the EXPRESS IMPLEMENTER finds the change larger or riskier than classified, it MUST NOT edit; it produces an EXPRESS Change note with `Result: scope_exceeded — <reason>`. The driver promotes the tier and enters `PLANNING`. This is the R-0b deviation path applied to intake misclassification.
- **R-106** (split per F-004) — *Technical design document.* **Driver half (core §2.5):** "At intake the driver resolves `design_doc` from config (`ask` | `always` | `never`; unset defaults: existing repo → `never`, greenfield/new area → `ask`, asked once) and records it in `run_config`. It applies to STANDARD/FULL only; EXPRESS and LIGHT never generate one." **Planner half (planner shard, new §3.2.3):** "When the run-config says `design_doc: true`, the PLANNER emits `docs/design/<task-id>.md` (path per `design_doc_path`) from `templates/technical-design.md` *before* the Planning Document, and the Planning Document references it. It is an input to the plan (resolution per core §2.5); acceptance criteria and every gate are unchanged by its presence."
- **R-107** (orchestrator shard, new §9.6) — *Shard dispatch.* The driver dispatches each role with `protocol/core.md` plus the role shard(s) in the dispatch matrix — never the full `PROTOCOL.md`. Context is assembled stable-prefix-first: shards, then config, then prompt, then task artifacts. The ordering is a cache optimization, never a correctness dependency.
- **R-108** (orchestrator shard, new §9.7) — *Generated protocol.* `protocol/` shards are canonical; `PROTOCOL.md` is generated by `build-protocol.sh`. Editing `PROTOCOL.md` directly is a defect. `sh build-protocol.sh --check` MUST exit 0 before a Heatwave release or install.
- **R-109** (reviewer shard, new §3.4.1) — *Findings ledger.* From v4, each FULL/TARGETED/FINAL review produces `NN-findings-K.yaml` (schema: `templates/findings-ledger.yaml`) as the machine artifact of record, alongside the prose Review Report as its rendered human view. A review transition produces the ledger and its rendered report under the same sequence number NN; the pair counts as one artifact for §9.2 numbering (F-009). The FIXER responds by finding `id`; reconciliation (R-58) and TARGETED_REVIEW are driven from the ledger's `status` fields. Appendix A field semantics are unchanged — the ledger is their compact carrier.

## API Design

The "APIs" here are file contracts between roles:

1. **`run_config` block** (in `run-record.yaml`, written by driver at intake; all fields optional with defaults for pre-v4 records):

```yaml
run_config:
  tier: EXPRESS            # EXPRESS | LIGHT | STANDARD | FULL — active
  tier_justification: ""   # one line, R-101 — active
  design_doc: false        # true | false — active (STANDARD/FULL only)
  autonomy: autopilot      # RESERVED (G/H): autopilot | gated | interactive — recorded only, no branching (YAGNI)
  scope: single_repo       # RESERVED (G): single_repo | multi_repo — recorded only, no branching (YAGNI)
```

2. **`state.yaml`** — `tier` enum gains `EXPRESS`; `state` enum gains `EXPRESS_IMPLEMENTING`, `EXPRESS_CHECK`. No new required fields (resume compatibility).
3. **EXPRESS artifacts** — `01-express-change.md` (IMPLEMENTER), `02-express-check.md` (checker); formats in Task 4 (each transition keeps its artifact, R-16).
4. **Findings ledger** — `templates/findings-ledger.yaml` schema in Task 6; paired NN numbering per R-109.
5. **Config keys** (`heatwave.config.example.yaml`) — `design_doc`, `design_doc_path`, `express.enabled`, `express.max_files`; all optional, all defaulted (Tasks 4/5).

## Data Design

No databases. On-disk YAML/Markdown schemas above are the data design. Migrations: none needed — every new field is optional with a default that reproduces v3.1 behavior (`run_config` absent ⇒ tier from `state.yaml`, `design_doc=false`, `autonomy=autopilot`, `scope=single_repo`). Verified by AC-F-10.

## State Management

Run state stays exactly where v3.1 put it: `state.yaml` (resume anchor) + append-only `run-record.yaml` (R-86/R-87). This plan adds two states and one optional block; the resume rule R-88 is untouched. No client/server state exists.

## Error Handling Strategy

- `build-protocol.sh`: `set -eu`; missing shard file ⇒ non-zero exit with the missing path on stderr; `--check` drift ⇒ exit 1 with "run: sh build-protocol.sh" instruction; generated file written via temp + atomic replace so a failed build never truncates `PROTOCOL.md`.
- EXPRESS machine gate with zero detectable checks (project has no build/lint/test): the checker MUST declare it `NOT AVAILABLE` per R-64; PASS then requires the glance alone to be conclusive, otherwise FAIL → promote to LIGHT. Never a narrated pass.
- Intake ambiguity: R-103's "any doubt resolves upward" — misclassification cost is bounded by auto-promotion (R-104/R-105), never by skipped verification.
- `install.sh`: existing idempotency preserved; new `protocol/` dir added to the refresh-on-every-run set (same `rm -rf` + `cp -R` pattern as `prompts/`).

## Security Considerations

New threat surface: EXPRESS could be used to slip a sensitive change past the full loop. Mitigations are the spec's own: R-102 denylist floor (auth/money/user-data/schema/public-API can never be EXPRESS), R-103 eligibility conjunction, the independent checker's explicit "touches nothing sensitive" glance, and promotion-on-doubt. The checker is a fresh context (R-1/R-2 hold). `install.sh` changes add no new writes outside the target's `.heatwave/` + existing adapter paths. No secrets, no network calls added.

## Edge Cases

1. EXPRESS task in a repo with no tests/lint/build → R-64 declaration; glance-only PASS allowed only when the diff is self-evidently the requested change, else promote (encoded in `prompts/express-checker.md`).
2. `scope_exceeded` on a task the driver already floor-raised → promotes to the R-102-implied tier, not blindly to LIGHT.
3. Pre-v4 in-flight run resumed by v4 driver (no `run_config`, state e.g. `FIXING`) → defaults applied, run proceeds; never re-enters intake (R-88).
4. EXPRESS check FAIL after the implementer already edited → edits remain in the working tree; the PLANNING entry documents the existing diff as input; nothing is auto-reverted (the plan/review loop now owns it).
5. `design_doc: always` on an EXPRESS/LIGHT task → ignored (R-106 scope: STANDARD/FULL only); driver records `design_doc: false`.
6. Task names ≤ 2 files but implementer discovers a third → that is `scope_exceeded` by definition (R-103 broken), not a judgment call.
7. Shard edited but `PROTOCOL.md` not regenerated → caught by `--check` (AC-F-07); install instructions and release checklist run it.
8. LIGHT combined-review flow (§0.5) — unchanged; regression-checked in AC-F-08's battery (the STANDARD run) plus existing docs examples untouched in behavior.
9. Adapter cache-ordering not honored by a tool → allowed; R-107 says best-effort, correctness never depends on ordering.
10. Driver session reads GATE.md (plan-first) while `state.yaml` says `EXPRESS_IMPLEMENTING` → no contradiction post-T9: GATE.md carries the EXPRESS carve-out (F-002).

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Extraction drops or **duplicates** a rule | Medium | AC-N-03 loss + duplication checks (`comm -23` + `uniq -d`, F-006); mechanical all-headings uniqueness loop in T1; Task 1 is a pure move reviewed before any content change |
| EXPRESS misclassification ships a bad change | Low | R-102/R-103/R-104 triple guard + machine gate + fresh-context glance; failure path is promotion, not approval |
| A stale instruction file (adapter shim, GATE.md, agent def) still asserts old packaging or unconditional plan-first, contradicting EXPRESS | Was Medium; now Low | Task 9 enumerates the complete repo-wide grep output (26 + 13 hits, both sweeps reproduced in-task) with per-file exact edits; exit checks are the two sweep greps from F-001/F-002; AC-F-12 gates on them repo-wide |
| Breaking resume of in-flight runs | Low | All new fields optional+defaulted; AC-F-10 live fixture test |
| `install.sh` regression (it rewrites user projects) | Medium | Idempotent pattern reused verbatim; AC-F-11 installs twice into a scratch dir and asserts no duplication |
| Generated-doc readability regression (sections out of numeric order) | Certain, accepted | Shard map table at top of generated doc; stable §/R numbers preserve every cross-reference — explicitly chosen over renumbering (spec alternative 5: extract, don't rewrite) |

## Dependencies

Internal: none beyond this repo. External: none added (hard constraint). Existing: POSIX `sh`, `cat`, `cmp`, `printf`, `mv`, `awk`, `git` — all verified present on this machine. Live verification depends on the Claude Code CLI (verified: `claude` 2.1.226 at `/Users/abhirajsinha/.local/bin/claude`).

## Testing Strategy

Heatwave is Markdown + shell; per spec §8 "tests" are (a) **deterministic self-checks** — `build-protocol.sh --check`, `sh -n` syntax checks, grep/comm/uniq structural assertions with exact expected output, and (b) **scripted live-adapter runs** against a throwaway target repo (created under the scratchpad, installed via `./install.sh <target> claude`, driven by the `claude` CLI), inspecting run-dir artifacts as evidence, with hand-written run-dir fixtures where a precondition must be deterministic (F-007). Who runs what: IMPLEMENTER runs all per-task checks in Tasks 1–10 and the battery in Task 11; REVIEWER re-runs the deterministic checks and spot-re-runs at least AC-F-01 and AC-F-08 live. No shellcheck (NOT AVAILABLE — see Tooling Declaration); shell scripts get `sh -n` + a restricted-PATH execution check instead.

## Rollout Plan

Single repo, no flags, no staging. Land as one reviewed commit series on `master` in task order (each task independently reviewable). `install.sh` consumers pick up v4 on their next install run (documented behavior: protocol files refresh, user config never touched). No coordination with in-flight runs needed beyond AC-F-10's compatibility guarantee.

## Rollback Plan

`git revert <first-task-commit>..<last-task-commit>` restores v3.1 exactly (repo is self-contained; no external state). For an already-upgraded target project: re-run `install.sh` from the reverted checkout — it refreshes `.heatwave/prompts`, `templates`, `PROTOCOL.md` and removes nothing user-owned; the orphaned `.heatwave/protocol/` dir is inert (nothing in v3.1 reads it) and the revert commit message documents `rm -rf .heatwave/protocol` as the optional cleanup. In-flight runs are unaffected in both directions because v4 fields are optional.

---

## Task-by-Task Implementation Plan

Execution order: T1 → T2 → T3 → {T4, T5, T6, T7 in any order} → T8 → T9 → T10 → T11. Each task = one commit, independently reviewable. Global constraints on every task: POSIX sh + Markdown only, no new dependencies; smallest diff (ponytail — extract, don't rewrite); stable §/R numbering; regenerate `PROTOCOL.md` (`sh build-protocol.sh`) in every task from T2 on that touches a shard, in the same commit.

### Task 1 — Extract shards (pure move, zero content change)

**Create:** `protocol/core.md`, `protocol/planner.md`, `protocol/implementer.md`, `protocol/reviewer.md`, `protocol/fixer.md`, `protocol/final-reviewer.md`, `protocol/orchestrator.md`, `protocol/history.md`.
**Modify:** nothing yet (`PROTOCOL.md` untouched until T2).

Move v3.1 sections verbatim per the shard map table above (exact §s and R-numbers listed there; note §5.4 → core and §5.1 → planner per F-004), including each rule's `> Rationale` block, which travels with its rule. Each shard opens with a 2-line header: `# Heatwave Protocol — <shard name> (canonical shard)` + `Loaded by: <dispatch states per matrix>. Section/rule numbers are global to the protocol.` Appendix D and E bodies are NOT moved; their replacement pointer lines land in T2's generation (core §3.1 and orchestrator §9.2, exact wording in Architecture §A).

**Interface produced:** the eight canonical shard files. **Consumes:** v3.1 `PROTOCOL.md`.
**Verification (exact; strengthened per F-006, POSIX-clean per F-008 — heading enumeration is mechanical, not hand-picked):**
```sh
cd /Users/abhirajsinha/Projects/heatwave
# 1. No rule lost:
grep -oE 'R-[0-9]+' PROTOCOL.md | sort -u > /tmp/hw-rules-v31
cat protocol/*.md | grep -oE 'R-[0-9]+' | sort -u > /tmp/hw-rules-shards
comm -23 /tmp/hw-rules-v31 /tmp/hw-rules-shards          # expected output: empty
# 2. No rule DEFINITION duplicated across shards:
cat protocol/*.md | grep -oE '^\*\*R-[0-9]+[ab]?\.' | sort | uniq -d   # expected output: empty
# 3. Every numbered §-heading from the source appears in exactly one shard (mechanical enumeration):
grep -E '^#{2,4} [0-9]+(\.[0-9]+)* ' PROTOCOL.md | sort -u | while IFS= read -r h; do
  n=$(grep -F -l -- "$h" protocol/*.md | wc -l)
  [ "$n" -eq 1 ] || echo "DUP/MISSING: $h (in $n shards)"
done                                                      # expected output: nothing
```

### Task 2 — `build-protocol.sh` + generated `PROTOCOL.md` + drift check

**Create:** `build-protocol.sh` (repo root, executable). Full content:

```sh
#!/bin/sh
# build-protocol.sh — PROTOCOL.md is GENERATED from the canonical protocol/ shards (R-108).
# Usage: sh build-protocol.sh          regenerate PROTOCOL.md
#        sh build-protocol.sh --check  exit 1 if PROTOCOL.md drifts from the shards
set -eu
cd "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
ORDER="core planner implementer reviewer fixer final-reviewer orchestrator history"
OUT=PROTOCOL.md
TMP=$OUT.build.$$
trap 'rm -f "$TMP"' EXIT
{
  printf '<!-- GENERATED FILE — do not edit. Canonical source: protocol/*.md. Rebuild: sh build-protocol.sh -->\n\n'
  first=1
  for s in $ORDER; do
    [ -f "protocol/$s.md" ] || { echo "error: missing shard protocol/$s.md" >&2; exit 1; }
    [ "$first" = 1 ] || printf '\n---\n\n'
    first=0
    cat "protocol/$s.md"
  done
} > "$TMP"
if [ "${1:-}" = "--check" ]; then
  if cmp -s "$TMP" "$OUT"; then echo "OK: PROTOCOL.md matches protocol/ shards"; exit 0; fi
  echo "DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh" >&2; exit 1
fi
mv "$TMP" "$OUT"; trap - EXIT
echo "generated $OUT from protocol/ shards"
```

**Modify:** `PROTOCOL.md` — becomes the T2 generator's output (version header inside `protocol/core.md` bumps to `**Version:** 4.0`, supersedes 3.1; core also gains the shard-map table right after the header, and the Appendix D pointer in §3.1; `protocol/orchestrator.md` gains the Appendix E pointer in §9.2).
**Interface produced:** `sh build-protocol.sh` / `--check` (consumed by T9 install docs, T11, releases).
**Verification (exact):**
```sh
sh -n build-protocol.sh                                   # expected: no output, exit 0
env PATH=/usr/bin:/bin sh build-protocol.sh --check       # expected: "OK: PROTOCOL.md matches protocol/ shards", exit 0 (also proves zero-dep)
printf '\n' >> protocol/fixer.md && sh build-protocol.sh --check; echo "exit=$?"   # expected: DRIFT message, exit=1
git restore protocol/fixer.md PROTOCOL.md
git show HEAD:PROTOCOL.md | grep -oE 'R-[0-9]+' | sort -u > /tmp/old
grep -oE 'R-[0-9]+' PROTOCOL.md | sort -u > /tmp/new
comm -23 /tmp/old /tmp/new                                # expected: empty (AC-N-03 loss guard)
```

### Task 3 — Core v4 content: EXPRESS tier, states, transitions, run-config

**Modify:** `protocol/core.md` (then regenerate). Exact additions/amendments:

0. **§0.5 preamble replaced (F-002).** Old: "Ceremony scales to the change; the gates do not. Every tier keeps all four gates: a plan reviewed by a separate context, distinct role contexts, evidence over assertion, and the completion gate (Section 8). What a tier changes is how much of the Planning Document must be written out." New: "Ceremony scales to the change; independent verification does not. Every tier except EXPRESS keeps all four gates: a plan reviewed by a separate context, distinct role contexts, evidence over assertion, and the completion gate (Section 8) — what those tiers change is how much of the Planning Document must be written out. EXPRESS (v4) drops the plan and its review but substitutes its own independent gate: a deterministic machine check plus a confirmation glance by a fresh context that did not make the change (R-104). No tier, including EXPRESS, ever lets a context approve its own work."
1. §0.5 tier table gains a first row:
   `| **EXPRESS** *(v4)* | A single obvious edit: copy, label, color, config value, typo. No new surface. | None — no Planning Document. | No PLAN_REVIEW. IMPLEMENTER makes the change; one independent EXPRESS_CHECK (deterministic machine gate + fresh-context confirmation glance) gates APPROVED. Any failure promotes to LIGHT — EXPRESS never loops. |`
2. §0.5 gains rules **R-101, R-102, R-103** — exact text in Architecture §D.
3. §2.1 states table gains: `EXPRESS_IMPLEMENTING | IMPLEMENTER | EXPRESS Change note produced` and `EXPRESS_CHECK | independent checker | EXPRESS Check report produced`.
4. §2.2 transition diagram gains the EXPRESS branch exactly as drawn in Architecture §B, plus **R-104**.
5. New **§2.5 Run-config**: the `run_config` YAML block from API Design §1 verbatim; the **driver half of R-106** (exact text in Architecture §D — design_doc resolution lives here, loaded by the intake dispatch, F-004); plus: "Only `tier`, `tier_justification`, and `design_doc` drive behavior. `autonomy` and `scope` are RESERVED for sub-projects G/H: recorded with defaults that reproduce current behavior, consulted by nothing (YAGNI). A Run Record without a `run_config` block (pre-v4) is read as `tier` from `state.yaml`, `design_doc: false`, `autonomy: autopilot`, `scope: single_repo`."

**Verification:** `sh build-protocol.sh --check` exits 0 after regeneration; `grep -c 'EXPRESS' protocol/core.md` ≥ 10; `grep -n 'R-101\|R-102\|R-103\|R-104\|except EXPRESS' protocol/core.md` shows all four new rules + amended preamble; `grep -rn 'keeps all four gates' PROTOCOL.md protocol/` → every hit reads "except EXPRESS keeps" (F-002 method); `git diff --name-only` = `protocol/core.md`, `PROTOCOL.md` only.

### Task 4 — EXPRESS pipeline: prompts, templates, implementer shard

**Create:** `templates/express-change.md`:

```markdown
# EXPRESS Change

task_id: | artifact_type: express-change | produced_by: IMPLEMENTER (<model>) | timestamp:

## Request
<the task, one line>

## Result
done | scope_exceeded — <reason: which R-103 condition broke> (R-105)

## Change
<files touched (≤ 2) + the diff; empty if scope_exceeded>

## Self-run checks
<build/lint/relevant-test commands + real output, or `NOT AVAILABLE — <reason>` per R-64>
```

**Create:** `templates/express-check.md`:

```markdown
# EXPRESS Check

task_id: | artifact_type: express-check | produced_by: CHECKER (<model>, fresh context) | timestamp:

## Verdict
PASS | FAIL — <one line>

## Machine gate
<commands run + real output; each unavailable check declared per R-64>

## Confirmation glance
- Diff does what was asked, nothing else: yes/no — <evidence>
- ≤ 2 files, none sensitive (R-102): yes/no — <files>
- No new dependency / public surface (R-103): yes/no
```

**Create:** `prompts/express-checker.md`:

```markdown
# Heatwave — EXPRESS CHECK (independent verifier)

You are a fresh context verifying an EXPRESS change (core §2.2, R-104). You did not write it and you never fix it. Input: the task statement, `01-express-change.md`, the diff. Output: `02-express-check.md` from `.heatwave/templates/express-check.md`.

1. **Machine gate (primary, deterministic):** run the project's build, lint, and the tests relevant to the touched files — detected from the project (package.json scripts, pytest.ini, go.mod, CI workflows) or `heatwave.config.yaml`. Attach real output. A check that does not exist is declared `NOT AVAILABLE` (R-64) — never narrated as run.
2. **Confirmation glance:** read the diff. Confirm it does what the task asked and nothing else; touches ≤ 2 files, none on the sensitive-path denylist (R-102); adds no dependency and no public surface (R-103).

Verdict: **PASS** only if the machine gate passes (or is fully NOT AVAILABLE *and* the diff is self-evidently the requested change) AND every glance item is yes. Anything else is **FAIL** — the driver promotes the run to LIGHT and enters PLANNING (R-104). Your final message is the artifact path plus the verdict line.
```

**Modify:** `prompts/implementer.md` — append an `## EXPRESS mode` section: "When dispatched in `EXPRESS_IMPLEMENTING`: make the single requested change (ponytail fully applies), run whatever build/lint/relevant tests exist and attach output, produce `01-express-change.md` from `.heatwave/templates/express-change.md`. If any R-103 condition breaks while working — a third file, a new dependency, new surface, a sensitive path — STOP without editing further and set `Result: scope_exceeded — <reason>` (R-105). No Implementation Package, no Planning Document."
**Modify:** `protocol/implementer.md` shard — new **§4.8 EXPRESS_IMPLEMENTING** carrying R-105 (exact text in Architecture §D) + one paragraph binding EXPRESS mode to ponytail and R-64/R-65 evidence rules. Regenerate.
**Modify:** `heatwave.config.example.yaml` — add under a new `# --- EXPRESS tier (§0.5, R-103) ---` comment block: `# express:` / `#   enabled: true` / `#   max_files: 2`.
**Verification:** `sh build-protocol.sh --check` → OK; `grep -n 'scope_exceeded' protocol/implementer.md prompts/implementer.md templates/express-change.md` → present in all three; both new templates contain `R-64`; `grep -n 'express' heatwave.config.example.yaml` → block present.

### Task 5 — Design-doc gate

**Create:** `templates/technical-design.md` (styled Markdown — git-native; the spec's locked section list exactly):

```markdown
# <Task title> — Technical Design

| | |
|---|---|
| **Task** | `<task-id>` |
| **Status** | Draft |
| **Tier** | STANDARD \| FULL |
| **Date** | <date> |
| **Author** | PLANNER (<model>) |

> One-paragraph summary of what this designs and why.

## Context
## Goals / Non-goals
**Goals:**
**Non-goals:**
## Architecture
<components, boundaries; Mermaid diagrams welcome — they render on GitHub>
## Data flow
## Alternatives considered
| Alternative | Why not |
|---|---|
## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
## Test strategy
```

**Modify:** `protocol/planner.md` shard — new **§3.2.3 Technical design document** carrying the **planner half of R-106** (exact text in Architecture §D; the driver half lands in core §2.5 via Task 3 — F-004). Regenerate.
**Modify:** `prompts/planner.md` — add: "If the run-config says `design_doc: true`: first emit the technical design from `.heatwave/templates/technical-design.md` to `<design_doc_path>/<task-id>.md` (default `docs/design/`), commit-ready, then write the Planning Document referencing it (R-106). The design doc feeds the plan; it replaces nothing and changes no gate."
**Modify:** `heatwave.config.example.yaml` — add: `# --- Technical design docs (STANDARD/FULL only, R-106) ---` / `# design_doc: ask        # ask | always | never; unset = never for existing repos, ask for greenfield` / `# design_doc_path: docs/design`.
**Verification:** `sh build-protocol.sh --check` → OK; `grep -n 'R-106' protocol/planner.md protocol/core.md prompts/planner.md` → all three (both halves of the split landed); `grep -c '^## ' templates/technical-design.md` → 7 (the seven locked sections).

### Task 6 — Findings ledger

**Create:** `templates/findings-ledger.yaml`:

```yaml
# Heatwave findings ledger — the machine artifact of record for a review round (R-109).
# The prose Review Report with the same sequence number is its rendered human view.
# Field semantics are Appendix A's; `verification` is consumed by R-32.
task_id:
iteration:
review_type:        # FULL_REVIEW | TARGETED_REVIEW | FINAL_REVIEW | FULL_FINAL_REVIEW (LIGHT)
produced_by:
verdict:            # GATE_MET | GATE_NOT_MET
findings: []
  # - id: F-<task_id>-001        # stable for the task's lifetime (R-55)
  #   severity: Blocker          # Blocker | Major | Minor | Nit
  #   category: business-logic   # Appendix C, or blast-radius | acceptance-criteria | over-engineering
  #   file: src/x.ts
  #   line: 42
  #   problem: <one line, observable>
  #   why: <one line — justifies the severity (R-80)>
  #   fix: <one line, actionable>
  #   verification: <executable method — R-32 makes the FIXER run it>
  #   evidence_ref: <artifact/section or command output reference>
  #   introduced: 1
  #   status: open               # open | fixed | deferred_approved | waived_owner | disputed
```

**Modify:** `protocol/reviewer.md` shard — new **§3.4.1** carrying **R-109** (Architecture §D, incl. the paired-NN numbering sentence, F-009); **amend §3.4 structure item 6 (F-005)** from "6. Findings — per Appendix A" to "6. Findings — summary per finding; canonical Appendix-A detail lives in the findings ledger (R-109)"; **amend R-29's first sentence (F-005)** to "Findings MUST use the Appendix A schema, carried in the findings ledger from v4 (R-109); the report's Findings section summarizes and references it." (rest of R-29 unchanged). **Modify:** `prompts/reviewer.md` and `prompts/final-reviewer.md` — output becomes "the findings ledger (`NN-findings-K.yaml`, from `.heatwave/templates/findings-ledger.yaml`) plus the Review Report as its rendered view — findings live in the ledger; the report's Findings section summarizes and points to it". **Modify:** `prompts/fixer.md` — input line gains "the findings ledger; respond per ledger `id`". **Modify:** `templates/review-report.md` — Findings section body becomes: `<summary per finding; canonical detail lives in NN-findings-K.yaml (R-109)>`. Regenerate.
**Verification:** `sh build-protocol.sh --check` → OK; `grep -n 'per Appendix A' protocol/reviewer.md` → the report-structure line references the ledger (F-005 method); `grep -l 'findings-ledger\|R-109' protocol/reviewer.md prompts/reviewer.md prompts/final-reviewer.md prompts/fixer.md templates/review-report.md templates/findings-ledger.yaml | wc -l` → 6.

### Task 7 — Run-record / state schema + resume defaults

**Modify:** `templates/run-record.yaml` — `tier` comment becomes `# EXPRESS | LIGHT | STANDARD | FULL`; insert the `run_config` block (API Design §1, all fields present with defaults, `autonomy`/`scope` commented as RESERVED). **Modify:** `protocol/orchestrator.md` shard §9.2 — `state.yaml` snippet's `tier` comment gains EXPRESS; `state` comment references §2.1 (which now includes the two EXPRESS states); add one sentence: "A run directory created before v4 (no `run_config`) resumes with the §2.5 defaults; the driver MUST NOT rewrite old records to add the block." Regenerate.
**Verification:** `sh build-protocol.sh --check` → OK; `grep -n 'run_config' templates/run-record.yaml protocol/orchestrator.md` → both; `grep -n 'EXPRESS' templates/run-record.yaml` → tier comment updated.

### Task 8 — Orchestrator prompt rewrite (intake, dispatch matrix, EXPRESS loop)

**Modify:** `prompts/orchestrator.md` (the largest behavioral diff; everything else it says today — resume rule, keep-awake, R-98 mobile question, non-stop rules, hard rules — stays). Its own protocol citations are reworded to shard-relative form ("core §2.1", "orchestrator shard §9.2") in this same task (F-003):

1. **New "## Intake (new tasks only, before any dispatch)" section:** classify per R-101–R-103 (denylist first, then EXPRESS conjunction, else LIGHT/STANDARD/FULL per core §0.5); resolve `design_doc` per core §2.5 (config; when `ask`, ask the owner once alongside the existing R-98 question); write `run_config` into `run-record.yaml` and tier into `state.yaml`; EXPRESS → `state: EXPRESS_IMPLEMENTING`, else `state: PLANNING`.
2. **Loop step 2 replaced** with the dispatch matrix from Architecture §C, verbatim as a table, prefixed by: "Assemble each dispatch stable-prefix-first — `[protocol shards, matrix order][heatwave.config.yaml][role prompt][task artifacts]` — an identical prefix across dispatches is prompt-cache-friendly (R-107). Never attach the full protocol document to a role."
3. **New "## EXPRESS path" section:** dispatch implementer (EXPRESS mode) → on `Result: done`, dispatch `prompts/express-checker.md` in a fresh context → PASS ⇒ `APPROVED` (record checker identity + timestamp in run record, R-82 analog); FAIL or `scope_exceeded` ⇒ set tier per R-104/R-105 with justification appended in the run record, `state: PLANNING`, continue the normal loop. Both artifacts + transitions recorded (R-16, R-87) so the run resumes anywhere (R-88).
4. **Step 5 (LIGHT combined pass)** — unchanged, restated against the matrix.

**Verification (POSIX-clean per F-008):** `grep -c 'protocol/core.md' prompts/orchestrator.md` ≥ 2; `grep -n 'EXPRESS_CHECK' prompts/orchestrator.md && grep -n 'scope_exceeded' prompts/orchestrator.md && grep -n 'run_config' prompts/orchestrator.md` → all present; the old full-doc attachment and every full-doc citation are gone: `grep -n 'PROTOCOL.md' prompts/orchestrator.md` → empty (F-003).

### Task 9 — install.sh + adapters + repo-wide reference/invariant amendment (F-001, F-002, F-003)

Scope: attachment instructions, reading instructions, **and invariant statements** — the complete repo-wide grep output, not a subset. Sweep basis (captured this session): `grep -rn "PROTOCOL.md" prompts/ adapters/ README.md docs/ COMPANIONS.md install.sh` → 26 non-spec hits; `grep -rni "before an approved plan\|before a Planning Document\|keeps all four gates\|not a skipped\|before any code is written" …` → 13 hits. The files below are the full offender list; the task's exit checks re-run both sweeps so nothing new slips in.

**Modify — scripts:**
- `install.sh` — refresh block: `rm -rf "$HW/prompts" "$HW/templates" "$HW/plugins" "$HW/protocol"` and add `cp -R "$SRC/protocol" "$HW/"` next to the existing `cp "$SRC/PROTOCOL.md"` (kept — the generated doc remains the human-readable spec).
- `adapters/claude-code/role-gate.sh` — `NO_EDIT_STATES` gains `"EXPRESS_CHECK"` (EXPRESS_IMPLEMENTING allows edits by omission).

**Modify — six role prompts (F-003):** `prompts/{planner,plan-reviewer,implementer,reviewer,fixer,final-reviewer}.md` — every "per PROTOCOL.md §x" becomes "per protocol §x (in your attached shards)". Exit check: `grep -rn 'PROTOCOL.md' prompts/` → empty (orchestrator done in T8).

**Modify — claude-code adapter (F-001, F-002):** `adapters/claude-code/HEATWAVE.md`:
- line 5 → "Full rendered spec: `.heatwave/PROTOCOL.md` (generated). As driver you read `.heatwave/protocol/core.md` + `.heatwave/protocol/orchestrator.md`; roles receive their shards per the dispatch matrix."
- line 15 → "Pass each subagent only its prompt file, `.heatwave/protocol/core.md` plus its role shard(s) per the dispatch matrix in `prompts/orchestrator.md`, the permitted artifacts (R-3), and `heatwave.config.yaml` — never another role's transcript, never the full rendered spec (R-107)."
- state→subagent map gains: `EXPRESS_IMPLEMENTING → heatwave-implementer (EXPRESS mode, prompts/implementer.md §EXPRESS)` and `EXPRESS_CHECK → heatwave-reviewer (with prompts/express-checker.md — fresh context, R-1/R-2)`.
- line 17 → "…not even 'just this once' for a small task. Small tasks use the EXPRESS or LIGHT tier, not a skipped protocol."
- line 27 → "Plan first: no implementation before a Planning Document passes PLAN_REVIEW (0 Blockers, 0 Majors) — except the EXPRESS tier, where one independent machine-gated check gates APPROVED (R-104)."

`adapters/claude-code/GATE.md` — two replacements: "read `.heatwave/protocol/core.md` + `.heatwave/protocol/orchestrator.md` before writing code (full rendered spec: `.heatwave/PROTOCOL.md`)" and "No code before a Planning Document passes PLAN_REVIEW at 0 Blockers / 0 Majors — except the EXPRESS tier, where one independent machine-gated check gates APPROVED (R-104)."

`adapters/claude-code/.claude/agents/heatwave-planner.md` → cites "`.heatwave/protocol/core.md` + `.heatwave/protocol/planner.md`"; `heatwave-implementer.md` → core + implementer shard, description gains EXPRESS_IMPLEMENTING; `heatwave-reviewer.md` → core + reviewer (+ final-reviewer) shards, description and prompt list gain "EXPRESS_CHECK via `.heatwave/prompts/express-checker.md`".

**Modify — generic + codex (F-002):** `adapters/generic/HEATWAVE-AGENT.md` line 6 → "Full rendered spec: `.heatwave/PROTOCOL.md`. Your working set: `.heatwave/protocol/core.md` + the shard for your role (`.heatwave/protocol/`)."; single-context role list gains "EXPRESS checker (`.heatwave/prompts/express-checker.md`) — a fresh session that did not make the change"; line 23 → "No implementation before a Planning Document passes PLAN_REVIEW with 0 Blockers / 0 Majors — except the EXPRESS tier: one independent machine-gated check gates APPROVED (R-104)." `adapters/codex/AGENTS.md` line 10 → "2. `.heatwave/protocol/core.md` + the shard for your role — the full rendered spec is `.heatwave/PROTOCOL.md`."; line 12 summary → "…no implementation before an approved plan (EXPRESS tier excepted: one independent machine-gated check gates APPROVED, R-104)…".

**Modify — remaining shims (F-001; same two-line pattern each):** `adapters/gemini/GEMINI.md` (lines 10, 12), `adapters/cursor/heatwave.mdc` (13, 15), `adapters/copilot/copilot-instructions.md` (10, 12), `adapters/windsurf/heatwave.md` (10, 12), `adapters/cline/heatwave.md` (5, 7), `adapters/zed/rules` (5, 7), `adapters/aider/CONVENTIONS.md` (5, 7): the "read the full spec" line gains "— your working set is `.heatwave/protocol/core.md` + your role's shard", and the summary sentence gains the EXPRESS exception clause verbatim from the codex edit.

**Modify — adapter docs:** `adapters/README.md` line 3 ("Everything else — the `protocol/` shards and generated PROTOCOL.md, prompts, templates, the run directory — is identical for every agent."), line 29 (point new tools at `.heatwave/protocol/core.md` + role shard, full spec as reference), line 30 (summary list gains "EXPRESS carve-out").

**Verification (the two sweep greps are the exit gate — F-001/F-002 methods adopted verbatim):**
```sh
sh -n install.sh && sh -n adapters/claude-code/role-gate.sh          # expected: exit 0, no output
grep -rn "PROTOCOL.md" prompts/ adapters/ | grep -v "full rendered spec" | grep -v "generated"
   # expected: empty — no remaining attach/read instruction; every surviving mention is a documented pointer
grep -rn "before a Planning Document\|before an approved plan\|keeps all four gates" adapters/ prompts/
   # expected: every hit contains "EXPRESS" on the same line
grep -n EXPRESS adapters/claude-code/HEATWAVE.md                     # expected: non-empty (map rows + boundary + plan-first carve-out)
grep -n 'EXPRESS_CHECK' adapters/claude-code/role-gate.sh            # expected: in NO_EDIT_STATES
T=$(mktemp -d); ./install.sh "$T" claude >/dev/null; ls "$T/.heatwave/protocol" | wc -l   # expected: 8
ls "$T/.heatwave/templates" | grep -c 'express\|findings\|technical' # expected: 4
./install.sh "$T" claude > /tmp/rerun.log; grep -c 'skipped' /tmp/rerun.log  # expected ≥ 1 (idempotent, AC-F-11)
grep -c 'Heatwave protocol (binding)' "$T/CLAUDE.md"                 # expected: 1 (no duplicate block)
```

### Task 10 — Docs + version

**Modify:** `README.md` line 85 tier sentence gains EXPRESS ("A trivial edit runs **EXPRESS**: the change plus one independent machine-gated check — no planner at all."); `docs/faq.md` line 7 (F-002, planner-found hit) — "the plan is still reviewed before any code is written" becomes "…for every tier except EXPRESS, whose gate is an independent machine-checked verification instead of a plan (R-104)", plus the EXPRESS one-liner; `docs/loop.md` diagram gains the EXPRESS branch; `docs/getting-started.md` — grep-verify, update only if it names the tier list. Add a "v4.0" row to `protocol/history.md` change table (EXPRESS · intake triage · shards canonical/generated PROTOCOL.md · findings ledger · run-config · design-doc gate). Regenerate.
**Verification:** `sh build-protocol.sh --check` → OK; `grep -rn 'EXPRESS' README.md docs/faq.md docs/loop.md | wc -l` ≥ 3; `grep -n 'Version.*4.0' PROTOCOL.md` → present; `grep -rn "before any code is written" docs/` → hit contains EXPRESS qualifier.

### Task 11 — Live verification battery (evidence for the ACs)

**Create nothing in this repo** (evidence lands in the run dir / scratchpad). Build a throwaway target: `mkdir $SCRATCH/hw-target && cd $_ && git init && npm init -y`, one `src/button.css` (`color: red`), one `src/auth/login.js`, a `package.json` `test` script that exits 0, `./install.sh $SCRATCH/hw-target claude`. Drive each scenario with the `claude` CLI (headless: `claude -p "<task>" --permission-mode acceptEdits` from the target dir) and collect run-dir evidence per the AC table. **Fixtures (deterministic preconditions, F-007):** (a) AC-F-03: hand-write `.heatwave/runs/<id>/state.yaml` (`state: EXPRESS_IMPLEMENTING`, `tier: EXPRESS`) + `run-record.yaml` with `run_config` for a task that in truth requires 3+ files, then resume — first-attempt-reproducible exercise of R-105 and the promotion transition; (b) AC-F-10: hand-write a v3.1-format run dir (state `FIXING`, tier `STANDARD`, no `run_config`) before the resume scenario. Each scenario's evidence = the target's `.heatwave/runs/<id>/` contents + transcript.

---

## Acceptance Criteria

### Functional

| ID | Spec §8 item | Criterion | Verification (concrete) |
|---|---|---|---|
| AC-F-01 | 1 | An EXPRESS-eligible task ("change the button color from red to white in src/button.css") runs implementer + independent check only and ends APPROVED | Live run (T11). Assert in the run dir: `ls` shows `01-express-change.md` + `02-express-check.md` and **no** `*planning-document*`/`*plan-review*` file; `state.yaml` → `state: APPROVED`, `tier: EXPRESS`; transcript shows no planner/plan-reviewer dispatch |
| AC-F-02 | 2 | A "small" auth-touching task ("change session timeout in src/auth/login.js") is refused EXPRESS and classified ≥ STANDARD | Live run. `grep -A3 run_config .heatwave/runs/<id>/run-record.yaml` → `tier: STANDARD` (or FULL) with justification citing the sensitive path; first artifact is `01-planning-document.md` |
| AC-F-03 | 3 | An EXPRESS run whose change in truth needs 3+ files promotes via `scope_exceeded` | **Fixture-driven, deterministic (F-007):** resume the hand-written EXPRESS_IMPLEMENTING fixture (T11a). Assert: `01-express-change.md` has `Result: scope_exceeded` and no source diff; run-record shows transition `EXPRESS_IMPLEMENTING → PLANNING` with promoted tier. First-attempt reproducible |
| AC-F-04 | 4 | STANDARD task with `design_doc: always` in config produces `docs/design/<task-id>.md` referenced by the Planning Document | Live run. `test -f docs/design/<task-id>.md` in target; `grep -l 'design/' .heatwave/runs/<id>/*planning-document*` non-empty; file contains the 7 template sections |
| AC-F-05 | 4 | Same task with `design_doc: never` produces no design doc | Live run. `ls docs/design/ 2>/dev/null` empty/absent; run-record `design_doc: false` |
| AC-F-06 | 5 | Role dispatches load core + shard(s) and never reference the full PROTOCOL.md (respecified per F-003 — satisfiable) | (1) Static: after T8+T9, `grep -rn 'PROTOCOL.md' prompts/` → 0 hits. (2) Live: a T11 dispatch payload (transcript) contains `.heatwave/protocol/core.md` + the matrix shard(s) for that state, and `grep -c 'PROTOCOL.md'` over that payload = 0 — passable because T8/T9 removed every prompt citation. Substantive size check: AC-N-01 |
| AC-F-07 | 6 | Drift self-check: committed PROTOCOL.md is byte-identical to regenerated | `sh build-protocol.sh --check` → "OK…", exit 0; after `printf '\n' >> protocol/fixer.md` → exit 1 with DRIFT message; restore via `git restore` |
| AC-F-08 | 7 | Full-loop regression: a STANDARD feature ("add a /health note file with tested generator script") completes PLANNING → … → APPROVED | Live run. Run dir contains planning doc, plan review, implementation package, review report(s), final review; `state.yaml` terminal `APPROVED`; run-record transitions complete |
| AC-F-09 | 8 | A review round emits the findings ledger; fixer answers by id; ledger drives TARGETED_REVIEW | In the AC-F-08 run (seed one deliberate flaw so a finding exists): `NN-findings-1.yaml` present, paired with the review report under the same NN (R-109), grep-conforms to template keys (`id:`, `severity:`, `status:`); fix report responds to the same `F-<task>-NNN` ids; targeted-review artifact reconciles by id |
| AC-F-10 | resume | Pre-v4 run dirs resume unchanged | Fixture v3.1 run dir (state `FIXING`, no `run_config`); resume via `claude -p "continue the run"`; assert driver proceeds in FIXING (next artifact is a fix report), never re-enters intake/PLANNING, old record not rewritten (`grep -c run_config run-record.yaml` = 0 for the fixture) |
| AC-F-11 | packaging | install.sh ships shards + new templates, idempotently | Task 9 verification block: fresh install lists 8 shard files + 4 new templates; second run prints `skipped` lines and produces no duplicate blocks (`grep -c 'Heatwave protocol (binding)' $T/CLAUDE.md` = 1) |
| AC-F-12 | consistency (F-001/F-002) | No file in the repo asserts the pre-v4 packaging or an unqualified plan-first invariant | Repo-wide sweeps: `grep -rn "before a Planning Document\|before an approved plan\|keeps all four gates" PROTOCOL.md protocol/ adapters/ prompts/ docs/ README.md` → every hit EXPRESS-qualified or in `protocol/history.md`; `grep -rn "PROTOCOL.md" prompts/ adapters/ \| grep -v "full rendered spec" \| grep -v "generated"` → empty |

### Non-functional

| ID | Criterion | Verification |
|---|---|---|
| AC-N-01 | Per-dispatch protocol payload shrinks: `wc -l protocol/core.md protocol/implementer.md` total ≤ 450 lines (vs 974 baseline, ≥ 50% cut for the modal IMPLEMENTING dispatch); every matrix row's shard total < 974 | `wc -l` on each matrix row's shard set; numbers recorded in the Implementation Package |
| AC-N-02 | Zero new runtime dependencies; all shell POSIX | `sh -n build-protocol.sh install.sh adapters/claude-code/role-gate.sh` exit 0; `env PATH=/usr/bin:/bin sh build-protocol.sh --check` exit 0; `git diff <pre-T1>..HEAD --stat` shows no package manifests added |
| AC-N-03 | No v3.1 rule lost **or duplicated** in extraction (F-006) | Loss: `git show <pre-T1>:PROTOCOL.md \| grep -oE 'R-[0-9]+' \| sort -u > /tmp/old; grep -oE 'R-[0-9]+' PROTOCOL.md \| sort -u > /tmp/new; comm -23 /tmp/old /tmp/new` → empty. Duplication: `cat protocol/*.md \| grep -oE '^\*\*R-[0-9]+[ab]?\.' \| sort \| uniq -d` → empty |

## Review Scope

Applicable
✓ `plan-conformance` — mandatory, and doubly so: the deliverable is itself a plan-governed protocol
✓ `verification-integrity` — mandatory; the ACs are evidence-driven live runs
✓ `business-logic` — the protocol's normative semantics (tier rules, transitions, gates) are the business logic
✓ `error-handling` — build-protocol.sh/install.sh failure modes; EXPRESS no-tooling path
✓ `secure-config` — install.sh writes into user projects (`.claude/settings.json` path unchanged but adjacent); role-gate change
✓ `data-integrity` — run-record/state schema compatibility (resume must not corrupt or rewrite old runs)

Not applicable
✗ `ui-rendering` `responsive-layout` `design-system` `navigation` `deep-links` `interaction` `forms` `client-state` `api-integration` `loading-states` `empty-states` `error-states` `offline` `accessibility` `visual-regression` — no UI; Markdown docs only
✗ `api-contracts` `request-validation` `response-validation` `status-codes` `versioning` — no network API; file contracts covered under business-logic/data-integrity
✗ `schema` `migrations` `transactions` `indexes` `query-performance` — no database
✗ `authentication` `authorization` `rbac` `input-validation` `output-encoding` `injection` `xss` `csrf` `ssrf` `secret-management` `encryption` `secure-headers` — no auth/network/web surface; the only security surface is secure-config (kept)
✗ `api-latency` `db-latency` `memory` `cpu` `cache` `concurrency` `scalability` — no runtime service; token payload size is covered by AC-N-01
✗ `retry` `circuit-breakers` `timeouts` `recovery` `rate-limiting` — no long-running processes beyond existing keep-awake (untouched)
✗ `logging` `metrics` `tracing` `monitoring` `alerting` — no runtime; the run record is the observability, covered under data-integrity

## Tooling Declaration

| Check type | Tool | Invoking role | Access |
|---|---|---|---|
| Shell syntax | `sh -n` (/bin/sh) | IMPLEMENTER + REVIEWER | confirmed (probed this machine) |
| Shell lint | shellcheck | — | **NOT AVAILABLE** (`which shellcheck` → empty; not installed). Consequence: style/portability lint unverified beyond `sh -n` + restricted-PATH execution — no AC depends on it |
| Byte/diff checks | `cmp`, `diff`, `comm`, `grep`, `wc`, `uniq` | IMPLEMENTER + REVIEWER | confirmed (`/usr/bin`) |
| Drift self-check | `build-protocol.sh --check` (built in T2) | IMPLEMENTER + REVIEWER | confirmed once T2 lands (self-hosted) |
| YAML schema validation | yamllint / PyYAML | — | **NOT AVAILABLE** (yamllint absent; PyYAML presence unverified). Consequence: ledger/run-record checks are grep-structural (AC-F-09 method), not parsed validation |
| Live adapter runs | Claude Code CLI (`claude` 2.1.226, `/Users/abhirajsinha/.local/bin/claude`) + throwaway repo in scratchpad | IMPLEMENTER (battery), REVIEWER (re-run AC-F-01, AC-F-08) | confirmed (probed) |
| VCS evidence | `git` | all | confirmed |
| Other adapters live (codex/gemini/cursor/…) | respective CLIs | — | **NOT AVAILABLE** — not installed here. Consequence: adapter file changes for non-Claude tools verified by inspection + install-script assertions only (AC-F-11/12), not live runs; stated, not papered over |
