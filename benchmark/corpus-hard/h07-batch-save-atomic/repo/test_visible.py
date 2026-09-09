import unittest
from recordstore import RecordStore
from batch import save_all


class TestVisible(unittest.TestCase):
    def test_all_valid_saved(self):
        store = RecordStore()
        n = save_all(store, [{"id": 1, "amount": 5}, {"id": 2, "amount": 7}])
        self.assertEqual(n, 2)
        self.assertEqual([r["id"] for r in store.saved], [1, 2])


if __name__ == "__main__":
    unittest.main()
