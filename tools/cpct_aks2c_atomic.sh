#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
real_converter=${CPCT_REAL_AKS2C:-"$root/.tools/cpctelera/cpctelera/tools/scripts/cpct_aks2c"}
stage=$(mktemp -d "$root/.tools/aks2c-stage.XXXXXX")
output_folder=
args=()

cleanup() {
  find "$stage" -mindepth 1 -delete 2>/dev/null || true
  rmdir "$stage" 2>/dev/null || true
}
trap cleanup EXIT HUP INT TERM

while test "$#" -gt 0; do
  if test "$1" = -od; then
    output_folder=$2
    args+=("$1" "$stage/")
    shift 2
  else
    args+=("$1")
    shift
  fi
done

if test -z "$output_folder"; then
  printf 'cpct_aks2c atomic wrapper requires an output folder (-od)\n' >&2
  exit 2
fi

"$real_converter" "${args[@]}"
for generated in "$stage"/*; do
  test -e "$generated" || continue
  mv -f "$generated" "$output_folder/$(basename "$generated")"
done
