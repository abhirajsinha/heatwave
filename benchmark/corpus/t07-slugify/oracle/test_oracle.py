import unittest
from slugify import slugify


class TestOracle(unittest.TestCase):
    def test_separator_runs_collapse(self):   # SPEC: "any run of one or more separators becomes a single hyphen"
        self.assertEqual(slugify("Hello  World"), "hello-world")
        self.assertEqual(slugify("a - b"), "a-b")

    def test_all_separator_kinds(self):       # SPEC: "Spaces, underscores, and hyphens are separators"
        self.assertEqual(slugify("Hello_World-Now"), "hello-world-now")

    def test_no_leading_or_trailing_hyphen(self):  # SPEC: "The slug never starts or ends with a hyphen."
        self.assertEqual(slugify(" Leading and trailing "), "leading-and-trailing")

    def test_other_chars_dropped(self):       # SPEC: "Every other character ... is dropped."
        self.assertEqual(slugify("C++ Rocks!"), "c-rocks")

    def test_empty_result_contract(self):     # SPEC: "If nothing remains ... return the empty string"
        self.assertEqual(slugify("!!!"), "")
        self.assertEqual(slugify(""), "")

    def test_uppercase_folding(self):         # SPEC: "uppercase letters fold to their lowercase form"
        self.assertEqual(slugify("MiXeD CaSe 42"), "mixed-case-42")


if __name__ == "__main__":
    unittest.main()
