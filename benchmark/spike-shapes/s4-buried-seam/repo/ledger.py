"""Append-only ledger store."""


class Ledger:
    def __init__(self):
        self._rows = []

    def append(self, txn):
        self._rows.append(txn)

    def all(self):
        return list(self._rows)
