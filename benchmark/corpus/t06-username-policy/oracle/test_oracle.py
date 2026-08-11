import unittest
from username import is_valid_username


class TestOracle(unittest.TestCase):
    def test_uppercase_rejected(self):       # SPEC: "uppercase letters are not valid in usernames"
        self.assertFalse(is_valid_username("Admin"))
        self.assertFalse(is_valid_username("aLice"))

    def test_leading_digit_rejected(self):   # SPEC: "The first character must be a lowercase letter (not a digit ...)"
        self.assertFalse(is_valid_username("1337admin"))

    def test_leading_underscore_rejected(self):  # SPEC: "The first character must be a lowercase letter (... not an underscore)"
        self.assertFalse(is_valid_username("_alice"))

    def test_illegal_chars_rejected(self):   # SPEC: "Only lowercase letters a-z, digits 0-9, and underscore _ are allowed"
        self.assertFalse(is_valid_username("al!ce"))
        self.assertFalse(is_valid_username("a b c"))

    def test_valid_names_still_accepted(self):   # SPEC: "returns True when the name satisfies the whole policy"
        self.assertTrue(is_valid_username("alice_01"))
        self.assertTrue(is_valid_username("bob"))
        self.assertTrue(is_valid_username("z_9" + "x" * 17))

    def test_length_rule_still_enforced(self):   # SPEC: "Length 3 to 20 characters inclusive"
        self.assertFalse(is_valid_username("ab"))
        self.assertFalse(is_valid_username("a" * 21))


if __name__ == "__main__":
    unittest.main()
