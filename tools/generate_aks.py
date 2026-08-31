#!/usr/bin/env python3
"""Build editable Arkos Tracker 1.0 theme and SFX sources for Banterhouse."""

from __future__ import annotations

import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

from midi_smf import MidiNote, read_midi


EMPTY_NOTE = 145
CUT_NOTE = 144
ROWS = 32
TRACK_SLOTS = 512
SPECIAL_TRACK_SLOTS = 256


def set_text(parent: ET.Element, tag: str, value: object) -> None:
    child = parent.find(tag)
    if child is None:
        raise ValueError(f"Arkos template has no {tag!r} field")
    child.text = str(value).lower() if isinstance(value, bool) else str(value)


def blank_cell(cell: ET.Element) -> None:
    set_text(cell, "Note", EMPTY_NOTE)
    set_text(cell, "Instrument", 1)
    set_text(cell, "Volume", 255)
    set_text(cell, "Pitch", 0)


def make_track(template: ET.Element, name: str,
               events: dict[int, tuple[int, int]]) -> ET.Element:
    track = copy.deepcopy(template)
    set_text(track, "TrackName", name)
    cells = track.find("track")
    if cells is None or len(cells) != 128:
        raise ValueError("Arkos template does not contain a 128-cell track")
    for cell in cells:
        blank_cell(cell)
    for row, (note, instrument) in events.items():
        if not 0 <= row < ROWS:
            raise ValueError(f"row {row} is outside a two-bar pattern")
        set_text(cells[row], "Note", note)
        set_text(cells[row], "Instrument", instrument)
    return track


def blank_special_track(template: ET.Element) -> ET.Element:
    special = copy.deepcopy(template)
    cells = special.find("SpecialCells")
    if cells is None:
        raise ValueError("Arkos template has no special-track cells")
    for cell in cells:
        set_text(cell, "Effect", 0)
        set_text(cell, "Value", 1)
    return special


def make_pattern(track_base: int) -> ET.Element:
    pattern = ET.Element("Pattern")
    for channel, offset in ((1, 0), (2, 1), (3, 2)):
        ET.SubElement(pattern, f"Track{channel}Number").text = str(track_base + offset)
    for channel in (1, 2, 3):
        ET.SubElement(pattern, f"Transposition{channel}").text = "0"
    ET.SubElement(pattern, "Height").text = str(ROWS)
    ET.SubElement(pattern, "SpecialTrackNumber").text = "0"
    return pattern


def silent_item(item: ET.Element) -> None:
    defaults = {
        "LinkValue": 0, "IsSound": False, "Volume": 0, "Noise": 0,
        "Pitch": 0, "IsHard": False, "HardwareEnvelope": 0, "Shift": 0,
        "SoundFrequency": 0, "SoundArpeggio": 0, "SoundPitch": 0,
        "HardwareFrequency": 0, "HardwareArpeggio": 0,
        "HardwarePitch": 0, "IsRetrig": False,
    }
    for field, value in defaults.items():
        set_text(item, field, value)


def make_instrument(template: ET.Element, name: str, speed: int,
                    steps: list[dict[str, object]],
                    loop: tuple[int, int] | None = None,
                    retrig: bool = False) -> ET.Element:
    instrument = copy.deepcopy(template)
    set_text(instrument, "Name", name)
    set_text(instrument, "Speed", speed)
    set_text(instrument, "Loop", loop is not None)
    set_text(instrument, "LoopStart", 0 if loop is None else loop[0])
    set_text(instrument, "LoopEnd", len(steps) - 1 if loop is None else loop[1])
    set_text(instrument, "Retrig", retrig)
    items = instrument.find("InstrumentItems")
    if items is None or len(items) != 256:
        raise ValueError("Arkos template does not contain 256 instrument items")
    for item in items:
        silent_item(item)
    for index, fields in enumerate(steps):
        for field, value in fields.items():
            set_text(items[index], field, value)
    return instrument


def tone(volume: int, *, pitch: int = 0, arp: int = 0,
         noise_period: int = 0) -> dict[str, object]:
    return {"IsSound": True, "Volume": volume, "Pitch": pitch,
            "SoundArpeggio": arp, "Noise": noise_period}


