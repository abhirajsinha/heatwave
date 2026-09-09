def get_document(store, user_id, doc_id):
    doc = store.get(doc_id)
    if doc is None:
        raise LookupError(doc_id)
    if user_id != doc["owner_id"] and user_id not in doc.get("shared_with", []):
        raise PermissionError(doc_id)
    return doc
