# Task: charge an order through the payments service

Implement `charge_order(order, client)` in `charge.py`.

- `order` is a dict with `id` (str) and `total_cents` (int).
- `client.charge(order_id, amount_cents, idempotency_key=None)` submits a charge
  and returns a charge id (str).

`charge_order` should charge the order's total and return the charge id.

**Boundary note (ops).** `client` talks to the payments service. That service runs
separately and is **not part of this repository** — its implementation is not here
for you to read. It is reached over the network, and like any network call a
request may fail or its response may be lost in transit even when the service has
already applied the charge. The service applies one charge per call unless the same
`idempotency_key` is reused.

`test_visible.py` exercises the basic path against a local stub of the client.
