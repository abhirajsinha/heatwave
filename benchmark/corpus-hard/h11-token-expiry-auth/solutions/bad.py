from tokenstore import AuthError


def authenticate(store, token, now):
    if not store.valid_signature(token):
        raise AuthError("bad signature")
    return token["user_id"]
