# Task: implement get_document()

Implement `get_document(store, user_id, doc_id)` in `docs.py` (keep the file
and function name).

`store` is a document store; `store.get(doc_id)` returns the document, or
`None` if there is no such document. A document is a dict
`{"id", "owner_id", "shared_with", "body"}` where `shared_with` is a list of
user ids.

Contract:
- get_document returns the document only if user_id is its owner or is listed in shared_with.
- If the user is not permitted, raise PermissionError.
- If the document does not exist, raise LookupError.

A basic check exists in `test_visible.py`.
