import unittest
from billing_client import BillingClient
from charge import charge_order


class TestVisible(unittest.TestCase):
    def test_charges_and_returns_id(self):
        c = BillingClient()
        cid = charge_order({"id": "o1", "total_cents": 500}, c)
        self.assertEqual(cid, "ch_o1")
        self.assertEqual(len(c.charges), 1)


if __name__ == "__main__":
    unittest.main()
