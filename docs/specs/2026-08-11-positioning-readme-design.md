# Design Spec — Positioning / README Refresh (Heatwave Protocol v4, Sub-project F)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project F. Documentation/positioning only — refresh user-facing copy to reflect shipped v4 (A–E) and add honest differentiation. No protocol rule changes.
- **Depends on:** A–E merged to main (the reality the copy must match).

---

## 1. Context & problem

The README still describes the pre-v4 protocol. Five sub-projects shipped today (EXPRESS tier, sharded protocol, machine-evidence ladder, ecosystem companions, a benchmark rig), none reflected in the public copy. Meanwhile the differentiation the research identified — Heatwave is a *vendor-neutral, auditable process with an evidence ledger*, where competitors sell a bolt-on reviewer — isn't stated anywhere. F fixes both, under a hard honesty constraint: **no claim may exceed what shipped, and the benchmark must be presented as an honest, inconclusive rig — never a performance win.**

## 2. Goals / non-goals

**Goals:**
- G1. Keep the proven hook ("make your AI coding agent prove its work"); refresh the body for v4.
- G2. Accurately describe the v4 additions: EXPRESS tier + adaptive intake (ceremony scales to task size), sharded protocol, machine-evidence ladder (tests→SAST→mutation) + refute-or-promote + reproduce-then-fix, model-tiering + delta-review (cheap/fast), ecosystem companions (Semgrep/gitleaks/Playwright/context7/Strix, all optional/detected).
- G3. Add an honest "How it differs" section: vendor-neutral process + evidence ledger + works with any agent + no dependencies — vs bolt-on reviewers. No naming-and-shaming; factual contrast only.
- G4. Add a "Benchmark" section that: says a reproducible harness + seeded-bug corpus exists in `benchmark/`, invites the reader to run it, and states plainly the pilot is **inconclusive** — no performance delta is claimed yet. Link METHODOLOGY.md.
- G5. Keep the existing visual assets and overall structure; refresh, don't rewrite from scratch.

**Non-goals:**
- Any protocol rule change or PROTOCOL.md edit beyond what a doc pointer needs (none expected).
- A performance/win claim from the benchmark (forbidden — see constraints).
- Enterprise multi-repo (G) / CLI (H) copy — those features don't exist yet, so they must NOT be described as present (a "roadmap" mention is allowed only if clearly labeled future).
- Rewriting COMPANIONS.md (D already refreshed it) beyond a link.

## 3. Locked decisions (owner brainstorm)

- **Benchmark copy = honest rig, no win-claim.** State the harness exists, invite running it, say the pilot is inconclusive, claim no delta.
- **Lead = keep "prove its work", refresh for v4**, and add a differentiation ("how it differs") section.

## 4. Hard honesty constraints (the review's primary target)

- Every capability sentence must map to a shipped rule/feature on main (A–E). If it isn't in the protocol/adapters as merged, it isn't in the README as present.
- The benchmark must never be quoted as "X% fewer bugs" or any delta. Permitted: "a reproducible harness exists; run it; the pilot is inconclusive." The literal string "0/3 vs 0/3" must not appear as a result.
- Roadmap items (G, H) if mentioned are labeled explicitly as not-yet-built.
- No competitor is misrepresented; differentiation is factual (they review code; Heatwave gates a process and keeps an evidence ledger).

## 5. Design

Refresh `README.md`:
1. **Hook (keep):** the existing "prove its work" opening + the three bad habits + the three fixes — light edits only.
2. **How a task runs (update):** note ceremony now scales — EXPRESS for trivial changes (do + one independent check, no full loop) up through FULL for cross-cutting; the loop diagram stays.
3. **What's new in v4 (new, concise):** a short bullet list — adaptive intake/EXPRESS, sharded protocol (cheaper context), machine-evidence ladder + refute-or-promote + reproduce-then-fix, model-tiering + delta-review, optional ecosystem companions. Each one factual.
4. **How it differs (new):** vendor-neutral (any agent), no dependencies (just markdown), an on-disk evidence ledger + never-restart resume, separate roles that never grade their own work — the auditable-process angle. Factual contrast with bolt-on reviewers, no names.
5. **Benchmark (new, honest):** harness in `benchmark/`, how to run it, explicit "pilot inconclusive, no delta claimed," link METHODOLOGY.md.
6. **Install/getting-started:** verify the existing instructions still match v4 (install.sh ships the new shards/templates/companions); fix any drift. Touch `docs/getting-started.md` / `docs/faq.md` only where they now misstate v4.

## 6. Alternatives considered

1. **Lead with the vendor-neutral wedge.** Deferred by owner: bigger rewrite, less-proven hook. Keep the working hook, add the wedge as a section.
2. **Put a benchmark number in.** Forbidden — no conclusive number exists; would undo E's honesty.
3. **Full rewrite of README.** Rejected: the current structure + visuals are good; refresh in place (ponytail).

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Overclaim a feature not actually shipped | review cross-checks every capability sentence against merged A–E rules/adapters; unmapped claim = Major |
| Benchmark copy implies a win | honesty constraint §4; review greps for delta/percentage claims and the "0/3" string |
| Roadmap (G/H) read as present | label future items explicitly; review checks |
| Getting-started drifts from real install | reviewer runs/reads install.sh against the copy |
| Copy edits accidentally touch protocol | diff must be docs-only (README/docs/*, no protocol/ or PROTOCOL.md); drift check stays OK |

## 8. Verification strategy (evidence, not assertion)

1. **Feature-claim accuracy.** Each v4 capability sentence maps to a specific shipped rule/file (reviewer lists the mapping). Evidence: claim→rule table.
2. **No benchmark overclaim.** `grep` the README for `%`, "faster", "fewer bugs", "0/3", "vs" performance phrasing → none present as a result claim; the inconclusive statement is present. Evidence: grep output.
3. **Roadmap honesty.** Any G/H mention is labeled future. Evidence: read.
4. **Install accuracy.** Getting-started matches install.sh's actual behavior on v4. Evidence: reviewer reads both.
5. **Docs-only + no regression.** `git diff main...HEAD --stat` shows only README/docs (+ maybe an assets pointer), no protocol change; build-protocol.sh drift `OK`. Evidence: diff + drift.
6. **Links resolve.** METHODOLOGY.md / COMPANIONS.md links point at real files. Evidence: path check.

## 9. Open questions

None blocking.
