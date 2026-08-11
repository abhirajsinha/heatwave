# Fix Report

task_id: hw-v4-C-speed-token | artifact_type: fix-report | iteration: 1 | responding to: 2026-08-11-full-review-C.md (FULL_REVIEW, iteration 1) | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

## Per-Finding Responses

```
Finding ID:            F-hwC-101
Response:              Fixed
Change:                protocol/orchestrator.md §9.1 speed-duties paragraph: "verify the working
                       tree is clean for tracked source (`git status --porcelain` empty)" →
                       "verify the working tree is clean (`git status --porcelain` empty)".
                       The strict reading was chosen because it already governs the other two
                       homes (R-118 in core.md has no qualifier; prompts/orchestrator.md says
                       "tree is clean (`git status --porcelain` empty)") and matches AC-F-06's
                       actual command; over-degrading on untracked files is the fail-safe
                       direction the finding itself endorsed. PROTOCOL.md regenerated.
Verification:          grep -rn "tracked source" protocol/ prompts/ adapters/ templates/ PROTOCOL.md
                       (excluding docs/) → zero hits, exit 1 — the three homes now say the same
                       thing. sh build-protocol.sh && sh build-protocol.sh --check.
Evidence:              tracked-source grep: no output, exit 1 (post-rebuild).
                       Drift: "OK: PROTOCOL.md matches protocol/ shards", exit 0.
                       Consistency spot-checks re-run: grep -c "git status --porcelain"
                       protocol/orchestrator.md → 1; prompts/orchestrator.md → 1;
                       R-116/R-117/R-118 counts in protocol/orchestrator.md → 1/1/1;
                       head_sha ≥ 1 (T4 verification block re-passes).
```

```
Finding ID:            F-hwC-102
Response:              Fixed
Change:                adapters/claude-code/HEATWAVE.md line 9 headline now reads "…with a fresh
                       context (review stages: the reviewer session MAY persist across a task's
                       FULL→TARGETED→FINAL, see the R-117 note below):" — the skimming driver
                       sees the exception at the headline; the full R-117 note at line 17 is
                       unchanged. Adapter-wide grep for blanket fresh-context claims run as
                       directed: the only other hits are (a) EXPRESS_CHECK "fresh context,
                       R-1/R-2" lines (HEATWAVE.md:15, heatwave-reviewer agent description) —
                       correct, EXPRESS_CHECK is not a FULL/TARGETED/FINAL stage and is always
                       fresh; (b) adapters/generic/HEATWAVE-AGENT.md:13 "start a fresh session"
                       — the conflicting-ROLE refusal instruction, not a per-review-pass claim,
                       and its own line 12 already carries C's R-117 span text. No other adapter
                       (aider/cline/codex/copilot/cursor/gemini/windsurf/zed) contains a
                       fresh-context claim at all. No further edits needed.
Verification:          sed -n '9p' adapters/claude-code/HEATWAVE.md shows the qualifier;
                       grep -rniE "fresh (context|session|subagent)" adapters/ | grep -viE
                       "R-117|express" → only the generic:13 role-refusal line remains;
                       AC-F-08 re-sweep re-run.
Evidence:              Line 9 output pasted in the fixing transcript; re-sweep
                       (fresh context per review|re-reviews everything|equivalent to
                       FULL_REVIEW|carried forward across adapters/ prompts/ protocol/ README
                       COMPANIONS docs/faq,loop,getting-started install.sh) → zero hits, exit 1.
```

## New Deviation Records

None.

## Blast Radius (fixes)

Components touched: `protocol/orchestrator.md` (one phrase in the §9.1 speed-duties paragraph) + regenerated `PROTOCOL.md`; `adapters/claude-code/HEATWAVE.md` (one headline parenthetical). Consumers: the driver dispatch path (reads §9.1) and claude-code installs (HEATWAVE.md is copied by install.sh appends). Shared state/schema: none. Contracts: none changed — the strict porcelain reading was already the normative R-118/prompt behavior; the shard prose now agrees instead of disagreeing. Boundary reasoning: both edits are wording alignment inside already-shipped C text; no rule number, gate, state, template, or config key touched; scripts byte-untouched.

## Notes

Commit: `fix(v4-C): resolve FULL_REVIEW minor F-hwC-101 + nit F-hwC-102` on `heatwave-v4-subproject-c`. Drift check re-run after the shard edit: `OK: PROTOCOL.md matches protocol/ shards`, exit 0.