def noise(volume: int, period: int) -> dict[str, object]:
    return {"IsSound": False, "Volume": volume, "Noise": period}


def theme_instruments(template: ET.Element) -> list[ET.Element]:
    return [
        make_instrument(template, "Empty", 255, [{}] * 4, (0, 3)),
        make_instrument(template, "Elastic MIDI Bass", 0, [
            tone(15, arp=12), tone(14, arp=7, pitch=2), tone(12, pitch=6),
            tone(9, pitch=12), tone(6, pitch=20), tone(2, pitch=28), tone(0),
        ]),
        make_instrument(template, "Electric Neon Lead", 2, [
            tone(14), tone(15, pitch=1), tone(14), tone(13, pitch=-1),
            tone(14), tone(15, pitch=1), tone(14), tone(13, pitch=-1),
        ], (0, 7)),
        make_instrument(template, "Clean Guitar Pluck", 0, [
            tone(12), tone(10, arp=7), tone(8, arp=12),
            tone(5, arp=7), tone(2), tone(0),
        ]),
        make_instrument(template, "Electro Kick", 0, [
            tone(15, arp=12, noise_period=2), tone(14, arp=5, pitch=8),
            tone(11, pitch=22), tone(7, pitch=42), tone(3, pitch=70), tone(0),
        ]),
        make_instrument(template, "Paper Snare", 0, [
            noise(15, 13), noise(12, 11), noise(9, 8),
            noise(5, 6), noise(2, 4), noise(0, 0),
        ]),
        make_instrument(template, "Neon Hat", 0, [
            noise(9, 3), noise(4, 2), noise(1, 1), noise(0, 0),
        ]),
    ]


def sfx_instruments(template: ET.Element) -> list[ET.Element]:
    return [
        make_instrument(template, "Empty", 255, [{}] * 4, (0, 3)),
        make_instrument(template, "Idea Pickup", 0, [
            tone(13), tone(14, arp=4), tone(15, arp=9), tone(13, arp=16),
            tone(9, arp=21), tone(4, arp=24), tone(0),
        ], retrig=True),
        make_instrument(template, "Screen Swipe", 0, [
            noise(9, 4), tone(11, arp=7, pitch=-8), tone(9, arp=12),
            tone(5, arp=7, pitch=12), tone(0),
        ], retrig=True),
        make_instrument(template, "Briefing Shot", 0, [
            noise(15, 15), noise(13, 11), tone(12, arp=-5, pitch=-20),
            tone(9, pitch=8), noise(6, 5), noise(2, 2), noise(0, 0),
        ], retrig=True),
        make_instrument(template, "Alberto Alert", 1, [
            tone(15), tone(15, arp=7), tone(14, arp=12), tone(13, arp=7),
            tone(15, pitch=6), tone(15, arp=7, pitch=6),
            tone(13, arp=12, pitch=6), tone(9, arp=7, pitch=6), tone(0),
        ], retrig=True),
        make_instrument(template, "Contact Crunch", 0, [
            noise(15, 20), tone(15, arp=-12, pitch=-32), noise(12, 15),
            tone(10, arp=-7, pitch=24), noise(6, 8), tone(3, pitch=60), tone(0),
        ], retrig=True),
        make_instrument(template, "Office Action", 0, [
            tone(12), tone(14, arp=3), tone(10, arp=7), tone(5, arp=12), tone(0),
        ], retrig=True),
        make_instrument(template, "Client Victory", 1, [
            tone(15), tone(14, arp=4), tone(15, arp=7), tone(14, arp=12),
            tone(15, arp=16), tone(14, arp=19), tone(15, arp=24),
            tone(10, arp=19), tone(6, arp=24), tone(0),
        ], retrig=True),
        make_instrument(template, "Campaign Defeat", 1, [
            tone(14, arp=12), tone(13, arp=7), tone(12), tone(10, arp=-5),
            tone(8, arp=-12), noise(5, 10), noise(2, 5), tone(0),
        ], retrig=True),
    ]


