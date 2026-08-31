# manuel3d resident font source

Source: [New Letter Font for AMSTRAD CPC](https://manuel3d.itch.io/letter-font-for-amstrad),
by manuel3d. `font.dsk` is the official disk download (itch.io upload 9340820).

- Official DSK SHA-256: `02cbbedce3f452895160f8cd178939333d655a7bc0fa6c6a7c705a1168694d3b`
- Extracted AMSDOS `FONTBASI.BAS` SHA-256: `aa3a0aa1672d1d57f1b6e82da9c2c03fb30848ab8e2d9d87d63c75b6afb45784`
- Tokenized BASIC payload SHA-256: `41bb8e82411b76de28e6f5cbda54298151980997b8e709f0fd30d940ae208156`
- Resident bitmap SHA-256: `6a7696a5682dd5e131dff039cb311493ae5d78ad94e7e6c2e51f4566701db491`

`tools/import_manuel3d_font.py` reads the Extended DSK, the CP/M directory,
the AMSDOS header and tokenized Locomotive BASIC. It extracts every active
`SYMBOL` statement and pads omitted trailing rows with zero, matching
Locomotive BASIC semantics. The output is deterministic `src/font_data.s`.

## Extracted format and coverage

- 8×8 pixels, one byte per row, one bit per pixel; bit 7 is the left pixel.
- 96 author-defined glyphs plus an explicit blank space: 776 bitmap bytes.
- ASCII A–Z, a–z, 0–9.
- Punctuation: `! ? % " $ # & ' ( ) + - * / \ [ ] , . : ; _ = < > ^ | @`,
  plus the grave-accent character.
- Source CPC codes `0xA1` Ñ, `0xAB` ñ, `0xA3` €, `0xAE` ¿ and `0xAF` ¡.
- ASCII `{`, `}` and `~`, plus every unknown internal byte, deterministically
  use the author's `?` glyph as fallback.

The game never embeds UTF-8 Ñ/€/¿/¡ in Z80 strings. It uses the internal bytes
`BH_CHAR_NTILDE` (`0x80`), `BH_CHAR_EURO` (`0x81`),
`BH_CHAR_INV_QUESTION` (`0x82`), `BH_CHAR_INV_EXCLAMATION` (`0x83`) and
`BH_CHAR_NTILDE_LOWER` (`0x84`).

`FONTBASI` also contains a commented-out former peseta definition for source
code `0xA3`; it is not active. The following active line assigns the euro
design to that code, and that active euro glyph is what the importer preserves.

## Permission notice

The itch.io page says the font may be used by including it in projects. It does
not publish a named or formal license. This repository therefore records the
author, source and statement without claiming a license that the author did not
publish.
