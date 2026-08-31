#!/usr/bin/env python3
"""Host-side invariants for the resident manuel3d font and Mode 0 renderer."""

from __future__ import annotations

import hashlib
import re
from pathlib import Path

from import_manuel3d_font import (
    ASCII_FIRST,
    ASCII_LAST,
    INTERNAL_SPECIALS,
    import_font,
    render_asm,
)


ROOT = Path(__file__).resolve().parents[1]
DSK = ROOT / "assets/fonts/manuel3d/font.dsk"
GENERATED = ROOT / "src/font_data.s"
RENDERER = ROOT / "src/font_renderer.s"
EXPECTED_BITMAP_SHA256 = "6a7696a5682dd5e131dff039cb311493ae5d78ad94e7e6c2e51f4566701db491"
GLYPH_COUNT = 97
GLYPH_HEIGHT = 8
GLYPH_WIDTH_BYTES = 4


def mode0_right(colour: int) -> int:
    return (
        ((colour & 0x01) << 6)
        | ((colour & 0x02) << 1)
        | ((colour & 0x04) << 2)
        | ((colour & 0x08) >> 3)
    )


def mode0_byte(left: int, right: int) -> int:
    return (mode0_right(left) << 1) | mode0_right(right)


def nibble_table(ink: int, paper: int) -> list[tuple[int, int]]:
    pairs = []
    for nibble in range(16):
        pixels = [ink if nibble & mask else paper for mask in (8, 4, 2, 1)]
        pairs.append((mode0_byte(*pixels[:2]), mode0_byte(*pixels[2:])))
    return pairs


def screen_pointer(base: int, x: int, y: int) -> int:
    return base + ((y & 7) << 11) + (y >> 3) * 80 + x


def next_renderer_row(address: int) -> int:
    address = (address + 0x0800) & 0xFFFF
    if not address & 0x3800:
        address = (address + 0xC050) & 0xFFFF
    return address


def assert_rect(base: int, x: int, y: int, text: str) -> None:
    width = len(text) * GLYPH_WIDTH_BYTES
    assert 0 <= x <= 80 and x + width <= 80, (x, text, width)
    assert 0 <= y and y + GLYPH_HEIGHT <= 200, (y, text)
    for character in range(len(text)):
        for row in range(GLYPH_HEIGHT):
            address = screen_pointer(base, x + character * 4, y + row)
            assert base <= address and address + 3 < base + 0x4000


def assert_renderer_vram_walk() -> None:
    """The Z80 row step must visit exactly the CPC's eight interlaced rows."""
    for base in (0x8000, 0xC000):
        for x in range(77):
            for y in range(193):
                address = screen_pointer(base, x, y)
                writes: set[int] = set()
                for row in range(GLYPH_HEIGHT):
                    assert address == screen_pointer(base, x, y + row)
                    writes.update(range(address, address + GLYPH_WIDTH_BYTES))
                    address = next_renderer_row(address)
                assert len(writes) == GLYPH_HEIGHT * GLYPH_WIDTH_BYTES
                assert min(writes) >= base and max(writes) < base + 0x4000


def assert_renderer_colour_constants() -> None:
    renderer = RENDERER.read_text(encoding="ascii")
    table_source = renderer.split("mode0_right_pixel:", 1)[1].split(";;", 1)[0]
    values = [int(value, 16) for value in re.findall(r"#0x([0-9A-Fa-f]{2})", table_source)]
    assert values == [mode0_right(colour) for colour in range(16)]


def c_string_inventory(glyph_codes: set[int]) -> None:
    allowed = {0x20, *[code for code in glyph_codes if code <= 0x7E]}
    string_re = re.compile(r'"((?:\\.|[^"\\])*)"')
    for source_path in sorted((ROOT / "src").glob("*.c")):
        source = source_path.read_text(encoding="utf-8")
        for match in string_re.finditer(source):
            literal = bytes(match.group(1), "utf-8").decode("unicode_escape")
            unsupported = sorted({ord(character) for character in literal if ord(character) not in allowed})
            assert not unsupported, f"{source_path.name}: unsupported bytes {unsupported} in {literal!r}"


