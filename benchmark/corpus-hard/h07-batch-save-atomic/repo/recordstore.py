"""In-memory record store. See SPEC.md. Injected into save_all()."""


class RecordStore:
    def __init__(self):
        self.saved = []

    def save(self, record):
        self.saved.append(record)
