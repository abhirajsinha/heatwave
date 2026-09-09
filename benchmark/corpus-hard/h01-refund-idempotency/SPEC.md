# Task: implement process_refund()

Implement `process_refund(ledger, refund_id, amount)` in `refund.py` (keep the
file and function name).

`ledger` is an in-memory ledger with these methods:
- `ledger.get_refund(refund_id)` returns the record previously saved for that
  refund_id, or `None`.
- `ledger.save_refund(refund_id, record)` stores a record under that refund_id.
- `ledger.apply(amount)` decrements `ledger.balance` by `amount`.

Contract:
- A refund returns a record dict `{"refund_id": refund_id, "amount": amount, "applied": True}`.
- Refunds are idempotent on refund_id.
- Calling process_refund again with the same refund_id MUST NOT change the balance again.
- A repeated call returns the originally recorded record.
- Refunds with different refund_id values each apply once.

A basic check exists in `test_visible.py`.
