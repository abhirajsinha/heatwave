# Heatwave Protocol — implementer (canonical shard)

Loaded by: IMPLEMENTING; EXPRESS_IMPLEMENTING; FIXING. Section/rule numbers are global to the protocol. At LIGHT the IMPLEMENTER also authors the LIGHT Plan (R-123/R-124, §3.3.1) as §1 of its Implementation Package before it edits.

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
| Test results | Per 6.4 — evidence, not assertion; bugfix runs attach the red-then-green reproduction pair (R-113) |
| Blast radius declaration | Per 5.4 |
| Known limitations | Explicit `None` if none |
| Tooling status | Per 6.2 |

**R-28.** `Blast radius declaration` and `Deviation Records` MUST NOT be empty fields. Absence is expressed as an explicit `None`, which is a claim the REVIEWER may find against.

#### 3.3.1 LIGHT Plan and LIGHT package *(v4.2)*

**R-124.** *(v4.2)* **LIGHT Plan.** The LIGHT Plan is the §0.5 LIGHT-minimum Planning Document in a fixed shape of at most **25 non-blank lines**: `problem` (1–3 lines); `tier: LIGHT — <one-line justification>`; `change_class: bugfix | feature — <one line>` (R-114); `change_surface: <subset or none> — <one line>` (R-122); acceptance criteria one line each — at least one `AC-F` (for a bugfix run one of them is the failing-reproduction criterion, R-113) and either at least one `AC-N` or `AC-N: none — <reason>` (R-23) — each with its verification method (R-27); `review_scope`: the files to be touched plus the applicable Appendix C categories on one line (`plan-conformance` and `verification-integrity` always apply and are not listed); `tooling`: the test command(s), each with the project evidence that proves it exists (R-99), and a `secrets` entry or `NOT AVAILABLE` (R-121). No other §3.2 section is written and no `N/A` rows are written — R-19 and R-20 apply to the fields above only. Every field is a claim the REVIEWER finds against.

At LIGHT the Implementation Package takes the shape `templates/light-implementation-package.md` fixes (R-126): the LIGHT Plan as §1 (written to disk before the first source edit, R-123), a touched-file table with a diff reference the REVIEWER can resolve, the machine evidence (a bugfix run's red→green reproduction, R-113), and a five-line change note — `change`, `blast_radius`, `deviations`, `known_limitations`, `tooling_gaps`, one line each, `None` written explicitly. No change-summary prose, no walkthrough. On the R-105 scope-exceeded path the diff and machine-evidence blocks are replaced by `Result: scope_exceeded — <reason>`.

---

### 4.3 IMPLEMENTING

*(v4.2)* At LIGHT the IMPLEMENTER also authors the LIGHT Plan as §1 of the package before editing — see §3.3.1 and R-123; it is then bound by that plan exactly as an approved plan binds it.

**R-37.** The IMPLEMENTER MUST build to the approved plan. Divergence is permitted but MUST be declared per 3.2.1.

**R-38.** The IMPLEMENTER MUST NOT expand functional scope beyond the acceptance criteria. Additional work identified during implementation is a Deviation Record requesting plan change, not a unilateral addition.

**R-113 (implementer half).** *(v4)* For a `change_class: bugfix` run (R-114), the IMPLEMENTER MUST capture the failing reproduction FIRST: run the plan's reproduction check against unmodified code and attach the red output to the Implementation Package, then fix, then re-run the same check and attach the green output. Red-then-green is the verification evidence for the reproduction criterion; a fix authored before the red run is captured is a deviation (3.2.1).

### 4.8 EXPRESS_IMPLEMENTING *(v4)*

**R-105.** *(v4; generalized v4.2)* If the IMPLEMENTER at EXPRESS or LIGHT finds the change larger, riskier, or on a sensitive path (R-102) relative to its classification, it MUST NOT edit further. At EXPRESS it produces an EXPRESS Change note with `Result: scope_exceeded — <reason>`. At LIGHT it reverts any edit already made in this dispatch (naming the files reverted) and produces the Implementation Package with the LIGHT Plan as written and `Result: scope_exceeded — <reason>` in place of the diff and evidence. The driver promotes the tier and enters `PLANNING` at the promoted tier with counters at 0. This is the R-0b deviation path applied to intake misclassification.

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

