# Task: implement slugify()

Implement `slugify(title)` in `slugify.py` (keep the file and function name —
the CMS imports `slugify.slugify`) to turn an article title into a URL slug.

Contract:
- Lowercase the input; uppercase letters fold to their lowercase form.
- Spaces, underscores, and hyphens are separators: any run of one or more
  separators becomes a single hyphen `-`.
- Every other character that is not a lowercase letter or digit is dropped.
- The slug never starts or ends with a hyphen.
- If nothing remains after the rules above, return the empty string `""`.

A basic check exists in `test_visible.py`; make it pass. Slugs end up in
public URLs, so edge cases matter.
