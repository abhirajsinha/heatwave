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
6. Findings          — summary per finding; canonical Appendix-A detail lives in the findings ledger (R-109)
7. Verification log  — per 6.4; what was verified, how, what was not, why
8. Summary narrative — free prose, ≤ 400 words, no findings introduced here
```

**R-29.** Findings MUST use the Appendix A schema, carried in the findings ledger from v4 (R-109); the report's Findings section summarizes and references it. Narrative belongs in §8 and MUST NOT introduce a finding. A concern that does not merit a structured finding is not a finding and MUST NOT gate approval.

> **Rationale for R-29.** v2 said free-form comments were "discouraged," which is not an enforceable rule — reviewers produce prose, and prose concerns then float in an undefined state where they neither block nor get tracked. Giving narrative a sanctioned home with an explicit no-findings rule resolves this without pretending reviewers won't write prose.

**R-30.** Every finding MUST carry a stable ID per 5.5.

#### 3.4.1 Findings ledger *(v4)*

**R-109.** *(v4)* From v4, each FULL/TARGETED/FINAL review produces `NN-findings-K.yaml` (schema: `templates/findings-ledger.yaml`) as the machine artifact of record, alongside the prose Review Report as its rendered human view. A review transition produces the ledger and its rendered report under the same sequence number NN; the pair counts as one artifact for §9.2 numbering. The FIXER responds by finding `id`; reconciliation (R-58) and TARGETED_REVIEW are driven from the ledger's `status` fields. Appendix A field semantics are the ledger's field semantics — the ledger is their compact carrier (the v4 machine-evidence additions `Origin`, `Refutation`, and the `Refuted` status live in both; §3.4.2).

#### 3.4.2 Machine evidence & refutation *(v4)*

**R-111.** *(v4)* Ladder verdicts (R-110) convert to findings mechanically, recorded in the ledger with `origin: machine` and their `rung`: a failing declared test is a machine finding of severity Blocker; a high-severity SAST result on changed lines is a machine finding, default Major; a surviving mutant on changed lines is a machine finding — `tests inadequate for <file>`, naming what to cover — default Major. Default categories: a failing test takes the category of the acceptance criterion it verifies, else `verification-integrity`; a SAST hit takes the matching Security category from Appendix C; a surviving mutant takes `verification-integrity`. The REVIEWER MAY reclassify a machine finding's default severity or category per R-5 with recorded reason; it MUST NOT discard one silently. All other Appendix A semantics apply, including stable IDs (R-55). The LLM review that follows covers what machines cannot — logic, design, plan conformance — and MUST NOT restate as prose findings what a rung already verified.

**R-112.** *(v4)* Refute-or-promote: before any candidate finding of severity Major or Blocker enters the ledger as `open`, the REVIEWER MUST attempt to refute it — is it actually reachable, actually wrong, not already handled? — and record the attempt and outcome in the finding's `refutation` field. A finding that survives is promoted (`status: open`) and gates per Section 8; one that is refuted is recorded with `status: refuted` and the refuting reason, MUST NOT enter FIXING, and MUST NOT gate (R-77 excludes it from "open"). Minors and Nits are exempt. A machine finding's refutation attempt is re-running its rung and checking the result is attributable to the change under review rather than a pre-existing baseline failure. Refuted findings remain in the ledger — visible, reconciled per 5.6, reopenable per R-59 — and are outside the set of findings R-31 obliges the FIXER to answer. Applies to ledger-producing reviews (R-109); PLAN_REVIEW findings are unaffected.

---

### 4.2 PLAN_REVIEW

**R-35.** The REVIEWER MUST evaluate: completeness against 3.2, acceptance criteria conformance against 3.2.2, review scope justification against 5.1, tooling declaration realism against 6.1, and internal consistency (does the architecture support the requirements; do the criteria cover the requirements; is the rollback plan actually executable).

**R-36.** Plan approval requires zero Blockers and zero Majors, per the same gate as feature review (Section 8).

### 4.4 FULL_REVIEW

**R-39.** The REVIEWER MUST evaluate every category in the effective review scope (5.1 as amended by 5.2), plus plan conformance (5.3), across the entire feature — not only changed files.

FULL_REVIEW opens with the machine-evidence ladder for the run's tier (R-110); LLM findings follow it.

**R-113 (reviewer half).** *(v4)* For a `change_class: bugfix` run (R-114), the REVIEWER MUST confirm the reproduction: red evidence captured on pre-fix code, and the same check re-run green after the fix. A bugfix with no reproducing check, or with no red-run evidence, is a Major (`Category: verification-integrity`) regardless of how plausible the fix reads.

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

