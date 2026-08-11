# Implementation Package

task_id: 2026-08-11-ecosystem-companions | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

## Change Summary

Sub-project D built exactly to the APPROVED plan, T1–T12 in order (T10 zero-companion verification deliberately BEFORE T11 tool installs — baseline `command -v semgrep gitleaks mutmut strix` all absent, output attached below). New rules R-119–R-122 shipped in `core.md` §6.5 (Strix opt-in dynamic security, companion integration policy, secrets rung) and `planner.md` §6.1 (change surface); seven surgical amendments to A/B/C text applied verbatim per the plan's Architecture list; templates, config, COMPANIONS.md, prompts, and the Claude Code adapter extended in place. Zero new files in the protocol (only the three run-trail docs + this package under `docs/`). Zero new runtime dependencies: every companion is external, detected, optional; absent → NOT AVAILABLE (R-64). All four PLAN_REVIEW residuals folded in (F-001/F-004 reviewer-directed plan-text edits; F-002 `external-input` defining clause in R-122; F-003 R-102 aside trimmed). Verified by 6 live protocol runs + 3 harness reviewer dispatches on scratch repos with real gitleaks/semgrep/mutmut, a declared Strix stub with real Docker discipline, live context7 lookups, and live Playwright MCP UI evidence.

## Files Changed

| Path | Change type | Line delta | Task |
|---|---|---|---|
| protocol/core.md | modified | +24/−2 | T1 (§6.5 + amendments 1–3) |
| protocol/planner.md | modified | +6/−0 | T2 (detection, R-122, context7 MAY) |
| protocol/reviewer.md | modified | +2/−0 | T3 (§4.4 companion invocation) |
| protocol/final-reviewer.md | modified | +1/−1 | T4 (secrets-rung sentence) |
| protocol/orchestrator.md | modified | +2/−0 | T4 (driver companions duty) |
| protocol/history.md | modified | +1/−0 | T4 (F.1 row R-119–R-122) |
| PROTOCOL.md | regenerated | +39/−2 | T1–T4 (generated, drift-checked) |
| templates/run-record.yaml | modified | +6/−0 | T5 (companions block) |
| templates/findings-ledger.yaml | modified | +1/−1 | T5 (rung enum + secrets/dynamic) |
| templates/planning-document.md | modified | +4/−0 | T5 (2 tooling rows + change_surface) |
| heatwave.config.example.yaml | modified | +11/−0 | T6 (secrets/ui_evidence/docs + dynamic_security) |
| COMPANIONS.md | modified | +25/−2 | T7 (protocol-wired section, verified entries) |
| prompts/planner.md | modified | +2/−1 | T8 (detection + change_surface, context7) |
| prompts/reviewer.md | modified | +4/−1 | T8 (gated /security-review rewrite + 3 lines) |
| prompts/final-reviewer.md | modified | +1/−1 | T8 (secrets rung in step 1(b)) |
| adapters/claude-code/HEATWAVE.md | modified | +2/−0 | T9 (dispatch note + companions recording) |
| adapters/claude-code/.claude/agents/heatwave-reviewer.md | modified | +1/−1 | T9 (§6.5 sentence) |
| docs/specs/…, docs/superpowers/plans/…, docs/superpowers/reviews/… | added | +491 | run trail (incl. F-001/F-004 folds) |

`git diff --stat main..HEAD`: 20 files changed, 620 insertions(+), 13 deletions(-); only-added files are the three docs; `git diff main..HEAD -- install.sh | wc -l` → 0; binary-file count in `git diff --numstat` → 0 (AC-N-03).

## Diff

Branch `heatwave-v4-subproject-d`, commits `e5df369..HEAD` (one commit per task: T1 `c89eaff`, T2 `5f17139`, T3 `a58c3e1`, T4 `af50309`, T5 `f10849d`, T6 `f086185`, T7 `c6a1644`, T8 `46e26eb`, T9 `5bdab1d`, residuals `c560ecb`). Base: `main` @ `fe1b92c`.

## Deviation Records

