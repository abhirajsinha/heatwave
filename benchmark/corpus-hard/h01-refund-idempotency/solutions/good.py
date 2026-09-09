def process_refund(ledger, refund_id, amount):
    existing = ledger.get_refund(refund_id)
    if existing is not None:
        return existing
    ledger.apply(amount)
    record = {"refund_id": refund_id, "amount": amount, "applied": True}
    ledger.save_refund(refund_id, record)
    return record
