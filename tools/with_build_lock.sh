#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
lock="$root/.tools/banterhouse-build.lock"

if test "${BH_BUILD_LOCK_HELD:-0}" = 1; then
  exec "$@"
fi

attempt=0
while ! mkdir "$lock" 2>/dev/null; do
  owner=unknown
  if test -f "$lock/pid"; then owner=$(cat "$lock/pid"); fi
  if test "$owner" != unknown && ! kill -0 "$owner" 2>/dev/null; then
    rm -f "$lock/pid"
    rmdir "$lock" 2>/dev/null || true
    continue
  fi
  attempt=$((attempt + 1))
  if test "$attempt" -ge 180; then
    printf 'Timed out waiting for Banterhouse build lock (pid %s)\n' "$owner" >&2
    exit 3
  fi
  sleep 1
done

printf '%s\n' "$$" >"$lock/pid"
cleanup() {
  rm -f "$lock/pid"
  rmdir "$lock" 2>/dev/null || true
}
trap cleanup EXIT HUP INT TERM

export BH_BUILD_LOCK_HELD=1
"$@"
