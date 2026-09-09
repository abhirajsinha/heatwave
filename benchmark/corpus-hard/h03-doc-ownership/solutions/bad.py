def get_document(store, user_id, doc_id):
    doc = store.get(doc_id)
    if doc is None:
        raise LookupError(doc_id)
    return doc
