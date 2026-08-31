#!/usr/bin/env python3
"""Host regression tests for the BHRES packer and inspector."""

from __future__ import annotations

import json
import tempfile
from pathlib import Path

from resource_pack import AMSDOS_HEADER_SIZE, ResourceError, inspect_container, load_manifest, write_outputs


def expect_error(action, text: str) -> None:
    try:
        action()
    except ResourceError as error:
        assert text in str(error), (text, str(error))
    else:
        raise AssertionError(f"expected ResourceError containing {text!r}")


def write_manifest(path: Path, resources: list[dict]) -> None:
    path.write_text(json.dumps({"format_version": 1, "resources": resources}), encoding="utf-8")


def record(resource_id: str, symbol: str, source: str, dependencies: list[str] | None = None) -> dict:
    return {
        "id": resource_id,
        "symbol": symbol,
        "type": "background_screen",
        "source": source,
        "codec": "none",
        "target": "hidden_framebuffer",
        "cache": "discardable",
        "dependencies": dependencies or [],
    }


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="banterhouse-resource-test.") as temp:
        root = Path(temp)
        (root / "a.bin").write_bytes(bytes(range(256)) * 3)
        (root / "b.bin").write_bytes(b"BANTRHOUSE" * 97)
        manifest = root / "resources.yml"
        write_manifest(manifest, [record("0x0102", "RESOURCE_B", "b.bin", ["RESOURCE_A"]), record("0x0101", "RESOURCE_A", "a.bin")])

        version, resources = load_manifest(manifest, root)
        first = root / "first.bin"
        second = root / "second.bin"
        write_outputs(first, root / "first.h", root / "first.json", version, resources)
        write_outputs(second, root / "second.h", root / "second.json", version, resources)
        assert first.read_bytes() == second.read_bytes()
        assert (root / "first.h").read_bytes() == (root / "second.h").read_bytes()
        assert (root / "first.s").read_bytes() == (root / "second.s").read_bytes()
        generated_header = (root / "first.h").read_text(encoding="ascii")
        assert "#define RESOURCE_A_FILE_SECTOR 1" in generated_header
        assert "#define RESOURCE_A_SECTOR_COUNT 2" in generated_header
        assert "#define RESOURCE_A_CRC16 " in generated_header
        result = inspect_container(first.read_bytes(), verify_payloads=True)
        assert result["count"] == 2
        assert [entry["id"] for entry in result["entries"]] == [0x0101, 0x0102]
        assert all((AMSDOS_HEADER_SIZE + entry["offset"]) % 512 == 0 for entry in result["entries"])
        assert result["data_offset"] == 384

        corrupted = bytearray(first.read_bytes())
        corrupted[result["entries"][0]["offset"]] ^= 0x80
        expect_error(lambda: inspect_container(bytes(corrupted), verify_payloads=True), "payload CRC mismatch")

        wrong_magic = bytearray(first.read_bytes())
        wrong_magic[0] ^= 0x20
        expect_error(lambda: inspect_container(bytes(wrong_magic)), "wrong magic")
        wrong_version = bytearray(first.read_bytes())
        wrong_version[4] = 2
        expect_error(lambda: inspect_container(bytes(wrong_version)), "unsupported header fields")
        wrong_build_id = bytearray(first.read_bytes())
        wrong_build_id[14] ^= 0x01
        expect_error(lambda: inspect_container(bytes(wrong_build_id)), "header/index CRC mismatch")
        expect_error(lambda: inspect_container(first.read_bytes()[:100]), "invalid data offset")

        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "a.bin"), record("0x0101", "RESOURCE_B", "b.bin")])
        expect_error(lambda: load_manifest(manifest, root), "duplicate resource ID")
        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "a.bin"), record("0x0102", "RESOURCE_A", "b.bin")])
        expect_error(lambda: load_manifest(manifest, root), "duplicate resource symbol")
        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "a.bin", ["MISSING"])])
        expect_error(lambda: load_manifest(manifest, root), "depends on missing")
        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "a.bin", ["RESOURCE_B"]), record("0x0102", "RESOURCE_B", "b.bin", ["RESOURCE_A"])])
        expect_error(lambda: load_manifest(manifest, root), "dependency cycle")
        (root / "empty.bin").write_bytes(b"")
        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "empty.bin")])
        expect_error(lambda: load_manifest(manifest, root), "invalid size 0")
        (root / "oversize.bin").write_bytes(b"x" * 0x10000)
        write_manifest(manifest, [record("0x0101", "RESOURCE_A", "oversize.bin")])
        expect_error(lambda: load_manifest(manifest, root), "invalid size 65536")

    print("Host resource container tests: PASS")


if __name__ == "__main__":
    main()
