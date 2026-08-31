#!/usr/bin/env python3
"""Report the highest resident byte, including SDCC's uninitialized data."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def map_value(text: str, symbol: str) -> int:
    match = re.search(rf"^\s*([0-9A-Fa-f]+)\s+{re.escape(symbol)}\s*$", text, re.M)
    if not match:
        raise SystemExit(f"missing linker symbol {symbol}")
    return int(match.group(1), 16)


def main() -> None:
    map_path = Path(sys.argv[1] if len(sys.argv) > 1 else "obj/banterhouse.map")
    log_path = Path(sys.argv[2] if len(sys.argv) > 2 else "obj/banterhouse.bin.log")
    map_text = map_path.read_text(encoding="latin-1")
    log_text = log_path.read_text(encoding="latin-1")
    match = re.search(r"Highest address\s*=\s*([0-9A-Fa-f]+)", log_text)
    if not match:
        raise SystemExit("missing binary high-water")
    high = int(match.group(1), 16)

    data_start = map_value(map_text, "s__DATA")
    data_size = map_value(map_text, "l__DATA")
    if data_size:
        high = max(high, data_start + data_size - 1)

    print(f"{high:08X}")


if __name__ == "__main__":
    main()