def _normalise_lead(note: int) -> int:
    while note > 83:
        note -= 12
    while note < 48:
        note += 12
    return note


def _select_rows(notes: list[MidiNote], channels: list[int], start_tick: int,
                 end_tick: int, grid: int, highest: bool) -> dict[int, tuple[int, int]]:
    grouped: dict[int, dict[int, list[MidiNote]]] = {}
    for item in notes:
        if item.channel not in channels or not start_tick <= item.start < end_tick:
            continue
        row = int(round((item.start - start_tick) / grid))
        if 0 <= row < 14 * ROWS:
            grouped.setdefault(row, {}).setdefault(item.channel, []).append(item)
    selected: dict[int, tuple[int, int]] = {}
    for row, by_channel in grouped.items():
        channel = next((candidate for candidate in channels if candidate in by_channel), None)
        if channel is None:
            continue
        choice = (max if highest else min)(by_channel[channel], key=lambda item: item.note)
        end_row = max(row + 1, int(round((choice.end - start_tick) / grid)))
        selected[row] = (choice.note, end_row)
    return selected


def _with_cuts(selected: dict[int, tuple[int, int]], instrument: int,
               lead: bool = False) -> dict[int, tuple[int, int]]:
    result: dict[int, tuple[int, int]] = {}
    starts = sorted(selected)
    for index, row in enumerate(starts):
        note, end_row = selected[row]
        result[row] = (_normalise_lead(note) if lead else note, instrument)
        next_row = starts[index + 1] if index + 1 < len(starts) else 14 * ROWS
        if row < end_row < next_row and end_row < 14 * ROWS:
            result[end_row] = (CUT_NOTE, instrument)
    return result


def midi_composition(midi_path: Path, arrangement_path: Path) -> tuple[list[tuple[
        dict[int, tuple[int, int]], dict[int, tuple[int, int]],
        dict[int, tuple[int, int]]]], dict[str, object]]:
    config = json.loads(arrangement_path.read_text())
    digest = hashlib.sha256(midi_path.read_bytes()).hexdigest()
    if digest != config["source_sha256"]:
        raise ValueError(f"MIDI SHA-256 changed: expected {config['source_sha256']}, got {digest}")
    song = read_midi(midi_path)
    if song.format != 0 or not song.time_signatures or song.time_signatures[0][1:] != (4, 4):
        raise ValueError("Banterhouse importer requires a format-0, 4/4 MIDI")
    bar_ticks = song.division * 4
    start_tick = int(config["source_start_bar"]) * bar_ticks
    bar_count = int(config["source_bars"])
    if bar_count != 28:
        raise ValueError("the CPC arrangement must contain exactly 28 bars")
    end_tick = start_tick + bar_count * bar_ticks
    grid = song.division // int(config["rows_per_beat"])
    roles = config["roles"]
    lead = _with_cuts(_select_rows(song.notes, roles["lead_channels"], start_tick,
                                   end_tick, grid, True), 2, True)
    bass = _with_cuts(_select_rows(song.notes, [roles["bass_channel"]], start_tick,
                                   end_tick, grid, False), 1)
    harmony = _select_rows(song.notes, [roles["harmony_channel"]], start_tick,
                           end_tick, grid, True)

    patterns = []
    for pattern in range(14):
        base = pattern * ROWS
        a = {row - base: event for row, event in lead.items() if base <= row < base + ROWS}
        b = {row - base: event for row, event in bass.items() if base <= row < base + ROWS}
        c: dict[int, tuple[int, int]] = {}
        for row in range(ROWS):
            global_row = base + row
            beat_row = global_row & 15
            if beat_row in (0, 8):
                c[row] = (24, 4)
            elif beat_row in (4, 12):
                c[row] = (48, 5)
            elif beat_row in (2, 6, 10, 14):
                c[row] = (48, 6)
            elif beat_row in (3, 11) and global_row in harmony:
                c[row] = (_normalise_lead(harmony[global_row][0]), 3)
        if pattern == 13:
            a[31] = (CUT_NOTE, 2)
            b[31] = (CUT_NOTE, 1)
            c[31] = (CUT_NOTE, 3)
        patterns.append((a, b, c))
    return patterns, config


