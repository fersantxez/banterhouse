#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cap32_dir=${CAP32_DIR:-"$root/.tools/caprice32"}
cap32=${CAP32:-"$cap32_dir/cap32"}
run_dir=$(mktemp -d "$root/artifacts/fdc-faults.XXXXXX")

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

make -C "$root" fdc-lab-dsk FDC_LAB_CYCLES=1 >"$run_dir/build.log" 2>&1
python3 "$root/tools/mutate_fdc_lab_dsk.py" "$root/generated/banterhouse-fdc-lab.dsk" \
  "$run_dir/payload-crc.dsk" --mode payload-crc
python3 "$root/tools/mutate_fdc_lab_dsk.py" "$root/generated/banterhouse-fdc-lab.dsk" \
  "$run_dir/missing-sector.dsk" --mode missing-sector

run_fault() {
  name=$1
  image=$2
  expected=$3
  result_file="$run_dir/$name.result.dat"
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
      "$image"
  ) >"$run_dir/$name.caprice32.log" 2>&1 &
  caprice_pid=$!

  matched=0
  for _ in $(seq 1 90); do
    if test -f "$result_file"; then
      result=$(tr -d '\r\n' <"$result_file")
      if [[ "$result" == "$expected"* ]]; then matched=1; break; fi
      if [[ "$result" == BH_PASS* ]]; then break; fi
    fi
    if ! kill -0 "$caprice_pid" 2>/dev/null; then break; fi
    sleep 1
  done
  kill "$caprice_pid" 2>/dev/null || true
  wait "$caprice_pid" 2>/dev/null || true
  if test "$matched" -ne 1; then
    printf '%s fault expected %s, got %s\n' "$name" "$expected" "${result:-<none>}" >&2
    return 1
  fi
  printf 'FDC fault %-14s: PASS (%s)\n' "$name" "$result"
}

run_fault payload-crc "$run_dir/payload-crc.dsk" BH_FAIL8
run_fault missing-sector "$run_dir/missing-sector.dsk" BH_FAIL7
printf 'FDC bounded retry/error paths: PASS (%s)\n' "$run_dir"
