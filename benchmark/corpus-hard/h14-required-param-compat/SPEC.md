# Task: implement create_invoice()

Implement `create_invoice(store, order_id, note="")` in `invoices.py` (keep the
file and function name).

`store.next_id()` returns a fresh integer id. `store.amount_for(order_id)`
returns the order's amount.

Contract:
- Existing callers invoke create_invoice(store, order_id) without note; note is optional and defaults to "".
- The returned invoice must include the keys id, order_id, amount, and note.
- id comes from store.next_id(); amount comes from store.amount_for(order_id).

A basic check exists in `test_visible.py`.
