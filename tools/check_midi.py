#!/usr/bin/env python3
"""Validate the frozen MIDI input and the CPC arrangement contract."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from midi_smf import read_midi


def main() -> None:
    arrangement_path = Path("music/banterhouse-theme-arrangement.json")
    config = json.loads(arrangement_path.read_text())
    midi_path = arrangement_path.parent / config["source"]
    digest = hashlib.sha256(midi_path.read_bytes()).hexdigest()
    assert digest == config["source_sha256"]
    song = read_midi(midi_path)
    assert (song.format, song.tracks, song.division) == (0, 1, 240)
    assert song.tempos == [(0, 1_000_000)]
    assert song.time_signatures[0] == (0, 4, 4)
    assert len(song.notes) == 5143
    assert config["source_bars"] == 28
    assert config["target_bpm"] == 125
    text = " ".join(item[2] for item in song.text if item[1] in (1, 2, 3, 4))
    assert config["embedded_title"] in text and config["embedded_artist"] in text
    print("MIDI source: PASS (SMF0, 4/4, 60 BPM source, 28-bar AY arrangement)")


if __name__ == "__main__":
    main()
