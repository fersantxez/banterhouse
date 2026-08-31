#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

test -s banterhouse.dsk
test -s banterhouse.cdt
test -s obj/banterhouse.bin
test -s music/source/banterhouse-theme.mid
test -s music/banterhouse-theme.aks
test -s music/banterhouse-sfx.aks
test -s src/banterhouse-theme.s
test -s src/banterhouse-theme.h
test -s src/banterhouse-sfx.s
test -s src/banterhouse-sfx.h
test "$(wc -c < dsk_files/LOADING.SCR | tr -d ' ')" -eq 16384
rg -q 'LOAD "LOADING.SCR",&C000' dsk_files/LOADER.BAS
rg -q 'RUN "BANTERHO.BIN"' dsk_files/LOADER.BAS
test "$(rg -o '"[A-Z0-9 ]+"' src/game.c src/game_render.c src/world_data.c | wc -l | tr -d ' ')" -ge 10
rg -q 'bh_game_render_frame.*const BHGameState\*' src/game_render.h
test "$(rg -c '^   \{ 0x' src/difficulty.c | tr -d ' ')" -eq 5
rg -q 'const BHProfile bh_profiles\[BH_DIFFICULTY_COUNT\]' src/difficulty.c
rg -q '#define BH_LEVELS          10' src/main.h
rg -q 'BH_DIFFICULTY_COUNT' src/difficulty.h
rg -q 'cpct_setVideoMemoryPage' src/game.c
rg -q 'bh_audio_tick' src/audio.c
rg -q 'cpct_akp_musicInit' src/audio.c
rg -q 'cpct_akp_musicPlay' src/audio.c
rg -q 'cpct_akp_SFXPlay' src/audio.c
rg -q '_cpct_akp_musicPlay' obj/banterhouse.map
rg -q '_cpct_akp_SFXPlay' obj/banterhouse.map
rg -q 'BH_AUTOTEST' src/game.c
rg -q 'HW_GREEN, HW_WHITE' src/main.c
if rg -n 'cpct_(setDrawCharM0|drawStringM0|drawCharM0)' src; then
  printf 'ROM text renderer call remains in src/\n' >&2
  exit 1
fi
if rg -q '_cpct_(setDrawCharM0|drawStringM0)|cpct_drawCharM0_inner' obj/banterhouse.map; then
  printf 'ROM text renderer remains linked\n' >&2
  exit 1
fi
node tools/check_pitu_palette.js

python3 tools/check_midi.py
python3 tools/check_aks.py music/banterhouse-theme.aks music/banterhouse-sfx.aks
python3 tools/test_font.py

check_tmp=$(mktemp -d /tmp/banterhouse-audio-check.XXXXXX)
trap 'test -n "$check_tmp" && rm -rf "$check_tmp"' EXIT
mono .tools/cpctelera/cpctelera/tools/arkosTracker-1.0/tools/AKSToBIN.exe \
  -a 0x0800 music/banterhouse-theme.aks "$check_tmp/theme.bin" >/dev/null
mono .tools/cpctelera/cpctelera/tools/arkosTracker-1.0/tools/AKSToBIN.exe \
  -s -a 0x1EA0 music/banterhouse-sfx.aks "$check_tmp/sfx.bin" >/dev/null
theme_size=$(wc -c < "$check_tmp/theme.bin" | tr -d ' ')
sfx_size=$(wc -c < "$check_tmp/sfx.bin" | tr -d ' ')
theme_header_size=$(awk '/^#define bh_theme_size/ { print $3 }' src/banterhouse-theme.h)
sfx_header_size=$(awk '/^#define bh_sfx_size/ { print $3 }' src/banterhouse-sfx.h)
test "$theme_size" -eq "$theme_header_size"
test "$sfx_size" -eq "$sfx_header_size"
test "$((0x0800 + theme_size))" -le $((0x1300))
test "$((0x1EA0 + sfx_size))" -le $((0x2000))

high_hex=$(python3 tools/runtime_highwater.py obj/banterhouse.map obj/banterhouse.bin.log)
test -n "$high_hex"
test "$((16#$high_hex))" -lt 32768
test "$((16#$(awk '$2 == "l__INITIALIZED" { print $1 }' obj/banterhouse.map)))" -eq 0
test "$((16#$(awk '$2 == "l__INITIALIZER" { print $1 }' obj/banterhouse.map)))" -eq 0
rg -q '00000800  _bh_theme' obj/banterhouse.map
rg -q '00001EA0  _bh_sfx' obj/banterhouse.map
rg -q '00001300  _g_pitu_rev' obj/banterhouse.map
rg -q '00001B00  _bh_font_glyphs' obj/banterhouse.map
rg -q '00001E6C  _bh_font_work_start' obj/banterhouse.map
rg -q '00001E92  _bh_font_work_end' obj/banterhouse.map
rg -q '00002000  _g_pitu_walk' obj/banterhouse.map
margin=$((0x8000 - 16#$high_hex - 1))
test "$margin" -ge 4096
if rg -q '_bh_autotest_result' obj/banterhouse.noi; then
  printf 'check requires a release build, not BH_AUTOTEST\n' >&2
  exit 1
fi

printf 'Static/content checks: PASS\n'
