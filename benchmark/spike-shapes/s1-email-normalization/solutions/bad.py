from store import UserStore  # noqa: F401


def find_user(store, email):
    return store.get_by_email(email)
