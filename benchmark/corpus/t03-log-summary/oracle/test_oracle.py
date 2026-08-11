import os
import tempfile
import unittest
from logstats import summarize


def _write(content):
    fd, path = tempfile.mkstemp()
    with os.fdopen(fd, "w") as f:
        f.write(content)
    return path


class TestOracle(unittest.TestCase):
    def _check(self, content, expected):
        path = _write(content)
        try:
            self.assertEqual(summarize(path), expected)
        finally:
            os.unlink(path)

    def test_corrupt_line_counted_malformed(self):   # SPEC: "corrupt (unparseable) line ... _malformed ... continues"
        self._check('{"level": "info"}\n{"level": "err\n{"level": "info"}\n',
                    {"info": 2, "_malformed": 1})

    def test_blank_line_counted_malformed(self):     # SPEC: "a blank line ... _malformed"
        self._check('{"level": "warn"}\n\n', {"warn": 1, "_malformed": 1})

    def test_missing_level_counted_malformed(self):  # SPEC: "record without a level field ... _malformed"
        self._check('{"msg": "no level"}\n{"level": "info"}\n',
                    {"_malformed": 1, "info": 1})

    def test_empty_file(self):                       # SPEC: "An empty file returns {}."
        self._check('', {})

    def test_valid_only_still_works(self):           # SPEC: "Valid lines are counted ... as today."
        self._check('{"level": "info"}\n{"level": "info"}\n', {"info": 2})


if __name__ == "__main__":
    unittest.main()
