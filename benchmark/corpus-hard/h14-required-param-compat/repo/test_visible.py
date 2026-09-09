import unittest
from invoicestore import InvoiceStore
from invoices import create_invoice


class TestVisible(unittest.TestCase):
    def test_create_with_note(self):
        store = InvoiceStore({"o1": 500})
        inv = create_invoice(store, "o1", note="paid in full")
        self.assertEqual(inv["order_id"], "o1")
        self.assertEqual(inv["note"], "paid in full")
        self.assertEqual(inv["id"], 1)


if __name__ == "__main__":
    unittest.main()
