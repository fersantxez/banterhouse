#!/usr/bin/env python3
"""Validate the 30-screen visual bible and emit compact CPC tables."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOMS = 30
MAX_RECTS = 16


def validate(data: dict) -> list[dict]:
    if data.get("format_version") != 1:
        raise ValueError("room visuals must use format_version 1")
    rooms = data.get("rooms")
    if not isinstance(rooms, list) or len(rooms) != ROOMS:
        raise ValueError("room visuals must contain exactly 30 rooms")
    coordinates: set[tuple[int, int]] = set()
    labels: set[str] = set()
    landmarks: set[str] = set()
    for room in rooms:
        coordinate = (room.get("level"), room.get("room"))
        if coordinate in coordinates or coordinate != (len(coordinates) // 3, len(coordinates) % 3):
            raise ValueError(f"room coordinates must be unique and ordered: {coordinate}")
        coordinates.add(coordinate)
        label = room.get("label")
        landmark = room.get("landmark")
        if not isinstance(label, str) or not label or len(label) > 18 or not label.isascii():
            raise ValueError(f"invalid CPC label at {coordinate}")
        if label in labels or not isinstance(landmark, str) or not landmark or landmark in landmarks:
            raise ValueError(f"labels and landmarks must be unique at {coordinate}")
        labels.add(label)
        landmarks.add(landmark)
        colours = [room.get(name) for name in ("paper", "ink", "accent", "shadow")]
        if any(not isinstance(colour, int) or not 0 <= colour < 16 for colour in colours):
            raise ValueError(f"invalid palette index at {coordinate}")
        if room["paper"] == room["ink"] or room["accent"] == room["paper"]:
            raise ValueError(f"room lacks semantic contrast at {coordinate}")
        rects = room.get("rects")
        if not isinstance(rects, list) or not 8 <= len(rects) <= MAX_RECTS:
            raise ValueError(f"room must contain 8..{MAX_RECTS} backdrop rectangles at {coordinate}")
        covered = 0
        for rect in rects:
            if len(rect) != 5 or any(not isinstance(value, int) for value in rect):
                raise ValueError(f"invalid rectangle at {coordinate}")
            x, y, width, height, colour = rect
            if x < 2 or y < 18 or width <= 0 or height <= 0 or x + width > 78 or y + height > 168:
                raise ValueError(f"rectangle outside playfield at {coordinate}: {rect}")
            if not 0 <= colour < 16:
                raise ValueError(f"invalid rectangle colour at {coordinate}: {rect}")
            covered += width * height
        if covered < 300:
            raise ValueError(f"room backdrop is too sparse at {coordinate}")
    return rooms


def emit_header(path: Path) -> None:
    path.write_text("""#ifndef BANTERHOUSE_ROOM_VISUALS_H
#define BANTERHOUSE_ROOM_VISUALS_H

#include "bh_types.h"

typedef struct {
   u8 x, y, width, height, colour;
} BHBackdropRect;

typedef struct {
   u16 first_rect;
   u8 rect_count;
   u8 paper, ink, accent, shadow;
} BHRoomVisual;

extern const BHBackdropRect bh_backdrop_rects[];
extern const BHRoomVisual bh_room_visuals[30];
extern const u8* const bh_room_labels[30];

#endif
""", encoding="ascii")


def emit_source(path: Path, rooms: list[dict]) -> None:
    lines = [
        '#include "room_visuals.h"',
        '',
        '#ifdef __SDCC',
        '#pragma constseg BH_GFX',
        '#endif',
        '',
    ]
    for index, room in enumerate(rooms):
        escaped = room["label"].replace('"', '\\"')
        lines.append(f'static const u8 room_label_{index}[] = "{escaped}";')
    lines.extend(['', 'const u8* const bh_room_labels[30] = {'])
    for start in range(0, ROOMS, 5):
        lines.append('   ' + ', '.join(f'room_label_{index}' for index in range(start, min(start + 5, ROOMS))) + ',')
    lines.extend(['};', '', 'const BHBackdropRect bh_backdrop_rects[] = {'])
    first_rects = []
    cursor = 0
    for room in rooms:
        first_rects.append(cursor)
        lines.append(f'   /* L{room["level"] + 1} R{room["room"] + 1}: {room["landmark"]} */')
        for rect in room["rects"]:
            lines.append('   {' + ', '.join(str(value) for value in rect) + '},')
            cursor += 1
    lines.extend(['};', '', 'const BHRoomVisual bh_room_visuals[30] = {'])
    for first, room in zip(first_rects, rooms):
        lines.append(
            f'   {{{first}, {len(room["rects"])}, {room["paper"]}, {room["ink"]}, '
            f'{room["accent"]}, {room["shadow"]}}},'
        )
    lines.extend(['};', ''])
    path.write_text('\n'.join(lines), encoding='ascii')


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--header', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    rooms = validate(json.loads(args.source.read_text(encoding='utf-8')))
    args.header.parent.mkdir(parents=True, exist_ok=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    emit_header(args.header)
    emit_source(args.output, rooms)
    args.report.write_text(json.dumps({
        'format_version': 1,
        'rooms': len(rooms),
        'rectangles': sum(len(room['rects']) for room in rooms),
        'unique_landmarks': len({room['landmark'] for room in rooms}),
        'maximum_rectangles_per_room': max(len(room['rects']) for room in rooms),
    }, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    print(f"Room visuals: PASS ({len(rooms)} rooms, 30 unique landmarks)")


if __name__ == '__main__':
    main()
