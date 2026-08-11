import unittest
from stats import mean


class TestOracle(unittest.TestCase):
    def test_empty_raises_value_error(self):   # SPEC: "An empty list raises ValueError"
        with self.assertRaises(ValueError):
            mean([])

    def test_string_raises_type_error(self):   # SPEC: "not an int or float raises TypeError"
        with self.assertRaises(TypeError):
            mean([1, "2", 3])

    def test_none_raises_type_error(self):     # SPEC: "not an int or float raises TypeError"
        with self.assertRaises(TypeError):
            mean([None])

    def test_bool_raises_type_error(self):     # SPEC: "a bool element also raises TypeError"
        with self.assertRaises(TypeError):
            mean([True, True])

    def test_single_element(self):             # SPEC: "A single-element list returns that element as a float."
        self.assertEqual(mean([7]), 7.0)
        self.assertIsInstance(mean([7]), float)

    def test_mean_value(self):                 # SPEC: "return their arithmetic mean as a float"
        self.assertEqual(mean([1, 2, 3, 4]), 2.5)


if __name__ == "__main__":
    unittest.main()
