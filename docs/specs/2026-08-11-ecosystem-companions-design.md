# Design Spec — Ecosystem Companions (Heatwave Protocol v4, Sub-project D)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project D of the Heatwave v4 redesign.
- **Depends on:** A (shards, tiers, tooling-declaration), B (machine-evidence ladder with abstract `sast`/`mutation` gates + NOT AVAILABLE degradation), C (tiering) — all merged to main.
- **Source:** the cited ecosystem catalog (2026-08) produced during brainstorming.

---

## 1. Context & problem

B defined the machine-evidence gates **abstractly and tool-agnostically** (a SAST scan, a mutation-adequacy check) and degrades to `NOT AVAILABLE` when no tool is declared. That was deliberate — B kept Heatwave dependency-free. D now makes those gates *real* by wiring the best existing tools as **optional, lazy companions**, and adds evidence channels B didn't cover (secret scanning, UI evidence, dynamic security, live docs). Nothing here becomes a hard dependency: Heatwave still runs by talking to any agent, and every companion absent → explicit `NOT AVAILABLE`, never a silent skip.

## 2. Goals / non-goals

**Goals:**
- G1. Bind concrete tools to B's abstract gates: **Semgrep** → the `sast` gate; **mutation runners** (Stryker/mutmut/PIT) → the `mutation` gate — auto-detected like test tooling (R-99).
- G2. Add **gitleaks** (secret scan) as a near-free deterministic rung at FINAL_REVIEW.
- G3. Add **Playwright MCP** as the UI-evidence capture mechanism for UI acceptance criteria (screenshots/assertions cited in the review, replacing "looks right" assertion).
- G4. Add **context7 MCP** as an on-demand docs lookup at PLANNING (kills hallucinated-API failures).
- G5. Add **Strix** (dynamic pentest, real PoC evidence) as an **opt-in, lazy, spin-up/tear-down** dynamic-security companion, gated to auth/payments/external-input on FULL tier.
- G6. Wire Anthropic's **`/security-review`** (already in the Claude Code adapter) as the semantic security pass, change-type gated.
- G7. One integration policy: **deterministic tools auto-run when present; LLM/token/Docker tools fire only on matching change-type or reviewer demand; nothing always-on that costs tokens.** Absent tool → `NOT AVAILABLE` (R-64).

