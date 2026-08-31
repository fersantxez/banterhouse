# manuel3d font validation

These PNGs were captured from Caprice32 booting the generated DSK through
`LOADER.BAS`. They are test artifacts, not source artwork.

- `loading-screen.png`: the unchanged 16 KiB Mode 0 loading screen, held after
  `LOAD "LOADING.SCR",&C000` so BASIC cannot scroll it.
- `font-specimen.png`: the required alphabet, numbers, punctuation, Ñ, euro and
  representative UI strings rendered by the resident font.
- `menu.png`: functional menu text rendered without firmware or character ROM.
- `hud-8000.png` and `hud-c000.png`: the same HUD captured independently from
  both framebuffer bases. Their identical SHA-256 is
  `1a8eb36ffa7aa2c7158cde5329e0bdc762e82a6302d40105e6ee8a3b55a7445d`.
- `boss.png`, `victory.png` and `defeat.png`: deterministic emulator builds
  stopped in busy loops after each ordinary game path rendered its screen.

The five `campaigns/difficulty-N/result.dat` files contain `BH_PASS`. Each was
written by the emulated Z80 only after its ten-level campaign completed through
the boss state machine. The release build was restored after test variants.

The pre-integration linker map ended resident runtime data at `0x77F9`
(`0x77EE` was its highest named byte), leaving 2,054 bytes below `0x8000`.
The validated release ends at `0x6B44`, leaving 5,307 bytes. Font storage is
776 bitmap bytes plus 100 index bytes; the renderer is 356 code bytes and 38
bytes of mutable Mode 0 conversion state. `baseline.map`/`baseline.bin.log` and
`release.map`/`release.bin.log` preserve the inputs to that calculation.
