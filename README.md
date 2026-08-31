# banterhouse

An Amstrad CPC game fueled by curiosity and nostalgia.

## Development

The project builds with CPCtelera and runs in a native Apple Silicon build of
Caprice32. Both tools live under the ignored `.tools/` directory.

```bash
make       # Build banterhouse.dsk and banterhouse.cdt
make run   # Build and boot through the loading screen in Caprice32
make loading-screen # Regenerate the 16 KiB Mode 0 loading screen
make font-data # Re-extract the resident font from the official DSK
make font-test-dsk # Build the CPC font specimen screen
make audio-test-dsk # Build the complete-loop and gameplay-SFX diagnostic
make audio-verify # Capture/validate the full loop and SFX reel, then restore release
make clean # Remove generated compiler output
make clean-build # Serial build from an empty output tree
make parallel-build # Parallel build from an empty output tree
make check # Validate content invariants and the CPC memory budget
make matrix # Build the deterministic campaign regression for all 5 difficulties
make release # Clean, validated release build
```

Controls: choose difficulty with `O` / `P` or left/right; start and interact
with `S`, Space or joystick fire; move with QAOP, cursor keys, or joystick;
pause with Esc. The test build used by `make matrix` is never left in the
release DSK.

The DSK boots through `LOADER.BAS`, which installs the loading-screen palette,
loads `LOADING.SCR` at `0xC000`, and keeps it visible while the multi-area
`BANTERHO.BIN` loads from `0x0800` (resident code starts at `0x4000`). The
screen therefore consumes no resident game memory.

## AY soundtrack

The user-supplied MIDI is deterministically reduced to the editable Arkos
Tracker source `music/banterhouse-theme.aks`; effects live independently in
`music/banterhouse-sfx.aks`. CPCtelera's Arkos Player runs both at 50 Hz and
provides eight prioritized gameplay SFX on channel C. The MIDI internally
identifies a third-party composition, so redistribution clearance remains a
release prerequisite. See [`docs/AUDIO.md`](docs/AUDIO.md) for provenance,
conversion, instruments, memory map and emulator evidence.

## Resident UI font

All functional text uses a firmware-independent 8×8, 1-bpp renderer backed by
the exact `SYMBOL` definitions in manuel3d's
[New Letter Font for AMSTRAD CPC](https://manuel3d.itch.io/letter-font-for-amstrad).
The official `font.dsk` is kept under `assets/fonts/manuel3d/`, and
`tools/import_manuel3d_font.py` deterministically extracts tokenized
`FONTBASI.BAS` into `src/font_data.s`. See the asset README there for hashes,
character coverage, internal Ñ/€/¿/¡ codes, attribution and licensing caveat.

The CPC build does not call `cpct_drawStringM0`, `cpct_drawCharM0`, firmware or
the character ROM. `make check` verifies the import hash, every glyph, Mode 0
conversion, text inventory, framebuffer bounds, linker map and stack margin.
Caprice32 evidence for the loading screen, font specimen, menu, both framebuffer
pages, boss, victory and defeat is indexed in
[`artifacts/font-validation/README.md`](artifacts/font-validation/README.md).

Game code is under `src/`; maps and source artwork are under `maps/` and
`assets/`. The imported game history comes from
[`fersantxez/bntrhs`](https://github.com/fersantxez/bntrhs).

## Production documents

- [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md): canonical 10-level game design.
- [`docs/GAMEPLAY_RESEARCH.md`](docs/GAMEPLAY_RESEARCH.md): CPC gameplay references and lessons.
- [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md): build order and milestone gates.
- [`docs/TEST_PLAN.md`](docs/TEST_PLAN.md): automated, emulator, performance and playtest plan.
- [`docs/AUDIO.md`](docs/AUDIO.md): MIDI-derived AY soundtrack, SFX, integration and memory map.
- [`docs/PITU_CANON.md`](docs/PITU_CANON.md): non-negotiable Pitu model rules.
- [`docs/CREATAS_CAST.md`](docs/CREATAS_CAST.md): approved character identities and model sheets.

The local CPCtelera 1.5/development checkout is pinned at commit
`662fc885adc3301205c87d2cd89462d67a64d809` and uses native Homebrew SDCC 4.6
because CPCtelera's bundled SDCC 3.6 cannot run on macOS ARM64.
