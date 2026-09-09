import unittest
from tokenstore import TokenStore, AuthError
from auth import authenticate


class TestOracle(unittest.TestCase):
    def test_expired_token_rejected(self):
        # SPEC: A token has expired when expires_at is less than or equal to now.
        store = TokenStore()
        token = {"id": "t1", "user_id": "alice", "expires_at": 50,
                 "sig": TokenStore.sign("t1", "alice", 50)}
        with self.assertRaises(AuthError):
            authenticate(store, token, now=100)

    def test_tampered_signature_rejected(self):
        # SPEC: A token is accepted only if its signature is valid and it has not expired.
        store = TokenStore()
        token = {"id": "t1", "user_id": "alice", "expires_at": 100, "sig": "forged"}
        with self.assertRaises(AuthError):
            authenticate(store, token, now=50)

    def test_valid_token_accepted(self):
        # SPEC: On acceptance, authenticate returns the token's user_id.
        store = TokenStore()
        token = {"id": "t1", "user_id": "alice", "expires_at": 100,
                 "sig": TokenStore.sign("t1", "alice", 100)}
        self.assertEqual(authenticate(store, token, now=50), "alice")


if __name__ == "__main__":
    unittest.main()
