import unittest
from ledger import Ledger
from refund import process_refund


class TestVisible(unittest.TestCase):
    def test_single_refund_decrements_once(self):
        ledger = Ledger(balance=100)
        rec = process_refund(ledger, "r1", 30)
        self.assertEqual(ledger.balance, 70)
        self.assertEqual(rec["amount"], 30)


if __name__ == "__main__":
    unittest.main()
