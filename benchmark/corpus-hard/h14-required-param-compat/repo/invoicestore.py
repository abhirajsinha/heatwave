"""In-memory invoice store. See SPEC.md. Injected into create_invoice()."""


class InvoiceStore:
    def __init__(self, amounts):
        self._amounts = amounts
        self._seq = 0

    def amount_for(self, order_id):
        return self._amounts[order_id]

    def next_id(self):
        self._seq += 1
        return self._seq
