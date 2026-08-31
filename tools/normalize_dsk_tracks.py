#!/usr/bin/env python3
"""Reduce a standard CPCEMU DSK to an explicit safe track count."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("dsk", type=Path)
    parser.add_argument("--tracks", type=int, required=True)
    args = parser.parse_args()

    data = bytearray(args.dsk.read_bytes())
    if len(data) < 0x100 or not data.startswith(b"MV - CPCEMU Disk-File"):
        raise SystemExit("not a standard CPCEMU DSK")
    current_tracks = data[0x30]
    sides = data[0x31]
    track_size = struct.unpack_from("<H", data, 0x32)[0]
    if sides != 1 or not 1 <= args.tracks <= current_tracks or track_size < 0x100:
        raise SystemExit(f"cannot normalize {current_tracks}x{sides} DSK to {args.tracks} tracks")
    expected_size = 0x100 + args.tracks * track_size
    if len(data) < expected_size:
        raise SystemExit("DSK is shorter than declared geometry")
    data[0x30] = args.tracks
    args.dsk.write_bytes(data[:expected_size])
    print(f"DSK geometry: {args.tracks} tracks, {sides} side, {track_size} bytes/track")


if __name__ == "__main__":
    main()
