#!/usr/bin/env python3
"""Write a host text file with the CRLF records expected by AMSDOS BASIC."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    text = args.source.read_text(encoding="ascii")
    records = text.replace("\r\n", "\n").replace("\r", "\n").splitlines()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(("\r\n".join(records) + "\r\n").encode("ascii"))


if __name__ == "__main__":
    main()
