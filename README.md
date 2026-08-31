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
make room-visuals # Regenerate the 30 data-driven comic backdrops
make gallery-dsk # Build the emulator-only 30-room visual acceptance reel
make resources # Rebuild BHRES.BIN, room packs and generated resource IDs
make resource-check # Validate manifest, CRCs, dependencies, DSK layout and rooms
make reproducibility # Compare serial/parallel release and resource outputs byte-for-byte
make matrix # Build the deterministic campaign regression for all 5 difficulties
make qa # Full automated acceptance, including banks, FDC, audio and campaign
make rc-verify # QA plus the 100-load FDC soak
make release # Clean, validated release build
```

Controls: choose difficulty with `O` / `P` or left/right; start and interact
with `S`, Space or joystick fire; move with QAOP, cursor keys, or joystick;
pause with Esc. The test build used by `make matrix` is never left in the
release DSK.

The DSK boots through `LOADER.BAS`, which installs the loading-screen palette,
loads `LOADING.SCR` at `0xC000`, and keeps it visible while the multi-area
`BANTERHO.BIN` loads from `0x0800` (resident code starts at `0x3D00`). The
screen therefore consumes no resident game memory.

## Complete campaign and Expanded laboratory

The downloadable DSK/CDT contains the complete ten-floor campaign with 30
data-driven comic-panel rooms. Every screen has its own label, palette and
landmark; a generated compact table keeps all backdrops resident without
duplicating 16 KiB framebuffers. The runtime composes static scenery only when
room state changes, then uses save-under buffers for moving actors at a measured
25.1 logical frames per second on a CPC 6128 emulated at 100%.

The Expanded work is an integrated technical slice rather than a replacement
release: a low-memory kernel pages RAM4–RAM7, reads a versioned `BHRES.BIN`
directly through the uPD765, validates CRC16, loads two external Mode 0 screens
and places a room pack in RAM5. Six data-driven rooms for floors 1–2 are built
and statically checked for bounds and a safe route.

`make qa` is green across reproducible builds, host tests, 30 room schemas,
10,000 bank changes, normal and faulty FDC paths, a 75.42-second AY capture and
all ten levels at five difficulties. The RC soak adds 100 complete 16 KiB
screen loads. See
[`docs/IMPLEMENTATION_STATUS.md`](docs/IMPLEMENTATION_STATUS.md) for the exact
scope, build identity and external hardware/playtest gates.

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
- [`docs/AMBITIOUS_IMPROVEMENT_PLAN.md`](docs/AMBITIOUS_IMPROVEMENT_PLAN.md): visual and product direction inspired by office comics and the best CPC patterns.
- [`docs/AMBITIOUS_IMPLEMENTATION_TEST_PLAN.md`](docs/AMBITIOUS_IMPLEMENTATION_TEST_PLAN.md): phased implementation and complete test strategy.
- [`docs/DISK_RESOURCE_ARCHITECTURE.md`](docs/DISK_RESOURCE_ARCHITECTURE.md): DSK/128K resource architecture and FDC contracts.
- [`docs/IMPLEMENTATION_STATUS.md`](docs/IMPLEMENTATION_STATUS.md): current evidence, hashes, phase status and honest blockers.
- [`docs/ROOM_VISUAL_SYSTEM.md`](docs/ROOM_VISUAL_SYSTEM.md): 30-room visual pipeline, runtime compositor and gallery evidence.
- [`docs/AUDIO.md`](docs/AUDIO.md): MIDI-derived AY soundtrack, SFX, integration and memory map.
- [`docs/PITU_CANON.md`](docs/PITU_CANON.md): non-negotiable Pitu model rules.
- [`docs/CREATAS_CAST.md`](docs/CREATAS_CAST.md): approved character identities and model sheets.

The local CPCtelera 1.5/development checkout is pinned at commit
`662fc885adc3301205c87d2cd89462d67a64d809` and uses native Homebrew SDCC 4.6
because CPCtelera's bundled SDCC 3.6 cannot run on macOS ARM64.
