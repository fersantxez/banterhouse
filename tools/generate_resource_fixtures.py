#!/usr/bin/env python3
"""Generate deterministic CPC Mode 0 screens for the disk-resource lab."""

from __future__ import annotations

import argparse
from pathlib import Path


WIDTH = 160
HEIGHT = 200
SCREEN_BYTES = 0x4000
PALETTE = (
    (0, 0, 0), (255, 255, 255), (0, 128, 255), (0, 255, 255),
    (128, 255, 255), (128, 128, 128), (0, 255, 0), (128, 255, 128),
    (255, 255, 128), (128, 0, 0), (255, 0, 128), (255, 128, 255),
    (255, 128, 0), (255, 128, 128), (255, 255, 0), (0, 0, 128),
)


def mode0_right(colour: int) -> int:
    return (
        ((colour & 0x01) << 6)
        | ((colour & 0x02) << 1)
        | ((colour & 0x04) << 2)
        | ((colour & 0x08) >> 3)
    )


def mode0_byte(left: int, right: int) -> int:
    return (mode0_right(left) << 1) | mode0_right(right)


def canvas(colour: int) -> list[list[int]]:
    return [[colour for _ in range(WIDTH)] for _ in range(HEIGHT)]


def rect(pixels: list[list[int]], x: int, y: int, w: int, h: int, colour: int) -> None:
    for py in range(max(0, y), min(HEIGHT, y + h)):
        pixels[py][max(0, x):min(WIDTH, x + w)] = [colour] * max(0, min(WIDTH, x + w) - max(0, x))


def frame(pixels: list[list[int]], x: int, y: int, w: int, h: int, colour: int) -> None:
    rect(pixels, x, y, w, 2, colour)
    rect(pixels, x, y + h - 2, w, 2, colour)
    rect(pixels, x, y, 2, h, colour)
    rect(pixels, x + w - 2, y, 2, h, colour)


def ellipse(pixels: list[list[int]], cx: int, cy: int, rx: int, ry: int, colour: int) -> None:
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if ((x - cx) * (x - cx) * ry * ry + (y - cy) * (y - cy) * rx * rx <= rx * rx * ry * ry):
                rect(pixels, x, y, 1, 1, colour)


def line(pixels: list[list[int]], x0: int, y0: int, x1: int, y1: int, colour: int, width: int = 1) -> None:
    dx = abs(x1 - x0)
    sx = 1 if x0 < x1 else -1
    dy = -abs(y1 - y0)
    sy = 1 if y0 < y1 else -1
    error = dx + dy
    while True:
        rect(pixels, x0, y0, width, width, colour)
        if x0 == x1 and y0 == y1:
            break
        twice = 2 * error
        if twice >= dy:
            error += dy
            x0 += sx
        if twice <= dx:
            error += dx
            y0 += sy


