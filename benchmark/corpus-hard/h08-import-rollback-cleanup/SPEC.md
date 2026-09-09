# Task: implement run_import()

Implement `run_import(resource, rows, transform)` in `importer.py` (keep the
file and function name).

`resource` has `write(value)`, `commit()`, `rollback()`, and `release()`.

Contract:
- run_import applies transform to each row and writes the result, then commits.
- If applying transform or writing raises, run_import rolls back and lets the error propagate.
- Whether it succeeds or fails, run_import must release the resource.

A basic check exists in `test_visible.py`.
