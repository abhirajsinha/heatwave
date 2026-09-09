import unittest
from tokenstore import TokenStore
from auth import authenticate


class TestVisible(unittest.TestCase):
    def test_valid_unexpired_token(self):
        store = TokenStore()
        token = {"id": "t1", "user_id": "alice", "expires_at": 100,
                 "sig": TokenStore.sign("t1", "alice", 100)}
        self.assertEqual(authenticate(store, token, now=50), "alice")


if __name__ == "__main__":
    unittest.main()
