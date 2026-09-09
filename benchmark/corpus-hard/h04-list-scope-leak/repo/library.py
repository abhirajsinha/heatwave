"""In-memory document library. See SPEC.md. Injected into the search functions."""


class Library:
    def __init__(self, docs):
        self._docs = list(docs)

    def all_docs(self):
        return list(self._docs)
