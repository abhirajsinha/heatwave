# Heatwave failure memory (`.heatwave/knowledge/`) — R-138

Plain-file memory of verified failures, so the same class of defect is re-checked next time it could
recur. No service, no dependency — just `<slug>.md` files.

## When an entry is written

On a **verified failure** (a defect the IMPLEMENTER or REVIEWER actually observed and confirmed on the
real product), that role writes one entry here, shaped by `templates/knowledge-entry.md`:

- `symptom` — what was observed.
- `class` — the failure class.
- `trigger_paths` — the repo path prefixes whose change should re-run this entry's regression scenario.
- a **Regression scenario** — the concrete, observable steps that re-expose the failure on the real build.

## How it gates (no new dispatch)

Before FULL_REVIEW the **driver** supplies the REVIEWER the entries whose `trigger_paths` intersect the
diff (the same driver bookkeeping as the R-131 context brief). The REVIEWER MUST run those regression
scenarios on the real product and **cite each entry by its slug** in the review report.

The completeness of that is machine-checked (R-138):

```
sh templates/checks/heatwave-report-check.sh knowledge-regression .heatwave/knowledge <diff> <review-report>
```

exits non-zero if any entry whose `trigger_paths` intersect the diff is not cited in the review report
(the slug — the filename without `.md` — is the pinned citation token). A non-intersecting entry is
neither listed nor required — no false-regression cost. The check is a presence gate, not a truth oracle:
R-65/R-68 still make an asserted-but-unrun scenario a Blocker.

This `README.md` is documentation only and is never treated as an entry.
