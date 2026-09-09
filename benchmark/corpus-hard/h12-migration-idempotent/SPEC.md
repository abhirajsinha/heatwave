# Task: implement migrate()

Implement `migrate(records)` in `migrate.py` (keep the file and function name).

A v1 record is a dict `{"id", "name"}`. A v2 record adds `{"version": 2, "status"}`
where status is `"active"` or `"closed"`. migrate upgrades each v1 record to v2
by adding `"version": 2` and `"status": "active"`.

Contract:
- migrate returns a list of v2 records, one per input record, in the same order.
- A record already at version 2 is returned unchanged.
- migrate must not drop any record.
- Running migrate again on its own output returns the same list.

A basic check exists in `test_visible.py`.
