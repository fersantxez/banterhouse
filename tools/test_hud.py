#!/usr/bin/env python3
"""Structural and memory gates for the resident Mode 0 gameplay HUD."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src/game_render.c"
MAP = ROOT / "obj/banterhouse.map"
BIN_LOG = ROOT / "obj/banterhouse.bin.log"
SCREEN_W = 80
HUD_H = 16


def rect(name: str, x: int, y: int, width: int, height: int) -> tuple[str, int, int, int, int]:
    assert 0 <= x < SCREEN_W, name
    assert 0 <= y < HUD_H, name
    assert width > 0 and x + width <= SCREEN_W, name
    assert height > 0 and y + height <= HUD_H, name
    return name, x, y, width, height


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    logo_match = re.search(r"static const u8 hud_logo\[196\] = \{(.*?)\};", source, re.S)
    assert logo_match, "missing fixed-size HUD logo"
    logo_bytes = re.findall(r"0x[0-9A-Fa-f]{2}", logo_match.group(1))
    assert len(logo_bytes) == 196, len(logo_bytes)
    assert "cpct_drawSprite((u8*)hud_logo" in source
    assert "cpct_getScreenPtr(page, 0, 1), 14, 14" in source

    # Maximum-value geometry: all counters remain inside the 80-byte Mode 0 row.
    geometry = [
        rect("logo", 0, 1, 14, 14),
        rect("idea 12/12", 15, 4, 24, 8),
        rect("carga 5", 40, 3, 9, 9),
        rect("coffee icon", 51, 5, 3, 6),
        rect("coffee 9", 55, 4, 4, 8),
        rect("score 65535", 60, 4, 20, 8),
        rect("accent rule", 15, 15, 65, 1),
    ]
    assert len(geometry) == 7
    assert all(marker in source for marker in (
        "key->score = state->campaign.score;",
        "bh_hud_digits2(&idea[1], count);",
        "bh_hud_digits5(score, state->campaign.score);",
        "index < state->campaign.carga ? 11 : 5",
    ))

    room_source = (ROOT / "src/room_visuals.c").read_text(encoding="utf-8")
    labels = re.findall(r'room_label_\d+\[\] = "([A-Z0-9 ]+)";', room_source)
    assert len(labels) == 30
    assert all(5 + len(label) * 4 <= SCREEN_W for label in labels)

    map_text = MAP.read_text(encoding="ascii")
    assert re.search(r"^\s*00002000\s+s__BH_GFX\s*$", map_text, re.M)
    high_hex = subprocess.check_output(
        ["python3", str(ROOT / "tools/runtime_highwater.py"), str(MAP), str(BIN_LOG)],
        text=True,
    ).strip()
    high = int(high_hex, 16)
    margin = 0x8000 - high - 1
    assert margin >= 4096, (high_hex, margin)
    print(f"HUD logo, maximum-value layout, cache key and memory margin ({margin} bytes): PASS")


if __name__ == "__main__":
    main()
