"""User store. Injected into find_user()."""


class UserStore:
    def __init__(self):
        self._by_email = {}

    def add_user(self, email, name):
        key = email.strip().lower()
        self._by_email[key] = {"email": key, "name": name}

    def get_by_email(self, email):
        # Exact key lookup. Returns the record or None.
        return self._by_email.get(email)
