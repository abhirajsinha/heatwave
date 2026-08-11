# Review Report

task_id: positioning-readme | artifact_type: review-report | iteration: 1 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict

GATE_MET — **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 2 | Nit: 2

## Scope Evaluated

Plan-conformance (spec `docs/specs/2026-08-11-positioning-readme-design.md`, locked decisions §3–§4) + verification-integrity, honesty-first per dispatch. Ground-truthed against main @ `2856943`: `PROTOCOL.md`, `protocol/*.md`, `install.sh`, `adapters/`, `benchmark/RESULTS.md`/`METHODOLOGY.md`/`README.md`/`run.sh`/`corpus/`, `README.md`, `docs/faq.md`, `docs/getting-started.md`.

## Scope Changes

None.

## Reconciliation

Iteration 1 — no prior findings. Late findings: None.

## Findings

**F-1 (Minor, verification-integrity) — AC-F-02 grep misses the pilot's ACTUAL numbers.** Plan L143. The pattern forbids the literal `0/3` (spec's string), but the real pilot figures are **0/4** (RAW) and **0/1** (HEATWAVE) — `benchmark/RESULTS.md` L7. A README quoting "0/4" passes the mechanical grep. The same AC's reviewer-read clause ("no RAW/HEATWAVE numeric result quoted") does cover it, and the plan's Edge Cases (L59) explicitly ban quoting any number — so the AC as a whole catches it, but the mechanical guard should too. Fix: extend the pattern with `0/[0-9]` (catches 0/3, 0/4, 0/1). Same residual note: bare comparatives ("faster"/"cheaper" without a multiplier) also rely on the reviewer read; the plan discloses this tradeoff (L60) and the spec's own G2 mandates "cheap/fast" phrasing for model-tiering, so a plain-word grep would false-positive on spec-required copy — accepted as designed, backstop stated.

**F-2 (Minor, plan-conformance) — T7(a) "scoped to tools with hooks" is looser than shipped reality.** Plan L108. Only Claude Code's `PreToolUse Edit|Write` hook (`adapters/claude-code/role-gate.sh`, exit-2 block) actually **blocks** source edits. Codex (`adapters/codex/hooks.json` — `cat GATE.md` on UserPromptSubmit) and Gemini (`adapters/gemini/gemini-gate.sh` — BeforeAgent context injection) re-inject the gate text; they do not block edits. An implementer reading "scoped to tools with hooks" could write "source-edit blocking shipped for tools with hooks" — an overclaim for Codex/Gemini. Mitigations already in the plan: T7(a) cites the exact Claude-Code-only mechanism in the same sentence, the T9 hooks row is correctly scoped ("source-edit gate (Claude Code), per-prompt gate (Codex), BeforeAgent gate (Gemini)"), README L125 models the correct scoping, and AC-F-05 requires the reviewer to cross-read install.sh. Fix: reword T7(a) to "scoped to Claude Code (the only adapter whose hook intercepts tool calls)".

**F-3 (Nit) — "numbered rules" phrasing vs 124.** README L159 says "102 numbered rules"; the correct distinct-ID count is **124**, but 2 of those are lettered (R-0a, R-0b; 122 numbered + 2 lettered, verified below). If a number is kept, prefer "124 rules"/"124 distinct rules" or the plan's count-free option; "124 numbered rules" would be off by two on its own terms. The plan's recount command and its 124 figure are themselves correct.

**F-4 (Nit) — AC-F-04 link-extraction regex skips targets starting with "h".** Plan L147: `[^)#h]` (meant to exclude `http`) also silently drops any relative link beginning with "h" (e.g. `heatwave.config.example.yaml`). No such link exists in the three files today (verified), so the AC is sound as pinned; noting so a future link doesn't slip the net. `[ -e "docs/$f" ]` fallback could also false-pass a root-broken link that exists under docs/ — the stated reviewer sanity-read covers both.

## Acceptance Status

N/A — PLAN_REVIEW (AC table applies at FINAL_REVIEW).

## Verification Log

Machine evidence (R-110): tests | none exists | NOT_AVAILABLE — markdown-only repo, no test framework (R-64); affects no AC (all ACs are grep/shell/read). sast | semgrep | deferred to FULL/FINAL per plan (prose diff; binary confirmed present). secrets | gitleaks | FINAL rung per R-121 (binary confirmed present).

