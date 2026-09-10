import unittest
from store import UserStore
from lookup import find_user


class TestOracle(unittest.TestCase):
    def test_lookup_is_case_insensitive_lower_query(self):
        # SPEC: find_user returns the stored user record for the given email.
        store = UserStore()
        store.add_user("Alice@Example.COM", "Alice")
        self.assertEqual(find_user(store, "alice@example.com")["name"], "Alice")

    def test_lookup_matches_original_mixed_case(self):
        # SPEC: find_user returns the stored user record for the given email.
        store = UserStore()
        store.add_user("Alice@Example.COM", "Alice")
        self.assertEqual(find_user(store, "Alice@Example.COM")["name"], "Alice")


if __name__ == "__main__":
    unittest.main()
