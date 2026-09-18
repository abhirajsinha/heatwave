# EXPRESS Check

task_id: | artifact_type: express-check | produced_by: CHECKER (<model>, fresh context) | timestamp:

## In plain English (read this part first)
<!-- R-142 binds EVERY report type, EXPRESS included. Plain words; no rule/AC/finding IDs, file paths, file:line,
     or code here. A clean check just says so. Checked by `heatwave-report-check.sh plain-language`. -->
**Result: <passed and nothing to fix | did not pass — what needs to happen>.**

---

## For the engineer

## Verdict
PASS | FAIL — <one line>

## Machine gate
<commands run + real output; each unavailable check declared per R-64>

## Confirmation glance
- Diff does what was asked, nothing else: yes/no — <evidence>
- ≤ 2 files, none sensitive (R-102): yes/no — <files>
- No new dependency / public surface (R-103): yes/no
