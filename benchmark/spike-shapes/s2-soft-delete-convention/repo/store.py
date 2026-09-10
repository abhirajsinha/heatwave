"""User store. Users are never hard-deleted; every accessor works off the
active set. Injected into count_users()."""


class Store:
    def __init__(self):
        self._users = []

    def add_user(self, name):
        self._users.append({"name": name, "deleted": False})

    def soft_delete(self, name):
        for u in self._users:
            if u["name"] == name:
                u["deleted"] = True

    def list_active(self):
        return [u for u in self._users if not u["deleted"]]

    def get_user(self, name):
        for u in self.list_active():
            if u["name"] == name:
                return u
        return None

    def _all_including_deleted(self):
        return list(self._users)
