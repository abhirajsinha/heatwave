"""See SPEC.md. Update to_record()."""


def to_record(txn):
    return {"id": txn["id"], "amount": txn["amount"]}
