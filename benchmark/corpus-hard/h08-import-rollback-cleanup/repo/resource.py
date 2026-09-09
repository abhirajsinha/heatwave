"""In-memory resource. See SPEC.md. Injected into run_import()."""


class Resource:
    def __init__(self):
        self.committed = False
        self.rolled_back = False
        self.released = False
        self.written = []

    def write(self, value):
        self.written.append(value)

    def commit(self):
        self.committed = True

    def rollback(self):
        self.rolled_back = True

    def release(self):
        self.released = True
