"""CSV export. Uses ids only."""

from serialize import to_record


def export_ids(txns):
    return "\n".join(to_record(t)["id"] for t in txns)
