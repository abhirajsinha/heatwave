import unittest
from accounts import Accounts
from metering import usage_cost


class TestVisible(unittest.TestCase):
    def test_cost_by_tier(self):
        a = Accounts({"acct1": {"tier": "standard"}})
        self.assertAlmostEqual(usage_cost("acct1", 100, a), 1.0)


if __name__ == "__main__":
    unittest.main()
