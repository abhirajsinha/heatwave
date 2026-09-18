# <one-line symptom title>

<!-- A Heatwave failure-memory entry (R-138). Plain file, no service. Written by the IMPLEMENTER or
     REVIEWER on a VERIFIED failure. Filename is the slug: <slug>.md — the slug is the citation token
     the REVIEWER writes into the review report when it runs this entry's regression scenario, and the
     token `heatwave-report-check.sh knowledge-regression` looks for. Keep the slug stable and specific. -->

symptom: <what the user or operator observed, one or two lines>
class: <e.g. UI-interaction | browser-lifecycle | deploy-env | logic/real-input | real-content>
trigger_paths: <space- or comma-separated repo path prefixes whose change should re-run this scenario,
                e.g. src/panel/ src/margin.ts — string-prefix matched against the diff>

## Regression scenario

<the concrete steps that reproduce (or would re-expose) the failure on the real built product —
 executable/observable, not a theory. The REVIEWER runs this when trigger_paths intersect the diff
 and cites this entry (by its slug) in the review report.>
