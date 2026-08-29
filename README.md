# banterhouse

An Amstrad CPC game fueled by curiosity and nostalgia.

## Development

The project builds with CPCtelera and runs in a native Apple Silicon build of
Caprice32. Both tools live under the ignored `.tools/` directory.

```bash
make       # Build banterhouse.dsk and banterhouse.cdt
make run   # Build and launch the game in Caprice32 with debug symbols
make clean # Remove generated compiler output
```

Game code is under `src/`; maps and source artwork are under `maps/` and
`assets/`. The imported game history comes from
[`fersantxez/bntrhs`](https://github.com/fersantxez/bntrhs).

The local CPCtelera 1.5/development checkout is pinned at commit
`662fc885adc3301205c87d2cd89462d67a64d809` and uses native Homebrew SDCC 4.6
because CPCtelera's bundled SDCC 3.6 cannot run on macOS ARM64.
