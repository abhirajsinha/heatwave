# Planning Document — Ecosystem Companions (Heatwave v4, Sub-project D)

task_id: 2026-08-11-ecosystem-companions | artifact_type: planning-document | iteration: 1 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Spec (source of truth): `docs/specs/2026-08-11-ecosystem-companions-design.md` (APPROVED).
Repo: `/Users/abhirajsinha/Projects/heatwave`, branch `main` (A + B + C merged).

## Tier

**FULL** — cross-cutting protocol change: it amends `protocol/core.md` (loaded by every dispatch), touches every review stage's semantics (SAST/mutation/secrets/dynamic security gating), the config schema, the run-record schema, prompts, and adapters. A defect here silently weakens the verification guarantees of every future Heatwave run — the protocol equivalent of "anything touching money or user data."

Change class: **feature** — new capability (companion bindings), not a defect correction.

## Problem Statement

B defined the `sast` and `mutation` gates abstractly (R-110 rungs consumed from the §6.1 tooling declaration, degrading to `NOT_AVAILABLE` per R-64) and deliberately named no tools. D binds verified concrete tools to those existing gates and adds four evidence channels B did not cover — secret scanning (gitleaks, FINAL), UI evidence (Playwright MCP), on-demand docs (context7 MCP), and opt-in dynamic security (Strix) — plus change-type gating for the Claude Code `/security-review` semantic pass. All companions are **external, optional, detected**: Heatwave ships only detection rules, config keys, invocation guidance, and COMPANIONS.md docs. Absent tool → explicit `NOT AVAILABLE`, never a silent skip. **Zero new runtime dependencies to Heatwave itself; nothing vendored; nothing always-on that costs tokens.**

Spec-correction note (PLAN_REVIEW F-004): spec §4.6's parenthetical "present in the Claude Code adapter" is inaccurate — `/security-review` appears nowhere under `adapters/`; the sole occurrence is `prompts/reviewer.md:24`, which T8 gates and T9 wires into the adapter.

## Functional Requirements

- FR-1. Semgrep binds to B's existing `sast` gate; mutation runners (Stryker/mutmut/PIT class) bind to B's existing `mutation` gate — detection is R-99-style (planner detects from evidence, reviewer runs). D does **not** recreate the gates; R-110/R-111 are untouched as gate definitions.
- FR-2. gitleaks-class secret scanning becomes a new deterministic rung at FINAL_REVIEW (all tiers with a FINAL, LIGHT combined pass included); any hit on the run's diff is a Blocker-class machine finding.
- FR-3. Playwright MCP is the UI-evidence capture mechanism for UI change-surface runs: accessibility-tree assertions + screenshot cited in the Review Report against UI ACs.
- FR-4. context7 MCP is an on-demand docs lookup at PLANNING when the plan leans on an external library's API — never always-on; absent → the API claim stays a labeled assumption.
- FR-5. Strix (R-119) is **opt-in + lazy + spin-up/tear-down**: fires iff config-enabled AND change_surface ∩ {auth, payments, external-input, new-endpoint} ≠ ∅ AND tier == FULL. Docker up → scan → down, both recorded; PoC (or clean result) attached to the Review Report; validated exploit = Blocker. Never on routine changes. Default: disabled.
- FR-6. `/security-review` (Claude Code adapter) fires only for change_surface ∩ {auth, external-input, deps, secrets, api-surface}; other adapters: documented equivalent or NOT AVAILABLE.
- FR-7. One integration policy (spec §4.7 table, reproduced in core.md + COMPANIONS.md in the change_surface vocabulary, with the FINAL-presence precision for gitleaks — intent-preserving normalizations per PLAN_REVIEW F-001): deterministic tools auto-run when present; token/LLM/Docker tools fire only on matching change-surface or explicit opt-in; nothing always-on that costs tokens; absent → NOT AVAILABLE (R-64).
- FR-8. A `change_surface` declaration (PLANNER-owned, in the Planning Document) is the gating input for FR-3/5/6.
- FR-9. COMPANIONS.md is expanded (not recreated): protocol-wired section with the policy table, Strix/Semgrep/gitleaks/mutation entries, and the paid-SaaS "documented, not wired" note.
- FR-10. A/B/C behavior is preserved: EXPRESS instant and companion-free, drift check green, ladder/refute/reproduce/hetero (B) and tiering/persistent-session/delta-FINAL (C) untouched except the two surgical amendments listed in the Architecture section.

## Non-Functional Requirements

