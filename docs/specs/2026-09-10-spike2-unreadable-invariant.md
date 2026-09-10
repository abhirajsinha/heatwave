# Spike 2: does an UNREADABLE deciding invariant trap a frontier RAW agent?

**Status:** SPIKE (Protocol §0.4 exempt — no plan, no plan-review, no AC ceremony). Output is a FINDING.
**Date:** 2026-09-10 · **Repo:** heatwave · **Author context:** IMPLEMENTER spike arm.
**Follow-on to:** `docs/specs/2026-09-10-spike-what-traps-raw.md` (spike 1, same author). This spike builds the *one* construction spike 1 named as still-untested: **the deciding invariant is physically absent from the handed surface.**
**Model under test (RAW):** `claude-opus-5[1m]` (session default; CSV `stage_model` = `claude-haiku-4-5-20251001;claude-opus-5[1m]` — the CLI's own sub-agent split, RAW arm, `HW_MODEL` unset, no model asymmetry). **Same model as the `hard-corpus` and spike-1 baselines** → directly comparable across all three nulls.
**Harness:** reused as-is. `RAW_DEADLINE=300 CORPUS=spike-shapes sh benchmark/run.sh --arm raw --only s5-unreadable-charge,s6-unreadable-schema,s7-unreadable-consumer --tasks 3 --trials 3`.
**Cost/wall consumed:** **$2.033** total (9 runs), mean agent wall **32.8s/run**; whole spike incl. build + `check-corpus.sh` well under the 45-min / $15 ceiling.
**Candidates:** `benchmark/spike-shapes/{s5-unreadable-charge,s6-unreadable-schema,s7-unreadable-consumer}/` (uncommitted). **Raw CSV:** `benchmark/results/20260910T013341Z-raw.csv`. **Transcripts:** `benchmark/results/transcripts/20260910T013341Z-raw/`.

## Result up front

| shape | direction | telegraphed? | graded | oracle_pass | **escaped (n=3)** |
|---|---|---|---|---|---|
| s5-unreadable-charge | unreadable service boundary (lost response + idempotency) | no | 3/3 | 3/3 | **0/3** |
| s6-unreadable-schema | state not in the repo (migration-drift, field may be absent) | no | 3/3 | 3/3 | **0/3** |
| s7-unreadable-consumer | behavior owned by an absent caller (at-least-once → dedupe) | no | 3/3 | 3/3 | **0/3** |

**Escape rate 0.000 (0/9). Third full null.** All 9 runs `graded` (zero timeout/error/escalated), deterministic, oracle-verified. Each shape passes `check-corpus.sh` (good passes oracle, bad fails oracle, bad passes the visible test) — the oracles are real and would catch a plausible-wrong implementation. The zero is a discrimination result, not a harness artifact.

## The fairness bar these shapes were built to

Each shape puts the deciding invariant *outside the repo the agent is handed* and discloses the boundary plainly in the SPEC — the honest analog of "`billing_client` calls the payments service; its implementation is not in this repo." In every shape:

- **The correct solution DEFENDS against the disclosed-but-unreadable boundary** — retries idempotently, guards the possibly-absent field, dedupes for a consumer that won't.
- **The wrong solution ASSUMES the happy path** — one call, `record["tier"]`, pass-through — and passes the visible test, because the visible test ships a *convenient* local stub (single success, field present, unique ids).
- Both are reachable from the handed surface; the crux is never spelled out as an instruction. `check-corpus.sh` confirms `bad.py` passes visible and fails oracle for all three.

This is exactly the defect class independent review exists to catch, and the tasks are fair: a competent engineer, told the boundary, codes defensively; a careless one assumes.

## Per-shape: what it was, escaped or not, and what RAW did to save itself

The signal is not the zero — it is *how* RAW defended. In every shape RAW's own transcript names the SPEC's boundary note as **the design driver** and reasons from it to the defensive code. Quotes are verbatim from `agent.ndjson`.

### s5 — unreadable service boundary (escaped 0/3)
`charge_order(order, client)`; the payments service is not in the repo. The withheld oracle's `FlakyPayments` **applies the charge server-side then loses the first response (raises)**, and dedupes only on a reused `idempotency_key`. Correct code retries with a stable key → exactly one charge + an id returned. Naive code (`bad.py`: one call, no key) raises on the lost response → fails "returns an id"; a retry-without-key variant double-charges → fails "exactly one charge."
**Why it failed to trap — quote:** *"The boundary note is the design driver: the call can fail after the service applied the charge, so any retry must reuse a stable idempotency key derived from the order rather than a fresh one."* RAW shipped a bounded retry with backoff and a key `order-<id>-<total_cents>`, then **wrote its own stub modeling the dedupe-plus-lost-response behavior and verified** "charge applied exactly once when the first two responses are lost, exactly once again after a caller-level re-invocation." It reconstructed the withheld oracle's adversary from the prose alone and tested against it.

### s6 — state not in the repo (escaped 0/3)
`usage_cost(account_id, num_events, accounts)`; records come from the production DB (not in repo). SPEC discloses `tier` was added by migration 014, run in some environments and not others. The withheld oracle feeds a **tier-less legacy record**. Correct code falls back to `rates.DEFAULT_TIER` and returns a float; naive `RATES[acct["tier"]]` raises `KeyError` — the exact founder outage (a metered route 503-ing on a column the migration hadn't added).
**Why it failed to trap — quote:** *"Missing-`tier` boundary: since migration 014 hasn't run everywhere, a record may lack the field. Rather than crash, those records bill at `rates.DEFAULT_TIER`. I treat an explicit `None` the same as absent, since a not-yet-backfilled column reads as NULL."* It even guarded the NULL case the oracle didn't test, and made a defensible call to still raise on a *garbage* tier (real data error) while defaulting on *absent* — the correct read of the SPEC's guarantee.

### s7 — behavior owned by an absent caller (escaped 0/3)
`build_feed(events)`; the analytics consumer is described, not shipped. SPEC discloses the consumer records one row per element and never dedupes, and upstream delivery is at-least-once. The withheld oracle feeds **duplicate ids**. Correct code dedupes by id (first-wins, order preserved); naive pass-through emits duplicates the absent consumer would double-count.
**Why it failed to trap — quote:** *"The SPEC's boundary note is the real requirement… dedup has to happen here, or duplicate rows get recorded."* And: *"the analytics service … does no dedup of its own … its code isn't in this repo, so it can't be changed. Passing duplicates through would therefore produce duplicate analytics rows, and this function is the only place left that can prevent it."* It reasoned to the consumer's contract "by elimination rather than stating it directly," preserved arrival order (which the visible test needs), and flagged the identity assumption.

## What this third null implies

Spike 1 showed dispersal-but-present context is defeated by `cat *.py`. This spike removes the file entirely: the invariant is *not in the repo at any budget*. It still did not trap RAW — and the transcripts show precisely why, and it is a mechanism, not luck:

**The fairness bar and the trap are in tension by construction.** To be fair, the boundary must be *disclosed* (the prompt requires it: "the agent is told plainly what it cannot see"). But disclosure puts the deciding fact back on the readable surface — as prose in the SPEC instead of code in a sibling file. A frontier model reads that prose as a first-class requirement. In all three shapes RAW literally names the boundary note "the design driver" / "the real requirement" and synthesizes the defense — the same read-everything-then-self-review loop from spike 1, now applied to the disclosed boundary rather than a neighbouring file. The unreadable code was absent; the *decision-relevant knowledge* was not, because fairness forced it into the SPEC.

The only way to make such a task trap RAW is to withhold the disclosure too — i.e. require the agent to *guess* the hidden fact. That is exactly the gotcha the prompt forbids and that measures nothing. **The fair version and the trapping version are mutually exclusive at n=3 for this model.** I could not construct a shape that is both, and per the prompt's instruction I stopped rather than lower the bar to manufacture an escape.

## Direct answer to the spike's question

**Is there a shape that traps a frontier agent on a task a competent human engineer would call fair?**

**No — this third null lands too, and I take the honest read the spike-1 report already anticipated.** Across three independent constructions (dispersed-present in spike 1, and now genuinely-absent-but-disclosed here), 0 escapes in 9+12+42 graded RAW runs on the same frontier model. The lever that would trap RAW — hiding the deciding fact entirely — is precisely what makes the task unfair. Fair-and-trapping did not exist in this design space at this scale.

**The implication, stated plainly:** on any task whose full decision-relevant context fits in one read budget — including a disclosed boundary, because a fair task must disclose it — **a frontier RAW agent is already its own reviewer.** Independent review earns its cost past that boundary, not inside it: where the deciding fact is *neither readable nor disclosable in the task* — a live prod schema no one thought to mention, another team's undocumented service behavior, a cross-repo contract nobody wrote down, tribal state that never entered the ticket. Heatwave's value is catching the case where the human writing the task *didn't know or didn't say* the invariant — not the case where the task states it and a frontier model implements it. That is a claim about *where* review pays, and it is worth stating rather than manufacturing a trap to contradict it.

## n=3 honesty
0/9 is a null with zero variance. It establishes that each unreadable-invariant mechanism was *present, disclosed, and defended* by RAW; it cannot prove any of them could *never* trap RAW, nor rank them. No ranking is claimed. The three nulls together (spike 1 dispersal, hard-corpus contract subtlety, spike 2 absent-invariant) are consistent and point one way, but each is small-n; the conclusion is a strong prior, not a proof.
