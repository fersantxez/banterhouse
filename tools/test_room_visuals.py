#!/usr/bin/env python3
"""Host validation and corruption fixtures for the visual room schema."""

from __future__ import annotations

import copy
import json
import tempfile
from pathlib import Path

from build_room_visuals import validate


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/rooms/visuals.json'


def rejected(data: dict) -> bool:
    try:
        validate(data)
    except ValueError:
        return True
    return False


def main() -> None:
    data = json.loads(SOURCE.read_text(encoding='utf-8'))
    rooms = validate(data)
    assert len(rooms) == 30
    assert len({room['landmark'] for room in rooms}) == 30
    assert all(8 <= len(room['rects']) <= 16 for room in rooms)

    bad = copy.deepcopy(data); bad['rooms'].pop()
    assert rejected(bad)
    bad = copy.deepcopy(data); bad['rooms'][1]['landmark'] = bad['rooms'][0]['landmark']
    assert rejected(bad)
    bad = copy.deepcopy(data); bad['rooms'][2]['rects'][0][2] = 90
    assert rejected(bad)
    bad = copy.deepcopy(data); bad['rooms'][3]['paper'] = bad['rooms'][3]['ink']
    assert rejected(bad)
    bad = copy.deepcopy(data); bad['rooms'][4]['rects'] = bad['rooms'][4]['rects'][:3]
    assert rejected(bad)

    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / 'roundtrip.json'
        path.write_text(json.dumps(data), encoding='utf-8')
        assert validate(json.loads(path.read_text(encoding='utf-8'))) == rooms

    print('Host room visual schema/fault tests: PASS (30 rooms)')


if __name__ == '__main__':
    main()