- NFR-1. Zero new runtime dependencies to Heatwave; no vendored binaries; `install.sh` behavior unchanged (see AC-N-03).
- NFR-2. Per-dispatch token cost bounded: the core.md addition (loaded by every dispatch) stays ≤ 90 lines; every token-costing companion instruction in any dispatched shard/prompt is conditional (change_surface / config / "when present"), never unconditional (AC-N-05).
- NFR-3. `sh build-protocol.sh --check` exits 0 after every shard-touching task (AC-N-01).

## Architecture

**LOCKED decisions (spec §3) honored exactly:**
1. Strix = opt-in + lazy + spin-up/tear-down; off by default; fires only when (a) config-enabled AND (b) change touches auth/payments/external-input/new-endpoint AND (c) tier FULL; Docker up→scan→down recorded; PoC to report; never on routine changes.
2. Deterministic floor (Semgrep, gitleaks) = auto-use when detected, R-99 parity: planner detects, reviewer runs. Absent → NOT AVAILABLE.

**Where things live (post-A/B/C reality, verified):**

| Concern | Location | What D does |
|---|---|---|
| Abstract `sast`/`mutation` gates + ladder | `protocol/core.md` R-110 (tier rigor table §0.5), `protocol/reviewer.md` R-111 | NOT recreated. D adds detection targets (planner.md §6.1) and invocation guidance (reviewer.md §4.4) that *feed* them. |
| Tooling declaration + NOT AVAILABLE | `protocol/planner.md` §6.1 (R-62/R-63/R-99 + v4 sast/mutation note) | Extended: secrets/ui_evidence/docs detection + `change_surface` (new R-122). |
| FINAL machine-gate re-run | core.md R-118(b), final-reviewer.md R-44 | Surgical amendment adding the secrets rung (R-121). |
| Config | `heatwave.config.example.yaml` (`tooling.sast`/`tooling.mutation` exist) | Add `tooling.secrets`/`ui_evidence`/`docs` + `dynamic_security` block. |
| Run Record | `templates/run-record.yaml` | Add `companions` block (fired list + Strix up/down markers). |
| `/security-review` | `prompts/reviewer.md` line 24 (currently ungated example); NOT in adapter files despite spec §4.6's parenthetical | Gate the prompt line by change_surface; add wiring note to `adapters/claude-code/HEATWAVE.md` + `.claude/agents/heatwave-reviewer.md`. |
| Rule numbering | Highest existing rule R-118 (verified by grep across shards/templates/config) | New rules R-119–R-122, no collision. Spec's R-119=Strix kept. |

**New rules — exact text** (all carry the *(v4-D)* marker; placed in a new core.md subsection `### 6.5 Companion tools *(v4-D)*`, except R-122 in planner.md §6.1). The §6.5 intro reconciles with R-110's "the protocol names the checks, never specific tools":

