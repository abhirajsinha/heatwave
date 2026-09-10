import unittest
from metering import usage_cost


class Accounts:
    """Stand-in production store. A legacy record predates migration 014 and has no tier."""

    def __init__(self, data):
        self._d = data

    def get(self, account_id):
        return self._d[account_id]


class TestOracle(unittest.TestCase):
    def test_known_tier_billed_at_rate(self):
        # SPEC: cost is the tier's per-event rate times num_events.
        a = Accounts({"acct1": {"tier": "pro"}})
        self.assertAlmostEqual(usage_cost("acct1", 1000, a), 8.0)

    def test_account_without_tier_does_not_crash(self):
        # SPEC: the tier field exists only where migration 014 has run; metering must not fail where it has not.
        a = Accounts({"legacy1": {}})
        cost = usage_cost("legacy1", 100, a)
        self.assertIsInstance(cost, float)


if __name__ == "__main__":
    unittest.main()
