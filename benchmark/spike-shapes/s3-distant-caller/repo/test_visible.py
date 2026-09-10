import unittest
from serialize import to_record


class TestVisible(unittest.TestCase):
    def test_record_shows_formatted_amount(self):
        rec = to_record({"id": "t1", "amount": 1234})
        self.assertIn("$12.34", [v for v in rec.values() if isinstance(v, str)])
        self.assertEqual(rec["id"], "t1")


if __name__ == "__main__":
    unittest.main()
