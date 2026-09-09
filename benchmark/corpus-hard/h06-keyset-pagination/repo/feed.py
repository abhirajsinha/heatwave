"""In-memory feed. See SPEC.md. Injected into next_page()."""


class Feed:
    def __init__(self, items):
        self._items = list(items)  # newest-first

    def snapshot(self):
        return list(self._items)

    def insert_newest(self, item):
        self._items.insert(0, item)
