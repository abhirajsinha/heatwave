# Task: implement list_documents() and search_documents()

Implement `list_documents(library, owner_id)` and
`search_documents(library, owner_id, query)` in `search.py` (keep the file and
function names).

`library.all_docs()` returns the full list of documents. A document is a dict
`{"id", "owner_id", "title"}`.

Contract:
- list_documents returns only documents whose owner_id equals owner_id.
- search_documents returns only documents owned by owner_id whose title contains query.

A basic check exists in `test_visible.py`.
