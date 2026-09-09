def run_import(resource, rows, transform):
    for row in rows:
        resource.write(transform(row))
    resource.commit()
    resource.release()
