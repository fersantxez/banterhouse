#!/usr/bin/env python3
"""Structural regression checks for the Banterhouse Arkos 1.0 sources."""

from __future__ import annotations

import gzip
import sys
from pathlib import Path
import xml.etree.ElementTree as ET


EMPTY_NOTE = 145
CUT_NOTE = 144
THEME_INSTRUMENTS = [
    "Empty", "Elastic MIDI Bass", "Electric Neon Lead", "Clean Guitar Pluck",
    "Electro Kick", "Paper Snare", "Neon Hat",
]
SFX_INSTRUMENTS = [
    "Empty", "Idea Pickup", "Screen Swipe", "Briefing Shot", "Alberto Alert",
    "Contact Crunch", "Office Action", "Client Victory", "Campaign Defeat",
]


def value(root: ET.Element, name: str) -> str:
    element = root.find(name)
    if element is None or element.text is None:
        raise AssertionError(f"missing Arkos field {name}")
    return element.text


def load(path: Path) -> ET.Element:
    with gzip.open(path, "rb") as stream:
        root = ET.parse(stream).getroot()
    assert value(root, "Version") == "ArkosTrackerSong 1.0a"
    assert value(root, "Frequency") == "freq50hz"
    assert int(value(root, "MasterFrequency")) == 1_000_000
    return root


def instrument_names(root: ET.Element) -> list[str]:
    return [value(instrument, "Name") for instrument in (root.find("InstrumentsList") or [])]


def check_theme(path: Path) -> None:
    root = load(path)
    assert int(value(root, "BeginningSpeed")) == 6
    assert (int(value(root, "Length")), int(value(root, "LoopStart")),
            int(value(root, "LoopEnd"))) == (14, 2, 13)
    patterns = list(root.find("PatternsList") or ())
    tracks = list(root.find("TrackArray") or ())
    assert len(patterns) == 14
    assert all(int(value(pattern, "Height")) == 32 for pattern in patterns)
    assert instrument_names(root) == THEME_INSTRUMENTS

    used = [set(), set(), set()]
    for pattern in patterns:
        for channel in range(3):
            number = int(value(pattern, f"Track{channel + 1}Number"))
            cells = list(tracks[number].find("track") or ())[:32]
            notes = [int(value(cell, "Note")) for cell in cells]
            used[channel].update(int(value(cell, "Instrument"))
                                 for cell, note in zip(cells, notes) if note < CUT_NOTE)
            if channel == 2:
                assert notes.count(EMPTY_NOTE) >= 6, "channel C needs SFX recovery gaps"
    assert 2 in used[0]
    assert used[1] == {1}
    assert {3, 4, 5, 6}.issubset(used[2])

    last = patterns[-1]
    for channel in range(3):
        number = int(value(last, f"Track{channel + 1}Number"))
        cells = list(tracks[number].find("track") or ())
        assert int(value(cells[31], "Note")) == CUT_NOTE
    bpm = 50 * 60 / (6 * 4)
    first_pass = 14 * 32 * 6 / 50
    loop = 12 * 32 * 6 / 50
    assert 118 <= bpm <= 126 and 45 <= first_pass <= 70 and 45 <= loop <= 70
    print(f"Theme AKS: PASS ({bpm:.0f} BPM, {first_pass:.2f}s, loop {loop:.2f}s)")


def check_sfx(path: Path) -> None:
    root = load(path)
    assert instrument_names(root) == SFX_INSTRUMENTS
    assert int(value(root, "Length")) == 1
    assert len(list(root.find("PatternsList") or ())) == 1
    for instrument in list(root.find("InstrumentsList") or ())[1:]:
        items = list(instrument.find("InstrumentItems") or ())
        assert any(value(item, "IsSound") == "true" or int(value(item, "Noise"))
                   for item in items[:16]), f"empty SFX instrument {value(instrument, 'Name')}"
    print(f"SFX AKS: PASS ({len(SFX_INSTRUMENTS) - 1} effects)")


def main() -> None:
    theme = Path(sys.argv[1] if len(sys.argv) > 1 else "music/banterhouse-theme.aks")
    sfx = Path(sys.argv[2] if len(sys.argv) > 2 else "music/banterhouse-sfx.aks")
    check_theme(theme)
    check_sfx(sfx)


if __name__ == "__main__":
    main()