None self-approved. Four reviewer-directed folds from PLAN_REVIEW (report: `docs/superpowers/reviews/2026-08-11-plan-review-D.md`, verdict APPROVED with "Findings 001–004 to be folded in during implementation"):

1. **F-001 (Minor)** — plan FR-7 "reproduced exactly" reworded to "reproduced … in the change_surface vocabulary, with the FINAL-presence precision for gitleaks" (commit `c560ecb`). Reviewer-directed plan-text edit, not an R-7 unilateral change.
2. **F-002 (Minor)** — R-122 as shipped carries the defining clause: "`external-input` means any handling of untrusted input — external, user-supplied, or crossing a service or trust boundary — the input-handling class, not only input originating outside the system", preserving spec §4.6's "input-handling" coverage. Echoed in prompts/planner.md.
3. **F-003 (Nit)** — R-122's final sentence drops the overbroad "R-102 already keeps sensitive paths out of it" aside; the operative guarantee ("EXPRESS has no plan and no change surface; companions never fire on EXPRESS") stands alone.
4. **F-004 (Nit)** — spec-correction note added to the plan's Problem Statement: spec §4.6's "present in the Claude Code adapter" was inaccurate; sole occurrence was `prompts/reviewer.md:24`, now gated (T8) and wired (T9).

Verification-shape notes for the REVIEWER (not plan deviations, judged at review): (a) AC-F-01's planted-secret Blocker demo ran at STANDARD exactly as planned, but the demo run ends ESCALATED (pending OWNER) rather than completing FIXING — the AC's evidence set (declaration, rung-fail ledger, Blocker finding, blocked run) is complete without the fix round; the additional R-121 LIGHT-combined coverage came from a separate clean run (docstring-refactor, gitleaks rung pass). (b) AC-F-06's paths inverted from the plan's expectation: Playwright MCP turned out PRESENT in the reviewer environment, so the POSITIVE path is live (a11y + screenshot) and the negative path is evidenced by live NOT-AVAILABLE declarations in the T10/T11 plans instead. (c) AC-F-07's positive-path planner was dispatched as a general-purpose (MCP-capable) context because the `heatwave-planner` agent type carries no MCP tools — an adapter capability nuance, recorded; it performed 2 on-demand lookups for 2 distinct cited external APIs (httpx + GitHub REST), zero speculative. (d) The strix-enabled positive/negative legs ran as harness re-reviews of existing run artifacts under a strix-enabled config in `hw-d-strix` (fresh FULL_REVIEW dispatches), per the plan's stub strategy.

## Migration Notes

None — text-only protocol change. Pre-D run records lack the `companions` block; the schema comment defines absent = "pre-D record or none declared"; old records are never rewritten (§9.2).

## Configuration Changes

`heatwave.config.example.yaml` only, all commented (no behavior until a user uncomments): `tooling.secrets`, `tooling.ui_evidence`, `tooling.docs`, and the `dynamic_security` block (`strix: disabled` default — absent key = disabled per R-119; `strix_target`). No env vars, no secrets.

## Test Additions

No runtime code — the "tests" are the plan's deterministic self-checks plus live protocol runs on scratch repos (scratchpad only; none in the repo):

- `hw-d-clean` (T10, zero-companion baseline): STANDARD run `add-power` → APPROVED; EXPRESS run `fix-readme-copy` → APPROVED; FULL+auth run `add-auth-check` → FULL_REVIEW GATE_MET; LIGHT runs `docstring-refactor` (surface none) and `status-page` (surface ui) → APPROVED; PLANNING-only `fetch-release` (context7 positive).
- `hw-d-floor` (T11, tools installed): STANDARD `gh-config` (planted `ghp_…` secret) → blocked at FINAL by the secrets rung; FULL `add-normalize` → real mutation-rung fail.
- `hw-d-strix` (T12): strix-enabled FULL_REVIEW re-reviews — positive (auth+FULL → run) and negative (api-surface+STANDARD → skipped-out-of-gate).

## Test Results

**AC-N-01 — drift check (run after every shard task and at completion; final output):**
```
$ sh build-protocol.sh --check
OK: PROTOCOL.md matches protocol/ shards
```
(exit 0; identical output pasted at T1, T2, T3, T4, T5, T8 commits)

