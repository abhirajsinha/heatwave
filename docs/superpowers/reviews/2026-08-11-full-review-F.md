# Review Report

task_id: positioning-readme | artifact_type: review-report | iteration: 2 | review_type: TARGETED_REVIEW (iteration 1 FULL_REVIEW preserved below) | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict (TARGETED_REVIEW, iteration 2 — current)

GATE_MET — **APPROVED at this gate**
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 0 open (F-FR-2 closed)

Scope: fix delta of commit `f8b7622` (README.md 2 lines, docs/faq.md 1 line) + regression checks. All prior findings closed; no new findings.

## Reconciliation (iteration 2)

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-FR-1 (Major) | open | **closed** | Both unqualified "physically blocks source edits" claims rewritten honestly. faq.md:28 now: "a `PreToolUse` gate mechanically blocks the agent's Edit/Write tool calls while the run state assigns them to another role. It's a tool gate, not a filesystem sandbox — it doesn't stop a raw shell write or a deliberately misbehaving agent; those land in the audit trail instead. Codex and Gemini CLI hooks re-inject the gate text each turn but don't block edits — those adapters rely on the rules plus the audit trail." README:146 now: "blocks the agent's Edit/Write file operations … — a tool gate, not a filesystem sandbox (Claude Code only; other tools rely on the rules and the audit trail)." Every element of the required fix present: Edit/Write tool-call scope, not-a-sandbox, raw-shell/misbehaving-agent bypass named, other adapters = rules + audit trail. `grep -rn "physically block" README.md docs/` → 5 hits, ALL inside run artifacts quoting the old text (impl package, this report, fix report); **zero in rendered copy** (README, faq, getting-started clean) |
| F-FR-2 (Nit) | open | **closed** | README:97 now "since the last full review" — matches R-118 baseline; verified by grep |