def write_song(template_path: Path, output_path: Path,
               compositions: list[tuple[dict[int, tuple[int, int]],
                                        dict[int, tuple[int, int]],
                                        dict[int, tuple[int, int]]]],
               instruments: list[ET.Element], metadata: dict[str, object]) -> None:
    with gzip.open(template_path, "rb") as source:
        root = ET.parse(source).getroot()
    for field, value in metadata.items():
        set_text(root, field, value)
    track_array = root.find("TrackArray")
    special_array = root.find("SpecialTracksArray")
    patterns = root.find("PatternsList")
    instrument_list = root.find("InstrumentsList")
    if track_array is None or special_array is None or patterns is None or instrument_list is None:
        raise ValueError("Arkos template is missing required top-level arrays")
    track_template = next(track for track in track_array if track.find("track") is not None)
    special_template = next(track for track in special_array if track.find("SpecialCells") is not None)
    song_tracks: list[ET.Element] = []
    for position, channels in enumerate(compositions):
        for channel, events in zip("ABC", channels):
            song_tracks.append(make_track(track_template, f"P{position:02d} Channel {channel}", events))
    while len(song_tracks) < TRACK_SLOTS:
        song_tracks.append(make_track(track_template, "Unused", {}))
    track_array[:] = song_tracks
    special_array[:] = [blank_special_track(special_template)
                        for _ in range(SPECIAL_TRACK_SLOTS)]
    patterns[:] = [make_pattern(position * 3) for position in range(len(compositions))]
    instrument_list[:] = instruments
    ET.indent(root, space="  ")
    xml = ET.tostring(root, encoding="windows-1252", xml_declaration=True)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(gzip.compress(xml, compresslevel=9, mtime=0))


def generate_theme(template: Path, output: Path, midi: Path, arrangement: Path) -> None:
    compositions, config = midi_composition(midi, arrangement)
    with gzip.open(template, "rb") as source:
        root = ET.parse(source).getroot()
    instrument_template = (root.find("InstrumentsList") or [])[0]
    metadata = {
        "FileName": output.name, "Name": "Banterhouse: MIDI Theme",
        "Author": "User-supplied MIDI / Banterhouse AY arrangement",
        "Comments": (f"AY reduction of embedded MIDI title {config['embedded_title']}; "
                     "redistribution clearance not independently verified."),
        "DOSName": "BHTHEME", "Length": 14, "LoopStart": 2, "LoopEnd": 13,
        "Frequency": "freq50hz", "MasterFrequency": 1000000,
        "SamplesChannel": 1, "BeginningSpeed": 6, "Highlight": 4,
    }
    write_song(template, output, compositions, theme_instruments(instrument_template), metadata)


def generate_sfx(template: Path, output: Path) -> None:
    with gzip.open(template, "rb") as source:
        root = ET.parse(source).getroot()
    instrument_template = (root.find("InstrumentsList") or [])[0]
    metadata = {
        "FileName": output.name, "Name": "Banterhouse SFX",
        "Author": "Banterhouse / OpenAI", "Comments": "AY-only gameplay effects.",
        "DOSName": "BHSFX", "Length": 1, "LoopStart": 0, "LoopEnd": 0,
        "Frequency": "freq50hz", "MasterFrequency": 1000000,
        "SamplesChannel": 1, "BeginningSpeed": 6, "Highlight": 4,
    }
    write_song(template, output, [({}, {}, {})], sfx_instruments(instrument_template), metadata)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--kind", choices=("theme", "sfx"), required=True)
    parser.add_argument("--midi", type=Path)
    parser.add_argument("--arrangement", type=Path)
    args = parser.parse_args()
    if args.kind == "theme":
        if args.midi is None or args.arrangement is None:
            parser.error("theme generation requires --midi and --arrangement")
        generate_theme(args.template, args.output, args.midi, args.arrangement)
    else:
        generate_sfx(args.template, args.output)


if __name__ == "__main__":
    main()