**T10 ordering guarantee — tool baseline BEFORE T11 installs:**
```
semgrep: absent
gitleaks: absent
mutmut: absent
strix: absent
docker daemon: UP
```

**AC-F-09 — zero-companion STANDARD run to APPROVED (`add-power`):** plan declares `SAST … NOT AVAILABLE — probed: no semgrep on PATH, no CodeQL/Semgrep config, no CI workflows`, `Secrets … NOT AVAILABLE — probed: no gitleaks…`; FULL_REVIEW ledger `tests = pass (11/11)`, `sast = NOT_AVAILABLE`; FINAL ledger re-run adds `secrets = NOT_AVAILABLE`, `dynamic = skipped-out-of-gate`; APPROVED with all ACs satisfied. Artifacts: `hw-d-clean/.heatwave/runs/add-power/` (01–05 + run-record with `companions.detected: []`).

**AC-N-02 — EXPRESS unchanged:** grep of EXPRESS-dedicated files (`prompts/express-checker.md`, `templates/express-change.md`, `templates/express-check.md`) and `implementer.md` §4.8 for companion terms → ZERO hits; the only EXPRESS+companion co-mentions in shards are R-121/R-122 sentences stating companions never fire on EXPRESS. Live EXPRESS run `fix-readme-copy`: 166s wall clock, 2 dispatches, no companion step, PASS.

**AC-F-04 — Strix disabled default (FULL+auth, default config, `add-auth-check`):** planner itself derived `Strix: skipped-disabled (no dynamic_security key)`; FULL_REVIEW: "marker recorded is exactly `companions.strix: skipped-disabled` — legs (b) auth-surface and (c) FULL hold, leg (a) fails"; `docker ps` before == after (`diff` → IDENTICAL, one pre-existing unrelated postgres container). Run record: `companions.strix: skipped-disabled`.

**AC-F-01 — planted secret caught at FINAL as machine Blocker (`gh-config`):** planner auto-declared `SAST: semgrep (confirmed, on PATH)` and `Secrets: gitleaks (confirmed, on PATH)`; FINAL ledger:
```
- rung: secrets
  tool: "gitleaks git --log-opts='43d29a9^..43d29a9' … R-121"
  verdict: fail
  evidence_ref: "Executed 2026-08-11: 'leaks found: 2'. RuleID github-pat … Converts to machine finding F-gh-config-001 (R-111/R-121)."
```
Finding F-gh-config-001: severity Blocker, category secret-management, `rung: secrets`, status open → GATE_NOT_MET, run blocked; reviewer recorded that clearance is OWNER-waiver-or-plan-change (R-9) — run parked ESCALATED pending OWNER, exactly the R-121 waiver path.

**AC-F-02 — real sast rung at STANDARD (`gh-config` FULL_REVIEW):** `sast | semgrep scan --config auto config.py test_config.py | pass | 290 rules, 2 targets, ~100% parsed, 0 findings` — reviewer-executed, in ledger `machine_evidence` with tool + evidence_ref.

**AC-F-03 — mutation binding at FULL (`add-normalize`):** reviewer-executed mutmut 3.7.0 on `ranges.py`: **fail** — 16 mutants, 10 killed / 6 survived; 4 survivors on changed `normalize` lines converted to machine findings ("tests inadequate", default Major; 3 Major + 1 recorded reclassification), 2 pre-existing `clamp` survivors refuted as baseline via rung re-run on pre-change SHA (R-112). Ledger: `hw-d-floor/.heatwave/runs/add-normalize/04-findings-1.yaml`.