Late findings: None. Regression: `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0; `git diff main...HEAD --stat` → 9 files, all README.md + docs/* (content 3 + run artifacts 6), zero protocol//PROTOCOL.md/install.sh/adapters/ lines; link-existence check → zero MISSING. Fix delta read in full — no new claim introduced, no other sentence touched.

---

# Iteration 1 — FULL_REVIEW (historical)

## Verdict

GATE_NOT_MET — **FIXING** *(superseded by iteration 2 above)*
Blockers: 0 open | Majors: 1 open | Minor: 0 | Nit: 1

## Scope Evaluated

Plan-conformance + verification-integrity, honesty-first (spec §4 hard constraints), per plan Review Scope. Diff `main...heatwave-v4-subproject-f` (README.md +35/−1, docs/faq.md +2/−2, docs/getting-started.md +2/−2, plus run artifacts under docs/). Ground truth re-read on the branch: PROTOCOL.md, protocol shards (via drift check), install.sh, adapters/claude-code/role-gate.sh, adapters/codex/hooks.json, adapters/gemini/gemini-gate.sh, benchmark/README.md, benchmark/RESULTS.md L1–12. Every AC grep re-run independently; nothing accepted from the Implementation Package on trust.

## Scope Changes

One (R-49): enforcement-claim accuracy expansion — trigger: driver-supplied verified nuance that the Claude Code gate is registered `"matcher": "Edit|Write"` (install.sh:110) and role-gate.sh inspects only `tool_input.file_path`, so Bash-tool writes bypass it. Verified independently by reading both files. Produced F-FR-1.

## Reconciliation

Iteration 1 of FULL_REVIEW — no prior FULL findings. PLAN_REVIEW findings (F-1, F-2 Minor; F-3, F-4 Nit): all four applied by the implementer and verified below (F-1 grep broadened with `0/[0-9]`; F-2 FAQ scoped to "the only adapter whose hook intercepts tool calls"; F-3 "124 rules" not "numbered"; F-4 no h-prefixed relative link added). Late findings: None.

## Acceptance Status

(Deferred to FINAL per template; recorded here anyway since all ACs were exercised.)

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Not satisfied (F-FR-1) | 24 sampled rule IDs all present (`R-113` as 3 halves at PROTOCOL.md L454/657/757); rule texts of R-101/102/103/104/108/110/112/116/118/88/1/2/12/17/87 read against the claims — all other rows accurate; row 14's prose exceeds the shipped gate (F-FR-1) |
| AC-F-02 | Satisfied | Refined grep `0/[0-9]|fewer bugs|[0-9]+ ?%([^0-9]|$)|[0-9]+(\.[0-9]+)?[x×] (fewer|faster|better|cheaper)` over the 3 files → exit 1, no output; `grep -ci inconclusive README.md` = 1; Benchmark section read — no RAW/HEATWAVE number, no comparative claim; RESULTS.md headline is "delta UNCOMPUTABLE… proves the rig, not a delta" and the README matches it |
| AC-F-03 | Satisfied | `multi-repo|enterprise|CLI` grep → 12 hits, all "Gemini CLI"/"Cline"/pre-existing adapter text + one FAQ "multi-round"; zero G/H feature claims; G/H not mentioned at all |
| AC-F-04 | Satisfied | Link-extraction + existence check → zero MISSING; `benchmark/METHODOLOGY.md` among targets (README L181, L192) |
| AC-F-05 | Satisfied | `on the roadmap` / `Claude Code today` in docs/faq.md → 0 and 0; replacement mechanisms cross-read against install.sh + all three adapter hook files — factually correct per-tool (Codex UserPromptSubmit `cat GATE.md`; Gemini BeforeAgent additionalContext; Claude Code PreToolUse exit-2) except the completeness wording in F-FR-1 |
| AC-F-06 | Satisfied | install.sh L21 case list = 12 adapters; getting-started L26 lists all 12 verbatim; intake/tier line present at L67 |
| AC-F-07 | Satisfied | `prove its work` = 1; `assets/` = 5; all 7 pre-existing `## ` headings present + exactly 3 new sections |
| AC-F-08 | Satisfied | `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md \| sort -u \| wc -l` → **124** at review time; README L191 says "124 rules" |
| AC-N-01 | Satisfied | `git diff main...HEAD --stat`: README.md, docs/faq.md, docs/getting-started.md + run artifacts (spec/plan/reviews/impl under docs/) only; zero lines in protocol/, PROTOCOL.md, install.sh, adapters/, benchmark/, templates/, prompts/ |
| AC-N-02 | Satisfied | `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0 |
| AC-N-03 | Satisfied | Diff is 1 inserted sentence + 3 inserted sections + 2 table-row edits; hook paragraph, habit list, 5-step list, both `<details>` blocks, all 5 image tags untouched |

## Findings

**F-FR-1 (Major, verification-integrity / spec §4 overclaim) — "physically blocks source edits" claims more than the shipped gate does.** docs/faq.md:28 (NEW copy in this diff): "a `PreToolUse` gate physically blocks source edits while the run state assigns them to another role." Shipped reality: install.sh:110 registers the hook with `"matcher": "Edit|Write"` and role-gate.sh reads only `tool_input.file_path` — the gate blocks the agent's Edit/Write **tool calls**. A write via the Bash tool (`sed -i`, `cat > file`, a Python one-liner) never triggers the hook, and role contexts do hold Bash. So the unqualified object "source edits" is a superset of what is blocked; the sentence's own contrast ("Codex and Gemini CLI hooks… can't block an edit") reinforces the completeness reading. Spec §7: capability sentence exceeding shipped reality = Major. Refutation attempted (R-112): (a) the same sentence scopes Claude Code as "the only adapter whose hook intercepts **tool calls**", implying the tool-call boundary; (b) global hedges exist (README L170 "not cryptographic"; faq L10 "not cryptographic enforcement… violations legible"). Refutation fails: no sentence anywhere in README/FAQ states the gate is not a filesystem sandbox or that shell writes bypass it, and "physically blocks" is an affirmative completeness word the mechanism cannot honor — the lay takeaway ("the AI cannot edit source during review states on Claude Code") is false. **Fix:** scope the claim, e.g. "…a `PreToolUse` gate physically blocks the agent's file-edit tool calls while the run state assigns them to another role — it is a tool gate, not a filesystem sandbox, so a raw shell write would bypass it and land in the audit trail instead." Same-class remediation to ride along (reviewer-scoped, permitted by AC-N-01): README:146 carries the identical pre-existing phrase "physically blocks source edits" — apply the same scoping there; faq:50 "edit-blocking hooks" is acceptable once L28 is scoped (the ladder names the hook class, not a completeness claim), optionally "file-tool edit-blocking".

**F-FR-2 (Nit, plan-conformance) — delta-review baseline phrase.** README:97 "the final review re-checks only what changed since the last approved pass". R-118 defines the delta as the diff since the last **FULL_REVIEW** SHA — which need not have been an approving pass (a failed FULL_REVIEW → FIXING still sets the baseline). Suggest "since the last full review". Does not overclaim capability; imprecise baseline only.

**Deviation dispositions (R-5/R-6 — both ACCEPTED):**
1. *AC-F-02 %-pattern refinement* — legit, and the plan's parenthetical was indeed wrong: I re-ran the plan's original pattern; its only hit is README:8 `setup-3%20minutes`, the pre-existing shields.io badge where `%20` is a URL-encoded space (digit **before** `%`, which the plan claimed would make badges pass — it doesn't). The refined `[0-9]+ ?%([^0-9]|$)` excludes only `%`-followed-by-digit (URL encoding) and still matches any real percentage ("38%", "38 %."). No real %-claim is hidden; the badge is untouched pre-existing content. Mechanically stronger than the plan's pattern, intent preserved.
2. *AC-F-01 R-113 grep form* — legit: R-113 ships as three half-entries (`**R-113 (planner half).` L454, implementer L657, reviewer L757), verified by my own grep; the literal-dot grep form simply doesn't match the parenthesized form. Rule exists and states red-then-green exactly as the README claims.

## Verification Log

Machine evidence (R-110): drift | build-protocol.sh --check | PASS | "OK: PROTOCOL.md matches protocol/ shards", exit 0. tests | none | NOT_AVAILABLE | markdown-only repo, no framework (R-64) — leaves no AC unverified (all ACs are grep/shell/read). sast | semgrep (config auto) | PASS | 0 findings on README.md + docs/faq.md + docs/getting-started.md, exit 0. mutation | — | N/A | STANDARD tier (FULL-only per R-110). secrets | gitleaks | deferred to FINAL rung per R-121 (binary present).

| Item | Method | Result | Evidence |
|---|---|---|---|
| Forbidden-pattern grep (refined) | re-run on branch | exit 1, no output | pattern + result pasted in AC-F-02 row |
| Forbidden-pattern grep (plan original) | re-run on branch | 1 hit: README:8 badge `setup-3%20minutes` only | Deviation 1 disposition |
| Rule count | `grep -o '^\*\*R-[0-9a-z]*' PROTOCOL.md \| sort -u \| wc -l` | **124** | matches README:191 "124 rules" |
| 24 cited rule IDs exist | per-ID grep loop | all present; R-113 = 3 halves L454/657/757 | shell output |
| Claim→rule semantic sample | read R-101, R-102, R-103, R-104, R-108, R-110, R-112, R-113 (all 3 halves), R-116, R-118, R-88, R-1, R-2, R-12, R-17, R-87 against README/FAQ sentences | all accurate except F-FR-1's completeness wording | rule texts quoted in session; e.g. R-104 = "check … by a context that did not make the change" ⇔ README:47/92; R-102 ⇔ "sensitive paths … never"; R-118(b)(c) ⇔ delta + full machine re-run |
| Enforcement gate reality | read install.sh:100–120, adapters/claude-code/role-gate.sh (full), adapters/codex/hooks.json, adapters/gemini/gemini-gate.sh | Claude Code: PreToolUse `Edit\|Write` exit-2 block on `tool_input.file_path`; Codex: UserPromptSubmit `cat GATE.md` (inject only); Gemini: BeforeAgent additionalContext (inject only) — FAQ per-tool facts correct; completeness wording = F-FR-1 |
| Benchmark section honesty | read README:172–181 vs benchmark/README.md:30–31 + RESULTS.md:1–12 | run commands verbatim; corpus `ls` = 8; "inconclusive … no performance delta is claimed" present; zero numbers quoted | RESULTS headline "delta UNCOMPUTABLE … proves the rig, not a delta" |
| G/H roadmap | AC-F-03 grep, read of all hits | zero G/H claims; all hits pre-existing tool names | grep output |
| Links | AC-F-04 extraction + existence loop | zero MISSING | shell output |
| Adapter list | `sed -n '21p' install.sh` vs getting-started:26 | 12 = 12, verbatim | shell output |
| Structure preservation | AC-F-07 greps + full diff read | 5 assets, 7 old + 3 new headings, insertions only | diff + grep output |
| Diff scope | `git diff main...HEAD --stat` | 3 content files + run artifacts only | pasted in AC-N-01 row |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Claim→rule rows for R-111, R-114, R-115, R-117, R-119–R-122 read only via grep-presence + plan-review's row-by-row log, not full re-read this pass | sampling per STANDARD tier; R-119/R-122 partially read (first 400 chars confirm optional/companion framing) | AC-F-01 residual — none of these back a sentence flagged by any check |
| GitHub-rendered appearance of new sections | no renderer in scope; markdown is plain | none (AC-N-03 covered by diff read) |

## Summary

The copy is honest almost everywhere it was newly written, and every mechanical guard passes on independent re-run: the refined forbidden-pattern grep is silent (and the implementer's %-pattern deviation is not only legitimate but corrects a factual error in the plan's badge reasoning — the only original-pattern hit is the pre-existing URL-encoded badge, hiding nothing), the rule count is verifiably 124 and stated as such, both FAQ stale strings are gone, getting-started matches install.sh's 12-adapter case list verbatim, the Benchmark section quotes zero numbers and mirrors RESULTS.md's "rig, not a result" framing with verbatim run commands and a working METHODOLOGY.md link, G/H are absent, the diff is docs-only, drift check is green, semgrep is clean, and the README is a structure-preserving insertion, not a rewrite. Both declared deviations are accepted. The single gate-relevant defect is an enforcement overclaim in the new FAQ copy: "physically blocks source edits" describes a gate that in shipped reality intercepts only Edit/Write tool calls — Bash-tool writes bypass it — and no sentence in README or FAQ supplies the not-a-sandbox caveat; under this run's own spec (§4/§7: capability sentence exceeding shipped reality = Major) that is a Major, with a one-clause fix and a same-class pre-existing phrase at README:146 to sweep in the same pass. One Nit on the delta-review baseline phrase. GATE_NOT_MET → FIXING; the fix is small and the re-review can be TARGETED on faq:28, README:146, and optionally README:97.
