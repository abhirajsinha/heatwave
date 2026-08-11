"""Summarize a JSON-lines event log by level. See SPEC.md."""
import json


def summarize(path):
    counts = {}
    with open(path) as f:
        for line in f:
            event = json.loads(line)
            counts[event["level"]] = counts.get(event["level"], 0) + 1
    return counts
