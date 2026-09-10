"""Local stub accounts store, used ONLY by the visible test.
The real store is the production database, which is not in this repo."""


class Accounts:
    def __init__(self, data):
        self._d = data

    def get(self, account_id):
        return self._d[account_id]
