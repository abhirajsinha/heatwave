import unittest
from serialize import to_record
from report import daily_total


class TestOracle(unittest.TestCase):
    def test_display_string_present(self):
        # SPEC: record shows the amount formatted as a dollar string like "$12.34".
        rec = to_record({"id": "t1", "amount": 1234})
        self.assertIn("$12.34", [v for v in rec.values() if isinstance(v, str)])

    def test_daily_total_still_sums_cents(self):
        # SPEC: to_record turns a transaction into a record dict (existing report consumers unbroken).
        txns = [{"id": "a", "amount": 1234}, {"id": "b", "amount": 100}]
        self.assertEqual(daily_total(txns), 1334)


if __name__ == "__main__":
    unittest.main()
