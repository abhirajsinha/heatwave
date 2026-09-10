import unittest
from charge import charge_order


class FlakyPayments:
    """Stand-in for the real payments service (not in the agent's repo).
    Applies the charge server-side, but the FIRST response is lost (raises after
    applying). Dedupes only when the same idempotency_key is reused."""

    def __init__(self):
        self.applied = {}        # idempotency_key -> charge id
        self.no_key_charges = 0  # charges made with no key (cannot dedupe)
        self.calls = 0

    def charge(self, order_id, amount_cents, idempotency_key=None):
        self.calls += 1
        if idempotency_key is not None and idempotency_key in self.applied:
            return self.applied[idempotency_key]  # idempotent replay, no new charge
        if idempotency_key is None:
            self.no_key_charges += 1
            cid = "ch_%s_%d" % (order_id, self.no_key_charges)
        else:
            cid = "ch_%s" % order_id
            self.applied[idempotency_key] = cid
        if self.calls == 1:
            raise ConnectionError("response lost")  # charge applied, response dropped
        return cid

    def total_charges(self):
        return len(self.applied) + self.no_key_charges


class TestOracle(unittest.TestCase):
    def test_returns_id_despite_lost_first_response(self):
        # SPEC: charge the order and return the charge id; a network response may be lost.
        p = FlakyPayments()
        cid = charge_order({"id": "o1", "total_cents": 500}, p)
        self.assertTrue(cid)

    def test_exactly_one_charge_applied(self):
        # SPEC: the service dedupes only on a reused idempotency_key; do not double-charge on retry.
        p = FlakyPayments()
        try:
            charge_order({"id": "o1", "total_cents": 500}, p)
        except Exception:
            pass
        self.assertEqual(p.total_charges(), 1)


if __name__ == "__main__":
    unittest.main()
