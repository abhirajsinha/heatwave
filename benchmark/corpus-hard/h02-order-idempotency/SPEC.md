# Task: implement place_order()

Implement `place_order(store, order_id, items)` in `orders.py` (keep the file
and function name).

`store` is an order store with these methods:
- `store.get_order(order_id)` returns the record saved for that order_id, or `None`.
- `store.save_order(order_id, record)` stores a record under that order_id.
- `store.add_line_items(items)` appends `items` to `store.line_items`.

Contract:
- A placed order returns a record dict `{"order_id": order_id, "items": items}`.
- place_order is idempotent on order_id.
- A retried order with the same order_id must not add its line items again.
- A repeated call returns the order recorded by the first call.

A basic check exists in `test_visible.py`.
