#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
test_dir=$(mktemp -d /tmp/banterhouse-host-tests.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT

cc -std=c99 -Wall -Wextra -Werror -DBH_QA_STATE_HASH \
  -I"$root/src" \
  "$root/tests/host/test_game_state.c" \
  "$root/src/game_state.c" \
  "$root/src/difficulty.c" \
  "$root/src/world_data.c" \
  -o "$test_dir/test_game_state"

"$test_dir/test_game_state"

cc -std=c99 -Wall -Wextra -Werror \
  -I"$root/src" \
  "$root/tests/host/test_hud_model.c" \
  "$root/src/hud_model.c" \
  -o "$test_dir/test_hud_model"

"$test_dir/test_hud_model"

cc -std=c99 -Wall -Wextra -Werror \
  -I"$root/src" \
  "$root/tests/host/test_resource_manager.c" \
  "$root/src/resource_manager.c" \
  -o "$test_dir/test_resource_manager"

"$test_dir/test_resource_manager"
