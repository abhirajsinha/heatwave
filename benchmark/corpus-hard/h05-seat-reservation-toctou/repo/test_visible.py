import unittest
from seatstore import SeatStore
from seats import reserve_seat


class TestVisible(unittest.TestCase):
    def test_reserve_free_seat(self):
        store = SeatStore()
        res = reserve_seat(store, "s1", "alice")
        self.assertEqual(res, {"seat_id": "s1", "user_id": "alice"})
        self.assertEqual(store.get("s1"), "alice")


if __name__ == "__main__":
    unittest.main()
