# Planning Document — Positioning / README Refresh (v4 Sub-project F)

task_id: positioning-readme | artifact_type: planning-document | iteration: 1 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Spec (source of truth): `docs/specs/2026-08-11-positioning-readme-design.md`. All locked decisions honored exactly.

## Tier

STANDARD — docs-only and technically trivial, but user-facing/reputational: the honesty constraints (spec §4) make the review the actual product of this run (PROTOCOL §0.5).
Change class: **feature** — the purpose is new positioning copy (three new sections) with drift corrections riding along; no executable red/green reproduction exists for prose, so `bugfix`/R-113 does not fit. The drift fixes are instead pinned by their own ACs (AC-F-05/06/07). (R-114)

## Problem Statement

README, FAQ, and getting-started still describe pre-v4 Heatwave. A–E shipped (EXPRESS+intake, shards, machine-evidence ladder, refute-or-promote, reproduce-then-fix, model-tiering, delta-review, companions, benchmark rig) and none of it is in the public copy; the differentiation story (vendor-neutral auditable process + evidence ledger vs bolt-on reviewers) is unstated. Refresh the copy under a hard honesty constraint: no claim beyond what is on main, and the benchmark presented as an honest inconclusive rig — never a win.

## Functional Requirements

1. README keeps the "prove its work" hook + three-bad-habits framing; body refreshed for v4 (spec §5.1–5.2, locked).
2. README gains a concise "What's new in v4" section — every bullet backed by a shipped rule (spec §5.3).
3. README gains a "How it differs" section — vendor-neutral, no-deps, on-disk evidence ledger + never-restart resume, roles never grade their own work; factual contrast with bolt-on reviewers, **no competitor names** (spec §5.4, locked).
4. README gains a "Benchmark" section — rig exists in `benchmark/`, how to run it, pilot **inconclusive**, **no delta claimed**, link `benchmark/METHODOLOGY.md` (spec §5.5, locked).
5. `docs/faq.md` and `docs/getting-started.md` corrected only where they misstate v4 (drift found: see Tasks T7–T8).
6. An explicit **claim→rule mapping table** delivered as review evidence (seeded below; implementer finalizes it in the Implementation Package for every capability sentence actually written).

## Non-Functional Requirements

- Honesty invariants (spec §4): every capability sentence maps to a merged rule/file; no benchmark %, "fewer bugs", speed/quality delta, or the literal string `0/3` as a result; any G (multi-repo) / H (CLI) mention labeled not-yet-built; no competitor misrepresented.
- Structure preservation (ponytail): refresh in place; all 5 existing `assets/*.svg` references and the existing section order survive; new sections are inserted, nothing rewritten wholesale.
- Docs-only diff; `build-protocol.sh --check` stays OK.

## Architecture

Three markdown files, one direction of truth: `protocol/` shards + `install.sh` + `benchmark/RESULTS.md`/`METHODOLOGY.md` are the reality; `README.md`, `docs/faq.md`, `docs/getting-started.md` are the copy being conformed to it. No code, no build, no data flow. `PROTOCOL.md` and `protocol/` are read-only inputs.

## API Design

N/A — documentation change, no contracts.

## Data Design

N/A — no schema or storage.

## State Management

N/A — no runtime state.

## Error Handling Strategy

N/A — prose. The failure mode is overclaim/drift, handled by the acceptance criteria and review greps, not runtime handling.

## Security Considerations

None introduced — no code, no secrets, no config. Secrets rung still runs on the diff at FINAL (R-121; gitleaks available).

## Edge Cases

