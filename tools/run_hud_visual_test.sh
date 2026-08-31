#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cap32_dir=${CAP32_DIR:-"$root/.tools/caprice32"}
cap32=${CAP32:-"$cap32_dir/cap32"}
baseline="$root/tests/visual/hud-score-panel.png"
capture_dir=$(mktemp -d /tmp/banterhouse-hud-visual.XXXXXX)

restore_release() {
  status=$?
  trap - EXIT
  (cd "$root" && make _bh-release >/tmp/banterhouse-hud-release-restore.log 2>&1) || {
    printf 'Failed to restore release build; see /tmp/banterhouse-hud-release-restore.log\n' >&2
    status=1
  }
  rm -rf "$capture_dir"
  exit "$status"
}
trap restore_release EXIT

test -x "$cap32"
test -s "$baseline"

cd "$root"
make cleanall >/dev/null
make Z80CCFLAGS='--sdcccall 0 --opt-code-size -DBH_CAPTURE_HUD -DBH_CAPTURE_HUD_PAGE=0' all \
  >"$capture_dir/build.log" 2>&1

args=(
  --verbose
  -O system.model=2
  -O system.ram_size=128
  -O system.limit_speed=0
  -O video.scr_fps=0
  -O sound.enabled=0
  -O "file.sdump_dir=$capture_dir"
  --autocmd='run"LOADER"'
)
for _ in $(seq 1 32); do args+=(--autocmd=CAP32_DELAY); done
args+=(--autocmd=s)
for _ in $(seq 1 12); do args+=(--autocmd=CAP32_DELAY); done
args+=(
  --autocmd=CAP32_SCRNSHOT
  --autocmd=CAP32_EXIT
  --sym_file="$root/obj/banterhouse.noi"
  "$root/banterhouse.dsk"
)

(cd "$cap32_dir" && env SDL_AUDIODRIVER=dummy "$cap32" "${args[@]}") \
  >"$capture_dir/caprice32.log" 2>&1
shot=$(find "$capture_dir" -maxdepth 1 -name 'screenshot_*.png' -print | head -1)
test -n "$shot"
if ! cmp -s "$baseline" "$shot"; then
  mkdir -p "$root/artifacts/hud-validation"
  actual="$root/artifacts/hud-validation/hud-actual-$$.png"
  cp "$shot" "$actual"
  printf 'HUD visual regression mismatch; actual capture: %s\n' "$actual" >&2
  exit 1
fi

sha=$(shasum -a 256 "$shot" | awk '{print $1}')
printf 'HUD emulator visual regression: PASS (%s)\n' "$sha"