def main() -> None:
    glyphs, payload = import_font(DSK)
    assert len(glyphs) == 96
    assert len({code for code, _ in glyphs}) == 96
    assert all(len(rows) == GLYPH_HEIGHT for _, rows in glyphs)
    assert all(0 <= row <= 0xFF for _, rows in glyphs for row in rows)

    all_glyphs = [(0x20, (0,) * 8), *glyphs]
    bitmap = b"".join(bytes(rows) for _, rows in all_glyphs)
    assert len(bitmap) == GLYPH_COUNT * GLYPH_HEIGHT == 776
    assert hashlib.sha256(bitmap).hexdigest() == EXPECTED_BITMAP_SHA256

    index_by_code = {code: index for index, (code, _) in enumerate(all_glyphs)}
    fallback = index_by_code[ord("?")]
    ascii_map = [index_by_code.get(code, fallback) for code in range(ASCII_FIRST, ASCII_LAST + 1)]
    special_map = [index_by_code[code] for code in INTERNAL_SPECIALS]
    assert len(ascii_map) == 95 and len(special_map) == 5
    assert all(0 <= index < GLYPH_COUNT for index in (*ascii_map, *special_map))
    assert ascii_map[ord("{") - ASCII_FIRST] == fallback
    assert ascii_map[ord("}") - ASCII_FIRST] == fallback
    assert ascii_map[ord("~") - ASCII_FIRST] == fallback
    assert special_map == [index_by_code[code] for code in (0xA1, 0xA3, 0xAE, 0xAF, 0xAB)]
    assert fallback == ascii_map[ord("?") - ASCII_FIRST]

    def glyph_index(character: int) -> int:
        if ASCII_FIRST <= character <= ASCII_LAST:
            return ascii_map[character - ASCII_FIRST]
        if 0x80 <= character < 0x80 + len(special_map):
            return special_map[character - 0x80]
        return fallback

    assert glyph_index(0x00) == fallback
    assert glyph_index(0x7F) == fallback
    assert glyph_index(0x85) == fallback
    assert glyph_index(0xFF) == fallback
    assert all(0 <= glyph_index(character) < GLYPH_COUNT for character in range(256))

    generated = render_asm(glyphs, payload)
    assert generated == render_asm(glyphs, payload)
    assert generated == GENERATED.read_text(encoding="ascii")
    assert hashlib.sha256(generated.encode("ascii")).hexdigest() == hashlib.sha256(
        GENERATED.read_bytes()
    ).hexdigest()

    for ink in range(16):
        for paper in range(16):
            table = nibble_table(ink, paper)
            assert len(table) == 16
            for nibble, pair in enumerate(table):
                pixels = [ink if nibble & mask else paper for mask in (8, 4, 2, 1)]
                assert pair == (mode0_byte(pixels[0], pixels[1]), mode0_byte(pixels[2], pixels[3]))
    assert_renderer_colour_constants()
    assert_renderer_vram_walk()

    placements = [
        (4, 86, "EL PITCH IMPOSIBLE"), (8, 118, "O/P: DIFICULTAD"),
        (2, 142, "S O FUEGO: EMPEZAR"), (18, 128, "MUY DIFICIL"),
        (15, 4, "*12/12"), (55, 4, "9"), (60, 4, "65535"),
        (5, 22, "UNA PALABRA MENOS"), (4, 56, "APROBADO [ ][ ][ ]"),
        (54, 93, "PANEL"), (45, 95, "PEQUENO"),
        (8, 104, "ENTREGA ORIGINAL"), (4, 184, "BURNOUT: REINTENTO"),
        (22, 160, "PAUSA ESC"),
        (0, 4, "ABCDEFGHIJKLM"), (0, 14, "NOPQRSTUVWXYZ"),
        (0, 98, "EL PITCH IMPOSIBLE"), (0, 110, "CARGANDO..."),
        (0, 122, "IDEAS 00/12"), (0, 134, "NIVEL 10"),
    ]
    for base in (0x8000, 0xC000):
        for x, y, text in placements:
            assert_rect(base, x, y, text)
        for text in ("APROBADO", "PITU SALVA LA IDEA", "BURNOUT", "ALBERTO GANA", "ESTA RONDA", "PULSA S"):
            width = len(text) * GLYPH_WIDTH_BYTES
            assert_rect(base, (80 - width) // 2, 124, text)

    c_string_inventory({code for code, _ in glyphs})
    print("Font import, glyphs, Mode 0 table, inventory and VRAM bounds: PASS")


if __name__ == "__main__":
    main()
