"""In-memory document store. See SPEC.md. Injected into get_document()."""


class DocStore:
    def __init__(self, docs):
        self._docs = {d["id"]: d for d in docs}

    def get(self, doc_id):
        return self._docs.get(doc_id)
