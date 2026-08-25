# Context Brief

<!-- STANDARD/FULL runs only (R-131). Produced by the DRIVER at intake, mechanically — no role
     dispatch, no planning: every line is derived from a re-runnable command quoted below. It is
     an ADVISORY intake artifact handed to the PLANNER, who verifies before relying (R-131 planner half).
     CAUTION: may quote ticket/task-derived terms and lives in the run dir; do not commit run dirs
     you do not intend to share. Paths and counts only — never file-body excerpts. ≤ 40 non-blank lines. -->

task_id: | artifact_type: context-brief | produced_by: DRIVER (intake, no dispatch) | timestamp:

## Primary repository
path: <working-dir> | remote: <normalized host/owner/name, or "no remote — path only"> | ownership: <repo_ownership.verdict (R-128)>

## Detected tooling evidence
<!-- R-99 evidence classes, each cited by the file that proves it — pre-feeds, never replaces, the PLANNER's tooling declaration -->
- <tool/class> — <file path>

## Domain terms
<!-- literal strings grepped, listed verbatim so term choice is auditable -->
<term-1> <term-2> ...

## Relevant files
<!-- per repo: the quoted command + its matched paths, ≤ 30 per repo, total count stated when truncated; empty stated honestly -->
`git grep -lF -e '<term>' -- .`  (N matches, showing ≤30)
- <path>

## Additional repositories
<!-- identity + path + trusted/untrusted flag. The set is EXACTLY the repos NAMED in the task/brief text and
     resolved by the R-128 ladder — never a filesystem sweep. File listing only for in-set (trusted-owner) repos;
     an outside-set repo (incl. disk-only) is identified + flagged, never listed. Trust = operator identity, not disk.
     Context only — this run modifies one repository (R-128). "None" when the task named no other repo. -->
None

## Derivation note
Advisory — the PLANNER verifies and may contradict; every line above traces to a quoted command.
