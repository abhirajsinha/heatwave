# Heatwave Protocol — final-reviewer (canonical shard)

Loaded by: FINAL_REVIEW. Section/rule numbers are global to the protocol.

---

### 4.7 FINAL_REVIEW

**R-44.** The REVIEWER MUST perform the FINAL_REVIEW scope of R-118 — ledger closure, the full machine-gate re-run for the tier, LLM review of the delta since the last FULL_REVIEW — plus per-criterion acceptance status (R-27), plus the production readiness checklist (Section 8.3). *(v4: supersedes the pre-C full-equivalence wording — within the delta, evaluation depth is unchanged; outside it, machine gates and AC re-confirmation carry the regression load, R-118.)* Where R-118's degrade condition holds (no recorded last-FULL SHA, dirty tree, or the LIGHT combined pass), the evaluation is complete at full scope, as before.

**R-45.** Findings raised in `FINAL_REVIEW` that were passable in prior iterations MUST be reconciled per 5.6 — the report MUST state why the earlier pass was wrong or what changed.

*(v4)* Session continuity never shrinks (b) or (d): a persistent reviewer (R-117) re-runs every machine rung from scratch and re-confirms every criterion with fresh evidence — reuse of context, never of a prior verdict. Files unchanged since the last FULL_REVIEW are outside the required reading scope (R-118(c)); reading one is done only as a recorded R-49 scope expansion substantiating a suspected delta-caused regression. Reconciliation (5.6) and the checklist (8.3) still cover the whole task from the artifacts already held.

---

### 8.3 Production readiness

Verified at `FINAL_REVIEW`. Each item MUST have status and evidence.

| Item | Requirement |
|---|---|
| Acceptance criteria | Every AC-F and AC-N reported individually: Satisfied / Not satisfied / Unverified |
| Plan conformance | Passed (5.3) |
| In-scope review categories | All passed (5.1 + 5.2) |
| Tests | All declared suites executed; results attached |
| Non-functional targets | Measured against thresholds; measurements attached |
| Tooling gaps | Enumerated per R-64; none affecting an unwaived criterion |
| Reconciliation | Complete; no unexplained reversals |
| Open findings | Blockers = 0, Majors = 0 |
| Deferred findings | Recorded with approver |
| Waived findings | Recorded with OWNER rationale |
| Documentation | Updated per plan |
| Observability | Per scope |
| Rollback | Plan present and executable |