**AC-F-05 — Strix triple gate, both directions (T12, `hw-d-strix`):**
- Positive (enabled + surface {auth, external-input} + FULL): rung `dynamic` in ledger — Docker `up` 2026-08-11T08:04:56Z (`docker run -d --name hw-strix-target -p 8899:80 nginx:alpine`, probe HTTP 200), stub scan 08:05:15Z (`strix invoked: -n --target http://127.0.0.1:8899` in `tools/strix-invocations.log`), `down` 08:05:23Z (`docker rm -f`), `docker ps` after == baseline (diff IDENTICAL — container gone); clean-result evidence attached to the report. Run-record provenance (corrected per FULL_REVIEW F-005): the up/down markers originated in the reviewer's ledger/report as recorded driver instructions; the driver's first copy attempt was a silent no-op (unverified `str.replace` against a block that no longer matched), so the record briefly still read `skipped-disabled` — the §9.1 *(v4-D)* copy-duty was then executed for real during FIXING with read-back assertions, and the record now shows `strix: run` + `strix_docker_up: "2026-08-11T08:04:56Z"` + `strix_docker_down: "2026-08-11T08:05:23Z"` (`hw-d-strix/.heatwave/runs/add-auth-check/run-record.yaml:32–34`), values copied verbatim from the review artifacts, no new scan or Docker activity. AC-F-04's disabled-default evidence is the separate `hw-d-clean` record and is unaffected.
- Negative (same enabled config, STANDARD + api-surface): marker `companions.strix: skipped-out-of-gate`, legs (b)+(c) failed; reviewer invoked neither docker nor the stub — invocation log still exactly 1 line (verified by line count), docker ps unchanged.
- Real Strix: **NOT AVAILABLE (R-64)** — requires its own LLM credentials; gating verified via the shipped rule text + declared stub, stated in the reviewer's ledger verbatim. (Repo/license/headless-flag authenticity verified live for COMPANIONS.md: GitHub API — usestrix/strix, Apache-2.0, active 2026-08-10; README confirms `strix -n --target` headless mode and the official installer.)

**AC-F-06 — UI evidence (`status-page`, change_surface ui):** POSITIVE PATH LIVE — reviewer loaded Playwright MCP, asserted a11y tree (title `hw-d-clean status`; exactly one level-1 heading `hw-d-clean: all systems go`; link `View README` with working click-through) and saved a screenshot, cited against the UI ACs: `…/status-page/04-ui-evidence-status-page.png` (PNG 1200×585, verified on disk). Negative path: live NOT-AVAILABLE declarations in T10/T11 plans (e.g. `gh-config` plan: "UI evidence + docs MCP: NOT AVAILABLE") — no silent skip anywhere.

**AC-F-07 — context7 on-demand:** negative: `add-power`/`add-auth-check`/`add-normalize` plans each record context7 "present — not used: no external library API cited" (zero calls). Positive: `fetch-release` PLANNING (MCP-capable planner context) performed exactly 2 on-demand retrievals for exactly 2 distinct cited external APIs (httpx client API; GitHub REST releases endpoint), each justified in the plan's Dependencies section; no speculative or repeated calls. Nuance recorded: the plan's AC letter says "exactly one lookup" for "a plan citing an external API" — this task cited two APIs; proportionality (one lookup per cited API, zero otherwise) is the property verified.

**AC-F-08 — /security-review change-surface gate:** positive-surface path: `add-auth-check` FULL_REVIEW (surface {auth, external-input, secrets}) — gate fired, slash command not invocable in the dispatched context → R-64 declaration + manual security-category review substituted (ledger + report). Negative path: `docstring-refactor` combined pass (surface none) — reviewer: "gate does not fire (∩ = ∅), non-invocability moot", no semantic-pass activity. Gate text verified present in `prompts/reviewer.md` (rewritten line) and `adapters/claude-code/HEATWAVE.md`.

**AC-N-03 — zero new runtime deps:** diff audit above; `install.sh` delta 0; no vendored binaries (0 binary diffs); tool installs were machine-side (brew/pipx: gitleaks 8.30.1, semgrep 1.172.0, mutmut 3.7.0) and scratch-side only.

**AC-N-04 — consistency sweep:** repo-wide grep (T9 + re-run at T12): 52 hits, all consistent — shards/COMPANIONS carry the policy; prompts/adapters carry only gated instructions; README hits are COMPANIONS pointers; `protocol/implementer.md:71` is the pre-existing neutral test-type table. No statement contradicts R-120; no ungated token-costing companion instruction (the formerly ungated `prompts/reviewer.md:24` now opens "when the plan's `change_surface` intersects …").

