#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cap32_dir=${CAP32_DIR:-"$root/.tools/caprice32"}
cap32=${CAP32:-"$cap32_dir/cap32"}
run_dir=$(mktemp -d "$root/artifacts/fdc-lab.XXXXXX")
result_file="$run_dir/result.dat"
cycles=${FDC_LAB_CYCLES:-1}
timeout_seconds=${FDC_LAB_TIMEOUT:-60}

restore_release() {
  result=$?
  trap - EXIT
  if ! make -C "$root" release >"$run_dir/release-restore.log" 2>&1; then
    tail -n 80 "$run_dir/release-restore.log" >&2
    result=1
  fi
  exit "$result"
}
trap restore_release EXIT

make -C "$root" fdc-lab-dsk FDC_LAB_CYCLES="$cycles" >"$run_dir/build.log" 2>&1
(
  cd "$cap32_dir"
  exec env SDL_AUDIODRIVER=dummy "$cap32" --verbose \
    -O system.model=2 \
    -O system.ram_size=128 \
    -O system.printer=1 \
    -O system.limit_speed=0 \
    -O video.scr_fps=0 \
    -O sound.enabled=0 \
    -O file.printer_file="$result_file" \
    -a 'run"LOADER"' \
    "$root/generated/banterhouse-fdc-lab.dsk"
) >"$run_dir/caprice32.log" 2>&1 &
caprice_pid=$!

passed=0
for _ in $(seq 1 "$timeout_seconds"); do
  if test -f "$result_file"; then
    result=$(tr -d '\r\n' <"$result_file")
    if test "$result" = BH_PASS; then passed=1; break; fi
    if [[ "$result" == BH_FAIL* ]]; then
      printf 'FDC lab returned %s\n' "$result" >&2
      break
    fi
  fi
  if ! kill -0 "$caprice_pid" 2>/dev/null; then break; fi
  sleep 1
done

kill "$caprice_pid" 2>/dev/null || true
wait "$caprice_pid" 2>/dev/null || true
test "$passed" -eq 1
printf 'FDC screen loads in Caprice32: PASS (%s loads, %s)\n' "$((cycles * 2))" "$run_dir"
