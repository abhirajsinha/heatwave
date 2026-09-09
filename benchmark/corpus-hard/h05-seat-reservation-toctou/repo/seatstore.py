"""In-memory seat store. See SPEC.md. Injected into reserve_seat()."""


class SeatTaken(Exception):
    pass


class SeatStore:
    def __init__(self):
        self._holders = {}

    def get(self, seat_id):
        return self._holders.get(seat_id)

    def compare_and_set(self, seat_id, expected, new):
        if self._holders.get(seat_id) == expected:
            self._holders[seat_id] = new
            return True
        return False
