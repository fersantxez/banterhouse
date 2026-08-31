#!/usr/bin/env python3
"""Build and inspect the Banterhouse menu-logo pixel art.

The artwork is authored directly at CPC Mode 0 resolution.  No external font,
resampling or antialiasing is involved.  The selected design is emitted as a
linear Mode 0 byte stream suitable for cpct_drawSprite().
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "artifacts" / "logo-redesign"

# Palette indices from bh_palette in src/main.c, represented with canonical CPC
# preview RGB values.  The emulator renders the mid level as 127 instead of 128;
# that difference does not affect sprite data.
PALETTE = (
    (0, 0, 0),        # 0 black
    (255, 255, 255),  # 1 bright white
    (0, 128, 255),    # 2 sky blue
    (0, 255, 255),    # 3 bright cyan
    (128, 255, 255),  # 4 pastel cyan
    (128, 128, 128),  # 5 white (menu background)
    (0, 255, 0),      # 6 bright green
    (128, 255, 128),  # 7 pastel green
    (255, 255, 128),  # 8 pastel yellow
    (128, 0, 0),      # 9 red
    (255, 0, 128),    # 10 purple
    (255, 128, 255),  # 11 pastel magenta
    (255, 128, 0),    # 12 orange
    (255, 128, 128),  # 13 pink
    (255, 255, 0),    # 14 yellow
    (0, 0, 128),      # 15 blue
)

BG, BLACK, PAPER, RED, ORANGE, YELLOW, SHADOW = 5, 0, 1, 9, 12, 14, 15
W, H = 126, 34

# Hand-authored 6x10 lettering.  The deliberately uneven joins and bowls echo
# the loader masthead while keeping every glyph unambiguous in wide-pixel M0.
FONT = {
    "A": ("011110", "100001", "100001", "100001", "111111", "100001", "100001", "100001", "100001", "000000"),
    "B": ("111110", "100001", "100001", "100001", "111110", "100001", "100001", "100001", "111110", "000000"),
    "E": ("111111", "100000", "100000", "100000", "111110", "100000", "100000", "100000", "111111", "000000"),
    "H": ("100001", "100001", "100001", "100001", "111111", "100001", "100001", "100001", "100001", "000000"),
    "N": ("100001", "110001", "110001", "101001", "101001", "100101", "100101", "100011", "100001", "000000"),
    "O": ("011110", "100001", "100001", "100001", "100001", "100001", "100001", "100001", "011110", "000000"),
    "R": ("111110", "100001", "100001", "100001", "111110", "101000", "100100", "100010", "100001", "000000"),
    "S": ("011111", "100000", "100000", "100000", "011110", "000001", "000001", "000001", "111110", "000000"),
    "T": ("111111", "001000", "001000", "001000", "001000", "001000", "001000", "001000", "001000", "000000"),
    "U": ("100001", "100001", "100001", "100001", "100001", "100001", "100001", "100001", "011110", "000000"),
}


def canvas() -> list[list[int]]:
    return [[BG for _ in range(W)] for _ in range(H)]


def polygon(pixels: list[list[int]], points: list[tuple[int, int]], ink: int) -> None:
    mask = Image.new("1", (W, H))
    ImageDraw.Draw(mask).polygon(points, fill=1)
    data = mask.load()
    for y in range(H):
        for x in range(W):
            if data[x, y]:
                pixels[y][x] = ink


def line(pixels: list[list[int]], xy: tuple[int, int, int, int], ink: int) -> None:
    mask = Image.new("1", (W, H))
    ImageDraw.Draw(mask).line(xy, fill=1)
    data = mask.load()
    for y in range(H):
        for x in range(W):
            if data[x, y]:
                pixels[y][x] = ink


def ellipse(pixels: list[list[int]], box: tuple[int, int, int, int], ink: int) -> None:
    mask = Image.new("1", (W, H))
    ImageDraw.Draw(mask).ellipse(box, fill=1)
    data = mask.load()
    for y in range(H):
        for x in range(W):
            if data[x, y]:
                pixels[y][x] = ink


def draw_word(
    pixels: list[list[int]],
    x: int,
    y: int,
    offsets: tuple[int, ...] = (0,) * 11,
    tracking: int = 2,
) -> None:
    for index, char in enumerate("BANTERHOUSE"):
        glyph = FONT[char]
        gy = y + offsets[index]
        for row, bits in enumerate(glyph):
            for col, bit in enumerate(bits):
                if bit == "1":
                    pixels[gy + row][x + col] = BLACK
        x += len(glyph[0]) + tracking


def ember(pixels: list[list[int]], box: tuple[int, int, int, int], lively: bool = False) -> None:
    x0, y0, x1, y1 = box
    ellipse(pixels, box, BLACK)
    ellipse(pixels, (x0 + 2, y0 + 2, x1 - 1, y1 - 2), RED)
    ellipse(pixels, (x0 + 3, y0 + 4, x1 - 2, y1 - 4), ORANGE)
    if lively:
        pixels[y0 + 5][x0 + 4] = YELLOW
        pixels[y0 + 6][x0 + 5] = YELLOW
        pixels[y1 - 5][x0 + 3] = YELLOW
    else:
        pixels[(y0 + y1) // 2][x0 + 4] = YELLOW


def variant_a() -> list[list[int]]:
    """Closest to the loader: lively coal, uneven paper and hand-set word."""
    p = canvas()
    polygon(p, [(7, 6), (104, 5), (114, 7), (118, 6), (120, 9), (124, 10),
                (123, 13), (125, 16), (123, 19), (125, 22), (119, 22),
                (115, 26), (11, 27), (7, 23), (5, 16)], BLACK)
    polygon(p, [(10, 8), (104, 7), (113, 9), (117, 8), (118, 11), (123, 11),
                (121, 14), (124, 16), (120, 18), (122, 20), (117, 20),
                (113, 24), (12, 25), (9, 22), (8, 16)], PAPER)
    ember(p, (0, 7, 12, 26), lively=True)
    line(p, (15, 10, 17, 23), SHADOW)
    line(p, (108, 10, 113, 12), SHADOW)
    line(p, (111, 22, 116, 19), SHADOW)
    draw_word(p, 20, 11, (0, 0, -1, 0, 0, -1, 0, 0, 0, -1, 0), tracking=2)
    return p


def variant_b() -> list[list[int]]:
    """Selected direction: clean silhouette, quiet folds and precise lettering."""
    p = canvas()
    polygon(p, [(7, 8), (39, 6), (76, 7), (110, 8), (116, 9), (119, 8), (120, 11), (124, 12),
                (123, 15), (125, 17), (123, 19), (125, 22), (120, 22),
                (116, 24), (78, 26), (39, 25), (9, 25), (6, 22), (5, 16), (6, 10)], BLACK)
    polygon(p, [(10, 10), (39, 8), (76, 9), (109, 10), (114, 11), (118, 10), (118, 13), (122, 13),
                (120, 16), (123, 17), (120, 19), (121, 20), (117, 20),
                (113, 22), (78, 24), (39, 23), (10, 23), (8, 21), (7, 16), (8, 11)], PAPER)
    ember(p, (0, 9, 11, 24), lively=False)
    line(p, (14, 21, 19, 22), SHADOW)
    line(p, (96, 22, 105, 21), SHADOW)
    line(p, (109, 21, 114, 19), SHADOW)
    line(p, (112, 11, 116, 13), SHADOW)
    draw_word(p, 20, 12, tracking=2)
    return p


def variant_c() -> list[list[int]]:
    """More comic-like: jaunty outline, energetic ember and irregular baseline."""
    p = canvas()
    polygon(p, [(6, 5), (31, 7), (59, 5), (87, 7), (110, 6), (116, 9),
                (120, 7), (121, 11), (125, 13), (123, 16), (124, 20),
                (120, 21), (116, 26), (89, 25), (62, 28), (35, 25),
                (11, 27), (6, 23), (4, 15)], BLACK)
    polygon(p, [(9, 8), (31, 10), (59, 8), (86, 10), (109, 9), (114, 11),
                (118, 10), (119, 13), (123, 14), (120, 16), (123, 19),
                (118, 19), (113, 23), (89, 22), (62, 25), (35, 22),
                (12, 24), (9, 21), (7, 15)], PAPER)
    ember(p, (0, 6, 12, 26), lively=True)
    line(p, (15, 10, 18, 22), SHADOW)
    line(p, (42, 23, 49, 22), SHADOW)
    line(p, (88, 22, 95, 21), SHADOW)
    draw_word(p, 20, 11, (1, 0, -1, 1, 0, -1, 1, 0, -1, 1, 0), tracking=2)
    return p


def px2byte_m0(left: int, right: int) -> int:
    def right_pixel(value: int) -> int:
        return ((value & 1) << 6) | ((value & 2) << 1) | ((value & 4) << 2) | ((value & 8) >> 3)
    return (right_pixel(left) << 1) | right_pixel(right)


def encode(pixels: list[list[int]]) -> bytes:
    return bytes(px2byte_m0(row[x], row[x + 1]) for row in pixels for x in range(0, W, 2))


def decode(data: bytes, width_bytes: int, height: int) -> list[list[int]]:
    decoded: list[list[int]] = []
    for y in range(height):
        row: list[int] = []
        for byte in data[y * width_bytes:(y + 1) * width_bytes]:
            left = ((byte >> 7) & 1) | ((byte >> 2) & 2) | ((byte >> 3) & 4) | ((byte << 2) & 8)
            right = ((byte >> 6) & 1) | ((byte >> 1) & 2) | ((byte >> 2) & 4) | ((byte << 3) & 8)
            row.extend((left, right))
        decoded.append(row)
    return decoded


def image_from_pixels(pixels: list[list[int]], scale: int = 1) -> Image.Image:
    height, width = len(pixels), len(pixels[0])
    image = Image.new("RGB", (width, height))
    image.putdata([PALETTE[value] for row in pixels for value in row])
    if scale != 1:
        image = image.resize((width * scale, height * scale), Image.Resampling.NEAREST)
    return image


def read_source_logo() -> bytes:
    source = (ROOT / "src" / "graphics.c").read_text()
    match = re.search(r"const unsigned char g_logo\[[^]]+]\s*=\s*\{(.*?)\};", source, re.S)
    if not match:
        raise RuntimeError("g_logo initializer not found")
    return bytes(int(value, 16) for value in re.findall(r"0x([0-9A-Fa-f]{2})", match.group(1)))


def read_old_logo() -> list[list[int]]:
    values = read_source_logo()
    if len(values) == 32 * 32:
        return decode(values, 32, 32)
    preview = OUT / "logo-old-native.png"
    if not preview.exists():
        raise RuntimeError("old logo diagnostic is missing; run this tool before replacing g_logo")
    rgb_to_ink = {rgb: index for index, rgb in enumerate(PALETTE)}
    image = Image.open(preview).convert("RGB")
    return [[rgb_to_ink[image.getpixel((x, y))] for x in range(image.width)] for y in range(image.height)]


def save_preview(name: str, pixels: list[list[int]]) -> None:
    image_from_pixels(pixels).save(OUT / f"{name}-native.png")
    image_from_pixels(pixels, 4).save(OUT / f"{name}-4x.png")


def make_comparison(variants: dict[str, list[list[int]]]) -> None:
    old = read_old_logo()
    panel = Image.new("RGB", (160 * 4, 200 * 4), PALETTE[15])
    draw = ImageDraw.Draw(panel)
    labels = ("OLD 64x32", "A LOADER", "B ELEGANT", "C COMIC")
    previews = (old, variants["variant-a"], variants["variant-b"], variants["variant-c"])
    ys = (16, 55, 94, 133)
    for label, pixels, y in zip(labels, previews, ys):
        x = (160 - len(pixels[0])) // 2
        native = Image.new("RGB", (160, 34), PALETTE[BG])
        native.paste(image_from_pixels(pixels), (x, 1))
        panel.paste(native.resize((640, 136), Image.Resampling.NEAREST), (0, y * 4))
        draw.text((8, (y - 10) * 4), label, fill=PALETTE[1])
    panel.save(OUT / "variants-at-cpc-size-4x.png")


def make_final_comparison(selected: list[list[int]]) -> None:
    """Place the canonical loader, previous logo and final bytes side by side."""
    loader = Image.open(
        ROOT / "assets" / "concepts" / "loading" / "banterhouse-loading-cpc-mode0-v1.png"
    ).convert("RGB").crop((0, 0, 160, 34))
    old = read_old_logo()
    old_panel = Image.new("RGB", (160, 34), PALETTE[BG])
    old_panel.paste(image_from_pixels(old), ((160 - len(old[0])) // 2, 1))
    new_panel = Image.new("RGB", (160, 34), PALETTE[BG])
    new_panel.paste(image_from_pixels(selected), ((160 - len(selected[0])) // 2, 0))

    scale = 4
    footer = 28
    comparison = Image.new("RGB", (160 * scale * 3, 34 * scale + footer), (0, 0, 0))
    for index, preview in enumerate((loader, old_panel, new_panel)):
        comparison.paste(
            preview.resize((160 * scale, 34 * scale), Image.Resampling.NEAREST),
            (index * 160 * scale, 0),
        )
    draw = ImageDraw.Draw(comparison)
    for index, label in enumerate(("LOADER / REFERENCIA", "MENU ANTERIOR", "MENU FINAL / B")):
        draw.text((index * 160 * scale + 8, 34 * scale + 7), label, fill=PALETTE[PAPER])
    comparison.save(OUT / "final-loader-old-new.png")


def format_c(data: bytes) -> str:
    lines = []
    width = W // 2
    for start in range(0, len(data), width):
        row = data[start:start + width]
        suffix = "," if start + width < len(data) else ""
        lines.append("   " + ", ".join(f"0x{value:02X}" for value in row) + suffix)
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--emit-c", action="store_true", help="print selected Mode 0 initializer")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    variants = {"variant-a": variant_a(), "variant-b": variant_b(), "variant-c": variant_c()}
    save_preview("logo-old", read_old_logo())
    for name, pixels in variants.items():
        save_preview(name, pixels)
    make_comparison(variants)
    make_final_comparison(variants["variant-b"])
    selected = encode(variants["variant-b"])
    (OUT / "g_logo.bin").write_bytes(selected)
    if decode(selected, W // 2, H) != variants["variant-b"]:
        raise RuntimeError("Mode 0 encode/decode round-trip failed")
    source_logo = read_source_logo()
    if len(source_logo) == len(selected) and source_logo != selected:
        raise RuntimeError("selected design and src/graphics.c g_logo differ")
    if args.emit_c:
        print(format_c(selected))
    else:
        inks = sorted({value for row in variants["variant-b"] for value in row})
        print(f"selected variant B: {W}x{H} px, {W // 2}x{H} bytes, {len(selected)} bytes, inks {inks}")


if __name__ == "__main__":
    main()