> ### 6.5 Companion tools *(v4-D)*
>
> Companions are external tools Heatwave detects and uses, never dependencies. This section does not amend R-110: the `tests`/`sast`/`mutation` rungs remain tool-agnostic and any equivalent declared tool satisfies its rung — the names below are verified bindings a repo MAY present, not requirements. Setup and the full catalog: `COMPANIONS.md`.
>
> | Companion | Stage | Trigger | Cost | Default |
> |---|---|---|---|---|
> | gitleaks | FINAL_REVIEW (+pre-commit) | detected; every run with a FINAL | ~0 | auto-when-present |
> | Semgrep | FULL_REVIEW (SAST rung) | detected; STANDARD+ changed paths | ~0 | auto-when-present |
> | Mutation (Stryker/mutmut/PIT) | FULL_REVIEW (mutation rung) | detected; FULL, changed modules | CPU | auto-when-present |
> | `/security-review` | FULL_REVIEW | change_surface ∩ {auth, external-input, deps, secrets, api-surface} | med tokens | on (Claude Code) |
> | Playwright MCP | FULL/FINAL evidence capture | change_surface ∋ ui; MCP present | low | auto-when-present |
> | context7 MCP | PLANNING | plan cites an external API | low, on-demand | optional |
> | **Strix** | FULL_REVIEW → report evidence | enabled + change_surface ∩ {auth, payments, external-input, new-endpoint} + FULL | high + Docker | **opt-in** |
>
> **R-119.** *(v4-D)* **Dynamic security (Strix class) — opt-in, lazy, spin-up/tear-down.** A dynamic-security scan runs iff ALL hold: (a) `dynamic_security.strix: enabled` in `heatwave.config.yaml` — the default, and the absence of the key, is `disabled`; (b) the plan's `change_surface` (R-122) intersects {auth, payments, external-input, new-endpoint}; (c) the tier is FULL. When it runs, the REVIEWER at FULL_REVIEW spins the target environment up in Docker, runs the headless scan (`strix -n --target <dynamic_security.strix_target>`), and tears the environment down immediately after — spin-up and tear-down timestamps recorded in the Run Record (`companions.strix_docker_up` / `companions.strix_docker_down`); an up marker without a down marker is a protocol defect. The PoC (or clean result) is attached to the Review Report as dynamic evidence with rung `dynamic` in the ledger's `machine_evidence`; a validated exploit is a machine finding of severity Blocker. Any leg failing → the scan MUST NOT run: disabled → `companions.strix: skipped-disabled`; non-matching surface or tier → `skipped-out-of-gate`; enabled but the tool or Docker is unavailable → `NOT AVAILABLE` per R-64, naming the security acceptance criteria left to the static and semantic layers. It never runs on a routine change.
>
> **R-120.** *(v4-D)* **Companion integration policy.** Heatwave ships detection rules, config keys, invocation guidance, and docs — never the tools, and no companion is required. Three classes govern every companion, present and future: **(1) deterministic, near-free** (secret scan, SAST, mutation) — auto-used when detected, exactly like test tooling (R-99): the PLANNER detects and declares (§6.1), the REVIEWER runs it at its bound stage; **(2) token- or LLM-priced** (semantic security pass, UI-evidence capture, docs lookup) — fires only on a matching `change_surface` (R-122) or as an explicit on-demand call, never unconditionally; **(3) heavy infrastructure** (dynamic security) — opt-in by config on top of class-2 gating (R-119). Nothing runs always-on that costs tokens. An absent companion is declared `NOT AVAILABLE` (R-64) — never a silent skip, and never by itself a failed run. Companion output enters review as candidate findings subject to refute-or-promote (R-112); for SAST-class scans only high-severity results convert (R-111).
>
> **R-121.** *(v4-D)* **Secrets rung.** When a secret scanner is declared — a detected gitleaks binary, config (`.gitleaks.toml`), or pre-commit hook, or `tooling.secrets` in config — the FINAL_REVIEW machine-gate re-run (R-118(b); the LIGHT combined pass included) MUST include a secret scan of the run's full diff as an additional ladder rung (`rung: secrets`). Any hit is a machine finding of severity Blocker (`Category: secret-management`) — a leaked secret must block; a false positive is waived only via the OWNER Blocker-waiver path (R-9), recorded. No scanner declared → `verdict: NOT_AVAILABLE` (R-64). Installing the scanner as a pre-commit hook is RECOMMENDED and is what covers EXPRESS runs, which have no FINAL_REVIEW.

R-122, appended to planner.md §6.1 after the v4 sast/mutation note:

> **R-122.** *(v4-D)* **Change surface.** For LIGHT+ runs the tooling declaration MUST carry a `change_surface` line: the subset of {auth, payments, external-input, new-endpoint, ui, deps, secrets, api-surface} the change touches, or `none`, with one line of justification, declared by the PLANNER from the plan's own scope (the Appendix C review-scope categories are its evidence). It is consumed by the companion gates: the semantic security pass fires on {auth, external-input, deps, secrets, api-surface}, UI-evidence capture on {ui}, dynamic security per R-119. Misclassification is a valid REVIEWER finding — minimum Major when it would have suppressed a security companion. EXPRESS runs have no plan and no change surface; companions never fire on EXPRESS (R-102 already keeps sensitive paths out of it).

**Surgical amendments to existing (A/B/C) text — the complete list, nothing else changes meaning:**
1. core.md R-118(b): "(build/drift, tests, SAST, mutation per R-110)" → "(build/drift, tests, SAST, mutation per R-110; secrets per R-121)".
2. core.md §0.5 rigor table: one footnote line under the table: "All tiers with a FINAL_REVIEW add the `secrets` rung there when a scanner is present (R-121); dynamic security is opt-in per R-119."
3. core.md shard map, core row: "§6.2/§6.4 tool unavailability & evidence" → "§6.2/§6.4–§6.5 tool unavailability, evidence & companions".
4. final-reviewer.md §4.7 *(v4)* note: append one sentence referencing the secrets rung (R-121) inside the (b) re-run.
5. reviewer.md §4.4: after the existing ladder sentence, a short *(v4-D)* companion-invocation paragraph (class-1 rung tools named as examples; class-2 `/security-review`-class + Playwright gated by change_surface; class-3 by R-119).
6. orchestrator.md §9.1 *(v4)* duties: one sentence — the driver copies companion activity (declared/fired/Strix markers) from the plan and review artifacts into the Run Record `companions` block.
7. history.md Appendix F.1: one new row `| Companion bindings: deterministic floor auto-use, secrets rung, change-surface gating, opt-in dynamic security | R-119–R-122 | B's gates named no tools; secrets/UI/dynamic/docs evidence had no channel |`.

## API Design

