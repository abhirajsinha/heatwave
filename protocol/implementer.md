# Heatwave Protocol — implementer (canonical shard)

Loaded by: IMPLEMENTING; EXPRESS_IMPLEMENTING. Section/rule numbers are global to the protocol.

---

#### 3.2.1 Deviation Records

**R-21.** When implementation diverges from the approved plan, the IMPLEMENTER MUST record a Deviation Record in the Implementation Package containing:

- What the plan specified
- What was built instead
- Why
- Whether it affects review scope, acceptance criteria, or non-functional targets
- Whether it affects the threat surface

**R-22.** An undeclared deviation discovered in review is a **Blocker**, categorized as `plan-conformance`, regardless of whether the deviation itself is otherwise benign.

> **Rationale for R-22.** The severity attaches to the concealment, not the change. A better-than-planned approach that arrives undeclared has still defeated scope control: the reviewer evaluated against a scope that no longer describes the system. Making this a Blocker without exception removes the judgment call about whether "this one was fine."

### 3.3 Implementation Package

Produced by IMPLEMENTER in `IMPLEMENTING`. Consumed by REVIEWER.

**Required contents:**

| Item | Detail |
|---|---|
| Change summary | What was built, in prose, ≤ 200 words |
| Files changed | Path, change type, line delta |
| Diff | Or a reference the REVIEWER can resolve |
| Deviation Records | Per 3.2.1; explicit `None` if none |
| Migration notes | Forward and backward |
| Configuration changes | Including new env vars, flags, secrets |
| Test additions | What was added and what it covers |
| Test results | Per 6.4 — evidence, not assertion |
| Blast radius declaration | Per 5.4 |
| Known limitations | Explicit `None` if none |
| Tooling status | Per 6.2 |

**R-28.** `Blast radius declaration` and `Deviation Records` MUST NOT be empty fields. Absence is expressed as an explicit `None`, which is a claim the REVIEWER may find against.

---

### 4.3 IMPLEMENTING

**R-37.** The IMPLEMENTER MUST build to the approved plan. Divergence is permitted but MUST be declared per 3.2.1.

**R-38.** The IMPLEMENTER MUST NOT expand functional scope beyond the acceptance criteria. Additional work identified during implementation is a Deviation Record requesting plan change, not a unilateral addition.

### 4.8 EXPRESS_IMPLEMENTING *(v4)*

**R-105.** *(v4)* If the EXPRESS IMPLEMENTER finds the change larger or riskier than classified, it MUST NOT edit; it produces an EXPRESS Change note with `Result: scope_exceeded — <reason>`. The driver promotes the tier and enters `PLANNING`. This is the R-0b deviation path applied to intake misclassification.

In EXPRESS mode the ponytail discipline (Appendix G) applies in full — the tier exists precisely for the single smallest change that works — and the evidence rules are unchanged: attach real output for every check run (R-65), and declare any check that does not exist as `NOT AVAILABLE` (R-64), never narrated as run.

---

### 6.3 Test type requirements

Applicability is per review scope (5.1).

| Type | Environment | Requirement |
|---|---|---|
| Unit | Project standard | All relevant suites pass; results attached |
| Integration | Project standard | All relevant suites pass; results attached |
| API contract | Project standard | Contracts verified against plan |
| Mobile E2E | Per `heatwave.config.yaml` (`tooling.mobile_e2e`), unless plan specifies otherwise with reason | Complete journeys per acceptance criteria |
| Web E2E | Playwright | Realistic journeys, not isolated page checks |
| Load / performance | Per plan | Only where non-functional criteria specify thresholds |
| Accessibility | Per plan | Where applicable |

**R-67.** E2E tests MUST exercise the acceptance criteria, not a reviewer's improvised checklist.

---

## Appendix G — Ponytail: the IMPLEMENTER's coding discipline

*New in v3.1.* Heatwave vendors [Ponytail](https://github.com/DietrichGebert/ponytail) (MIT, © Dietrich Gebert) at `plugins/ponytail/SKILL.md` and binds it to one role.

**R-91.** The IMPLEMENTER MUST apply the ponytail ladder when writing code: question whether the code needs to exist, reuse what the codebase already has, prefer stdlib and native platform features over dependencies, and ship the shortest working diff — after fully understanding the problem, never instead of it.

**R-92.** Ponytail governs the IMPLEMENTER only. The REVIEWER's severity rules (8.2), the evidence rules (6.4), and every gate are unchanged — "lazy" never means unverified. Ponytail's own guardrails agree: input validation at trust boundaries, error handling that prevents data loss, security, and anything the plan explicitly requires are never simplified away.

**R-93.** Deliberate simplifications with a known ceiling MUST carry a `ponytail:` comment naming the ceiling and upgrade path, and MUST be listed under `Known limitations` in the Implementation Package — which makes each one a claim the REVIEWER can find against.

**R-94.** A REVIEWER finding of over-engineering (speculative abstraction, unneeded dependency, reinvented stdlib) is a valid finding, `Category: over-engineering`, severity per judgment. The completion gate is symmetric: code can fail review for doing too much, not only too little.

> **Rationale.** A verification protocol this strict invites over-building — an implementer graded on passing review will gold-plate. Binding a minimalism discipline to the same role that faces the gate keeps diffs small, which also makes every review cheaper and blast-radius claims easier to check.

