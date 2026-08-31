#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
run_dir=$(mktemp -d "$root/artifacts/reproducibility.XXXXXX")

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

hash_outputs() {
  shasum -a 256 \
    "$root/obj/banterhouse.bin" \
    "$root/banterhouse.dsk" \
    "$root/banterhouse.cdt" \
    "$root/generated/BHRES.BIN" \
    "$root/generated/resource_ids.h" \
    "$root/generated/resource_ids.s" |
    sed "s|$root/||"
}

make -C "$root" clean-build >"$run_dir/serial-build.log" 2>&1
make -C "$root" resources >"$run_dir/serial-resources.log" 2>&1
hash_outputs >"$run_dir/serial.sha256"

make -C "$root" parallel-build >"$run_dir/parallel-build.log" 2>&1
make -C "$root" resources >"$run_dir/parallel-resources.log" 2>&1
hash_outputs >"$run_dir/parallel.sha256"

diff -u "$run_dir/serial.sha256" "$run_dir/parallel.sha256"
printf 'Serial/parallel release and resource outputs: PASS (%s)\n' "$run_dir"
