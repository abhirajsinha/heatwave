import os
import tempfile
import unittest
from logstats import summarize


class TestVisible(unittest.TestCase):
    def test_counts_levels(self):
        fd, path = tempfile.mkstemp()
        with os.fdopen(fd, "w") as f:
            f.write('{"level": "info", "msg": "a"}\n{"level": "error", "msg": "b"}\n'
                    '{"level": "info", "msg": "c"}\n')
        try:
            self.assertEqual(summarize(path), {"info": 2, "error": 1})
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
