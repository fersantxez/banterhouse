#!/usr/bin/env python3
"""Create deterministic fault-injection variants of the FDC lab DSK."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


def locate_sector(image: bytearray, track: int, sector_id: int) -> tuple[int, int]:
    if not image.startswith(b"MV - CPCEMU Disk-File"):
        raise ValueError("not a standard CPCEMU DSK")
    track_size = struct.unpack_from("<H", image, 0x32)[0]
    track_start = 0x100 + track * track_size
    header = track_start
    sector_count = image[header + 0x15]
    data_cursor = track_start + 0x100
    for index in range(sector_count):
        descriptor = header + 0x18 + index * 8
        size_code = image[descriptor + 3]
        actual_size = struct.unpack_from("<H", image, descriptor + 6)[0]
        size = actual_size or (128 << size_code)
        if image[descriptor + 2] == sector_id:
            return descriptor, data_cursor
        data_cursor += size
    raise ValueError(f"sector 0x{sector_id:02X} not found on track {track}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--mode", choices=("payload-crc", "missing-sector"), required=True)
    args = parser.parse_args()

    image = bytearray(args.source.read_bytes())
    descriptor, payload = locate_sector(image, track=0, sector_id=0xC6)
    if args.mode == "payload-crc":
        image[payload] ^= 0x80
    else:
        image[descriptor + 2] = 0xCA
    args.output.write_bytes(image)


if __name__ == "__main__":
    main()
