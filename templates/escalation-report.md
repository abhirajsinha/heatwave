# Escalation Report

task_id: | artifact_type: escalation-report | iteration: | produced_by: REVIEWER (<model>) | state: | counters: plan=N fix=N final=N | timestamp:

## In plain English (read this part first)
<!-- R-142: everyday words, short sentences. No rule/AC/finding IDs, file paths, file:line, or code here.
     Checked by `heatwave-report-check.sh plain-language`. -->
**Result: the run has stopped and needs a decision from you.**

<what went wrong in plain terms, why it matters, and the one decision you are being asked to make>

---

## For the engineer

## Trigger
<which §7.1 condition fired; which counter, if applicable>

## Outstanding Findings
<full list with IDs, severity, history>

## Root Cause Analysis
<why convergence failed — not a restatement of the findings>

## Attempted Fixes
<what was tried, per finding, and why it did not work>

## Unverified Criteria
<per R-66, or "None">

## Options
<concrete alternatives with tradeoffs>

## Decision Required
<a specific, answerable question for the OWNER — "please advise" is non-conforming (R-72)>

---

## Owner Decision Record (completed by the human)

```
Decision:         continue | replan | abandon
Resume state:     <state>                                (required if continue)
Counter reset:    <which counters, to what>              (required if continue; at least one, R-74)
Waivers:          <finding IDs waived, with reason>      (optional)
Scope changes:    <additions or removals, with reason>   (optional)
Criteria changes: <AC IDs added/modified/removed, why>   (optional)
Rationale:        <why>
```
