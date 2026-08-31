#!/usr/bin/env python3
"""Validate and pack the six-room Banterhouse vertical slice."""

from __future__ import annotations

import argparse
import json
import struct
from collections import deque
from pathlib import Path


LANDMARKS = {
    "reception_arch": 1, "paper_wall": 2, "elevator_proof": 3,
    "copy_machine": 4, "red_pencil": 5, "deadline_clock": 6,
}
PLAYER_W = 8
PLAYER_H = 32
MAX_X = 72
TOP = 18
BOTTOM = 168


def blocked(x: int, y: int, obstacles: list[list[int]]) -> bool:
    if x < 0 or x > MAX_X or y < TOP or y > BOTTOM - PLAYER_H:
        return True
    return any(x + PLAYER_W > bx and x < bx + bw and y + PLAYER_H > by and y < by + bh
               for bx, by, bw, bh in obstacles)


def route_exists(spawn: list[int], obstacles: list[list[int]], exit_side: str) -> bool:
    start = tuple(spawn)
    if blocked(*start, obstacles):
        return False
    queue = deque([start])
    visited = {start}
    while queue:
        x, y = queue.popleft()
        if (exit_side == "right" and x == MAX_X) or (exit_side == "left" and x == 0):
            return True
        for dx, dy in ((-1, 0), (1, 0), (0, -2), (0, 2)):
            candidate = (x + dx, y + dy)
            if candidate not in visited and not blocked(*candidate, obstacles):
                visited.add(candidate)
                queue.append(candidate)
    return False


def validate(room: dict) -> None:
    required_text = ("symbol", "landmark", "verb", "rule", "twist", "payoff", "safe_exit")
    if any(not isinstance(room.get(field), str) or not room[field] for field in required_text):
        raise ValueError(f"room has empty semantic field: {room}")
    if room["landmark"] not in LANDMARKS or room["safe_exit"] not in ("left", "right"):
        raise ValueError(f"room has invalid landmark/exit: {room['symbol']}")
    if not (0 <= room["level"] < 10 and 0 <= room["room"] < 3 and 0 <= room["palette"] < 10):
        raise ValueError(f"room coordinates/palette out of range: {room['symbol']}")
    obstacles = room.get("obstacles")
    if not isinstance(obstacles, list) or not 1 <= len(obstacles) <= 8:
        raise ValueError(f"room must have 1..8 obstacles: {room['symbol']}")
    for rect in obstacles:
        if len(rect) != 4 or any(not isinstance(value, int) for value in rect):
            raise ValueError(f"bad obstacle in {room['symbol']}")
        x, y, width, height = rect
        if x < 0 or y < TOP or width <= 0 or height <= 0 or x + width > 80 or y + height > BOTTOM:
            raise ValueError(f"obstacle outside playfield in {room['symbol']}")
    if not route_exists(room["spawn"], obstacles, room["safe_exit"]):
        raise ValueError(f"safe exit is unreachable in {room['symbol']}")


def pack_room(room: dict) -> bytes:
    output = bytearray(struct.pack(
        "<4sBBBBBBBB", b"BHRM", 1, room["level"], room["room"], room["palette"],
        LANDMARKS[room["landmark"]], room["spawn"][0], room["spawn"][1],
        1 if room["safe_exit"] == "right" else 0,
    ))
    output.append(len(room["obstacles"]))
    for rect in room["obstacles"]:
        output.extend(bytes(rect))
    for field in ("verb", "rule", "twist", "payoff"):
        encoded = room[field].encode("ascii")
        if len(encoded) > 63:
            raise ValueError(f"{field} is too long in {room['symbol']}")
        output.append(len(encoded))
        output.extend(encoded)
    return bytes(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    source = json.loads(args.source.read_text(encoding="utf-8"))
    rooms = source.get("rooms", [])
    if source.get("format_version") != 1 or len(rooms) != 6:
        raise ValueError("vertical slice must contain exactly six version-1 rooms")
    coordinates = set()
    symbols = set()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    report = []
    for room in rooms:
        validate(room)
        coordinate = (room["level"], room["room"])
        if coordinate in coordinates or room["symbol"] in symbols:
            raise ValueError(f"duplicate room coordinate/symbol: {room['symbol']}")
        coordinates.add(coordinate)
        symbols.add(room["symbol"])
        payload = pack_room(room)
        if len(payload) > 14336:
            raise ValueError(f"room exceeds RAM5 budget: {room['symbol']}")
        path = args.output_dir / f"{room['symbol'].lower()}.bin"
        path.write_bytes(payload)
        report.append({"symbol": room["symbol"], "level": room["level"], "room": room["room"],
                       "landmark": room["landmark"], "size": len(payload), "safe_route": True})
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps({"rooms": report}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("Vertical slice room packs: PASS (6 rooms, safe routes, RAM5 budget)")


if __name__ == "__main__":
    main()