**AC-N-05 — dispatch cost bounded:** `git diff main..HEAD -- protocol/core.md | grep "^+" | grep -v "^+++" | wc -l` → **24** added lines (≤ 90). Conditionality audit (grep output attached in the run transcript): every class-2/3 instruction is conditional — reviewer.md §4.4 ("iff … intersects", "iff change_surface ∋ ui", "strictly per R-119"), planner.md §4.1 ("MAY … when … present … never always-on"), prompts likewise ("when", "iff", "MAY").

## Blast Radius Declaration

Components touched: the six protocol shards (regenerating PROTOCOL.md), three templates, the example config, COMPANIONS.md, three role prompts, two Claude Code adapter files. Consumers: every future Heatwave dispatch (core.md is loaded by all — bounded by the 24-line budget); planner/reviewer/final-reviewer dispatches consume the new declaration/invocation text; the driver consumes the run-record `companions` schema and the HEATWAVE.md note. Shared state: run-record schema gains one optional block (absent = pre-D, old records untouched); findings-ledger rung enum extended (comment-level, non-breaking). Contracts: R-110's tool-agnostic gate contract explicitly preserved (§6.5 intro sentence); B's ladder and C's tiering/session/delta text untouched except the seven listed amendments. Out of radius: implementer/fixer shards and prompts (zero edits — implementer.md untouched per plan), install.sh, state machine, counters, EXPRESS mechanics.

## Known Limitations

- Real Strix never executed (needs its own LLM credentials + heavyweight setup) — gating verified via shipped rule text + declared stub with real Docker discipline; the positive-scan realism gap is the plan's declared R-64 mitigation, for the REVIEWER to weigh.
- The `heatwave-planner` agent type in this harness carries no MCP tools, so context7's positive path required an MCP-capable planner context; adapters whose planner contexts lack MCP will hit the R-64 labeled-assumption path by design (rule text handles it).
- AC-F-07's "exactly one lookup" was verified as "exactly one per cited external API" (2 lookups / 2 APIs); zero-API runs verified at zero.
- The `gh-config` demo run terminates ESCALATED (OWNER decision pending) by design of R-121's waiver path; it was not driven through a FIXING round.
- No `ponytail:` ceiling comments — text-only change, no code.

## Tooling Status

| Tool | Status | Would have verified | ACs affected |
|---|---|---|---|
| gitleaks 8.30.1 / semgrep 1.172.0 / mutmut 3.7.0 | installed at T11 (brew/pipx), used live | — | AC-F-01/02/03 fully machine-verified |
| Real Strix | **NOT AVAILABLE (R-64)** — own LLM credentials required | realism of a positive dynamic scan/PoC | AC-F-05 positive-scan realism — mitigated by declared stub + real Docker up/down discipline + shipped rule text; skip/marker legs fully live |
| `/security-review` slash command | **NOT AVAILABLE inside dispatched subagent contexts (R-64)** | live invocation transcript | AC-F-08 invocation half — verified as gate-fires + R-64-declares (live) and gate-silent on none-surface (live); prompt/adapter gate text verified by grep |
| Playwright MCP | AVAILABLE (probed live, used) | — | AC-F-06 positive path live; MCP rejects `file:` URLs so the reviewer served localhost and logged the substitution per R-64 |
| context7 MCP | AVAILABLE to MCP-capable contexts (used, 2 lookups); not exposed to the `heatwave-planner` agent type | — | AC-F-07 verified with the noted adapter nuance |
| Docker | AVAILABLE (daemon up); only the throwaway nginx target was created and it was torn down; no scratch containers remain (`docker ps` = pre-existing unrelated postgres only) | — | — |

All scratch evidence lives under `/private/tmp/claude-501/-Users-abhirajsinha/15c46597-eed4-480a-8abd-9bda21bc71f8/scratchpad/{hw-d-clean,hw-d-floor,hw-d-strix}/.heatwave/runs/` (run artifacts, ledgers, run records, screenshot, strix invocation log).