`N/A` — no runtime API. The "contracts" are the config keys, the run-record `companions` schema, and the `change_surface` vocabulary, specified verbatim in Data Design.

## Data Design

**`heatwave.config.example.yaml`** — extend the existing commented `tooling:` block and add one new block (all commented out, like everything else in the file):

```yaml
#   secrets: "gitleaks"           # FINAL_REVIEW rung (R-121); auto-detected (binary / .gitleaks.toml /
#                                 # pre-commit hook); a hit on the diff is a Blocker
#   ui_evidence: "playwright-mcp" # UI-evidence capture when change_surface ∋ ui (R-120); auto-when-present
#   docs: "context7-mcp"          # on-demand docs lookup at PLANNING (R-120); never always-on

# --- Dynamic security (v4-D, R-119) — OPT-IN; unset = disabled -----------------
# dynamic_security:
#   strix: disabled               # disabled | enabled. enabled fires ONLY when change_surface
#                                 # ∩ {auth, payments, external-input, new-endpoint} AND tier FULL.
#                                 # Docker spin-up → scan → tear-down, both recorded (R-119).
#   strix_target: ""              # target for `strix -n --target <...>` (URL or compose service)
```

**`templates/run-record.yaml`** — one new top-level block after `tooling_resolutions`:

```yaml
companions:              # v4-D (R-119–R-121): companion activity; absent = pre-D record or none declared
  detected: []           #   from the plan's tooling declaration, e.g. [semgrep, gitleaks]
  fired: []              #   - { tool: , stage: , verdict: , evidence: }
  strix: ""              #   run | skipped-disabled | skipped-out-of-gate | NOT AVAILABLE (R-119)
  strix_docker_up: ""    #   timestamp — set only when strix ran (R-119)
  strix_docker_down: ""  #   timestamp — MUST be set whenever _up is set (R-119)
```

**`templates/findings-ledger.yaml`** — rung enum comment `tests | sast | mutation` → `tests | sast | mutation | secrets | dynamic` (+ pointer to R-121/R-119).

**`templates/planning-document.md`** — Tooling Declaration gains two rows and one line:

```
| Secrets (FINAL rung) | <tool> | REVIEWER | confirmed — <evidence> / NOT AVAILABLE (R-121) |
| UI evidence (change_surface ∋ ui) | <MCP/tool> | REVIEWER | confirmed / NOT AVAILABLE (R-120) |

change_surface: <subset of {auth, payments, external-input, new-endpoint, ui, deps, secrets, api-surface} or none> — <one line> (R-122)
```

## State Management

`N/A` — no state-machine change: no new states, transitions, or counters. Companion activity is recorded in existing artifacts (ledger `machine_evidence`, Review Report, Run Record `companions` block).

## Error Handling Strategy

Every failure mode degrades explicitly, never silently: absent tool → `NOT AVAILABLE` naming unverified ACs (R-64); Strix gate not met → recorded `skipped-*` marker; Strix enabled but Docker/tool missing → `NOT AVAILABLE`; gitleaks false positive → OWNER Blocker-waiver path (R-9), recorded; noisy/misconfigured detected tool → output is candidate findings under refute-or-promote (R-112), high-severity-only conversion for SAST (R-111). A companion failure is never itself a run failure.

## Security Considerations

D *adds* security surface coverage; the threat introduced by D itself is (a) false confidence if a companion claim overstates what ran — mitigated by R-64/R-65 evidence discipline and the machine_evidence rungs; (b) a leaked secret passing because the scanner is absent — mitigated by the explicit NOT AVAILABLE line plus the pre-commit recommendation; (c) Strix's Docker container left running — mitigated by R-119's mandatory down-marker (up-without-down = protocol defect). COMPANIONS.md keeps the official-channels-only install stance.

## Edge Cases

