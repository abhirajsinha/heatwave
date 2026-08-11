# Implementation Package — Positioning / README Refresh (v4 Sub-project F)

task_id: positioning-readme | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

Plan: `docs/superpowers/plans/2026-08-11-positioning-readme.md` (APPROVED at PLAN_REVIEW, `docs/superpowers/reviews/2026-08-11-plan-review-F.md`). Branch: `heatwave-v4-subproject-f` off main @ `2856943`.

## Tasks completed

| Task | Commit | What shipped |
|---|---|---|
| T1 hook/habits pass | (no-op, noted in T2 commit) | Planning read confirmed: no sentence in README L1–37 conflicts with v4 — zero edits, per plan ("only touch if a sentence conflicts; none found") |
| T2 intake sentence | `cb0de45` | One sentence before step 1 of "How a task actually runs": driver sizes the task; trivial single-file edit runs EXPRESS (change + one independent machine-gated check by a fresh context). Wording matches the existing overhead `<details>` block ("independent machine-gated check") — one consistent EXPRESS description, no duplication |
| T3 "What's new in v4" | `b75058c` | 7 bullets: adaptive intake+EXPRESS (+sensitive-paths-never-EXPRESS), sharded protocol+drift check, machine-evidence ladder (mutation scoped FULL-only), refute-or-promote, reproduce-then-fix, model-tiering+delta review, companions (COMPANIONS.md linked; "honest gap" phrasing). Inserted after "How a task actually runs", before "Setup" |
| T4 "How it differs" | `f9cde58` | Factual bolt-on-reviewer contrast, no competitor named, no bug-catching claim; 4 differentiators: vendor-neutral/no-deps, on-disk evidence ledger, never-restart resume, role separation |
| T5 "Benchmark" | `2d499e1` | Rig + 8-task corpus + withheld oracles; verbatim run commands from `benchmark/README.md` L30–31; "**inconclusive** … **no performance delta is claimed**"; invitation to contribute runs; links METHODOLOGY.md + RESULTS.md. Placed before "Learn more" (plan-permitted position). No number from RESULTS.md quoted |
| T6 small-fact fixes | `44de776` | "102 numbered rules" → "124 rules" (recounted at write time = 124; Nit F-3 applied — not "numbered"); benchmark row added to Learn-more table |
| T7 FAQ drift | `9cdcb6c` | (a) "on the roadmap" clause → present tense, **blocking scoped to Claude Code only** ("the only adapter whose hook intercepts tool calls"; Codex/Gemini re-inject, can't block) — Minor F-2 applied; (b) "(Claude Code today)" → "(Claude Code, Codex, Gemini CLI)" for per-turn gate hooks, edit-blocking + subagent isolation kept Claude-Code-only |
| T8 getting-started drift | `4c67453` | (a) step 2 lists all 12 adapters (matches `install.sh` L21 case list exactly); (b) step 4 gains the intake/tier line (EXPRESS = no plan; walkthrough = standard loop) |
| T9 claim→rule table | this file | Below, as-shipped |
| T10 guards | this file | Evidence below |

## Deviations (not self-approved — for REVIEWER judgment)

1. **AC-F-02 grep pattern refined**: plan pattern `[0-9]+ ?%` matches the pre-existing badge URL `setup-3%20minutes` (digit `3` before `%` — the plan's "badges pass" parenthetical was wrong for this one badge; verified by running the plan's exact pattern → hit on README L8). Shipped pattern uses `[0-9]+ ?%([^0-9]|$)` so URL-encoding (`%` followed by a digit) is excluded while any real percentage claim ("38%", "38 %.") still matches. Also broadened with `0/[0-9]` per Minor F-1. The AC's intent (no %-delta claim anywhere) is preserved and mechanically stronger; the badge is untouched.
2. **AC-F-01 mechanical grep form**: `grep -n '^\*\*R-113\.' PROTOCOL.md` is empty because R-113 ships as three "half" entries (`**R-113 (planner half).` L454, `(implementer half)` L657, `(reviewer half)` L757). Rule exists; checked with `grep -n '\*\*R-113'`. Same for no other cited rule (all others matched the literal-dot form).

Nit F-4 (link-regex "h"-prefix skip): no relative link starting with "h" was added; the plan's command remains sound as pinned (run below).

## Claim→rule table (as shipped — every capability sentence written)

| # | Shipped sentence (location) | Backing |
|---|---|---|
| 1 | Driver sizes the task; trivial edit runs EXPRESS = change + one independent machine-gated check by a fresh context (README "How a task actually runs" + step-4 line in getting-started) | R-101, R-0a/R-0b intake+tier; R-103/R-104 EXPRESS + independent machine gate (`protocol/core.md` §0.5, `protocol/implementer.md` §4.8) |
| 2 | Adaptive intake bullet; "sensitive paths like auth, payments, or migrations can never take that shortcut" (README v4 §) | R-101, R-102 (`protocol/core.md`) |
| 3 | Sharded protocol; each role loads its shard; PROTOCOL.md generated; drift check (README v4 §) | R-108 + `build-protocol.sh` |
| 4 | Reviewer itself runs tests → static analysis → mutation (FULL-tier only); machine findings converted (README v4 §) | R-110 (`protocol/core.md`), R-111 (`protocol/reviewer.md`) |
| 5 | Refute-or-promote: reviewer tries to disprove serious findings first; survivors promoted with evidence (README v4 §) | R-112 (`protocol/reviewer.md`) |
| 6 | Reproduce-then-fix: failing repro before, same repro green after (README v4 §) | R-113 (3 halves), R-114 (`protocol/planner.md`, `protocol/implementer.md`, `protocol/reviewer.md`) |
| 7 | Stage model-tiering, zero-config default unchanged; delta-only final review + full machine-gate re-run (README v4 §) | R-116, R-118 (`protocol/core.md`); persistent reviewer R-117 already covered in FAQ (pre-existing) |
| 8 | Companions optional/verified; missing tool = honest gap (README v4 § + pre-existing Good-to-know bullet) | R-119–R-122 (`protocol/core.md` §6.5), `COMPANIONS.md` |
| 9 | Vendor-neutral, markdown + one shell script, no deps, 12 agents, cross-tool resume (README "How it differs") | `install.sh` (POSIX sh, adapter case L21), `adapters/`, R-88 |
| 10 | Evidence ledger on disk before next step; every claim traces to a file (README "How it differs") | R-17, R-87 |
| 11 | Never-restart resume; redoing finished work against the rules (README "How it differs") | R-88, §9.3 |
| 12 | Roles never grade their own work; approval requires attached evidence (README "How it differs") | R-1, R-2, R-12; R-65/R-68 evidence rules |
| 13 | Benchmark: reproducible rig, 8-task corpus, withheld oracles, frozen pre-run; pilot inconclusive, no delta claimed (README "Benchmark") | `benchmark/METHODOLOGY.md` §2, `check-corpus.sh`, `ls benchmark/corpus` = 8; `benchmark/RESULTS.md` headline ("delta UNCOMPUTABLE") |
| 14 | FAQ: Claude Code PreToolUse gate physically blocks source edits; Codex/Gemini hooks re-inject, can't block; per-turn gate hooks on 3 tools (docs/faq.md) | `install.sh` hook installs; `adapters/claude-code/role-gate.sh` (exit-2 block), `adapters/codex/hooks.json` (UserPromptSubmit cat GATE.md), `adapters/gemini/gemini-gate.sh` (BeforeAgent injection) |
| 15 | "124 rules" (README Learn-more) | `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md \| sort -u \| wc -l` → 124, run at write time (evidence below) |

Roadmap items G (multi-repo) / H (CLI): **not mentioned anywhere** (plan's default). AC-F-03 grep hits are all "Gemini CLI"/"Cline" false positives — see evidence.

## AC → evidence

**AC-F-01** — mechanical rule-existence check (all 25 cited IDs):
```
$ for r in R-0a R-0b R-1 R-2 R-12 R-17 R-87 R-88 R-101 ... R-122; do grep -q "^\*\*$r\." PROTOCOL.md && echo "$r ok"; done
→ all "ok" except R-113 (ships as '**R-113 (planner half).' etc — present at PROTOCOL.md L454/657/757, verified by grep -n '\*\*R-113')
```
Row-by-row semantic check is the REVIEWER's (table above is the input).

**AC-F-02** — forbidden-pattern grep (F-1 broadened, %-pattern refined per Deviation 1):
```
$ grep -nE '0/[0-9]|fewer bugs|[0-9]+ ?%([^0-9]|$)|[0-9]+(\.[0-9]+)?[x×] (fewer|faster|better|cheaper)' README.md docs/faq.md docs/getting-started.md
exit=1   (no output — nothing present)
$ grep -n '0/3\|0/4\|0/1' README.md docs/faq.md docs/getting-started.md
exit=1   (no output)
$ grep -ci 'inconclusive' README.md
1
```

**AC-F-03** — `grep -niE 'multi-repo|enterprise|CLI' README.md docs/faq.md docs/getting-started.md` → 11 hits, every one is "Gemini CLI", "Cline", or the CLI-substring of those in pre-existing/adapter text; zero G/H feature claims (full output in run transcript; sample: README L17 tool list, faq L50 enforcement ladder).

**AC-F-04** — plan's link-extraction + existence check → **no MISSING lines**. Linked targets (all exist): `adapters/README.md, benchmark/METHODOLOGY.md, benchmark/RESULTS.md, COMPANIONS.md, docs/example.md, docs/faq.md, docs/getting-started.md, docs/loop.md, plugins/ponytail/ATTRIBUTION.md, PROTOCOL.md`. `benchmark/METHODOLOGY.md` present among targets as required.

**AC-F-05** — `grep -n 'on the roadmap' docs/faq.md` → exit=1 (none); `grep -n 'Claude Code today' docs/faq.md` → exit=1 (none).

**AC-F-06** — `sed -n '21p' install.sh` → `case "$ADAPTER" in claude|codex|gemini|cursor|copilot|windsurf|cline|zed|amp|opencode|aider|generic)`; getting-started L26 lists `claude` + the other 11 — exact match, 12 of 12. Intake line present in step 4.

**AC-F-07** — `grep -c 'prove its work' README.md` → 1; `grep -c 'assets/' README.md` → 5 (unchanged set); `grep -n '^## '` → all 7 pre-existing headings present ("What is this?", "Why you'd want it", "How a task actually runs", "Setup (3 minutes)", "Good to know", "Learn more", "License") + the 3 new sections ("What's new in v4", "How it differs", "Benchmark").

**AC-F-08** — `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md | sort -u | wc -l` → **124** at write time; README states "124 rules" (count-word "numbered" dropped per Nit F-3: 122 numbered + R-0a/R-0b lettered).

**AC-N-01** — `git diff main...HEAD --stat`:
```
 README.md               | 35 ++++++++++++++++++++++++++++++++++-
 docs/faq.md             |  4 ++--
 docs/getting-started.md |  4 ++--
 3 files changed, 38 insertions(+), 5 deletions(-)
```
Zero lines in `protocol/`, `PROTOCOL.md`, `install.sh`, `adapters/`, `benchmark/`, `templates/`, `prompts/`. (This package + plan/spec/review trail under `docs/` commit after this snapshot — permitted run artifacts per the AC.)

**AC-N-02** — `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit=0.

**AC-N-03** — structure preserved: diff is 3 inserted sections + 1 inserted sentence + 2 line-edits in README; hook paragraph, habit list, 5-step list, both `<details>` blocks, all 5 image tags untouched (see per-task commits `cb0de45`…`44de776` for isolated diffs).

## Files changed / blast radius

- `README.md` (+35/−1): 1 sentence + 3 new sections + 2 table-row edits. Rendered copy only.
- `docs/faq.md` (+2/−2): two answers' stale clauses.
- `docs/getting-started.md` (+2/−2): step-2 adapter list, step-4 intake line.
- Run artifacts: this package + plan/spec/plan-review under `docs/specs/`, `docs/superpowers/`.
- Blast radius: zero executable surface — no protocol rule, script, adapter, or benchmark file touched; GitHub-rendered markdown only. Rollback = revert the docs commits.

## Machine-verification declaration (R-64)

Tests: NOT AVAILABLE (markdown-only repo, no framework) — affects no AC. SAST (semgrep) + secrets (gitleaks): binaries present; reviewer-run rungs at FULL/FINAL per plan. Drift check run green (above).
