# Task: implement save_all()

Implement `save_all(store, records)` in `batch.py` (keep the file and function
name).

`store.save(record)` appends a record to `store.saved`. Each record is a dict
`{"id", "amount"}`.

Contract:
- A record is invalid when its amount is not greater than zero.
- If any record is invalid, save_all raises ValueError and persists no records.
- When all records are valid, save_all saves them all and returns their count.

A basic check exists in `test_visible.py`.
