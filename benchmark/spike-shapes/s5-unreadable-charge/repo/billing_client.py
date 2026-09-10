"""Local stub of the payments client, used ONLY by the visible test.
The real client talks to the payments service, which is not in this repo."""


class BillingClient:
    def __init__(self):
        self.charges = []

    def charge(self, order_id, amount_cents, idempotency_key=None):
        cid = "ch_%s" % order_id
        self.charges.append((idempotency_key, cid, amount_cents))
        return cid
