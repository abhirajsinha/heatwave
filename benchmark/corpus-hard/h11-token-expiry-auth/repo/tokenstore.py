"""In-memory token store. See SPEC.md. Injected into authenticate()."""

import hashlib

_SECRET = "benchmark-secret"


class AuthError(Exception):
    pass


class TokenStore:
    @staticmethod
    def sign(token_id, user_id, expires_at):
        raw = f"{token_id}|{user_id}|{expires_at}|{_SECRET}"
        return hashlib.sha256(raw.encode()).hexdigest()

    def valid_signature(self, token):
        expected = self.sign(token["id"], token["user_id"], token["expires_at"])
        return token.get("sig") == expected