1. EXPRESS run in a repo with gitleaks installed: no FINAL_REVIEW → no secrets rung; covered by the pre-commit recommendation; R-102 keeps sensitive paths out of EXPRESS. Companion text adds zero EXPRESS steps.
2. LIGHT combined FULL+FINAL pass: secrets rung runs there (R-121 says so explicitly); sast/mutation rungs still tier-gated (STANDARD+/FULL) — unchanged from B.
3. `strix: enabled` but change_surface `none` or tier STANDARD: `skipped-out-of-gate`, never a scan (both directions of the gate).
4. Semgrep binary on PATH but no repo config: detected (spec §4.1 lists the binary as evidence) → `semgrep scan --config auto` on changed paths.
5. Tool detected at PLANNING but broken at review time: rung records `NOT_AVAILABLE` with reason; discrepancy with the plan's `confirmed` is a candidate R-63 finding — reviewer's call.
6. Pre-v4-D run record (no `companions` block): read as "no companions declared" — schema comment says so; the driver MUST NOT rewrite old records (existing §9.2 rule).
7. Playwright MCP present but change is non-UI: never invoked (change_surface gate) — no cost.
8. context7 in a plan with no external API: zero calls (on-demand only).
9. `dynamic_security.strix_target` unset with strix enabled and gate met: nothing to scan → `NOT AVAILABLE` naming the missing target, per R-64 — never a guessed target.
10. A repo whose CI already runs Semgrep: detection cites the CI workflow; the reviewer still runs the rung itself (R-110 "executing each rung itself" is unchanged).

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Contradiction with R-110's "never specific tools" | Medium | §6.5 intro sentence reconciles explicitly (bindings, not requirements); AC-N-04 grep |
| core.md bloat taxes every dispatch | Medium | NFR-2 line budget (≤ 90 lines); table + 3 rules only, catalog detail lives in COMPANIONS.md |
| `prompts/reviewer.md` line 24 (ungated `/security-review` example) contradicts the new gate | High if unfixed | T8 rewrites that line to the change_surface gate |
| Strix repo/license unverifiable at implementation time | Low-Med | COMPANIONS.md contract requires verification before listing; fallback: list with the spec's 2026-08 catalog citation and an explicit "verify before install" flag — honesty over omission |
| Real tools uninstallable in test env | Medium | Tiered verification: gitleaks/semgrep/mutmut installable (brew/pipx); Strix/Playwright-MCP → R-64 declaration + stub/rule-text verification, exactly as B did for SAST/mutation |
| Detection-order flaw in verification (installed binaries make the "no companions" case untestable) | Certain if unordered | T10 (zero-companion runs) executes BEFORE T11 installs any tool; PATH-stripping as backup |
| Drift between shards and PROTOCOL.md | Low | Every shard task ends with regenerate + `--check` (AC-N-01) |

## Dependencies

Internal: A (shards + build-protocol.sh + EXPRESS), B (R-110–R-115, ledger machine_evidence, §6.1 sast/mutation note), C (R-116–R-118) — all merged to main, verified by reading the shards. External (test-time only, none become Heatwave deps): gitleaks + semgrep via brew, mutmut via pipx — availability confirmed at T11, declared honestly if install fails; Docker present (`/usr/local/bin/docker`; daemon liveness checked at T12, torn down after per the 8GB rule); Strix real binary NOT expected (needs its own LLM keys) — stub planned; context7 MCP available in this environment; Playwright MCP availability probed at T12, declared either way.

## Testing Strategy

Deterministic self-checks (drift, greps, diff audits) + live adapter runs on scratch repos under the Claude Code adapter, with real tools where installable and declared stubs where not (R-64) — the same honest pattern B used. Scratch targets live in the scratchpad, never in the repo. Details per task and in Acceptance Criteria.

## Rollout Plan

`N/A — docs/protocol repo`: single branch of commits to `main` per the repo's push-to-main convention; each task is one commit with drift green. No flags, no staging.

## Rollback Plan

Every task is an isolated commit touching only text files. Rollback = `git revert <task-commit>..HEAD` (or the individual commit), then `sh build-protocol.sh && sh build-protocol.sh --check` to regenerate PROTOCOL.md at the reverted shard state. No data, no migrations, no installs to undo (scratch-repo tool installs are outside the repo; `brew uninstall gitleaks semgrep` / `pipx uninstall mutmut` if the OWNER wants the machine clean).

---

## Task-by-task Implementation Plan

Every shard-touching task (T1–T4) ends with: `sh build-protocol.sh && sh build-protocol.sh --check` → expect `OK: PROTOCOL.md matches protocol/ shards`. PROTOCOL.md is never hand-edited. Ponytail: extend existing sections in place; no new files except none — D creates zero new files.

**T1 — core.md: §6.5 + surgical amendments.**
`protocol/core.md`: insert `### 6.5 Companion tools *(v4-D)*` (intro + policy table + R-119, R-120, R-121 — exact text above) after the existing §6.4 Evidence block; apply amendments 1–3 (R-118(b) secrets clause, rigor-table footnote, shard-map core row). Regenerate + drift check. Line budget: ≤ 90 added lines in core.md.

**T2 — planner.md: detection + R-122 + context7.**
`protocol/planner.md` §6.1: extend the v4 note's detection list with secrets (gitleaks binary / `.gitleaks.toml` / pre-commit hook), UI evidence (Playwright MCP presence in the agent environment), docs (context7 MCP presence); add: LIGHT+ declarations SHOULD carry a `secrets` entry (NOT AVAILABLE when undetected); append R-122 (exact text above). §4.1: one *(v4-D)* MAY-sentence — when the plan cites an external library API and a docs companion is present, the PLANNER MAY fetch version-specific docs on-demand (never always-on); absent → the API claim remains a labeled assumption. Regenerate + drift check.

