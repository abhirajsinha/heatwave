# Spike: what task shape makes a frontier coding agent ship a defect?

**Status:** SPIKE (Protocol §0.4 exempt — no plan, no plan-review). Output is a FINDING, not shippable corpus.
**Date:** 2026-09-10 · **Repo:** heatwave@dfd612e · **Author context:** IMPLEMENTER spike arm.
**Model under test (RAW):** `claude-opus-5[1m]` (session default; CSV `stage_model` = `claude-haiku-4-5;claude-opus-5[1m]` — the CLI's own sub-agent split, RAW arm, no model asymmetry). **Same model as the `hard-corpus` baseline** → directly comparable.
**Harness:** reused as-is. `CORPUS=spike-shapes sh benchmark/run.sh --arm raw --tasks 4 --trials 3` (RAW_DEADLINE=300s).
**Cost/wall consumed:** **$2.57** total (12 runs), agent wall sum **307s** (mean 25.6s/run); whole spike incl. build+checks well under the 45-min / $15 ceiling.
**Candidates:** `benchmark/spike-shapes/` (uncommitted). **Raw CSV:** `benchmark/results/20260910T012147Z-raw.csv`. **Transcripts:** `benchmark/results/transcripts/20260910T012147Z-raw/`.

## Result up front

| shape | direction probed | telegraphed? | graded | **escaped (n=3)** |
|---|---|---|---|---|
| s1-email-normalization | invariant living elsewhere (store.py lowercases keys) | no | 3/3 | **0/3** |
| s2-soft-delete-convention | unwritten tribal convention (deleted rows don't count) | no | 3/3 | **0/3** |
| s3-distant-caller | distant caller depends on numeric field (report.py, 3 files) | no | 3/3 | **0/3** |
| s4-buried-seam | same defect as s3, buried in 16 files | no | 3/3 | **0/3** |

**Escape rate 0.000 (0/12). Another full null.** All 12 runs `graded`, deterministic, oracle-verified. Each shape passes `check-corpus.sh` (good passes oracle, bad fails oracle, bad passes the visible test) — so the oracles are real and would have caught a plausible-wrong implementation. The zero is a discrimination result, not a harness artifact.

The working hypothesis — *"defects escape when the knowledge needed is NOT in front of the agent: dispersed across a codebase, unwritten, or owned by code it did not author"* — **did not hold at this scale.** None of these three dispersal mechanisms trapped RAW.

## Per-shape: what it was, and why RAW saved itself

Each shape's defect is genuinely dispersed — the SPEC is complete about the goal and silent about the tribal context, exactly as a real ticket is. The visible test passes a naive implementation in every case. RAW still shipped correct code in every trial. **The reason is the same across all four, and it is the mechanism, not luck:** the entire agent surface is a handful of small files that `run.sh` copies whole, and `opus-5` reads the whole surface before writing, then self-reviews past the visible test against the trap it reconstructs from what it read.

### s1 — invariant living elsewhere (0/3)
`store.py::add_user` stores keys as `email.strip().lower()`; `get_by_email` is an exact dict lookup. SPEC: "return the user for the given email." The lowercase-on-write rule is never stated. Visible test queries an already-normalized address, so `get_by_email(email)` passes it.
**Why it failed to trap:** the agent `ls`-ed and read `store.py`, then wrote, verbatim: *"add_user normalizes keys with strip().lower(), but get_by_email only does exact lookup — so find_user must apply the same normalization"* and *"a naive pass-through would work for the visible tests (which use an already-normalized address) but fail on any query differing in case."* It reconstructed the exact trap **and** the exact reason the visible test misses it, then normalized the query. This is the h05-TOCTOU self-review behavior repeating: the model reviews to the withheld oracle's standard from the sibling file alone.
**Caveat:** email case-insensitivity is also guessable from domain knowledge, so s1 does not cleanly isolate "reading the sibling" from "knowing emails are case-folded." The transcript shows it did read the sibling; the confound only matters if you wanted s1 to prove dispersal specifically.

### s2 — unwritten tribal convention (0/3)
Soft-delete: `store.py` filters `deleted` in `list_active`/`get_user`; the only accessor exposing deleted rows is named `_all_including_deleted`. SPEC: "count_users returns the number of users." Silent about soft-delete. This convention is **not** guessable from domain knowledge (count-including-deleted is a defensible reading in the abstract).
**Why it failed to trap:** the agent ran `cat store.py` up front, saw that every real accessor works off the active set and that the deleted-inclusive accessor is underscore-private, and used `list_active()`. The convention was loud in the file it read; reading it was enough.

### s3 — distant caller (0/3)
`report.py::daily_total` sums `to_record(t)["amount"]` (int cents). SPEC: "update to_record so the amount shows as a `$12.34` string." Silent that a caller depends on the numeric field. Bad impl clobbers `amount` with the string → `daily_total` breaks.
**Why it failed to trap:** the agent ran `cat serialize.py report.py test_visible.py && grep -rn ...` for callers **before editing** — it grepped for consumers exactly as the ponytail rule prescribes — found `daily_total`'s numeric dependence, and added a new `amount_display` field while leaving `amount` numeric. It never had to be told there was a caller; it looked.

### s4 — buried seam (0/3)
Identical defect to s3, but `report.py` is 1 of **16 files** (12 plausible filler modules: validators, permissions, pagination, ledger, currency, …). The hypothesis: dispersion *volume* forces the model to locate context rather than read it.
**Why it failed to trap:** the agent ran `for f in *.py; do echo …; cat $f; done` — it dumped **all 16 files**, found `report.py` among them, and preserved the invariant. **"Buried in 16 files" is not buried when the whole surface is a few KB and one `cat *.py` reads it all.** Volume at this scale costs the model ~5s of extra wall (31s vs 26s) and changes nothing.

## What this null actually implies

The three dispersal mechanisms (invariant elsewhere / unwritten convention / distant caller) are real sources of human defects, but they **only bite when reading the relevant code is infeasible or the code is genuinely absent** — not when it is merely in a neighbouring file. Every shape here kept the knowledge inside the copied surface, and the surface was small enough to read in full. `opus-5`'s default loop is: read the whole surface → grep callers → self-test against the reconstructed edge. That loop defeats "dispersed but present" context outright.

This sharpens (does not refute) the finding's hypothesis. The lever that matters is **not** dispersal per se — it is whether the deciding knowledge is **reachable within the agent's read budget.** Two ways to make it unreachable, neither of which any shape here implemented:

1. **Genuinely absent from the surface** — the invariant is enforced by a service/module/DB constraint that is *not in the repo the agent is handed* (a real cross-repo or runtime contract). The agent cannot `cat` what isn't there. This is the honest version of "owned by code it did not author."
2. **Present but past the read budget** — a repo large enough (hundreds of files / not `cat *.py`-able in one shot) that locating the one caller requires search that can miss, under a realistic per-task budget. s4 tried this with 16 files and lost by two orders of magnitude; the real threshold is much higher and is itself the thing to measure.

## Recommendation

**None of the four shapes is worth building a corpus around as-built.** They reproduce the `hard-corpus` null for the same reason: small, fully-readable surface + a model that reads all of it and self-reviews.

**One direction is worth a follow-on spike (not a corpus yet):** mechanism (1) above — the deciding invariant **physically absent from the handed surface**, enforced by a stub the agent is told exists but cannot read (e.g. "the persistence layer rejects X" with no persistence layer in the repo, only its interface). That is the only construction that cannot be defeated by `cat`-ing the surface, and it is the honest form of "knowledge the agent did not author and cannot reach." If that also fails to trap RAW, the practical conclusion is strong: **a single frontier RAW agent on a readable task is already its own reviewer, and the value of a review protocol is not in catching single-shot single-file defects but in the places a single read budget genuinely cannot reach — cross-repo/runtime contracts and large-repo search** — which is a claim about *where* Heatwave earns its cost, and worth stating plainly rather than manufacturing a trap.

**Do not** invest in mechanism (2) (large-repo volume) before (1): it is expensive to build and s4 gives no reason to expect volume alone flips the result until the surface is far past `cat`-able.

### n=3 honesty
0/12 is a null with zero variance. It establishes each mechanism was *present and defeated*; it cannot rank the shapes or prove any of them could *never* trap RAW. No ranking is claimed.
