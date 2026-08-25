# Heatwave Protocol — reviewer (canonical shard)

Loaded by: PLAN_REVIEW; FULL_REVIEW; TARGETED_REVIEW; FINAL_REVIEW; ESCALATED (report). Section/rule numbers are global to the protocol.

---

### 3.4 Review Report

Produced by REVIEWER in `PLAN_REVIEW`, `FULL_REVIEW`, `TARGETED_REVIEW`, `FINAL_REVIEW`. Consumed by IMPLEMENTER and OWNER.

**Structure:**

```
1. Header            — task_id, iteration, review_type, scope evaluated
2. Verdict           — GATE_MET | GATE_NOT_MET, with counts by severity
3. Scope changes     — per 5.2; explicit "None" if none
4. Reconciliation    — per 5.6; required from iteration 2 onward
5. Acceptance status — per criterion; required in FINAL_REVIEW
6. Findings          — summary per finding; canonical Appendix-A detail lives in the findings ledger (R-109). *(v4.4, R-132: at STANDARD, one line each pointing to the ledger where a ledger exists — FULL/TARGETED/FINAL; full Appendix-A blocks at PLAN_REVIEW, which has none.)*
7. Verification log  — per 6.4; what was verified, how, what was not, why
8. Summary narrative — free prose, ≤ 400 words, no findings introduced here. *(v4.4, R-132: FULL-tier only — not written at STANDARD.)*
```

*(v4.2)* At LIGHT the Review Report takes the shape `templates/light-review-report.md` (R-126): a one-line verdict, the plan-check table (R-125), the machine-evidence table, the per-criterion acceptance table, one-line findings pointing to the ledger, reconciliation from iteration 2, and the §8.3 readiness table — no summary narrative.

*(v4.4)* At STANDARD the Review Report takes the capped shape `templates/review-report.md` fixes (R-132): the same tables, findings one-line-to-ledger where a ledger exists (Appendix-A blocks at PLAN_REVIEW), and no summary narrative — evidence exempt in R-126's exact terms.

**R-29.** Findings MUST use the Appendix A schema, carried in the findings ledger from v4 (R-109); the report's Findings section summarizes and references it. Narrative belongs in §8 and MUST NOT introduce a finding. A concern that does not merit a structured finding is not a finding and MUST NOT gate approval. *(v4.4: at STANDARD the §8 summary narrative is not written — R-132 makes §8 FULL-tier only; this rule's no-finding-in-narrative and "a concern that is not a finding does not gate" clauses are unchanged and tier-independent.)*

> **Rationale for R-29.** v2 said free-form comments were "discouraged," which is not an enforceable rule — reviewers produce prose, and prose concerns then float in an undefined state where they neither block nor get tracked. Giving narrative a sanctioned home with an explicit no-findings rule resolves this without pretending reviewers won't write prose.

**R-30.** Every finding MUST carry a stable ID per 5.5.

#### 3.4.1 Findings ledger *(v4)*

**R-109.** *(v4)* From v4, each FULL/TARGETED/FINAL review produces `NN-findings-K.yaml` (schema: `templates/findings-ledger.yaml`) as the machine artifact of record, alongside the prose Review Report as its rendered human view. A review transition produces the ledger and its rendered report under the same sequence number NN; the pair counts as one artifact for §9.2 numbering. The FIXER responds by finding `id`; reconciliation (R-58) and TARGETED_REVIEW are driven from the ledger's `status` fields. Appendix A field semantics are the ledger's field semantics — the ledger is their compact carrier (the v4 machine-evidence additions `Origin`, `Refutation`, and the `Refuted` status live in both; §3.4.2).

#### 3.4.2 Machine evidence & refutation *(v4)*

**R-111.** *(v4)* Ladder verdicts (R-110) convert to findings mechanically, recorded in the ledger with `origin: machine` and their `rung`: a failing declared test is a machine finding of severity Blocker; a high-severity SAST result on changed lines is a machine finding, default Major; a surviving mutant on changed lines is a machine finding — `tests inadequate for <file>`, naming what to cover — default Major. Default categories: a failing test takes the category of the acceptance criterion it verifies, else `verification-integrity`; a SAST hit takes the matching Security category from Appendix C; a surviving mutant takes `verification-integrity`. The REVIEWER MAY reclassify a machine finding's default severity or category per R-5 with recorded reason; it MUST NOT discard one silently. All other Appendix A semantics apply, including stable IDs (R-55). The LLM review that follows covers what machines cannot — logic, design, plan conformance — and MUST NOT restate as prose findings what a rung already verified.

