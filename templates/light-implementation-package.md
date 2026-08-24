# Implementation Package (LIGHT)

<!-- LIGHT tier only (R-123/R-126). The FIRST section is the LIGHT Plan, written to
     this file BEFORE the first project-source edit. STANDARD/FULL use implementation-package.md. -->

task_id: | artifact_type: implementation-package | iteration: | tier: LIGHT | produced_by: IMPLEMENTER (<model>) | timestamp:
plan_written_at: <timestamp — this LIGHT Plan written to disk BEFORE the first source edit, R-123> | first_edit_at: <timestamp>

## LIGHT Plan
problem: <1–3 lines>
tier: LIGHT — <one-line justification> (R-0a)
change_class: <bugfix | feature> — <one line> (R-114)
change_surface: <subset of {auth, payments, external-input, new-endpoint, ui, deps, secrets, api-surface} | none> — <one line> (R-122)
AC-F-01 | <observable behavior> | Verification: <executable method>
AC-N-01 | <metric> <op> <threshold> under <conditions> | Verification: <method>   — or:  AC-N: none — <reason> (R-23)
review_scope: <files to touch>; categories: <applicable Appendix C names>
tooling: <test command> — <evidence file>; secrets: <tool | NOT AVAILABLE> (R-99, R-121)

## Files Changed
| Path | Change type | Line delta |
|---|---|---|
diff_ref: <commit range, or "working tree vs <sha>">

## Machine Evidence
<real output of every declared command (R-65/R-68); bugfix: red run first, then green (R-113); trim long output to the relevant lines and state the total line count — never a prose summary (R-126); Result: scope_exceeded — <reason> replaces this block on the R-105 path>

## Change Note
change: <one line>
blast_radius: <one line — touched, consumers, shared state, contracts>
deviations: <one line | None>
known_limitations: <one line incl. ponytail: ceilings | None>
tooling_gaps: <one line per R-64 | None>
