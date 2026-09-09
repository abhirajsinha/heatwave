import unittest
from recordstore import RecordStore
from batch import save_all


class TestOracle(unittest.TestCase):
    def test_invalid_midlist_persists_nothing(self):
        # SPEC: If any record is invalid, save_all raises ValueError and persists no records.
        store = RecordStore()
        records = [{"id": 1, "amount": 5}, {"id": 2, "amount": 7},
                   {"id": 3, "amount": -1}, {"id": 4, "amount": 9}]
        with self.assertRaises(ValueError):
            save_all(store, records)
        self.assertEqual(store.saved, [])

    def test_all_valid_saved(self):
        # SPEC: When all records are valid, save_all saves them all and returns their count.
        store = RecordStore()
        n = save_all(store, [{"id": 1, "amount": 5}])
        self.assertEqual(n, 1)
        self.assertEqual(len(store.saved), 1)


if __name__ == "__main__":
    unittest.main()
