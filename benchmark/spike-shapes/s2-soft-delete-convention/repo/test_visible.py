import unittest
from store import Store
from metrics import count_users


class TestVisible(unittest.TestCase):
    def test_counts_users(self):
        store = Store()
        store.add_user("alice")
        store.add_user("bob")
        self.assertEqual(count_users(store), 2)


if __name__ == "__main__":
    unittest.main()
