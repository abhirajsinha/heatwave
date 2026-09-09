from tokenstore import AuthError


def authenticate(store, token, now):
    if not store.valid_signature(token):
        raise AuthError("bad signature")
    if token["expires_at"] <= now:
        raise AuthError("expired")
    return token["user_id"]
