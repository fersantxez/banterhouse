#!/usr/bin/env python3
"""Import manuel3d's exact Locomotive BASIC SYMBOL definitions from font.dsk.

The source asset is the official download from:
https://manuel3d.itch.io/letter-font-for-amstrad

The author permits use in projects on that page, but does not publish a named
license.  This importer deliberately reads FONTBASI.BAS from the DSK instead of
depending on firmware, the CPC character ROM, or the BASIC loader at runtime.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


OFFICIAL_DSK_SHA256 = "02cbbedce3f452895160f8cd178939333d655a7bc0fa6c6a7c705a1168694d3b"
FONTBASI_SHA256 = "aa3a0aa1672d1d57f1b6e82da9c2c03fb30848ab8e2d9d87d63c75b6afb45784"
EXPECTED_SOURCE_CODES = (
    tuple(range(0x41, 0x5B))
    + (0xA1,)
    + tuple(range(0x61, 0x6F))
    + (0xAB,)
    + tuple(range(0x6F, 0x7B))
    + tuple(range(0x30, 0x3A))
    + (
        0x21, 0x3F, 0x25, 0x22, 0x24, 0x23, 0x26, 0x27,
        0x28, 0x29, 0x2B, 0x2D, 0x2A, 0x2F, 0x5C, 0x5B,
        0x5D, 0x2C, 0x2E, 0x3A, 0x3B, 0x5F, 0x3D, 0xA3,
        0x3C, 0x3E, 0x5E, 0x7C, 0x40, 0x60, 0xAF, 0xAE,
    )
)

ASCII_FIRST = 0x20
ASCII_LAST = 0x7E
INTERNAL_SPECIALS = (0xA1, 0xA3, 0xAE, 0xAF, 0xAB)
FONT_DATA_ADDRESS = 0x1B00


class FontImportError(ValueError):
    """The source DSK is not the expected, structurally valid asset."""


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_extended_dsk(dsk: bytes) -> bytes:
    """Return sectors in CPC logical order from a one-sided Extended DSK."""
    if not dsk.startswith(b"EXTENDED CPC DSK File\r\nDisk-Info\r\n"):
        raise FontImportError("source is not an Extended CPC DSK")
    tracks = dsk[0x30]
    sides = dsk[0x31]
    if sides != 1:
        raise FontImportError(f"expected one disk side, found {sides}")

    offset = 0x100
    disk_data = bytearray()
    for track_index in range(tracks * sides):
        track_units = dsk[0x34 + track_index]
        if not track_units:
            continue
        track_size = track_units * 256
        header = dsk[offset : offset + 0x100]
        if not header.startswith(b"Track-Info\r\n"):
            raise FontImportError(f"invalid track header at track {track_index}")
        sector_count = header[0x15]
        sector_offset = offset + 0x100
        sectors: dict[int, bytes] = {}
        for sector_index in range(sector_count):
            descriptor = header[0x18 + sector_index * 8 : 0x20 + sector_index * 8]
            sector_id = descriptor[2]
            sector_size = descriptor[6] | (descriptor[7] << 8)
            if not sector_size:
                sector_size = 128 << descriptor[3]
            sectors[sector_id] = dsk[sector_offset : sector_offset + sector_size]
            sector_offset += sector_size
        if sector_offset > offset + track_size:
            raise FontImportError(f"sector data exceeds track {track_index}")
        disk_data.extend(b"".join(sectors[key] for key in sorted(sectors)))
        offset += track_size
    return bytes(disk_data)


def extract_cpm_file(disk_data: bytes, filename: str) -> bytes:
    """Extract a small AMSDOS/CP-M file from this CPC data-format disk."""
    stem, suffix = filename.upper().split(".", 1)
    wanted = stem.ljust(8).encode("ascii") + suffix.ljust(3).encode("ascii")
    extents: list[tuple[int, int, list[int]]] = []
    for offset in range(0, 64 * 32, 32):
        entry = disk_data[offset : offset + 32]
        if len(entry) != 32 or entry[0] in (0xE5,):
            continue
        entry_name = bytes(value & 0x7F for value in entry[1:12])
        if entry_name != wanted:
            continue
        extent_number = entry[12] + ((entry[14] & 0x3F) << 5)
        blocks = [block for block in entry[16:32] if block]
        extents.append((extent_number, entry[15], blocks))
    if not extents:
        raise FontImportError(f"{filename} is absent from the DSK directory")

    contents = bytearray()
    record_count = 0
    for _, records, blocks in sorted(extents):
        for block in blocks:
            start = block * 1024
            contents.extend(disk_data[start : start + 1024])
        record_count += records
    return bytes(contents[: record_count * 128])


def extract_basic_payload(amsdos_file: bytes) -> bytes:
    if len(amsdos_file) < 128:
        raise FontImportError("FONTBASI.BAS has no AMSDOS header")
    expected_checksum = amsdos_file[67] | (amsdos_file[68] << 8)
    if sum(amsdos_file[:67]) & 0xFFFF != expected_checksum:
        raise FontImportError("FONTBASI.BAS has an invalid AMSDOS checksum")
    payload_size = amsdos_file[64] | (amsdos_file[65] << 8)
    end = 128 + payload_size
    if end > len(amsdos_file):
        raise FontImportError("FONTBASI.BAS payload is truncated")
    return amsdos_file[128:end]


def _numeric_literals(line: bytes) -> list[int]:
    """Decode the compact integer forms used by Locomotive BASIC here."""
    values: list[int] = []
    offset = 0
    while offset < len(line):
        token = line[offset]
        if 0x0E <= token <= 0x18:
            values.append(token - 0x0E)
            offset += 1
        elif token == 0x19:
            if offset + 1 >= len(line):
                raise FontImportError("truncated BASIC byte literal")
            values.append(line[offset + 1])
            offset += 2
        elif token == 0x1A:
            if offset + 2 >= len(line):
                raise FontImportError("truncated BASIC 16-bit literal")
            values.append(line[offset + 1] | (line[offset + 2] << 8))
            offset += 3
        else:
            offset += 1
    return values


def extract_symbol_glyphs(payload: bytes) -> list[tuple[int, tuple[int, ...]]]:
    """Extract SYMBOL code,row... statements, padding omitted trailing rows."""
    glyphs: list[tuple[int, tuple[int, ...]]] = []
    offset = 0
    while offset + 2 <= len(payload):
        line_size = payload[offset] | (payload[offset + 1] << 8)
        if not line_size:
            break
        if line_size < 5 or offset + line_size > len(payload):
            raise FontImportError("invalid tokenized BASIC line length")
        body = payload[offset + 4 : offset + line_size]
        offset += line_size
        # 0xCF is SYMBOL.  SYMBOL AFTER contains token 0x80 immediately after
        # the space and is ignored because it has no row definitions.
        if not body.startswith(b"\xCF ") or body[2:3] == b"\x80":
            continue
        values = _numeric_literals(body[2:])
        if len(values) < 2 or len(values) > 9:
            raise FontImportError(f"unexpected SYMBOL arity: {len(values)}")
        code, rows = values[0], values[1:]
        if code > 0xFF or any(row > 0xFF for row in rows):
            raise FontImportError("SYMBOL value is outside the byte range")
        rows.extend([0] * (8 - len(rows)))
        glyphs.append((code, tuple(rows)))
    if tuple(code for code, _ in glyphs) != EXPECTED_SOURCE_CODES:
        raise FontImportError("FONTBASI character order/range differs from the audited source")
    return glyphs


def import_font(dsk_path: Path) -> tuple[list[tuple[int, tuple[int, ...]]], bytes]:
    dsk = dsk_path.read_bytes()
    if sha256(dsk) != OFFICIAL_DSK_SHA256:
        raise FontImportError("font.dsk SHA-256 does not match the official audited download")
    amsdos_file = extract_cpm_file(read_extended_dsk(dsk), "FONTBASI.BAS")
    exact_file_size = 128 + (amsdos_file[64] | (amsdos_file[65] << 8))
    exact_file = amsdos_file[:exact_file_size]
    if sha256(exact_file) != FONTBASI_SHA256:
        raise FontImportError("extracted FONTBASI.BAS hash differs from the audited source")
    payload = extract_basic_payload(exact_file)
    return extract_symbol_glyphs(payload), payload


def render_asm(glyphs: list[tuple[int, tuple[int, ...]]], payload: bytes) -> str:
    all_glyphs = [(0x20, (0,) * 8), *glyphs]
    index_by_source_code = {code: index for index, (code, _) in enumerate(all_glyphs)}
    fallback = index_by_source_code[0x3F]
    ascii_map = [index_by_source_code.get(code, fallback) for code in range(ASCII_FIRST, ASCII_LAST + 1)]
    special_map = [index_by_source_code[code] for code in INTERNAL_SPECIALS]
    bitmap = b"".join(bytes(rows) for _, rows in all_glyphs)

    lines = [
        "; Generated by tools/import_manuel3d_font.py; do not edit.",
        "; Source: New Letter Font for AMSTRAD CPC by manuel3d (official font.dsk).",
        "; The itch.io page permits project use but publishes no named license.",
        f"; DSK SHA-256: {OFFICIAL_DSK_SHA256}",
        f"; FONTBASI payload SHA-256: {sha256(payload)}",
        f"; Resident bitmap SHA-256: {sha256(bitmap)}",
        "",
        "; The song occupies 0x0800-0x1270 and four runtime sprite mirrors",
        "; occupy 0x1300-0x1AFF.  This absolute 876-byte block ends at 0x1E6B.",
        ".area _BH_FONT_DATA (ABS)",
        f".org 0x{FONT_DATA_ADDRESS:04X}",
        "",
        "_bh_font_glyphs::",
    ]
    labels = {0x20: "SPACE", 0xA1: "NTILDE", 0xAB: "ntilde", 0xA3: "EURO", 0xAE: "INV_QUESTION", 0xAF: "INV_EXCLAMATION"}
    for code, rows in all_glyphs:
        if code in labels:
            label = labels[code]
        elif 0x21 <= code <= 0x7E:
            label = chr(code)
        else:
            label = f"0x{code:02X}"
        values = ", ".join(f"0x{row:02X}" for row in rows)
        lines.append(f".db {values} ; {label}")
    lines.extend(("", "_bh_font_ascii_map::"))
    for start in range(0, len(ascii_map), 16):
        chunk = ", ".join(f"{value:2d}" for value in ascii_map[start : start + 16])
        lines.append(f".db {chunk}")
    lines.extend(("", "_bh_font_special_map::"))
    lines.append(".db " + ", ".join(str(value) for value in special_map))
    lines.append("_bh_font_data_end::")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dsk", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    glyphs, payload = import_font(args.dsk)
    output = render_asm(glyphs, payload)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="ascii", newline="\n") as destination:
        destination.write(output)


if __name__ == "__main__":
    main()
