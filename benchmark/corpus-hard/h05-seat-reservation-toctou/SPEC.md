# Task: implement reserve_seat()

Implement `reserve_seat(store, seat_id, user_id)` in `seats.py` (keep the file
and function name).

`store` is a seat store with two methods:
- `store.get(seat_id)` returns the user currently holding the seat, or `None`.
- `store.compare_and_set(seat_id, expected, new)` sets the holder to `new` only
  if the current holder equals `expected`; it returns `True` when it set the
  value and `False` when it did not.

Contract:
- A seat must be held by exactly one user.
- Claim a free seat for `user_id` by setting its holder from `None` to `user_id`.
- If the seat is already held, raise SeatTaken.
- On a successful claim, return `{"seat_id": seat_id, "user_id": user_id}`.

Import `SeatTaken` from `seatstore`. A basic check exists in `test_visible.py`.
