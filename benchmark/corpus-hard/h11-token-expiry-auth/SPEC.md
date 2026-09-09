# Task: implement authenticate()

Implement `authenticate(store, token, now)` in `auth.py` (keep the file and
function name).

A token is a dict `{"id", "user_id", "expires_at", "sig"}` where `expires_at`
is an integer and `now` is the current integer time. `store.valid_signature(token)`
returns whether the token's signature is authentic.

Contract:
- A token is accepted only if its signature is valid and it has not expired.
- A token has expired when expires_at is less than or equal to now.
- On acceptance, authenticate returns the token's user_id.
- Reject an invalid or expired token by raising AuthError.

Import `AuthError` from `tokenstore`. A basic check exists in `test_visible.py`.
