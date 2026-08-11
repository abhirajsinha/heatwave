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

AC-F-01 | <observable behavior> | Verification: <method>

<bugfix runs: one functional criterion MUST be the failing reproduction — red on pre-fix code, green after (R-113)>

### Non-functional

AC-N-01 | <metric> <operator> <threshold> under <conditions> | Verification: <method>

<or: "No non-functional constraints because <justification>" (R-23)>

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
