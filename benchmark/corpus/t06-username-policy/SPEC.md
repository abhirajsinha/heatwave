# Task: fix the holes in username.is_valid_username()

Bug report: users are registering usernames like `1337admin`, `Admin`, and
`al!ce` — support says the signup form accepts names our policy forbids.

Fix `username.py` (keep the file and function name — signup imports
`username.is_valid_username`). The full policy:

- Length 3 to 20 characters inclusive (this part already works).
- Only lowercase letters `a-z`, digits `0-9`, and underscore `_` are allowed —
  uppercase letters are not valid in usernames.
- The first character must be a lowercase letter (not a digit, not an
  underscore).
- `is_valid_username(name)` returns `True` when the name satisfies the whole
  policy, `False` otherwise.

`test_visible.py` covers the length rule, which works today; keep it passing.
