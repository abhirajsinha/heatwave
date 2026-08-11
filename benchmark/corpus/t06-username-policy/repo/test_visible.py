import unittest
from username import is_valid_username


class TestVisible(unittest.TestCase):
    def test_valid_name_accepted(self):
        self.assertTrue(is_valid_username("alice_01"))

    def test_too_short_rejected(self):
        self.assertFalse(is_valid_username("ab"))

    def test_too_long_rejected(self):
        self.assertFalse(is_valid_username("a" * 21))


if __name__ == "__main__":
    unittest.main()
