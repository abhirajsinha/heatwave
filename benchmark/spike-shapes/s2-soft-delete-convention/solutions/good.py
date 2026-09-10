from store import Store  # noqa: F401


def count_users(store):
    return len(store.list_active())