def speech(pixels: list[list[int]], x: int, y: int, w: int, h: int, accent: int) -> None:
    ellipse(pixels, x + w // 2, y + h // 2, w // 2, h // 2, 0)
    ellipse(pixels, x + w // 2, y + h // 2, w // 2 - 2, h // 2 - 2, 1)
    line(pixels, x + 7, y + h - 3, x + 3, y + h + 6, 0, 2)
    line(pixels, x + 9, y + h - 3, x + 5, y + h + 4, 1, 1)
    rect(pixels, x + 10, y + h // 2 - 1, w - 20, 2, accent)


def cartoon_person(pixels: list[list[int]], x: int, y: int, shirt: int, pose: int = 0) -> None:
    ellipse(pixels, x + 12, y + 12, 10, 11, 0)
    ellipse(pixels, x + 12, y + 12, 8, 9, 13)
    ellipse(pixels, x + 18, y + 13, 6, 4, 13)
    rect(pixels, x + 8, y + 8, 3, 4, 1)
    rect(pixels, x + 15, y + 8, 3, 4, 1)
    rect(pixels, x + 9, y + 9, 1, 2, 0)
    rect(pixels, x + 16, y + 9, 1, 2, 0)
    line(pixels, x + 10, y + 18, x + 17, y + 18, 0, 1)
    rect(pixels, x + 5, y + 23, 17, 21, shirt)
    rect(pixels, x + 10, y + 23, 4, 12, 1)
    if pose:
        line(pixels, x + 6, y + 26, x - 2, y + 13, shirt, 3)
        line(pixels, x + 21, y + 26, x + 29, y + 10, shirt, 3)
    else:
        line(pixels, x + 6, y + 26, x, y + 37, shirt, 3)
        line(pixels, x + 21, y + 26, x + 27, y + 37, shirt, 3)
    line(pixels, x + 9, y + 43, x + 5, y + 55, 0, 3)
    line(pixels, x + 18, y + 43, x + 23, y + 55, 0, 3)


def hatch(pixels: list[list[int]], x: int, y: int, w: int, h: int, colour: int) -> None:
    for offset in range(-h, w, 7):
        line(pixels, x + max(0, offset), y + max(0, -offset),
             x + min(w - 1, offset + h), y + min(h - 1, h + offset), colour)


def paper_screen() -> list[list[int]]:
    pixels = canvas(1)
    frame(pixels, 4, 4, 152, 192, 0)
    rect(pixels, 4, 4, 152, 16, 0)
    rect(pixels, 14, 9, 55, 5, 1)
    rect(pixels, 75, 9, 18, 5, 3)
    rect(pixels, 98, 9, 44, 5, 14)
    frame(pixels, 10, 26, 66, 67, 0)
    frame(pixels, 84, 26, 66, 67, 0)
    frame(pixels, 10, 101, 140, 84, 0)
    hatch(pixels, 12, 28, 62, 63, 5)
    cartoon_person(pixels, 24, 35, 6, 0)
    rect(pixels, 13, 79, 58, 11, 9)
    speech(pixels, 91, 31, 49, 23, 3)
    cartoon_person(pixels, 101, 49, 10, 1)
    rect(pixels, 88, 82, 58, 8, 14)
    rect(pixels, 13, 104, 134, 78, 5)
    hatch(pixels, 13, 104, 134, 78, 1)
    cartoon_person(pixels, 31, 116, 6, 1)
    cartoon_person(pixels, 91, 116, 9, 0)
    rect(pixels, 57, 150, 45, 20, 1)
    frame(pixels, 57, 150, 45, 20, 0)
    rect(pixels, 62, 155, 12, 5, 10)
    rect(pixels, 78, 155, 18, 5, 14)
    line(pixels, 18, 177, 139, 177, 0, 2)
    return pixels


def ink_screen() -> list[list[int]]:
    pixels = canvas(0)
    rect(pixels, 6, 6, 148, 188, 1)
    frame(pixels, 6, 6, 148, 188, 0)
    rect(pixels, 6, 6, 148, 17, 10)
    rect(pixels, 16, 12, 40, 5, 1)
    rect(pixels, 62, 12, 31, 5, 0)
    rect(pixels, 99, 12, 43, 5, 14)
    frame(pixels, 13, 29, 134, 61, 0)
    rect(pixels, 15, 31, 130, 57, 5)
    hatch(pixels, 15, 31, 130, 57, 1)
    rect(pixels, 21, 52, 44, 30, 0)
    frame(pixels, 24, 55, 38, 24, 1)
    rect(pixels, 30, 61, 25, 4, 3)
    rect(pixels, 30, 69, 18, 4, 14)
    cartoon_person(pixels, 102, 34, 10, 0)
    speech(pixels, 67, 34, 35, 19, 14)
    frame(pixels, 13, 98, 62, 83, 0)
    frame(pixels, 85, 98, 62, 83, 0)
    ellipse(pixels, 44, 126, 22, 22, 0)
    ellipse(pixels, 44, 126, 18, 18, 1)
    line(pixels, 44, 126, 44, 111, 10, 2)
    line(pixels, 44, 126, 56, 132, 10, 2)
    rect(pixels, 20, 153, 48, 19, 5)
    frame(pixels, 20, 153, 48, 19, 0)
    cartoon_person(pixels, 96, 110, 6, 1)
    line(pixels, 91, 164, 139, 113, 10, 4)
    line(pixels, 91, 164, 95, 174, 0, 2)
    rect(pixels, 89, 176, 52, 3, 14)
    return pixels


def encode_screen(pixels: list[list[int]]) -> bytes:
    output = bytearray(SCREEN_BYTES)
    for y, row in enumerate(pixels):
        base = ((y & 7) << 11) + ((y >> 3) * 80)
        for x in range(0, WIDTH, 2):
            output[base + (x >> 1)] = mode0_byte(row[x], row[x + 1])
    return bytes(output)


def write_ppm(path: Path, pixels: list[list[int]]) -> None:
    with path.open("wb") as handle:
        handle.write(f"P6\n{WIDTH} {HEIGHT}\n255\n".encode("ascii"))
        for row in pixels:
            for colour in row:
                handle.write(bytes(PALETTE[colour]))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)

    for name, pixels in (("lab-paper", paper_screen()), ("lab-ink", ink_screen())):
        (args.output_dir / f"{name}.scr").write_bytes(encode_screen(pixels))
        write_ppm(args.output_dir / f"{name}.ppm", pixels)

    print(f"Resource lab screens: 2 x {SCREEN_BYTES} bytes")


if __name__ == "__main__":
    main()