**R-112.** *(v4)* Refute-or-promote: before any candidate finding of severity Major or Blocker enters the ledger as `open`, the REVIEWER MUST attempt to refute it — is it actually reachable, actually wrong, not already handled? — and record the attempt and outcome in the finding's `refutation` field. A finding that survives is promoted (`status: open`) and gates per Section 8; one that is refuted is recorded with `status: refuted` and the refuting reason, MUST NOT enter FIXING, and MUST NOT gate (R-77 excludes it from "open"). Minors and Nits are exempt. A machine finding's refutation attempt is re-running its rung and checking the result is attributable to the change under review rather than a pre-existing baseline failure. Refuted findings remain in the ledger — visible, reconciled per 5.6, reopenable per R-59 — and are outside the set of findings R-31 obliges the FIXER to answer. Applies to ledger-producing reviews (R-109); PLAN_REVIEW findings are unaffected.

#### 3.4.3 STANDARD review output shape *(v4.4)*

**R-132.** *(v4.4)* At STANDARD every REVIEWER-authored Review Report — PLAN_REVIEW, FULL_REVIEW, TARGETED_REVIEW, FINAL_REVIEW — takes the shape `templates/review-report.md` fixes: a one-line verdict with severity counts; scope evaluated as a line and scope changes per R-49; the reconciliation table (R-58) from iteration 2; the per-criterion acceptance table with evidence references (R-27); the machine-evidence table (R-110); findings as **one line each pointing to the ledger** where a ledger exists (FULL/TARGETED/FINAL, R-109) and as full Appendix-A blocks at PLAN_REVIEW, which has none; the verification log as tables. The free-prose **Summary narrative** (§3.4 structure item 8) is **FULL-tier only** — not written at STANDARD.

The cap binds **narrative only; evidence is never cut to fit** — exactly as R-126: R-65 and R-68 hold in full, long command output MAY be trimmed to the relevant lines **with the total line count stated** and MUST NOT be replaced by a prose summary, and the findings ledger (R-109) is uncapped and carries every finding's full Appendix-A detail. What the cap removes is the *duplicate* prose rendering of what the ledger already carries, plus the free-form summary narrative. A missing required element is a **Blocker** (R-16 — the artifact is incomplete). Surplus narrative is a **Minor** (`Category: over-engineering`), recorded, never gating — a reviewer is never penalized for attaching *more evidence*, only for wrapping the report in unrequested prose. **Prose the driver's dispatch explicitly directed — an operator's standing instruction, such as a required plain-language opening section — is not "surplus narrative": the Minor targets unrequested narrative only.** FULL-tier reports, the findings-ledger schema (R-109), the Implementation Package, and the Fix Report are unchanged.

---

### 4.2 PLAN_REVIEW

*(v4.2)* PLAN_REVIEW is not entered at LIGHT — at LIGHT the plan is reviewed inside the combined FULL+FINAL pass (R-125), by a REVIEWER context distinct from the IMPLEMENTER that wrote it (R-1/R-2). R-35/R-36 below govern that plan check as well.

**R-35.** The REVIEWER MUST evaluate: completeness against 3.2, acceptance criteria conformance against 3.2.2, review scope justification against 5.1, tooling declaration realism against 6.1, and internal consistency (does the architecture support the requirements; do the criteria cover the requirements; is the rollback plan actually executable).

**R-36.** Plan approval requires zero Blockers and zero Majors, per the same gate as feature review (Section 8).

**R-130 (reviewer half).** *(v4.3)* On a Jira-sourced run the REVIEWER MUST check the plan's `jira_ac_map` (R-130 planner half) at PLAN_REVIEW — or, at LIGHT, at the combined pass plan-check (R-125): a `J-AC` from the brief left unmapped, or a plan AC that narrows or redefines a `J-AC`, is a **Major** (`Category: acceptance-criteria`) — the plan must not redefine the requirement. A plan AC tagged `derived` (no J-AC source) is acceptable only when justified; an unjustified `derived` AC is a finding per R-26. A plan MAY **refuse** a `J-AC` on stated security or integrity grounds — a ticket, being untrusted input (R-128), can carry a hostile or unsafe acceptance criterion — and a documented refusal does NOT count as narrowing (R-130) or as an unmapped-J-AC Major: the refused J-AC is surfaced at the GO checkpoint / to the OWNER (R-129) for the human to decide, not filed as the mandatory finding. Text runs carry no map and this check is vacuous.

