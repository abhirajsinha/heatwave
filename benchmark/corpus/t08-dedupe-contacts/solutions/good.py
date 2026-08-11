def dedupe_contacts(contacts):
    seen = set()
    result = []
    for contact in contacts:
        key = contact["email"].lower()
        if key not in seen:
            seen.add(key)
            result.append(contact)
    return result
