import unittest
from store import Store
from metrics import count_users


class TestOracle(unittest.TestCase):
    def test_excludes_soft_deleted(self):
        # SPEC: count_users returns the number of users in the store.
        store = Store()
        store.add_user("alice")
        store.add_user("bob")
        store.add_user("carol")
        store.soft_delete("bob")
        self.assertEqual(count_users(store), 2)


if __name__ == "__main__":
    unittest.main()