### 4.4 FULL_REVIEW

**R-39.** The REVIEWER MUST evaluate every category in the effective review scope (5.1 as amended by 5.2), plus plan conformance (5.3), across the entire feature — not only changed files.

FULL_REVIEW opens with the machine-evidence ladder for the run's tier (R-110); LLM findings follow it.

*(v4-D)* Companion invocation (core §6.5): class-1 rungs run the declared tools — e.g. a declared `sast: semgrep` runs `semgrep scan --config auto` on the changed paths, high-severity results converting to machine findings per R-111; a declared mutation tool runs on changed modules at FULL. The semantic security pass (`/security-review` in Claude Code; the adapter's documented equivalent elsewhere) runs iff the plan's `change_surface` (R-122) intersects {auth, external-input, deps, secrets, api-surface}; its output enters as candidate findings under R-112. UI evidence is captured via Playwright MCP iff `change_surface` ∋ ui — accessibility-tree assertions plus a screenshot, cited in the Review Report against the UI acceptance criteria. Dynamic security runs strictly per R-119. Each companion absent → `NOT AVAILABLE` (R-64), never a silent skip.

**R-113 (reviewer half).** *(v4)* For a `change_class: bugfix` run (R-114), the REVIEWER MUST confirm the reproduction: red evidence captured on pre-fix code, and the same check re-run green after the fix. A bugfix with no reproducing check, or with no red-run evidence, is a Major (`Category: verification-integrity`) regardless of how plausible the fix reads.

**R-125.** *(v4.2)* **Plan review inside the LIGHT combined pass.** At the LIGHT combined FULL+FINAL pass the REVIEWER MUST evaluate the LIGHT Plan before the diff, applying R-35 to the R-124 fields — acceptance-criteria conformance (§3.2.2), tooling realism (R-63), tier (R-0a), change class and change surface (R-114, R-122) — and MUST check the acceptance criteria against the task statement, not against the diff: criteria that merely restate what was built, or that omit a behavior the task asked for, are a finding (`Category: acceptance-criteria`, minimum Major). A package with no LIGHT Plan, a LIGHT Plan missing an R-124 field, or a LIGHT Plan that the available evidence (artifact ordering, timestamps, commit history) shows was written after the code, is a Blocker (`Category: plan-conformance`). Plan findings carry normal severities, enter the ledger, and are answered in `FIXING` like any other finding; a failed combined pass increments `final_iterations` and the next review is the combined pass again (§0.5, R-14). When the REVIEWER judges the task mis-tiered — it should have run STANDARD or FULL — it raises the tier (R-0a) instead of filing plan findings: the driver enters `PLANNING` at the raised tier with counters at 0; the LIGHT package is superseded, not amended (R-89); R-0b's "re-enters PLAN_REVIEW" reads as "enters PLANNING" for a run that had none. R-81's "plan approved" is satisfied at LIGHT by a combined pass reporting GATE_MET with no open plan finding.

### 4.6 TARGETED_REVIEW

**R-42.** The REVIEWER MUST evaluate: each finding's claimed resolution against its verification evidence, the declared blast radius of the fixes, regression risk in components the fixes touch, and any new Deviation Records.

**R-43.** The REVIEWER MUST NOT re-litigate areas passed in prior iterations unless a fix's blast radius reaches them, or reconciliation (5.6) justifies reopening.

*(v4)* In a persistent session (R-117) the REVIEWER arrives at TARGETED_REVIEW already holding its ledger and finding memory — that is the economy of persistence. The recorded artifacts remain authoritative: reconciliation (5.6) is still written from the ledger, and a degraded fresh context (R-117) performs it from the supplied prior reports exactly as R-4 provides.

---

### 5.2 Dynamic scope

**R-48.** The REVIEWER MAY expand the effective review scope beyond the plan's declaration when the implementation introduces surface the plan did not anticipate — a new endpoint, a cache, a background job, a third-party call, a new data store, a new permission.

**R-49.** Scope expansion MUST be recorded in the Review Report §3 with: category added, what triggered it, and whether a Deviation Record declared the trigger (if not, see R-22).

**R-50.** The REVIEWER MUST NOT narrow scope below the plan's declaration without OWNER approval.

> **Rationale for R-48.** A scope fixed at planning time is stale the moment implementation surprises anyone, and v2 bound the reviewer to ignore whatever the plan marked N/A. That converts an honest planning-time estimate into a permanent blind spot: an implementer who adds a cache the plan didn't foresee gets no cache review, forever. Expansion is one-directional by design — the reviewer can add surface, never remove it.

### 5.3 Plan conformance

**R-51.** Plan conformance is a mandatory review category in every `FULL_REVIEW` and `FINAL_REVIEW`. It MUST NOT be marked N/A.

**R-52.** The REVIEWER MUST verify: the implementation realizes the planned architecture, all Deviation Records are declared, no undeclared divergence exists, and the acceptance criteria are satisfied by what was actually built rather than by something adjacent to it.

> **Rationale.** v2 required implementation "according to the approved plan" but had no review category that checked it. An implementer who solved the problem differently — even competently — passed every listed check, because every check examined the code on its own terms rather than against the plan. Plan conformance is the category that makes plan approval load-bearing.

### 5.5 Finding identity

**R-55.** Every finding MUST have an ID stable for the task's lifetime: `F-<task_id>-<NNN>`, assigned sequentially, never reused.

**R-56.** A finding that recurs across iterations MUST retain its original ID. A finding that is genuinely new gets a new ID.

**R-57.** A finding's severity MAY change across iterations, but each change MUST be recorded in the reconciliation section with reason.

### 5.6 Reconciliation

**R-58.** From iteration 2 onward, every Review Report MUST contain a reconciliation section addressing every finding from all prior reports:

```
Finding ID | Prior status | Current status | Change reason (required if changed)
```

**R-59.** Reopening a previously-resolved finding requires a stated reason: the fix regressed, the fix was inadequate, or the earlier resolution was accepted in error.

**R-60.** A finding raised at iteration N against code unchanged since iteration 1 MUST be flagged as a **late finding** and MUST state why earlier iterations passed it. Late findings are valid — a reviewer who spots a real problem late should say so — but they MUST be visible as a review-quality signal rather than absorbed silently into the count.

**R-61.** Severity reversals (a finding downgraded or upgraded without a corresponding code change) MUST be justified in reconciliation.

> **Rationale for 5.6.** Without reconciliation, a review loop can churn indefinitely: iteration 3 raises what iteration 1 passed, iteration 4 quietly drops it, and nobody can tell whether the code is converging or the reviewer is drifting. Stable IDs plus mandatory reconciliation make the loop's trajectory legible — and make review quality itself measurable, since a run with many late findings indicates the early reviews were shallow.

---

### 7.2 Escalation Report

Produced by the REVIEWER upon entering `ESCALATED` (the driver dispatches it with the Run Record and all prior artifacts). Consumed by the OWNER.

**R-71.** Entering `ESCALATED` MUST produce an Escalation Report containing:

| Section | Content |
|---|---|
| Trigger | Which condition fired; which counter, if applicable |
| State | Current state, all counter values |
| Outstanding findings | Full list with IDs, severity, history |
| Root cause analysis | Why convergence failed — not a restatement of the findings |
| Attempted fixes | What was tried, per finding, and why it did not work |
| Unverified criteria | Per R-66 |
| Options | Concrete alternatives with tradeoffs |
| Decision required | The specific question the OWNER must answer |

**R-72.** The "Decision required" section MUST pose an answerable question. "Please advise" is non-conforming.

---

## Appendix A — Finding Schema

```
Finding ID:           F-<task_id>-<NNN>
Severity:             Blocker | Major | Minor | Nit
Category:             <from Appendix C, or: blast-radius |
                       acceptance-criteria | over-engineering>
Origin:               reviewer | machine (R-111; absent = reviewer)
Location:             <file:line, endpoint, screen, or artifact section>
Problem:              <what is wrong — observable, specific>
Why it matters:       <consequence; MUST justify the severity assigned>
Recommended fix:      <actionable; not "consider improving">
Verification method:  <how the fix will be proven — MUST be executable by
                       the IMPLEMENTER; this field is consumed by R-32>
Refutation:           <refutation attempt + outcome — REQUIRED for
                       Major/Blocker (R-112)>
Introduced in:        <iteration first raised>
Status:               Open | Fixed | Deferred (approved) | Waived (OWNER) |
                      Disputed | Refuted
```

Notes:

- `Verification method` MUST be concrete enough to execute and to produce evidence. "Retest the flow" is non-conforming; "Run `<suite>::<test>`; expect pass" or "In the simulator, navigate Home → Settings → Delete Account; expect confirmation modal, then logout" conforms.
- `Why it matters` is where severity is defended. A Blocker whose consequence reads like a Nit will be reclassified.

