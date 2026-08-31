#!/usr/bin/env python3
"""Build and verify the versioned Banterhouse BHRES container."""

from __future__ import annotations

import argparse
import binascii
import hashlib
import json
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Any


MAGIC = b"BHRS"
HEADER_SIZE = 20
ENTRY_SIZE = 20
SECTOR_SIZE = 512
AMSDOS_HEADER_SIZE = 128
MAX_RESOURCE_SIZE = 0xFFFF

TYPE_IDS = {
    "background_screen": 1,
    "room_pack": 2,
    "tileset": 3,
    "sprite_set": 4,
    "portrait_set": 5,
    "ui_pack": 6,
    "text_pack": 7,
    "audio_song": 8,
    "audio_sfx": 9,
    "cutscene_frame": 10,
}
TARGET_IDS = {
    "hidden_framebuffer": 1,
    "ram4": 4,
    "ram5": 5,
    "ram6": 6,
    "ram7": 7,
}
CACHE_FLAGS = {"resident": 0x01, "area": 0x02, "room": 0x04, "scene": 0x08, "discardable": 0x10}


class ResourceError(ValueError):
    pass


@dataclass(frozen=True)
class Resource:
    resource_id: int
    symbol: str
    type_name: str
    source: Path
    codec: str
    target: str
    cache: str
    dependencies: tuple[str, ...]
    payload: bytes


@dataclass(frozen=True)
class PackedEntry:
    resource: Resource
    offset: int
    stored_size: int
    unpacked_size: int
    dependency_start: int
    dependency_count: int
    payload_crc: int


def crc16(data: bytes) -> int:
    return binascii.crc_hqx(data, 0xFFFF)


def align(value: int, alignment: int = SECTOR_SIZE) -> int:
    return (value + alignment - 1) & ~(alignment - 1)


def align_disk_payload(container_offset: int) -> int:
    """Align a container byte after iDSK prepends its 128-byte AMSDOS header."""
    return align(AMSDOS_HEADER_SIZE + container_offset) - AMSDOS_HEADER_SIZE


def pack_u24(value: int) -> bytes:
    if not 0 <= value <= 0xFFFFFF:
        raise ResourceError(f"u24 out of range: {value}")
    return bytes((value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF))


def unpack_u24(data: bytes) -> int:
    if len(data) != 3:
        raise ResourceError("u24 requires exactly three bytes")
    return data[0] | (data[1] << 8) | (data[2] << 16)


def load_manifest(path: Path, root: Path) -> tuple[int, list[Resource]]:
    try:
        raw: dict[str, Any] = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ResourceError(f"cannot parse {path}: {error}") from error

    version = raw.get("format_version")
    if version != 1:
        raise ResourceError(f"unsupported format_version: {version}")
    records = raw.get("resources")
    if not isinstance(records, list) or not records:
        raise ResourceError("manifest resources must be a non-empty list")

    resources: list[Resource] = []
    ids: set[int] = set()
    symbols: set[str] = set()
    for record in records:
        try:
            value = record["id"]
            resource_id = int(value, 0) if isinstance(value, str) else int(value)
            symbol = str(record["symbol"])
            type_name = str(record["type"])
            source = root / str(record["source"])
            codec = str(record.get("codec", "none"))
            target = str(record["target"])
            cache = str(record.get("cache", "discardable"))
            dependencies = tuple(str(item) for item in record.get("dependencies", []))
        except (KeyError, TypeError, ValueError) as error:
            raise ResourceError(f"invalid resource record: {record}") from error

        if not 0 < resource_id <= 0xFFFF:
            raise ResourceError(f"resource ID out of range: {resource_id}")
        if resource_id in ids:
            raise ResourceError(f"duplicate resource ID: 0x{resource_id:04X}")
        if symbol in symbols:
            raise ResourceError(f"duplicate resource symbol: {symbol}")
        if type_name not in TYPE_IDS:
            raise ResourceError(f"unknown resource type: {type_name}")
        if target not in TARGET_IDS:
            raise ResourceError(f"unknown target: {target}")
        if cache not in CACHE_FLAGS:
            raise ResourceError(f"unknown cache policy: {cache}")
        if codec != "none":
            raise ResourceError(f"codec not implemented in F1: {codec}")
        try:
            payload = source.read_bytes()
        except OSError as error:
            raise ResourceError(f"cannot read resource {symbol}: {source}") from error
        if not payload or len(payload) > MAX_RESOURCE_SIZE:
            raise ResourceError(f"resource {symbol} has invalid size {len(payload)}")

        ids.add(resource_id)
        symbols.add(symbol)
        resources.append(Resource(resource_id, symbol, type_name, source, codec, target, cache, dependencies, payload))

    resources.sort(key=lambda item: item.resource_id)
    validate_dependencies(resources)
    return version, resources


