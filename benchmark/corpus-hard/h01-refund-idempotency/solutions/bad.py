def process_refund(ledger, refund_id, amount):
    ledger.apply(amount)
    return {"refund_id": refund_id, "amount": amount, "applied": True}
