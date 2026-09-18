# Planning Document

task_id: | artifact_type: planning-document | iteration: | produced_by: PLANNER (<model>) | timestamp:

## Tier

<LIGHT | STANDARD | FULL> — <one-line justification> (PROTOCOL §0.5)
Change class: <bugfix | feature> — <one-line justification> (R-114; bugfix triggers R-113)

## Problem Statement
<what is being solved and for whom>

## Functional Requirements

## Non-Functional Requirements
<measurable targets; see §3.2.2>

## Architecture
<components, boundaries, data flow>

## API Design
<contracts, or `N/A — <reason>`>

## Data Design
<schema, migrations, or `N/A — <reason>`>

## State Management
<client and server state, or `N/A — <reason>`>

## Error Handling Strategy
<failure modes and responses>

## Security Considerations
<threat surface introduced by this change>

## Edge Cases
<enumerated, not gestured at>

## Risks
<with likelihood and mitigation>

## Dependencies
<internal and external, with availability status>

## Testing Strategy
<what is tested, how, by whom, with what tools>

## Rollout Plan
<flags, staging, phasing, or `N/A — <reason>`>

## Rollback Plan
<concrete steps, not "revert the commit">

## Acceptance Criteria

### Functional

AC-F-01 | <observable behavior> | runtime: <yes | no> | Verification: <method>

<runtime: yes (R-133) when the criterion is only truly verifiable by driving the real built artifact —
 its accepting evidence must name a verification_matrix class (web-ui | chrome-extension | api |
 db-migration | mobile | deploy | real-input); the runtime-evidence rung checks this (R-110).>
<bugfix runs: one functional criterion MUST be the failing reproduction — red on the REAL build at/before
 PLANNING (R-136), re-run green after the fix (R-113)>

### Non-functional

AC-N-01 | <metric> <operator> <threshold> under <conditions> | Verification: <method>

<or: "No non-functional constraints because <justification>" (R-23)>

## Jira Traceability (jira_ac_map)

<!-- Jira-sourced runs ONLY — omit this section entirely for text runs (required-iff-jira, R-130;
     not an N/A row on a text plan). Every J-AC from the Requirement Brief maps to ≥1 plan AC;
     an unmapped or redefined J-AC is a Major at PLAN_REVIEW. A plan AC with no J-AC source is
     tagged `derived` and justified. -->

| J-AC | Plan AC(s) | Note |
|---|---|---|
| J-AC-1 | AC-F-01 | |

Derived ACs (no J-AC source): <AC-id — justification, or None> (R-130)

## Review Scope

Applicable
✓ <category> — <why>

Not applicable
✗ <category> — <why not>

(`plan-conformance` and `verification-integrity` are always applicable and never listed as N/A.)

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Unit | <framework> | IMPLEMENTER | confirmed / NOT AVAILABLE — <affected ACs> |
| SAST (STANDARD+) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE — <affected ACs> (R-110) |
| Mutation (FULL, with timeout ceiling) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE — <affected ACs> (R-110) |
| Secrets (FINAL rung) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE (R-121) |
| UI evidence (change_surface ∋ ui) | <MCP/tool> | REVIEWER | confirmed / NOT AVAILABLE (R-120) |
| Runtime evidence (per runtime: yes AC) | <verification_matrix driver per class> | REVIEWER | confirmed / NOT AVAILABLE — <affected ACs> (R-133) |
| Deploy (change_surface ∋ deploy) | deploy-smoke.sh (HEALTH_URL/REQUEST_URL/SCHEMA_CMD) | REVIEWER | confirmed / NOT AVAILABLE (R-137) |

change_surface: <subset of {auth, payments, external-input, new-endpoint, ui, deps, secrets, api-surface} or none> — <one line> (R-122)

verification_matrix: <class -> driver, per required runtime class, or "none — no runtime AC"> (R-133)
exploratory_flows: <real user/operator flows the REVIEWER exercises for the touched surface, or "none declared"> (R-134)
