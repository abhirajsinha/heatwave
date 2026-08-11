import unittest
from slugify import slugify


class TestVisible(unittest.TestCase):
    def test_simple_title(self):
        self.assertEqual(slugify("Hello World"), "hello-world")

    def test_three_words(self):
        self.assertEqual(slugify("My Blog Post"), "my-blog-post")


if __name__ == "__main__":
    unittest.main()
