# Task: implement cart_total()

Implement `cart_total(items)` in `cart.py` (keep the file and function name —
checkout imports `cart.cart_total`).

Contract:
- `items` is a list of dicts, each with a `"price"` and a `"qty"` key.
- Returns the order total: the sum of `price * qty` over all items, rounded to
  2 decimal places (money is cent-exact).
- `qty` must be an integer >= 1; a zero, negative, or non-integer `qty` raises
  `ValueError` (this is a checkout path — bad quantities must never price).
- `price` must be a number >= 0; a negative `price` raises `ValueError`.
- An empty cart totals `0.0`.

A basic check exists in `test_visible.py`; make it pass.