- **Rule-count drift**: README says "102 numbered rules"; current count of distinct `R-*` IDs is 124 (verified: `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md | sort -u | wc -l` → 124 on main @ 2856943). The implementer MUST re-run this at write time and use the fresh number (or a count-free phrasing) — not copy 124 blindly.
- **The existing EXPRESS mention**: README's "overhead" details block already describes EXPRESS/LIGHT/FULL; T3 must not duplicate it — cross-check wording against R-103/R-104 and keep one consistent description.
- **"0/4" and cost numbers**: RESULTS.md contains real numbers (0/4 RAW, $12.37, 60×/80× cost/wall). The README benchmark section quotes **none of them** — not even the unfavorable ones — because any number invites delta arithmetic; it links METHODOLOGY.md/RESULTS.md and states "inconclusive, no delta claimed" in prose. (Mentioning that the pilot surfaced a real cost/latency finding is allowed only as unquantified prose, and only if the implementer keeps it clearly non-comparative on quality.)
- **"vs" grep false positives**: README legitimately contains no performance "X vs Y" today; the AC grep targets result-claims, with a reviewer read as the backstop (mechanical grep can't catch every phrasing).
- **Benchmark run commands**: copy them from `benchmark/RESULTS.md` / `benchmark/README.md` verbatim (`sh benchmark/run.sh --arm …`) — do not invent flags.

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Capability sentence exceeds shipped reality | Medium (easy to slip in marketing) | Claim→rule table mandatory (T9); reviewer treats any unmapped claim as Major (spec §7) |
| Benchmark copy drifts into a win-claim | Medium | AC-F-02 forbidden-pattern grep + reviewer read; locked wording skeleton in T5 |
| Roadmap (G/H) reads as present | Low | Default is to not mention G/H at all; if mentioned, explicit "not yet built" label (AC-F-03) |
| FAQ/getting-started edits overreach beyond drift | Low | T7/T8 enumerate the exact drift lines; anything else is out of scope |
| Accidental protocol/ or install.sh edit | Low | AC-N-01 docs-only diff + AC-N-02 drift check |

## Dependencies

- A–E merged on main — **fact**, verified: `git log` head `2856943`, `build-protocol.sh --check` → OK, R-101…R-122 present in `PROTOCOL.md`/shards.
- `benchmark/RESULTS.md` + `METHODOLOGY.md` committed with the honest inconclusive framing — **fact**, read in full.
- `COMPANIONS.md` already v4-refreshed by D — **fact**, read; F links it, never duplicates it.
- No external dependencies. No new files created in the repo (the claim→rule table travels in the Implementation Package, not as a new doc).

## Testing Strategy

No executable test suite exists or applies (markdown repo). Verification is: (1) mechanical greps with pinned expected output (ACs below), run by the IMPLEMENTER and re-run independently by the REVIEWER; (2) the claim→rule table checked entry-by-entry against `PROTOCOL.md` by the REVIEWER; (3) `build-protocol.sh --check`; (4) link-existence shell check; (5) SAST/secrets ladder rungs on the diff (tools confirmed below).

## Rollout Plan

Single commit to `main` per repo practice (docs ship immediately on push to GitHub). No flags/staging — N/A beyond that.

## Rollback Plan

`git revert <commit>` of the single docs commit restores the previous README/docs exactly; no state, data, or installs depend on the copy.

---

## Tasks (ordered; exact files; no placeholders)

**T1 — README hook & habits: light-touch pass.** `README.md` lines 1–37. Keep the banner/badges, the "prove its work" sentence, the three-role paragraph, the 12-tool list, the three bad habits + three fixes, and `assets/roles.svg`. Allowed edits: none required; only touch if a sentence conflicts with v4 (none found in planning read).

**T2 — "How a task actually runs": intake sentence.** `README.md` §"How a task actually runs". Add one sentence (before or after step 1) stating that the driver first sizes the task — a trivial single-file edit skips the full loop and runs EXPRESS: the change plus one machine-gated check by a context that didn't make it (R-101/R-103/R-104). Keep `assets/loop.svg`, the 5 numbered steps, the runs-without-stopping and never-loses-progress blocks, `assets/resume.svg`, both `<details>` blocks. Reconcile wording with the existing overhead-details block (edge case above) — one consistent EXPRESS description.

**T3 — New section "What's new in v4".** Insert into `README.md` after "How a task actually runs" (before "Setup"). One short bullet list, each bullet ≤ 2 lines, each backed by the mapping table (T9 / seed below): adaptive intake + EXPRESS tier; sharded protocol (cheaper per-role context); machine-evidence ladder (tests → static analysis → mutation) run by the reviewer itself; refute-or-promote for Major+ findings; reproduce-then-fix for bugfixes (red before, green after); stage model-tiering + delta-only final review (cheaper/faster); optional detected companions (link `COMPANIONS.md`, state "none required; absent = honestly reported gap"). No other v4 features may be claimed.

**T4 — New section "How it differs".** Insert after T3's section. Factual contrast, no competitor names: most AI code-review tooling is a bolt-on reviewer that inspects a diff; Heatwave gates an end-to-end *process* — vendor-neutral (any agent, incl. resuming across tools), zero dependencies (markdown + one shell script), an on-disk evidence ledger every claim traces to, and role separation so no context ever approves its own work. Each differentiator maps to a rule in T9's table. Forbidden: naming any product, characterizing any competitor's quality, or claiming Heatwave "catches more bugs" (unproven — see T5).

**T5 — New section "Benchmark".** Insert after T4 (or before "Learn more"). Content, fixed skeleton: (a) a reproducible harness + 8-task seeded-defect corpus with withheld oracles lives in `benchmark/` — link `benchmark/METHODOLOGY.md` (required) and `benchmark/RESULTS.md`; (b) how to run it — verbatim `sh benchmark/run.sh --arm raw` / `--arm heatwave` invocation copied from benchmark docs; (c) the plain statement that the pilot is **inconclusive**: too few completed protocol-arm runs to compute any comparison, **no performance delta is claimed**; (d) an invitation to run it and file results. Forbidden in this section and everywhere: any %, "fewer bugs", "faster", any RAW-vs-HEATWAVE number, and the literal string `0/3`.

**T6 — README small-fact fixes.** (a) "102 numbered rules" in the Learn-more table → the freshly recounted number (edge case above) or a count-free phrasing; (b) add a Learn-more table row for the benchmark (`benchmark/METHODOLOGY.md` — "How the benchmark works and exactly what it does and doesn't show"); (c) verify every relative link in the final README resolves.

**T7 — `docs/faq.md` drift fixes (only these).** (a) "Does the AI ever still cut corners?" answer claims hook-level source-edit blocking "is on the roadmap" — it **shipped** (`install.sh` installs a `PreToolUse` `Edit|Write` gate running `sh .heatwave/role-gate.sh`; README already says so). Rewrite that clause to present tense, scoped to tools with hooks. (b) "Will it work with agents that don't exist yet?" says per-turn gate hooks "(Claude Code today)" — Codex (`.codex/hooks.json` UserPromptSubmit) and Gemini CLI (BeforeAgent in `.gemini/settings.json`) also have them per `install.sh`; update the parenthetical. No other FAQ edits (the tiers answer already covers EXPRESS correctly).

**T8 — `docs/getting-started.md` drift fixes (only these).** (a) Step 2 "Replace `claude` with your tool: `codex` · `gemini` · `cursor` · `generic`" omits 8 supported adapters — list all 12 (`codex gemini cursor copilot windsurf cline zed amp opencode aider generic`) or list a few + "see README for all 12". (b) Step 4's flow starts at PLANNING with no intake — add one line that the driver first classifies the tier (trivial edits run EXPRESS with no plan; this walkthrough shows the standard loop). No other edits; the escalation budgets (3/5/2) match §2.3 unchanged — verified against `docs/faq.md`/PROTOCOL §2.3.

**T9 — Claim→rule mapping table (review evidence, not a repo file).** The implementer finalizes this table in the Implementation Package with one row per capability sentence actually written in T2–T5, citing rule + file. Seed (verified against `protocol/` on main @ 2856943):

| README claim | Shipped backing |
|---|---|
| Adaptive intake; ceremony scales; tier recorded | R-101, R-0a/R-0b — `protocol/core.md` §0.5 |
| EXPRESS: trivial edit + independent machine-gated check, no plan | R-103, R-104 — `protocol/core.md`, `protocol/implementer.md` §4.8 |
| Sensitive paths can never run EXPRESS | R-102 — `protocol/core.md` |
| Sharded protocol; PROTOCOL.md generated; per-role shards | R-108 — `protocol/` + `build-protocol.sh` |
| Machine-evidence ladder tests→SAST→mutation, reviewer-run | R-110 — `protocol/core.md`; findings conversion R-111 — `protocol/reviewer.md` |
| Refute-or-promote before Major+ findings gate | R-112 — `protocol/reviewer.md` |
| Bugfixes need a red-then-green reproduction | R-113, R-114 — `protocol/planner.md`, `protocol/reviewer.md` |
| Stage model-tiering (cheap model for mechanical stages, zero-config unchanged) | R-116 — `protocol/core.md`; different-family reviewer advisory R-115 |
| Delta-only final review + full machine-gate re-run | R-118 — `protocol/core.md`; persistent reviewer R-117 |
| Companions optional/detected, never required; absent = explicit NOT AVAILABLE | R-119–R-122 — `protocol/core.md` §6.5, `COMPANIONS.md` |
| Secrets scan rung at final review when a scanner is present | R-121 — `protocol/core.md` |
| Evidence ledger on disk; never-restart resume, cross-tool | R-17, R-87, R-88 — PROTOCOL.md (v3, unchanged) |
| Roles never grade their own work; context isolation | R-1, R-2, R-12 — PROTOCOL.md §1.2 |
| No dependencies; markdown + one install script; 12 tool adapters | `install.sh` (POSIX sh; adapter case list), `adapters/` |
| Hook enforcement: prompt re-injection + source-edit gate (Claude Code), per-prompt gate (Codex), BeforeAgent gate (Gemini) | `install.sh` lines installing GATE.md hooks, `role-gate.sh`, `.codex/hooks.json`, `.gemini/settings.json` |
| Benchmark rig: 8 tasks, withheld oracles, discrimination-gated corpus, frozen pre-run | `benchmark/METHODOLOGY.md` §2, `check-corpus.sh`; pilot inconclusive — `benchmark/RESULTS.md` headline |

**T10 — Guards (last).** Run and record: `sh build-protocol.sh --check` (expect `OK: PROTOCOL.md matches protocol/ shards`); `git diff --stat` (docs-only); the AC-F-02 forbidden-pattern grep; the AC-F-04 link check.

---

## Acceptance Criteria

### Functional

AC-F-01 | Every v4 capability sentence in the final README maps to a row in the Implementation Package's claim→rule table, and every cited rule exists on main | Verification: REVIEWER reads the table row-by-row and confirms each cited rule ID/file in `PROTOCOL.md`/`protocol/` states what the claim says; any unmapped or exceeded claim = Major (spec §7). Mechanically: for each cited `R-NNN`, `grep -n '^\*\*R-NNN\.' PROTOCOL.md` is non-empty.

AC-F-02 | No benchmark overclaim anywhere in the diff | Verification: `grep -nE '0/3|fewer bugs|[0-9]+ ?%|[0-9]+(\.[0-9]+)?[x×] (fewer|faster|better|cheaper)' README.md docs/faq.md docs/getting-started.md` → **no output** (exit 1); `grep -ci 'inconclusive' README.md` ≥ 1; plus REVIEWER read of the Benchmark section confirming no comparative quality/speed claim in any phrasing and no RAW/HEATWAVE numeric result quoted. (The shields.io badge URLs contain `%20` — pattern above requires a digit before `%`, so badges pass; reviewer confirms any other grep hit is a false positive before waiving, and none is expected.)

AC-F-03 | Roadmap honesty | Verification: `grep -niE 'multi-repo|enterprise|CLI' README.md docs/faq.md docs/getting-started.md` — every hit (if any) is either pre-existing non-roadmap text (e.g. "Gemini CLI") or explicitly labeled not-yet-built; presenting G/H as existing = Major. Default expectation: G/H not mentioned at all.

AC-F-04 | All relative links in the three edited files resolve | Verification: from repo root, `grep -oE '\]\(([^)#h][^)#]*)' README.md docs/faq.md docs/getting-started.md | sed 's/](//' | sort -u | while read -r f; do [ -e "$f" ] || [ -e "docs/$f" ] || echo "MISSING $f"; done` → no `MISSING` lines (README links resolve from root, docs/ links from `docs/`; reviewer sanity-reads the mapping). `benchmark/METHODOLOGY.md` MUST appear among the linked targets.

AC-F-05 | FAQ drift fixed | Verification: `grep -n 'on the roadmap' docs/faq.md` → no output; `grep -n 'Claude Code today' docs/faq.md` → no output; replacement text names the shipped mechanisms consistently with `install.sh` (REVIEWER cross-reads install.sh).

AC-F-06 | Getting-started drift fixed | Verification: every adapter named in `install.sh`'s case list (`claude codex gemini cursor copilot windsurf cline zed amp opencode aider generic`) is either listed in `docs/getting-started.md` step 2 or covered by an explicit "all 12 — see README" pointer; an intake/tier line exists in step 4. REVIEWER compares against `install.sh` line 21.

AC-F-07 | Hook and structure preserved | Verification: `grep -c 'prove its work' README.md` ≥ 1; `grep -c 'assets/' README.md` = 5 (banner, demo, roles, loop, resume — unchanged set); the pre-existing top-level section headings ("What is this?", "Why you'd want it", "How a task actually runs", "Setup (3 minutes)", "Good to know", "Learn more", "License") all still present via `grep -n '^## '`.

AC-F-08 | Rule count accurate | Verification: the number of protocol rules stated in README (if a number is stated) equals the output of `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md | sort -u | wc -l` run at review time (124 at planning); a count-free phrasing also passes.

### Non-functional

AC-N-01 | Docs-only diff | Verification: `git diff main-pre-F..HEAD --stat` (or `git show --stat` of the single commit) lists only `README.md`, `docs/faq.md`, `docs/getting-started.md` (plus this plan/spec and run artifacts under `docs/` / `.heatwave/`); zero lines touching `protocol/`, `PROTOCOL.md`, `install.sh`, `adapters/`, `benchmark/`, `templates/`, `prompts/`.

AC-N-02 | No protocol drift | Verification: `sh build-protocol.sh --check` → exit 0, prints `OK: PROTOCOL.md matches protocol/ shards`.

AC-N-03 | Refresh, not rewrite (ponytail) | Verification: REVIEWER inspects `git diff README.md` — hook paragraph, habit list, step list, both `<details>` blocks, and all image tags survive with at most light edits; wholesale reflow of untouched sections = finding.

## Review Scope

Applicable
✓ plan-conformance — locked decisions (hook kept, differ section, honest benchmark) are the spec; deviation is the primary defect class
✓ verification-integrity — the entire task is claims-vs-evidence; every AC grep must be actually run, output attached
✗ All Frontend categories — no UI code; README renders as GitHub markdown, no interaction surface
✗ All Backend categories — no code
✗ All Security categories — no code paths, no secrets introduced (secrets rung still runs at FINAL per R-121)
✗ All Performance categories — prose
✗ All Reliability categories — prose
✗ All Observability categories — prose

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Unit | none exists | — | NOT AVAILABLE — markdown-only repo, no test framework evidence (no package.json/pyproject/go.mod); affected ACs: none — all ACs verify via grep/shell/read (R-64) |
| SAST (STANDARD+) | semgrep | REVIEWER | confirmed — binary at `/opt/homebrew/bin/semgrep` (verified `command -v`); expected trivially clean on a prose diff (R-110) |
| Mutation | — | — | N/A — STANDARD tier; mutation is FULL-only (R-110) |
| Secrets (FINAL rung) | gitleaks | REVIEWER | confirmed — binary at `/opt/homebrew/bin/gitleaks` (verified `command -v`) (R-121) |
| UI evidence | — | — | NOT AVAILABLE — change_surface has no `ui` (R-120) |
| Docs lookup | context7 MCP | PLANNER/REVIEWER | available in this environment; not needed — no external-library API claims (R-120) |
| Drift check | build-protocol.sh --check | IMPLEMENTER + REVIEWER | confirmed — script at repo root, run green during planning |

change_surface: **none** — documentation copy only; no auth/payments/input/endpoint/ui/deps/secrets/api surface touched (R-122).