| Item | Method | Result | Evidence |
|---|---|---|---|
| Rule count = 124 | `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md \| sort -u \| wc -l` on main @ 2856943 | **124** — plan's number correct; README "102" is real drift | ID list = R-0a, R-0b, R-1…R-122; 127 raw `**R-` lines reduce to 124 distinct because R-106 (2 halves) and R-113 (3 halves) repeat; `cat protocol/*.md` gives the same 124 (shards agree) |
| Claim→rule table (all 16 rows) | grep each cited rule in PROTOCOL.md/protocol/, read against the claim | **All rows accurate; no overclaim found** | R-0a/0b/101 intake+tier ✓; R-102 sensitive-never-EXPRESS ✓; R-103/104 EXPRESS + independent machine gate ✓ (implementer.md §4.8 exists ✓); R-108 shards canonical ✓; R-110 ladder tests→SAST→mutation, reviewer executes rungs itself, mutation FULL-only ✓; R-111 machine findings ✓; R-112 refute-or-promote ✓; R-113/114 red-then-green ✓; R-115 different-family advisory ✓; R-116 tiering, zero-config unchanged ✓; R-117 persistent reviewer ✓; R-118 delta-only FINAL + full machine re-run ✓; R-119–R-122 companions optional/NOT_AVAILABLE ✓; R-121 secrets rung ✓; R-17/87/88 + §9.3 "the loop never restarts" ✓; R-1/2/12 role separation ✓ |
| Hooks row | read install.sh L78–210, adapters/claude-code/role-gate.sh, adapters/codex/hooks.json, adapters/gemini/gemini-gate.sh | Row accurate and correctly scoped (see F-2 for the T7(a) prose looseness) | PreToolUse `Edit\|Write` → role-gate.sh exit-2 block (Claude Code); UserPromptSubmit `cat GATE.md` (Codex); BeforeAgent additionalContext injection (Gemini) |
| 12 adapters / install.sh line 21 | read install.sh | ✓ case list at L21: `claude codex gemini cursor copilot windsurf cline zed amp opencode aider generic` = 12 | matches T8(a)/AC-F-06 exactly |
| Benchmark honesty framing | read RESULTS.md + METHODOLOGY.md + benchmark/README.md in full | Plan matches reality: headline "delta UNCOMPUTABLE… proves the rig, not a delta"; RESULTS itself says do not quote "0/3 vs 0/3"; run commands `sh benchmark/run.sh --arm raw\|heatwave` exist verbatim; corpus = 8 tasks, oracle-unreachable scratch, freeze commit `cfeaf8f`, check-corpus.sh present | RESULTS.md L6–11, L58, L97–98; METHODOLOGY.md L40–43, L84–89, L154–159; `ls benchmark/corpus` = 8 |
| FAQ drift (T7) real | `grep -n 'on the roadmap\|Claude Code today' docs/faq.md` | Both present (L28, L50) and both stale vs install.sh — fixes accurate | role-gate shipped (Claude Code); Codex+Gemini per-turn gate hooks shipped |
| Getting-started drift (T8) real | read step 2 + step 4; §2.3 budgets | Step 2 lists 4 of 12 adapters ✓ drift; step 4 starts at PLANNING, no intake line ✓ drift; budgets 3/5/2 confirmed unchanged in §2.3 | getting-started L24, L61–77; PROTOCOL §2.3 table |
| Structure-preservation ACs pinned to reality | ran AC-F-07 greps on current README | `prove its work` present (L13); `grep -c 'assets/'` = 5; all 7 listed `## ` headings present verbatim | grep output |
| Roadmap (G/H) | read README/docs; AC-F-03 | No multi-repo/CLI-product claims exist today; "Gemini CLI" false-positive anticipated by the AC | grep |
| AC-F-04 link check | ran extraction on the 3 files; existence-checked targets | All current relative targets exist (docs/example.md, docs/loop.md, plugins/ponytail/ATTRIBUTION.md, COMPANIONS.md, PROTOCOL.md, adapters/README.md…) | see F-4 for the "h"-prefix regex nit |
| Tooling declaration | `command -v semgrep gitleaks` | Both present at /opt/homebrew/bin — declaration truthful | shell output |
| Drift check green | plan L187 claims run green; script exists at repo root | Accepted (re-run at T10 + review anyway per AC-N-02) | — |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Final README prose itself | Does not exist yet — plan-stage review; AC-F-01/02/03 re-run for real at FULL/FINAL | none at this gate |

## Summary

The plan is honest and executable. Its central artifact — the 16-row claim→rule mapping — was verified row-by-row against `PROTOCOL.md`/`protocol/` on main @ 2856943: every planned capability sentence has a shipped backing rule stating what the claim says; no overclaim. The correct rule count is **124** distinct IDs (README's "102" is real drift; the plan's recount command and figure are right — see F-3 on the word "numbered"). The benchmark section is locked to the honest framing: rig + 8-task corpus exist, verbatim run commands, "inconclusive, no delta", METHODOLOGY.md link mandatory, and quoting any RESULTS number is banned in prose — F-1 asks the mechanical grep to also cover `0/4`/`0/1` (the actual pilot figures), which today only the reviewer-read clause catches. Roadmap honesty is handled by defaulting to no G/H mention with a labeled-future fallback and a grep. Both drift fixes (FAQ hook-roadmap staleness; getting-started 4-of-12 adapters + missing intake line) are confirmed real against install.sh, with F-2 tightening T7(a)'s scoping so source-edit *blocking* is claimed only for Claude Code. Scope is docs-only with pinned guards; the structure-preservation ACs match the current README exactly; tooling declarations were independently re-verified. Zero Blockers, zero Majors — gate met. The two Minors and two Nits are implementation-time corrections the IMPLEMENTER applies during the build; they do not require a plan re-spin.