**T3 — reviewer.md: companion invocation.**
`protocol/reviewer.md` §4.4, after the ladder sentence, one *(v4-D)* paragraph: class-1 rungs run the declared tools (e.g. declared `sast: semgrep` → `semgrep scan --config auto` on changed paths, high-severity → machine findings per R-111; declared mutation tool on changed modules at FULL); the semantic security pass (`/security-review` in Claude Code; adapter equivalent elsewhere) runs iff change_surface ∩ {auth, external-input, deps, secrets, api-surface}, output = candidate findings under R-112; UI evidence via Playwright MCP iff change_surface ∋ ui — a11y assertions + screenshot cited against the UI ACs; dynamic security strictly per R-119. Each absent → NOT AVAILABLE (R-64). Regenerate + drift check.

**T4 — final-reviewer.md + orchestrator.md + history.md.**
Amendments 4, 6, 7 (exact text above). Regenerate + drift check.

**T5 — templates.**
`templates/run-record.yaml`: `companions` block (exact YAML above). `templates/findings-ledger.yaml`: rung enum extension. `templates/planning-document.md`: two tooling rows + `change_surface` line (exact text above).

**T6 — config.**
`heatwave.config.example.yaml`: the exact additions from Data Design (tooling keys + `dynamic_security` block), all commented, comment style matching the file.

