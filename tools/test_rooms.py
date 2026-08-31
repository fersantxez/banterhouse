#!/usr/bin/env python3
"""Host regressions for room semantics, geometry and binary packing."""

from __future__ import annotations

import copy
import json
from pathlib import Path

from build_rooms import pack_room, validate


def must_fail(room: dict, fragment: str) -> None:
    try:
        validate(room)
    except ValueError as error:
        assert fragment in str(error), (fragment, str(error))
    else:
        raise AssertionError(f"room validation should fail with {fragment!r}")


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    rooms = json.loads((root / "assets/rooms/vertical_slice.json").read_text(encoding="utf-8"))["rooms"]
    assert len(rooms) == 6
    payloads = []
    for room in rooms:
        validate(room)
        first = pack_room(room)
        second = pack_room(copy.deepcopy(room))
        assert first == second and first.startswith(b"BHRM") and len(first) < 512
        payloads.append(first)
    assert len(set(payloads)) == 6

    invalid = copy.deepcopy(rooms[0])
    invalid["spawn"] = invalid["obstacles"][0][:2]
    must_fail(invalid, "safe exit is unreachable")
    invalid = copy.deepcopy(rooms[0])
    invalid["obstacles"][0] = [79, 36, 8, 10]
    must_fail(invalid, "outside playfield")
    invalid = copy.deepcopy(rooms[0])
    invalid["payoff"] = ""
    must_fail(invalid, "empty semantic field")
    print("Host room schema/route/fault tests: PASS")


if __name__ == "__main__":
    main()
