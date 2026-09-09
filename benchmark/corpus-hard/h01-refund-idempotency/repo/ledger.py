"""In-memory ledger. See SPEC.md. Injected into process_refund()."""


class Ledger:
    def __init__(self, balance):
        self.balance = balance
        self._refunds = {}

    def get_refund(self, refund_id):
        return self._refunds.get(refund_id)

    def save_refund(self, refund_id, record):
        self._refunds[refund_id] = record

    def apply(self, amount):
        self.balance -= amount
