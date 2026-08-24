# Fix Report

task_id: | artifact_type: fix-report | iteration: | responding to: <Review Report id> | produced_by: IMPLEMENTER (<model>) | timestamp:

## Per-Finding Responses
<exactly one block per finding in the report being answered (R-31)>

```
Finding ID:            <stable ID>
Response:              Fixed | Reclassification proposed | Deferral requested | Disputed
Change:                <what was changed, or "none">
Verification:          <the finding's Verification Method, executed (R-32)>
Evidence:              <real output / artifact reference, or "unavailable: <reason>">
Argument:              <required for Reclassification proposed | Deferral requested | Disputed>
```

## New Deviation Records
<per §3.2.1, or "None">

## Blast Radius (fixes)
<per §5.4, for the fixes themselves>

## LIGHT Plan (revised)
<!-- LIGHT only, and only when a plan finding was fixed (R-126): restate the corrected LIGHT Plan in full; omit this section otherwise -->

## Notes