**Non-goals (deferred):**
- Benchmark (E), positioning (F), multi-repo (G), CLI (H).
- Bundling/vendoring any tool binary. D provides detection + config + invocation guidance + setup docs, not the tools themselves.
- Changing what any gate *requires* (that's B). D binds tools to existing gates and adds evidence channels.
- Paid SaaS reviewers (CodeRabbit/Greptile/Qodo) — documented as optional in COMPANIONS.md, never wired as protocol gates (Heatwave's reviewer already has full-repo context).

## 3. Locked decisions (owner brainstorm)

- **Strix = opt-in + lazy, spin-up/tear-down.** Off by default. Fires only when (a) explicitly enabled in config AND (b) the change touches auth/payments/external-input AND (c) tier is FULL. Docker up → scan → down (8GB-Mac rule). PoC evidence attached to the Review Report. Never on a routine change.
- **Deterministic floor (Semgrep, gitleaks) = auto-use when detected**, exactly like test tooling (R-99): planner detects, reviewer runs it as part of the ladder. Absent → `NOT AVAILABLE`. Free security signal by default.

## 4. Design

### 4.1 Tool bindings for B's gates (`protocol/planner.md` detection, `protocol/reviewer.md` invocation)

- **Semgrep → `sast` gate.** Planner detection (R-99 style): a `.semgrep.yml`/`semgrep` binary/CI step → declares `sast: semgrep`. Reviewer runs `semgrep scan --config auto` on the changed paths as the ladder's SAST rung (STANDARD+); high-severity output → machine findings. Absent → `sast: NOT AVAILABLE` with the ACs it leaves unverified.
- **Mutation runners → `mutation` gate.** Detection: `stryker.conf.*` (JS/.NET), `mutmut`/`cosmic-ray` in Python deps, PIT in a JVM build → declares `mutation: <tool>`. Reviewer runs it on changed modules at FULL tier; surviving mutants → "tests inadequate" finding. Absent → `NOT AVAILABLE`.

### 4.2 New deterministic rung — secrets (`protocol/reviewer.md`, `core.md`)

- **gitleaks** auto-detected (binary/config/pre-commit hook) → runs at FINAL_REVIEW (and recommended as a pre-commit hook) on the diff; any hit is a Blocker-class machine finding (a leaked secret must block). Near-zero cost, all tiers. Absent → `NOT AVAILABLE`.

### 4.3 UI evidence — Playwright MCP (`protocol/reviewer.md`, `planner.md`)

- For a **UI change-type** (planner classifies), the reviewer captures evidence via the Playwright MCP if available: accessibility-tree assertions + a screenshot, cited in the Review Report against the UI acceptance criteria — turning "looks right" into attached evidence. Not a UI change, or MCP absent → skipped/`NOT AVAILABLE` (no cost). This is the evidence-capture mechanism for A/B's UI-related ACs.

### 4.4 Live docs — context7 MCP (`protocol/planner.md`)

- At PLANNING, when the plan leans on an external library's API, the planner MAY call context7 for version-specific docs (on-demand tool call only — never always-on). Prevents hallucinated APIs at design time. Absent → the planner marks the API an assumption (existing planner rule), no failure.

### 4.5 Dynamic security — Strix (`protocol/reviewer.md`, `core.md`, config)

- New rule (R-119): Strix runs iff `dynamic_security.strix: enabled` in config AND change-type ∈ {auth, payments, external-input, new-endpoint} AND tier == FULL. The reviewer (or a driver step) runs headless Strix (`strix -n --target <app>`) in Docker, **spins up before / tears down after** (recorded in run-record), attaches the PoC (or clean result) to the Review Report as dynamic evidence. A validated exploit is a Blocker. Disabled/absent Docker/absent tool → `NOT AVAILABLE` with the security ACs left to static+semantic layers. Never fires outside the gate (cost/Docker discipline).

### 4.6 Semantic security — `/security-review` (`adapters/claude-code/*`, `protocol/reviewer.md`)

- For change-type ∈ {auth, input-handling, deps, secrets, API-surface}, the reviewer invokes Anthropic's `/security-review` (present in the Claude Code adapter) as the semantic layer between static (Semgrep) and dynamic (Strix). Costs tokens → change-type gated. Other adapters: documented equivalent or `NOT AVAILABLE`.

### 4.7 Integration policy table (the heart — into `core.md` + `COMPANIONS.md`)

| Companion | Stage | Trigger | Cost | Default |
|---|---|---|---|---|
| gitleaks | FINAL_REVIEW (+pre-commit) | detected; every run | ~0 | auto-when-present |
| Semgrep | FULL_REVIEW (SAST rung) | detected; STANDARD+ changed paths | ~0 | auto-when-present |
| Mutation (Stryker/mutmut/PIT) | FULL_REVIEW (mutation rung) | detected; FULL, changed modules | CPU | auto-when-present |
| `/security-review` | FULL_REVIEW | change-type ∈ {auth,input,deps,secrets,API} | med tokens | on (Claude Code) |
| Playwright MCP | FULL/FINAL evidence capture | UI change-type; MCP present | low | auto-when-present |
| context7 MCP | PLANNING | planner cites external API | low, on-demand | optional |
| **Strix** | FULL_REVIEW → report evidence | enabled + {auth,payments,input,new-endpoint} + FULL | high + Docker | **opt-in** |

Everything absent → explicit `NOT AVAILABLE` (R-64). Nothing always-on that costs tokens.

## 5. Affected files

**Modified:**
- `protocol/planner.md` — detection for semgrep/gitleaks/mutation/playwright/context7; tooling-declaration entries + `NOT AVAILABLE` lines
- `protocol/reviewer.md` — bind Semgrep/mutation to the ladder rungs; gitleaks at FINAL; Playwright UI evidence; `/security-review` change-type gate; Strix conditional invocation + evidence attachment
- `protocol/core.md` — R-119 (Strix gating + Docker up/down discipline) + companion invocation policy table + the "auto-when-detected vs opt-in vs on-demand" principle
- `heatwave.config.example.yaml` — `sast`, `secrets`, `mutation`, `ui_evidence`, `docs`, and `dynamic_security.strix: disabled` (opt-in) with comments
- `templates/run-record.yaml` — record which companions fired + Strix up/down markers
- `COMPANIONS.md` — rewrite/expand from the catalog: each companion (what, why, setup, trigger, cost, required-when-present/optional/opt-in), MCP install pointers (pulsemcp/mcp.so), and the paid-SaaS "documented not wired" note
- `adapters/claude-code/*` — `/security-review` wiring note; MCP companion notes; grep the rest for any companion contradiction
- `PROTOCOL.md` — regenerated via build-protocol.sh (drift-checked)

**No new runtime dependencies added to Heatwave itself.** Companions are external, detected, and optional; Heatwave ships only detection rules, config, invocation guidance, and docs.

## 6. Alternatives considered

1. **Bundle/require the tools.** Rejected: breaks the zero-dependency, any-agent identity. Detect + degrade instead.
2. **Strix as a standard FULL security gate.** Rejected by owner: Docker + token cost on every FULL security change is too heavy for a solo 8GB setup. Opt-in + lazy.
3. **Opt-in-only floor.** Rejected by owner: leaves free security signal unused when the repo already ships Semgrep/gitleaks. Auto-when-detected (R-99 parity).
4. **Wire paid reviewers (CodeRabbit/Greptile/Qodo) as gates.** Rejected: paid SaaS + the isolated REVIEWER already has full-repo context. Document as optional only.
5. **Custom filesystem/git/test-runner MCPs.** Rejected: native agent tools + the shell already cover these; an MCP wrapper adds tokens/deps for no new capability.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| A detected tool is misconfigured/noisy | reviewer treats tool output as candidate findings subject to B's refute-or-promote; high-severity only for Semgrep |
| Strix Docker left running / OOM on 8GB | R-119 mandates tear-down after scan, recorded in run-record; opt-in so it never surprises |
| context7/Playwright MCP absent on a given agent | on-demand / change-type gated; absent → NOT AVAILABLE, no failure |
| gitleaks false positive blocks a run | it's a Blocker by design (leaked secret); a false positive is waived via the normal OWNER Blocker-waiver path (§7), recorded |
| Companion behavior contradicts an adapter's text | repo-wide grep of adapters (A/B/C lesson) as an AC |
| Regenerated PROTOCOL.md drift | build-protocol.sh drift self-check |

## 8. Verification strategy (evidence, not assertion)

Live adapter runs on scratch targets (with real tools where installable, stubs where not — declared) + deterministic self-checks:
1. **Auto-detect floor.** A scratch repo with a semgrep config + gitleaks → planner declares them; reviewer runs them in the ladder/FINAL; a planted secret is caught as a Blocker. A repo without them → `NOT AVAILABLE` lines, no silent skip. Evidence: tooling declaration + ledger + transcript.
2. **Semgrep→sast / mutation→mutation binding.** A STANDARD change with semgrep present shows a real SAST rung verdict; a FULL change with a mutation tool shows a surviving-mutant finding. Evidence: ledger.
3. **Strix gating.** With `strix: disabled` (default), an auth+FULL change does NOT invoke Strix (NOT AVAILABLE/disabled recorded). With it enabled, the same change spins Docker up, runs, tears down (up/down markers in run-record), attaches evidence; a non-auth or non-FULL change never triggers it. Evidence: run-record + report. (If Docker/Strix not installable in the test env, declare R-64 and verify the gating logic via the shipped rule text + a stub.)
4. **Playwright UI evidence.** A UI change-type with the MCP available yields a screenshot/assertion cited in the report; absent → NOT AVAILABLE. Evidence: report.
5. **context7 on-demand.** A plan citing an external API triggers an on-demand lookup when available; never always-on. Evidence: transcript.
6. **`/security-review` change-type gate.** An auth change invokes it; a pure-refactor does not. Evidence: transcript.
7. **Zero-config / no-companion run unchanged.** A repo with no companions still completes A/B/C flows to APPROVED with honest NOT AVAILABLE lines — no regression. Evidence: run-record.
8. **Regression + drift + adapter consistency.** EXPRESS still instant; drift green; repo-wide grep shows no adapter contradicts the companion policy. Evidence: outputs.

Unavailable tooling/Docker declared explicitly (R-64), never silently skipped.

## 9. Open questions

None blocking. Real-tool live verification depth (Semgrep/gitleaks installable in the test env; Strix/Docker likely R-64-declared) is a review-time judgment, same as B.
