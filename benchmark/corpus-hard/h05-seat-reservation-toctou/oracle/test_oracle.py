import unittest
from seatstore import SeatTaken
from seats import reserve_seat


class StaleSeatStore:
    """get() reports the seat free, but another user already holds it (a lost update)."""

    def __init__(self, real_holder):
        self._holder = real_holder

    def get(self, seat_id):
        return None

    def compare_and_set(self, seat_id, expected, new):
        if self._holder == expected:
            self._holder = new
            return True
        return False

    def holder(self):
        return self._holder


class TestOracle(unittest.TestCase):
    def test_lost_update_raises_seat_taken(self):
        # SPEC: If the seat is already held, raise SeatTaken.
        store = StaleSeatStore(real_holder="alice")
        with self.assertRaises(SeatTaken):
            reserve_seat(store, "s1", "bob")

    def test_lost_update_preserves_existing_holder(self):
        # SPEC: A seat must be held by exactly one user.
        store = StaleSeatStore(real_holder="alice")
        try:
            reserve_seat(store, "s1", "bob")
        except SeatTaken:
            pass
        self.assertEqual(store.holder(), "alice")


if __name__ == "__main__":
    unittest.main()