**T7 — COMPANIONS.md expansion (never recreate).**
Prepend a new section `## Protocol-wired companions (v4-D)` above the existing tables: the §6.5 policy table + one row-per-tool with what/trigger/cost/install: Semgrep (`brew install semgrep`, semgrep/semgrep), gitleaks (`brew install gitleaks`, gitleaks/gitleaks), mutation runners (Stryker `npm i -D @stryker-mutator/core` / mutmut `pipx install mutmut` / PIT), Strix (usestrix/strix per the spec's 2026-08 catalog — headless: `strix -n --target <app>`; opt-in, R-119, Docker discipline note), `/security-review` (Anthropic, built into Claude Code; equivalents: gemini-cli-extensions/security, codex-security — already listed below). Verify each new repo's authenticity/license per the file's stated contract before listing (WebSearch/WebFetch if available; else mark the entry "listed from the approved spec's catalog — re-verify channel before install" — honest, explicit). Annotate the existing Playwright MCP and Context7 rows with their protocol roles (R-120 stages). Append to Notes: paid SaaS reviewers (CodeRabbit/Greptile/Qodo) are documented options only, never protocol gates — Heatwave's isolated REVIEWER already has full-repo context.

**T8 — prompts alignment.**
`prompts/planner.md`: extend the tooling-detection bullet (gitleaks/playwright-mcp/context7 evidence + `change_surface` per R-122); add the context7 on-demand sentence. `prompts/reviewer.md`: rewrite line 24's ungated example into the R-120 class-2 gate ("when change_surface matches {auth, external-input, deps, secrets, api-surface} and a semantic security command is available (`/security-review`, ECC scan), run it and attach output; absent → review manually + log the gap (R-64)"); add one line each for the sast/mutation tool invocation, Playwright UI evidence (ui surface only), and R-119. `prompts/final-reviewer.md`: add the secrets rung to step 1(b). No prompt gains an unconditional companion instruction.

**T9 — adapters.**
`adapters/claude-code/HEATWAVE.md`: one short paragraph in the dispatch notes — FULL_REVIEW dispatches for runs whose change_surface matches the semantic-security set should note `/security-review` availability to the reviewer; MCP companions (Playwright, context7) reach roles through the environment, install pointers in COMPANIONS.md. `adapters/claude-code/.claude/agents/heatwave-reviewer.md`: append one sentence (companion tools per core §6.5; run what is present, declare what is not). Then the consistency sweep: `grep -rn -i "semgrep\|gitleaks\|strix\|playwright\|context7\|security-review\|mutation\|companion" adapters/ prompts/ README.md COMPANIONS.md protocol/` — fix any statement contradicting the R-120 policy (known hit: prompts/reviewer.md line 24, fixed in T8; expected residual hits are consistent mentions only).

**T10 — Verification A: zero/negative paths (MUST run before T11 installs anything).**
Scratch repo `hw-d-clean` (tiny node or python project, no companion tools on PATH — verify with `command -v semgrep gitleaks mutmut strix`): (1) full STANDARD run via the Claude Code adapter to APPROVED — expect tooling declaration `sast: NOT AVAILABLE`/`secrets: NOT AVAILABLE` lines, ledger rungs `NOT_AVAILABLE`, no companion invocation, A/B/C flow intact → AC-F-09. (2) EXPRESS run (one-line copy edit) — no plan, no companion step, wall-clock comparable to pre-D → AC-N-02. (3) FULL run with change_surface `auth` and default config (no `dynamic_security` key) — run-record `companions.strix: skipped-disabled`, no Docker activity (`docker ps` unchanged) → AC-F-04.

**T11 — Verification B: deterministic floor + bindings.**
Install: `brew install gitleaks semgrep`, `pipx install mutmut` (record versions; any failure → R-64 declaration + rule-text/stub fallback for that AC). Scratch repo `hw-d-floor` (python, weak test suite): (1) STANDARD run with a planted fake secret in the diff (`aws_secret_access_key = "AKIA..."` pattern) — plan auto-declares `sast: semgrep — <binary evidence>` and `secrets: gitleaks — <binary evidence>`; FULL_REVIEW ledger shows a real `sast` rung verdict; FINAL_REVIEW `secrets` rung fails → machine finding severity Blocker, category secret-management; run blocks until the secret is removed via FIXING → AC-F-01, AC-F-02. (2) FULL run on a module whose test misses a branch, mutmut declared — `mutation` rung yields a surviving-mutant Major (`tests inadequate for <file>`) → AC-F-03.

**T12 — Verification C: gated companions + audits.**
(1) Strix positive/negative: stub `strix` shim on PATH (script emitting a canned clean JSON) + real Docker (daemon up; target = `docker run -d nginx:alpine`-class throwaway). FULL+auth run with `dynamic_security.strix: enabled` → run-record shows `strix: run` + both up/down timestamps, `docker ps` empty after, evidence attached; same config with a STANDARD run and with change_surface `none` → `skipped-out-of-gate`, zero Docker activity. Real Strix declared `NOT AVAILABLE — requires its own LLM credentials; gating verified via shipped rule text + stub` (R-64, B's pattern) → AC-F-05. Tear Docker down after (8GB rule). (2) context7: PLANNING for a task citing an external library → transcript shows exactly one on-demand lookup; the T10 clean-run transcript shows zero → AC-F-07. (3) `/security-review`: auth-change FULL_REVIEW transcript shows invocation (or, if unavailable to subagents, R-64 declaration + verification that prompt/adapter text carries the gate); pure-refactor run shows none → AC-F-08. (4) Playwright: probe MCP availability; if absent — expected — a ui-surface run shows `ui_evidence: NOT AVAILABLE` in declaration and report (negative path live), positive path verified by rule text, declared → AC-F-06. (5) Audits: `sh build-protocol.sh --check` → OK (AC-N-01); `git diff --stat main..HEAD` — only existing text files modified, zero new binaries/vendored code, install.sh untouched (AC-N-03); T9 grep clean (AC-N-04); `git diff main..HEAD -- protocol/core.md | grep -c "^+"` ≤ 90 and manual audit that every companion instruction in dispatched shards/prompts is conditional (AC-N-05).

---

## Acceptance Criteria

### Functional

| ID | Criterion (spec §8 item) | Verification |
|---|---|---|
| AC-F-01 | (§8.1) Scratch repo with gitleaks+semgrep present: planner auto-declares both with evidence; a planted secret in the diff is caught at FINAL as a machine finding, severity Blocker, category secret-management, blocking the run | T11 live run; evidence: tooling declaration, `NN-findings-K.yaml` `machine_evidence` rung `secrets` verdict fail + Blocker finding, transcript |
| AC-F-02 | (§8.2) STANDARD run with semgrep detected shows a real `sast` rung verdict produced by `semgrep scan --config auto` on changed paths | T11; evidence: ledger `machine_evidence` entry with tool + evidence_ref |
| AC-F-03 | (§8.2) FULL run with mutmut declared shows a surviving-mutant machine finding "tests inadequate for `<file>`", default Major | T11; evidence: ledger |
| AC-F-04 | (§8.3) Default config (key absent = disabled): FULL+auth run does NOT invoke Strix; `companions.strix: skipped-disabled` recorded; zero Docker activity | T10 live run BEFORE any tool install; evidence: run-record + `docker ps` output |
| AC-F-05 | (§8.3) `strix: enabled` + FULL + auth → up marker, scan, down marker, evidence in report, container gone after; enabled + (non-auth OR non-FULL) → `skipped-out-of-gate`, no invocation. Real Strix binary honestly declared NOT AVAILABLE (R-64); gating exercised via stub + shipped rule text | T12; evidence: run-record `companions.*`, `docker ps` before/after, report, R-64 declaration |
| AC-F-06 | (§8.4) ui change_surface + MCP present → screenshot/a11y assertion cited against UI ACs; MCP absent → `ui_evidence: NOT AVAILABLE` in declaration and report (no silent skip) | T12; evidence: report; negative path live, positive path per availability (declared) |
| AC-F-07 | (§8.5) Plan citing an external API triggers exactly one on-demand context7 lookup; runs with no external API trigger zero — never always-on | T12 + T10 transcripts |
| AC-F-08 | (§8.6) Auth-change FULL_REVIEW invokes `/security-review` (or carries the R-64 declaration if unavailable to the dispatched context); pure-refactor run does not | T12; evidence: transcripts + prompt/adapter text |
| AC-F-09 | (§8.1b, §8.7) Repo with no companions: full A/B/C flow to APPROVED with explicit NOT AVAILABLE lines for sast/secrets; no new failure mode, no silent skip | T10; evidence: run-record, declaration, ledger |

### Non-functional

| ID | Criterion | Verification |
|---|---|---|
| AC-N-01 | (§8.8) `sh build-protocol.sh --check` exits 0 (output `OK: ...`) after every shard task and at completion | Command output attached per task |
| AC-N-02 | (§8.8) EXPRESS unchanged: no companion step in EXPRESS text (grep of shards/prompts for companion terms in EXPRESS sections = empty) and a live EXPRESS run completes with no companion invocation | T10 run + grep output |
| AC-N-03 | Zero new runtime dependencies: `git diff --stat main..HEAD` shows only modifications to existing text files (+ COMPANIONS.md content); no vendored binaries; install.sh behavior untouched | Diff audit output |
| AC-N-04 | (§8.8) Repo-wide grep (adapters/, prompts/, README.md, protocol/, COMPANIONS.md) shows no statement contradicting the R-120 policy — specifically no ungated token-costing companion instruction | T9/T12 grep output |
| AC-N-05 | Dispatch cost bounded: core.md addition ≤ 90 lines; every class-2/3 companion instruction in dispatched shards/prompts is conditional | Line count + text audit |

## Review Scope

Applicable
✓ `plan-conformance` — always
✓ `verification-integrity` — always; the whole feature is about evidence honesty
✓ `secure-config` — companion gating semantics (Strix opt-in default, secrets Blocker) are security-relevant configuration
✓ `secret-management` — the gitleaks rung's semantics
✓ `over-engineering` — D must stay detection+docs, zero machinery

Not applicable
✗ All frontend categories — no UI; docs/protocol repo
✗ All backend categories (`business-logic` … `data-integrity`) — no runtime code; the only executable touched is nothing (build-protocol.sh unchanged)
✗ Performance categories — no runtime; token-cost concern is covered by AC-N-05, not `api-latency`-class review
✗ Reliability/Observability categories — no services; run-record markers are the observability and are covered functionally
✗ Remaining security categories (`injection`, `xss`, `csrf`, `ssrf`, `encryption`, `secure-headers`, `authentication`, `authorization`, `rbac`, `input-validation`, `output-encoding`) — no attack surface in markdown/yaml text changes

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Drift check | `sh build-protocol.sh --check` | IMPLEMENTER + REVIEWER | confirmed — script read, present at repo root |
| Live E2E (protocol runs) | Claude Code adapter on scratch repos (scratchpad) | REVIEWER (+ IMPLEMENTER for setup) | confirmed — adapter files present; same harness A/B/C used |
| Secret scan (real) | gitleaks via `brew install gitleaks` | REVIEWER | expected available — brew present; install at T11; failure → R-64 fallback to stub |
| SAST (real) | semgrep via `brew install semgrep` | REVIEWER | expected available — same basis |
| Mutation (real) | mutmut via `pipx install mutmut`; timeout ceiling 10m on the scratch module | REVIEWER | expected available; failure → R-64 fallback |
| Dynamic security (real Strix) | strix | REVIEWER | **NOT AVAILABLE** — requires its own LLM credentials and heavyweight setup; affected: AC-F-05 positive-scan realism — mitigated by stub + Docker-discipline live check + rule-text verification, declared per R-64 (B's SAST/mutation pattern) |
| Docker (Strix harness) | docker (`/usr/local/bin/docker`) | REVIEWER | binary confirmed; daemon liveness checked at T12; torn down after (8GB rule) |
| UI evidence | Playwright MCP | REVIEWER | unknown until probed at T12 — declared either way; affected: AC-F-06 positive path (negative path verifiable regardless) |
| Docs lookup | context7 MCP | PLANNER-side verification | confirmed — present in this environment |
| Consistency | grep/git diff audits | REVIEWER | confirmed |

No tool is claimed that was not probed or explicitly marked expected/unknown with its fallback — R-63/R-64.
