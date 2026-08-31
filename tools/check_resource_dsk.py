#!/usr/bin/env python3
"""Verify that BHRES.BIN is contiguous and extractable from a DATA DSK."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

from resource_pack import AMSDOS_HEADER_SIZE, SECTOR_SIZE, inspect_container


class DskError(ValueError):
    pass


def logical_disk_bytes(image: bytes) -> tuple[bytes, int, int]:
    if len(image) < 0x100 or not image.startswith(b"MV - CPCEMU Disk-File"):
        raise DskError("not a standard CPCEMU DSK")
    tracks = image[0x30]
    sides = image[0x31]
    track_size = struct.unpack_from("<H", image, 0x32)[0]
    if tracks != 40 or sides != 1 or track_size < 0x100:
        raise DskError(f"expected 40-track single-sided DATA DSK, got {tracks}x{sides}")

    logical = bytearray()
    for track in range(tracks):
        start = 0x100 + track * track_size
        header = image[start:start + 0x100]
        if len(header) != 0x100 or not header.startswith(b"Track-Info"):
            raise DskError(f"invalid track header {track}")
        sector_count = header[0x15]
        data_cursor = start + 0x100
        sectors: list[tuple[int, bytes]] = []
        for index in range(sector_count):
            descriptor = 0x18 + index * 8
            sector_id = header[descriptor + 2]
            size_code = header[descriptor + 3]
            actual_size = struct.unpack_from("<H", header, descriptor + 6)[0]
            size = actual_size or (128 << size_code)
            payload = image[data_cursor:data_cursor + size]
            if len(payload) != size:
                raise DskError(f"truncated sector track={track} id=0x{sector_id:02X}")
            sectors.append((sector_id, payload))
            data_cursor += size
        sectors.sort(key=lambda item: item[0])
        for _, payload in sectors:
            logical.extend(payload)
    return bytes(logical), tracks, sides


def directory_entries(logical: bytes, filename: bytes) -> list[bytes]:
    if len(filename) != 11:
        raise DskError("CP/M filename must be 11 bytes")
    matches: list[bytes] = []
    for offset in range(0, 2048, 32):
        entry = logical[offset:offset + 32]
        if len(entry) < 32:
            raise DskError("truncated CP/M directory")
        clean_name = bytes(value & 0x7F for value in entry[1:12])
        if entry[0] != 0xE5 and clean_name == filename:
            matches.append(entry)
    if not matches:
        raise DskError(f"file {filename!r} not found")
    matches.sort(key=lambda entry: entry[12] | (entry[14] << 5))
    return matches


def extract_file(logical: bytes, entries: list[bytes]) -> tuple[bytes, list[int]]:
    allocation_blocks: list[int] = []
    output = bytearray()
    total_records = 0
    for entry in entries:
        records = entry[15]
        total_records += records
        blocks = [value for value in entry[16:32] if value]
        needed_blocks = (records * 128 + 1023) // 1024
        if len(blocks) < needed_blocks:
            raise DskError("extent does not contain enough allocation blocks")
        for block in blocks[:needed_blocks]:
            start = block * 1024
            payload = logical[start:start + 1024]
            if len(payload) != 1024:
                raise DskError(f"allocation block {block} is outside disk")
            allocation_blocks.append(block)
            output.extend(payload)
    return bytes(output[:total_records * 128]), allocation_blocks


def verify_dsk(path: Path, expected_container: Path) -> dict[str, object]:
    logical, tracks, sides = logical_disk_bytes(path.read_bytes())
    entries = directory_entries(logical, b"BHRES   BIN")
    file_data, blocks = extract_file(logical, entries)
    if blocks != list(range(blocks[0], blocks[0] + len(blocks))):
        raise DskError(f"BHRES.BIN is fragmented: {blocks}")

    expected = expected_container.read_bytes()
    amsdos_skip = 128 if file_data[128:132] == b"BHRS" else 0
    if file_data[amsdos_skip:amsdos_skip + len(expected)] != expected:
        raise DskError("extracted BHRES payload differs from generated container")
    if amsdos_skip + len(expected) > len(file_data):
        raise DskError("directory record count truncates BHRES")

    if amsdos_skip != AMSDOS_HEADER_SIZE:
        raise DskError(f"expected {AMSDOS_HEADER_SIZE}-byte AMSDOS header, got {amsdos_skip}")
    container = inspect_container(expected, verify_payloads=True)
    physical_offsets = [amsdos_skip + entry["offset"] for entry in container["entries"]]
    if any(offset % SECTOR_SIZE for offset in physical_offsets):
        raise DskError(f"resource payload is not sector aligned: {physical_offsets}")

    return {
        "tracks": tracks,
        "sides": sides,
        "amsdos_skip": amsdos_skip,
        "first_block": blocks[0],
        "block_count": len(blocks),
        "blocks_contiguous": True,
        "container_size": len(expected),
        "resource_file_offsets": physical_offsets,
        "resources_sector_aligned": True,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("dsk", type=Path)
    parser.add_argument("--container", type=Path, required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = verify_dsk(args.dsk, args.container)
    rendered = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.report:
        args.report.write_text(rendered, encoding="utf-8")
    print(rendered, end="")


if __name__ == "__main__":
    main()
