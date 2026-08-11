import json


def summarize(path):
    counts = {}
    with open(path) as f:
        for line in f:
            try:
                event = json.loads(line)
                level = event["level"]
            except (ValueError, KeyError, TypeError):
                counts["_malformed"] = counts.get("_malformed", 0) + 1
                continue
            counts[level] = counts.get(level, 0) + 1
    return counts
