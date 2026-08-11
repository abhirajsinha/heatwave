# Task: implement dedupe_contacts()

Implement `dedupe_contacts(contacts)` in `dedupe.py` (keep the file and
function name — the importer imports `dedupe.dedupe_contacts`).

Contract:
- `contacts` is a list of dicts, each with `"email"` and `"name"` keys.
- Returns a new list with duplicate contacts removed. Two contacts are
  duplicates when their emails match **case-insensitively**
  (`Ada@example.com` and `ada@EXAMPLE.com` are the same contact).
- For each set of duplicates, keep the **first** occurrence exactly as it
  appeared (its original email casing and name).
- The order of the surviving contacts is the order of their first appearance.
- The input list is not modified.

A basic check exists in `test_visible.py`; make it pass. This runs on CRM
imports, where the same person shows up with differently-cased emails.
