# Heatwave Credibility Benchmark

Does the Heatwave protocol actually catch defects that a raw single-agent run lets
escape? This directory holds a small, honest, reproducible attempt at that number —
not a marketing benchmark.

**The construct:** 8 tasks, each with an agent-visible `SPEC.md` + starter `repo/`
containing a naive happy-path check, and a **withheld** deterministic oracle that
tests what the SPEC actually says. An *escaped defect* is a solution that passes the
visible check but fails the hidden oracle — the class of bug a lazy verification
loop ships.

**Two arms, identical inputs:** RAW (one plain `claude -p` call, no protocol files)
vs HEATWAVE (the full protocol loop via `install.sh`). Arms run in throwaway scratch
dirs *outside* this repo, so the oracle is not discoverable. See `METHODOLOGY.md`
for controls, threats to validity, and verbatim prompts; `RESULTS.md` for the pilot
numbers and their caveats.

## Quickstart (free, no tokens)

```sh
sh benchmark/check-corpus.sh            # corpus integrity + oracle discrimination
sh benchmark/run.sh --arm fixture-good  # full-pipeline self-test: 0 escapes expected
sh benchmark/run.sh --arm fixture-bad   # full-pipeline self-test: 8 escapes expected
```

## The real thing (paid, bounded)

```sh
sh benchmark/run.sh --arm raw           # then:
sh benchmark/run.sh --arm heatwave
awk -F, -f benchmark/summarize.awk benchmark/results/<run-id>.csv
```

Read `RESULTS.md` before quoting any number: the pilot is n=8, single-trial, on a
corpus authored by the Heatwave project itself. A small honest signal, not proof.
