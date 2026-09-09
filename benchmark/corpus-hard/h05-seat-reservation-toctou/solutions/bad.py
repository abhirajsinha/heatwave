from seatstore import SeatTaken


def reserve_seat(store, seat_id, user_id):
    if store.get(seat_id) is not None:
        raise SeatTaken(seat_id)
    store.compare_and_set(seat_id, None, user_id)
    return {"seat_id": seat_id, "user_id": user_id}
