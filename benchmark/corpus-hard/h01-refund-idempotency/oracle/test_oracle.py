import unittest
from ledger import Ledger
from refund import process_refund


class TestOracle(unittest.TestCase):
    def test_repeat_same_id_applies_once(self):
        # SPEC: Calling process_refund again with the same refund_id MUST NOT change the balance again.
        ledger = Ledger(balance=100)
        process_refund(ledger, "r1", 30)
        process_refund(ledger, "r1", 30)
        self.assertEqual(ledger.balance, 70)

    def test_repeat_returns_recorded_record(self):
        # SPEC: A repeated call returns the originally recorded record.
        ledger = Ledger(balance=100)
        first = process_refund(ledger, "r1", 30)
        second = process_refund(ledger, "r1", 30)
        self.assertEqual(second, first)

    def test_distinct_ids_each_apply(self):
        # SPEC: Refunds with different refund_id values each apply once.
        ledger = Ledger(balance=100)
        process_refund(ledger, "r1", 30)
        process_refund(ledger, "r2", 20)
        self.assertEqual(ledger.balance, 50)


if __name__ == "__main__":
    unittest.main()