def validate_dependencies(resources: list[Resource]) -> None:
    by_symbol = {resource.symbol: resource for resource in resources}
    for resource in resources:
        for dependency in resource.dependencies:
            if dependency not in by_symbol:
                raise ResourceError(f"{resource.symbol} depends on missing {dependency}")

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(symbol: str) -> None:
        if symbol in visiting:
            raise ResourceError(f"dependency cycle at {symbol}")
        if symbol in visited:
            return
        visiting.add(symbol)
        for dependency in by_symbol[symbol].dependencies:
            visit(dependency)
        visiting.remove(symbol)
        visited.add(symbol)

    for resource in resources:
        visit(resource.symbol)


def calculate_build_id(version: int, resources: list[Resource]) -> int:
    digest = hashlib.sha256()
    digest.update(bytes((version,)))
    for resource in resources:
        digest.update(struct.pack("<H", resource.resource_id))
        digest.update(resource.symbol.encode("ascii"))
        digest.update(b"\0")
        digest.update(resource.type_name.encode("ascii"))
        digest.update(b"\0")
        digest.update(resource.target.encode("ascii"))
        digest.update(b"\0")
        digest.update(resource.cache.encode("ascii"))
        digest.update(b"\0")
        for dependency in resource.dependencies:
            digest.update(dependency.encode("ascii"))
            digest.update(b"\0")
        digest.update(resource.payload)
    return int.from_bytes(digest.digest()[:4], "little")


def build_container(version: int, resources: list[Resource]) -> tuple[bytes, int, list[PackedEntry]]:
    by_symbol = {resource.symbol: resource for resource in resources}
    dependency_ids: list[int] = []
    dependency_starts: dict[str, int] = {}
    for resource in resources:
        dependency_starts[resource.symbol] = len(dependency_ids)
        dependency_ids.extend(by_symbol[name].resource_id for name in resource.dependencies)

    index_size = ENTRY_SIZE * len(resources) + 2 * len(dependency_ids)
    data_offset = align_disk_payload(HEADER_SIZE + index_size)
    cursor = data_offset
    entries: list[PackedEntry] = []
    for resource in resources:
        cursor = align_disk_payload(cursor)
        entries.append(PackedEntry(
            resource=resource,
            offset=cursor,
            stored_size=len(resource.payload),
            unpacked_size=len(resource.payload),
            dependency_start=dependency_starts[resource.symbol],
            dependency_count=len(resource.dependencies),
            payload_crc=crc16(resource.payload),
        ))
        cursor += len(resource.payload)

    index = bytearray()
    for entry in entries:
        index.extend(struct.pack(
            "<HBB", entry.resource.resource_id, TYPE_IDS[entry.resource.type_name], CACHE_FLAGS[entry.resource.cache]
        ))
        index.extend(pack_u24(entry.offset))
        index.extend(struct.pack(
            "<HHBBHBHH",
            entry.stored_size,
            entry.unpacked_size,
            0,
            TARGET_IDS[entry.resource.target],
            entry.dependency_start,
            entry.dependency_count,
            entry.payload_crc,
            0,
        ))
    for dependency_id in dependency_ids:
        index.extend(struct.pack("<H", dependency_id))
    if len(index) != index_size:
        raise ResourceError(f"internal index size mismatch: {len(index)} != {index_size}")

    build_id = calculate_build_id(version, resources)
    header_without_crc = (
        struct.pack("<4sBBH", MAGIC, version, 0, len(resources))
        + pack_u24(HEADER_SIZE)
        + pack_u24(data_offset)
        + struct.pack("<I", build_id)
        + b"\0\0"
    )
    header_crc = crc16(header_without_crc + index)
    header = header_without_crc[:-2] + struct.pack("<H", header_crc)

    output = bytearray(header)
    output.extend(index)
    output.extend(b"\0" * (data_offset - len(output)))
    for entry in entries:
        output.extend(b"\0" * (entry.offset - len(output)))
        output.extend(entry.resource.payload)
    return bytes(output), build_id, entries


