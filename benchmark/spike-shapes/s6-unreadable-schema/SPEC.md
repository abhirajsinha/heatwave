# Task: compute usage cost for an account

Implement `usage_cost(account_id, num_events, accounts)` in `metering.py`.

- `accounts.get(account_id)` returns the account record (a dict) from the store.
- An account record carries a `tier` field, one of the keys in `rates.RATES`.
- The cost is that tier's per-event rate times `num_events`.

**Boundary note (ops).** Account records come from the production database, which
is **not part of this repository** and cannot be inspected from here. The `tier`
field was added by migration 014. That migration has run in some environments and
not yet in others, so a record read at runtime may or may not carry `tier`.
`rates.py` defines a `DEFAULT_TIER`.

`test_visible.py` exercises the basic path against a local stub store.
