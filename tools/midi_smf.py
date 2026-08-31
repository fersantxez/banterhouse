#!/usr/bin/env python3
"""Small, dependency-free Standard MIDI File reader used by the AKS builder."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import struct


@dataclass(frozen=True)
class MidiNote:
    start: int
    end: int
    channel: int
    note: int
    velocity: int


@dataclass
class MidiSong:
    format: int
    division: int
    tracks: int
    end_tick: int = 0
    notes: list[MidiNote] = field(default_factory=list)
    tempos: list[tuple[int, int]] = field(default_factory=list)
    time_signatures: list[tuple[int, int, int]] = field(default_factory=list)
    programs: list[tuple[int, int, int]] = field(default_factory=list)
    text: list[tuple[int, int, str]] = field(default_factory=list)


def _vlq(data: bytes, offset: int) -> tuple[int, int]:
    value = 0
    for _ in range(4):
        byte = data[offset]
        offset += 1
        value = (value << 7) | (byte & 0x7F)
        if not byte & 0x80:
            return value, offset
    raise ValueError("invalid MIDI variable-length quantity")


def read_midi(path: Path) -> MidiSong:
    data = path.read_bytes()
    if data[:4] != b"MThd" or len(data) < 14:
        raise ValueError(f"{path} is not a Standard MIDI File")
    header_size = struct.unpack(">I", data[4:8])[0]
    midi_format, track_count, division = struct.unpack(">HHH", data[8:14])
    if division & 0x8000:
        raise ValueError("SMPTE MIDI timing is not supported")
    song = MidiSong(midi_format, division, track_count)
    offset = 8 + header_size

    for track_number in range(track_count):
        if data[offset:offset + 4] != b"MTrk":
            raise ValueError(f"missing MTrk chunk {track_number}")
        length = struct.unpack(">I", data[offset + 4:offset + 8])[0]
        track = data[offset + 8:offset + 8 + length]
        offset += 8 + length
        cursor = tick = 0
        running_status: int | None = None
        active: dict[tuple[int, int], list[tuple[int, int]]] = {}

        while cursor < len(track):
            delta, cursor = _vlq(track, cursor)
            tick += delta
            song.end_tick = max(song.end_tick, tick)
            status = track[cursor]
            if status & 0x80:
                cursor += 1
                if status < 0xF0:
                    running_status = status
            elif running_status is not None:
                status = running_status
            else:
                raise ValueError("MIDI running status used before a channel event")

            if status == 0xFF:
                event_type = track[cursor]
                cursor += 1
                size, cursor = _vlq(track, cursor)
                payload = track[cursor:cursor + size]
                cursor += size
                if event_type == 0x51 and len(payload) == 3:
                    song.tempos.append((tick, int.from_bytes(payload, "big")))
                elif event_type == 0x58 and len(payload) >= 2:
                    song.time_signatures.append((tick, payload[0], 1 << payload[1]))
                elif event_type in (0x01, 0x02, 0x03, 0x04):
                    song.text.append((tick, event_type, payload.decode("latin1", "replace")))
                if event_type == 0x2F:
                    break
                continue

            if status in (0xF0, 0xF7):
                size, cursor = _vlq(track, cursor)
                cursor += size
                running_status = None
                continue

            event_type = status & 0xF0
            channel = status & 0x0F
            size = 1 if event_type in (0xC0, 0xD0) else 2
            payload = track[cursor:cursor + size]
            cursor += size
            if event_type == 0xC0:
                song.programs.append((tick, channel, payload[0]))
            elif event_type == 0x90 and payload[1]:
                active.setdefault((channel, payload[0]), []).append((tick, payload[1]))
            elif event_type in (0x80, 0x90):
                starts = active.get((channel, payload[0]))
                if starts:
                    start, velocity = starts.pop(0)
                    song.notes.append(MidiNote(start, tick, channel, payload[0], velocity))

        for (channel, note), starts in active.items():
            for start, velocity in starts:
                song.notes.append(MidiNote(start, tick, channel, note, velocity))

    song.notes.sort(key=lambda item: (item.start, item.channel, item.note))
    song.tempos.sort()
    song.time_signatures.sort()
    return song
