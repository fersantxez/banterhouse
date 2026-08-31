#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

artifact_root="$root/artifacts/audio"
cap32_dir=${CAP32_DIR:-"$root/.tools/caprice32"}
cap32=${CAP32:-"$cap32_dir/cap32"}
run_dir=$(mktemp -d "$artifact_root/midi-theme-events.XXXXXX")
raw="$run_dir/audio.raw"
wav="$run_dir/audio.wav"
result_file="$run_dir/result.dat"
log="$run_dir/caprice32.log"

restore_release() {
  status=$?
  trap - EXIT
  printf 'Restoring validated release build\n'
  if ! make release >"$run_dir/release-build.log" 2>&1; then
    tail -n 80 "$run_dir/release-build.log" >&2
    status=1
  fi
  exit "$status"
}
trap restore_release EXIT

make audio-test-dsk >"$run_dir/test-build.log" 2>&1
(
  cd "$cap32_dir"
  exec env SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE="$raw" "$cap32" --verbose \
    -O system.model=2 \
    -O system.ram_size=128 \
    -O system.printer=1 \
    -O system.limit_speed=1 \
    -O video.scr_fps=0 \
    -O sound.enabled=1 \
    -O file.printer_file="$result_file" \
    -a 'run"LOADER"' \
    "$root/banterhouse.dsk"
) >"$log" 2>&1 &
caprice_pid=$!

passed=0
for quarter_second in $(seq 1 400); do
  if test -f "$result_file" && test "$(cat "$result_file")" = 'BH_PASS'; then
    passed=1
    break
  fi
  if ! kill -0 "$caprice_pid" 2>/dev/null; then break; fi
  sleep 0.25
done
if kill -0 "$caprice_pid" 2>/dev/null; then
  kill "$caprice_pid" 2>/dev/null || true
fi
wait "$caprice_pid" 2>/dev/null || true
test "$passed" -eq 1
test -s "$raw"

ffmpeg -hide_banner -loglevel error -f s16le -ar 44100 -ac 2 -i "$raw" "$wav"
python3 - "$wav" <<'PY'
import audioop
import sys
import wave

path = sys.argv[1]
with wave.open(path, "rb") as stream:
    frames = stream.readframes(stream.getnframes())
    duration = stream.getnframes() / stream.getframerate()
    peak = audioop.max(frames, stream.getsampwidth())
    rms = audioop.rms(frames, stream.getsampwidth())
assert duration >= 65.0, duration
assert peak > 1000, peak
assert rms > 100, rms
print(f"Caprice32 audio reel: PASS ({duration:.2f}s, peak {peak}, RMS {rms})")
PY
shasum -a 256 "$wav" >"$wav.sha256"
printf 'Audio artifact: %s\n' "$wav"
