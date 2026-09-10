# Task: add a display amount to transaction records

`to_record(txn)` in `serialize.py` turns a transaction into a record dict.
`txn` is a dict with keys `id` (str) and `amount` (int, in cents).

Update `to_record` so the record shows the amount formatted as a dollar string
like `"$12.34"` (1234 cents -> `"$12.34"`). Keep `to_record` returning a dict.

A basic check exists in `test_visible.py`.
