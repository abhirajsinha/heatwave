# Heatwave Protocol — final-reviewer (canonical shard)

Loaded by: FINAL_REVIEW. Section/rule numbers are global to the protocol.

---

### 4.7 FINAL_REVIEW

**R-44.** The REVIEWER MUST perform a complete evaluation equivalent to `FULL_REVIEW`, plus per-criterion acceptance status (R-27), plus the production readiness checklist (Section 8.3).

**R-45.** Findings raised in `FINAL_REVIEW` that were passable in prior iterations MUST be reconciled per 5.6 — the report MUST state why the earlier pass was wrong or what changed.

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

