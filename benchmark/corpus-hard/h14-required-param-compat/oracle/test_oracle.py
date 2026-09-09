import unittest
from invoicestore import InvoiceStore
from invoices import create_invoice


class TestOracle(unittest.TestCase):
    def test_old_contract_call_returns_amount(self):
        # SPEC: The returned invoice must include the keys id, order_id, amount, and note.
        store = InvoiceStore({"o1": 500})
        inv = create_invoice(store, "o1")
        self.assertEqual(inv["amount"], 500)

    def test_old_contract_note_defaults_empty(self):
        # SPEC: Existing callers invoke create_invoice(store, order_id) without note; note is optional and defaults to "".
        store = InvoiceStore({"o1": 500})
        inv = create_invoice(store, "o1")
        self.assertEqual(inv["note"], "")


if __name__ == "__main__":
    unittest.main()
