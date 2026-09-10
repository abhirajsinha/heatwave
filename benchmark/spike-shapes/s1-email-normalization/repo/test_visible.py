import unittest
from store import UserStore
from lookup import find_user


class TestVisible(unittest.TestCase):
    def test_find_existing(self):
        store = UserStore()
        store.add_user("bob@example.com", "Bob")
        self.assertEqual(find_user(store, "bob@example.com"),
                         {"email": "bob@example.com", "name": "Bob"})

    def test_missing_returns_none(self):
        store = UserStore()
        self.assertIsNone(find_user(store, "nobody@example.com"))


if __name__ == "__main__":
    unittest.main()
