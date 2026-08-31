#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

artifact_root="$root/artifacts/campaigns"
cap32_dir=${CAP32_DIR:-"$root/.tools/caprice32"}
cap32=${CAP32:-"$cap32_dir/cap32"}
matrix_lock="$root/.tools/banterhouse-matrix.lock"

if ! mkdir "$matrix_lock" 2>/dev/null; then
  owner=unknown
  if test -f "$matrix_lock/pid"; then owner=$(cat "$matrix_lock/pid"); fi
  if test "$owner" != unknown && ! kill -0 "$owner" 2>/dev/null; then
    rm -f "$matrix_lock/pid"
    rmdir "$matrix_lock" 2>/dev/null || true
    mkdir "$matrix_lock"
  else
    printf 'Another Banterhouse campaign matrix is already running (pid %s)\n' "$owner" >&2
    exit 3
  fi
fi
printf '%s\n' "$$" >"$matrix_lock/pid"

mkdir -p "$artifact_root"

restore_release() {
  result=$?
  trap - EXIT
  printf 'Restoring validated release build\n'
  if ! make release >"$artifact_root/release-build.log" 2>&1; then
    tail -n 80 "$artifact_root/release-build.log" >&2
    result=1
  fi
  rm -f "$matrix_lock/pid"
  rmdir "$matrix_lock" 2>/dev/null || true
  exit "$result"
}
trap restore_release EXIT

run_campaign() {
  difficulty=$1
  run_dir=$2
  log="$run_dir/caprice32.log"

  (
    cd "$cap32_dir"
    exec env SDL_AUDIODRIVER=dummy "$cap32" --verbose \
      -O system.model=2 \
      -O system.ram_size=128 \
      -O system.printer=1 \
      -O system.limit_speed=0 \
      -O video.scr_fps=0 \
      -O sound.enabled=0 \
      -O file.printer_file="$run_dir/result.dat" \
      -a 'run"LOADER"' \
      "$root/banterhouse.dsk"
  ) >"$log" 2>&1 &
  caprice_pid=$!

  passed=0
  for second in $(seq 1 45); do
    if test -f "$run_dir/result.dat" && \
       test "$(cat "$run_dir/result.dat")" = 'BH_PASS'; then
      passed=1
      break
    fi
    if ! kill -0 "$caprice_pid" 2>/dev/null; then break; fi
    sleep 1
  done
  if test "$passed" -eq 1; then
    kill "$caprice_pid" 2>/dev/null || true
    wait "$caprice_pid" 2>/dev/null || true
  elif kill -0 "$caprice_pid" 2>/dev/null; then
    kill "$caprice_pid" 2>/dev/null || true
    wait "$caprice_pid" 2>/dev/null || true
    printf 'Caprice32 timeout on difficulty %s\n' "$difficulty" >&2
    return 1
  elif ! wait "$caprice_pid"; then
    tail -n 80 "$log" >&2
    return 1
  else
    printf 'Caprice32 exited before campaign result on difficulty %s\n' "$difficulty" >&2
    return 1
  fi

  test "$(cat "$run_dir/result.dat")" = 'BH_PASS'
}

campaign_count=0
for difficulty in ${MATRIX_DIFFICULTIES:-0 1 2 3 4}; do
  printf 'Caprice32 campaign, difficulty %s/4\n' "$difficulty"
  run_dir=$(mktemp -d "$artifact_root/difficulty-${difficulty}.XXXXXX")
  make test-dsk TEST_DIFFICULTY="$difficulty" >"$run_dir/build.log" 2>&1
  high_hex=$(python3 tools/runtime_highwater.py obj/banterhouse.map obj/banterhouse.bin.log)
  test -n "$high_hex"
  test "$((16#$high_hex))" -lt 32768
  cp obj/banterhouse.bin.log "$run_dir/memory.log"
  shasum -a 256 banterhouse.dsk >"$run_dir/banterhouse.dsk.sha256"
  run_campaign "$difficulty" "$run_dir"
  campaign_count=$((campaign_count + 1))
done

printf '%s ten-level campaign(s) executed in Caprice32: PASS\n' "$campaign_count"