def write_outputs(container_path: Path, header_path: Path, report_path: Path, version: int, resources: list[Resource]) -> None:
    container, build_id, entries = build_container(version, resources)
    container_path.parent.mkdir(parents=True, exist_ok=True)
    header_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    container_path.write_bytes(container)

    lines = [
        "#ifndef BANTERHOUSE_RESOURCE_IDS_H",
        "#define BANTERHOUSE_RESOURCE_IDS_H",
        "",
        f"#define BH_RESOURCE_FORMAT_VERSION {version}",
        f"#define BH_RESOURCE_BUILD_ID 0x{build_id:08X}UL",
        f"#define BH_RESOURCE_BUILD_ID_B0 0x{build_id & 0xFF:02X}",
        f"#define BH_RESOURCE_BUILD_ID_B1 0x{(build_id >> 8) & 0xFF:02X}",
        f"#define BH_RESOURCE_BUILD_ID_B2 0x{(build_id >> 16) & 0xFF:02X}",
        f"#define BH_RESOURCE_BUILD_ID_B3 0x{(build_id >> 24) & 0xFF:02X}",
        f"#define BH_RESOURCE_COUNT {len(resources)}",
        f"#define BH_RESOURCE_AMSDOS_SKIP {AMSDOS_HEADER_SIZE}",
        "",
    ]
    for entry in entries:
        symbol = entry.resource.symbol
        disk_file_offset = AMSDOS_HEADER_SIZE + entry.offset
        lines.extend((
            f"#define {symbol} 0x{entry.resource.resource_id:04X}",
            f"#define {symbol}_OFFSET {entry.offset}UL",
            f"#define {symbol}_FILE_OFFSET {disk_file_offset}UL",
            f"#define {symbol}_FILE_SECTOR {disk_file_offset // SECTOR_SIZE}",
            f"#define {symbol}_STORED_SIZE {entry.stored_size}",
            f"#define {symbol}_SECTOR_COUNT {(entry.stored_size + SECTOR_SIZE - 1) // SECTOR_SIZE}",
            f"#define {symbol}_CRC16 0x{entry.payload_crc:04X}",
            "",
        ))
    lines.extend(("", "#endif", ""))
    header_path.write_text("\n".join(lines), encoding="ascii")

    asm_lines = [
        ";; Generated by tools/resource_pack.py; do not edit.",
        f"BH_RESOURCE_FORMAT_VERSION = {version}",
        f"BH_RESOURCE_BUILD_ID_B0 = 0x{build_id & 0xFF:02X}",
        f"BH_RESOURCE_BUILD_ID_B1 = 0x{(build_id >> 8) & 0xFF:02X}",
        f"BH_RESOURCE_BUILD_ID_B2 = 0x{(build_id >> 16) & 0xFF:02X}",
        f"BH_RESOURCE_BUILD_ID_B3 = 0x{(build_id >> 24) & 0xFF:02X}",
        f"BH_RESOURCE_COUNT = {len(resources)}",
        f"BH_RESOURCE_AMSDOS_SKIP = {AMSDOS_HEADER_SIZE}",
        "",
    ]
    for entry in entries:
        symbol = entry.resource.symbol
        disk_file_offset = AMSDOS_HEADER_SIZE + entry.offset
        logical_sector = 4 + disk_file_offset // SECTOR_SIZE
        asm_lines.extend((
            f"{symbol} = 0x{entry.resource.resource_id:04X}",
            f"{symbol}_FILE_SECTOR = {disk_file_offset // SECTOR_SIZE}",
            f"{symbol}_DISK_TRACK = {logical_sector // 9}",
            f"{symbol}_DISK_SECTOR_ID = 0x{0xC1 + logical_sector % 9:02X}",
            f"{symbol}_STORED_SIZE = {entry.stored_size}",
            f"{symbol}_SECTOR_COUNT = {(entry.stored_size + SECTOR_SIZE - 1) // SECTOR_SIZE}",
            f"{symbol}_CRC16 = 0x{entry.payload_crc:04X}",
            f"{symbol}_CRC16_LO = 0x{entry.payload_crc & 0xFF:02X}",
            f"{symbol}_CRC16_HI = 0x{(entry.payload_crc >> 8) & 0xFF:02X}",
            "",
        ))
    header_path.with_suffix(".s").write_text("\n".join(asm_lines), encoding="ascii")

    report = {
        "format_version": version,
        "build_id": f"0x{build_id:08X}",
        "container_size": len(container),
        "amsdos_skip": AMSDOS_HEADER_SIZE,
        "sector_size": SECTOR_SIZE,
        "resources": [
            {
                "id": f"0x{entry.resource.resource_id:04X}",
                "symbol": entry.resource.symbol,
                "type": entry.resource.type_name,
                "offset": entry.offset,
                "disk_file_offset": AMSDOS_HEADER_SIZE + entry.offset,
                "stored_size": entry.stored_size,
                "unpacked_size": entry.unpacked_size,
                "crc16": f"0x{entry.payload_crc:04X}",
                "target": entry.resource.target,
                "cache": entry.resource.cache,
                "dependencies": list(entry.resource.dependencies),
            }
            for entry in entries
        ],
    }
    report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def inspect_container(data: bytes, verify_payloads: bool = True) -> dict[str, Any]:
    if len(data) < HEADER_SIZE:
        raise ResourceError("container shorter than header")
    magic, version, flags, count = struct.unpack_from("<4sBBH", data, 0)
    if magic != MAGIC:
        raise ResourceError(f"wrong magic: {magic!r}")
    index_offset = unpack_u24(data[8:11])
    data_offset = unpack_u24(data[11:14])
    build_id = struct.unpack_from("<I", data, 14)[0]
    stored_header_crc = struct.unpack_from("<H", data, 18)[0]
    if version != 1 or flags != 0 or index_offset != HEADER_SIZE:
        raise ResourceError("unsupported header fields")
    if data_offset > len(data) or (AMSDOS_HEADER_SIZE + data_offset) % SECTOR_SIZE:
        raise ResourceError("invalid data offset")

    entries: list[dict[str, int]] = []
    index_end = index_offset + count * ENTRY_SIZE
    if index_end > data_offset:
        raise ResourceError("index exceeds data area")
    max_dependency = 0
    for index in range(count):
        start = index_offset + index * ENTRY_SIZE
        resource_id, type_id, cache_flags = struct.unpack_from("<HBB", data, start)
        offset = unpack_u24(data[start + 4:start + 7])
        stored_size, unpacked_size, codec, target, dependency_start, dependency_count, payload_crc, reserved = struct.unpack_from(
            "<HHBBHBHH", data, start + 7
        )
        if reserved or codec != 0 or type_id not in TYPE_IDS.values() or target not in TARGET_IDS.values():
            raise ResourceError(f"entry 0x{resource_id:04X} has unsupported fields")
        if cache_flags not in CACHE_FLAGS.values():
            raise ResourceError(f"entry 0x{resource_id:04X} has invalid cache flags")
        if ((AMSDOS_HEADER_SIZE + offset) % SECTOR_SIZE or
                offset < data_offset or offset + stored_size > len(data)):
            raise ResourceError(f"entry 0x{resource_id:04X} has invalid bounds")
        if stored_size != unpacked_size:
            raise ResourceError("F1 only supports raw resources")
        if verify_payloads and crc16(data[offset:offset + stored_size]) != payload_crc:
            raise ResourceError(f"entry 0x{resource_id:04X} payload CRC mismatch")
        max_dependency = max(max_dependency, dependency_start + dependency_count)
        entries.append({"id": resource_id, "offset": offset, "size": stored_size, "crc16": payload_crc})

    dependency_end = index_end + max_dependency * 2
    if dependency_end > data_offset:
        raise ResourceError("dependency list exceeds data area")
    header_for_crc = bytearray(data[:HEADER_SIZE])
    header_for_crc[18:20] = b"\0\0"
    calculated = crc16(bytes(header_for_crc) + data[index_offset:dependency_end])
    if calculated != stored_header_crc:
        raise ResourceError("header/index CRC mismatch")

    return {
        "version": version,
        "count": count,
        "build_id": build_id,
        "data_offset": data_offset,
        "entries": entries,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    pack_parser = subparsers.add_parser("pack")
    pack_parser.add_argument("--manifest", type=Path, required=True)
    pack_parser.add_argument("--root", type=Path, required=True)
    pack_parser.add_argument("--output", type=Path, required=True)
    pack_parser.add_argument("--header", type=Path, required=True)
    pack_parser.add_argument("--report", type=Path, required=True)
    inspect_parser = subparsers.add_parser("inspect")
    inspect_parser.add_argument("container", type=Path)
    inspect_parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    if args.command == "pack":
        version, resources = load_manifest(args.manifest, args.root)
        write_outputs(args.output, args.header, args.report, version, resources)
        result = inspect_container(args.output.read_bytes(), verify_payloads=True)
        print(
            f"BHRES: {result['count']} resources, {args.output.stat().st_size} bytes, "
            f"build 0x{result['build_id']:08X}"
        )
    else:
        result = inspect_container(args.container.read_bytes(), verify_payloads=args.verify)
        print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
