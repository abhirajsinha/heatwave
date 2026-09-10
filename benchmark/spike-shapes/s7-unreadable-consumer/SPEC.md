# Task: build the analytics feed

Implement `build_feed(events)` in `feed.py`.

- `events` is a list of event dicts, each with an `id` (str) and other fields.
- Return the list of events to publish.

**Boundary note.** The published feed is read by the analytics service, which runs
separately and is **not part of this repository** — its code is not here to read.
That service records one row per element it receives and performs no deduplication
of its own. Events arrive here from an upstream queue whose delivery is
at-least-once.

`test_visible.py` covers the basic shape.
