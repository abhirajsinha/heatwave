# Heatwave Protocol — fixer (canonical shard)

Loaded by: FIXING. Section/rule numbers are global to the protocol.

---

### 3.5 Fix Report

Produced by IMPLEMENTER in `FIXING`. Consumed by REVIEWER.

**Structure:**

```
1. Header                 — task_id, iteration, responding to <Review Report ID>
2. Per-finding response   — one entry per finding in the report being answered
3. Deviation Records      — new deviations introduced by fixes
4. Blast radius           — for the fixes themselves, per 5.4
5. Notes
```

**R-31.** Every finding in the Review Report being answered MUST have exactly one response entry. Silence is not a response.

**Per-finding response schema:**

```
Finding ID:            <stable ID>
Response:              Fixed | Reclassification proposed | Deferral requested | Disputed
Change:                <what was changed, or "none">
Verification:          <evidence per the finding's Verification Method>
Evidence:              <output, artifact reference, or explicit "unavailable: reason">
Argument:              <required for Reclassification proposed | Deferral requested | Disputed>
```

**R-32.** For any finding marked `Fixed`, the IMPLEMENTER MUST execute the finding's stated `Verification Method` and attach its result. If the method cannot be executed, the response MUST be `Disputed` or the evidence field MUST read `unavailable: <reason>` — and per R-70, the REVIEWER MUST NOT mark it resolved on that basis alone. *(v3.1 erratum: v3.0 cited R-46 here, an unrelated rule.)*

> **Rationale for R-32.** In v2, `Verification Method` was part of the finding schema but nothing consumed it, which made it decorative. Closing the loop — the method is stated by the reviewer, executed by the implementer, and checked by the reviewer — is what turns "fixed" from an assertion into a claim with evidence behind it.

---

### 4.5 FIXING

**R-40.** The IMPLEMENTER MUST address every finding per 3.5, including those it disputes.

**R-41.** The IMPLEMENTER MUST NOT make changes unrelated to the findings being addressed. Opportunistic refactoring during `FIXING` invalidates blast-radius reasoning and is itself a finding.

