#!/usr/bin/env bash
# Compile + link the throwaway timelimit_shot harness against the ALREADY
# BUILT ci-test artifacts (libog_game_test.a is the -DTESTING engine, and
# tests/integration/integration_main.cpp.o is the gtest main the integration
# binaries use). No repo file is modified; nothing is added to CMake.
#
# Usage: nix develop -c build/media/pr-match-knobs/repro/build.sh
set -euo pipefail
REPO=/home/yans/code/openglad
B=$REPO/build/ci-test
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CXX=$(python3 - <<'EOF'
import json
cc=json.load(open('/home/yans/code/openglad/build/ci-test/compile_commands.json'))
for e in cc:
    if e['file'].endswith('tests/integration/test_game_loop.cpp'):
        print(e['command'].split(' ',1)[0]); break
EOF
)

"$CXX" -DGTEST_LINKED_AS_SHARED_LIBRARY=1 -DIXWEBSOCKET_USE_OPEN_SSL \
  -DIXWEBSOCKET_USE_TLS -DOPENGLAD_VALIDATE_SERIALIZATION=0 \
  -DPHYSFS_NO_CDROM_SUPPORT=1 -DPHYSFS_SUPPORTS_ZIP=1 -DTESTING \
  -DUSE_BMP_SCREENSHOT=1 -D_USE_MATH_DEFINES \
  -I"$B" -I"$REPO/include" -I"$REPO/tests" \
  -isystem "$B/_deps/lua-src" \
  -g -std=c++20 -Wall -Wextra -Werror -c "$HERE/timelimit_shot.cpp" \
  -o "$HERE/timelimit_shot.o"

cd "$B"
"$CXX" -g \
  CMakeFiles/og_test_game_core.dir/tests/integration/integration_main.cpp.o \
  "$HERE/timelimit_shot.o" \
  -o "$HERE/og_timelimit_shot" \
  libog_game_test.a \
  /nix/store/rsmk7psm9kph06fdjay1g97syi8g6g7c-gtest-1.17.0/lib/libgtest.so.1.17.0 \
  /nix/store/phzxi1l7gcm9slvikj9w4yswd89hi14x-libyaml-0.2.5/lib/libyaml.so \
  /nix/store/61a1nwx3w6rqyaisj5rn1sal1981apm7-zlib-1.3.2/lib/libz.so \
  /nix/store/2py465bh36f0rx2pqcwkmsjfldzxwmin-physfs-3.2.0/lib/libphysfs.so.3.2.0 \
  /nix/store/h05vjlnh3zmbln8b6zm0y8a5d4aspirv-libzip-1.11.4/lib/libzip.so \
  /nix/store/8937qcdavd54lr56mmx8b2sf5gs2v9pw-lodepng-2026-06-26-unstable/lib/liblodepng.a \
  libog_lua.a \
  /nix/store/i4hxv76a0kra72galsjibbdkyjdkad63-sdl3-3.4.8-lib/lib/libSDL3.so.0.4.8 \
  -lm -lpthread \
  /nix/store/9xsh7c4ydfl1zpmzk7v7wq7p8i50dgm5-ixwebsocket-11.4.6-unstable-2026-06-26/lib/libixwebsocket.a \
  /nix/store/y18pnbvfarnilsmgayswvi1khaw9wbsc-openssl-3.6.2/lib/libssl.so \
  /nix/store/y18pnbvfarnilsmgayswvi1khaw9wbsc-openssl-3.6.2/lib/libcrypto.so
# The binary resolves builtin/ + campaign assets relative to its own
# directory, so it has to live beside the other ci-test binaries.
cp "$HERE/og_timelimit_shot" "$B/og_timelimit_shot"
echo "built $B/og_timelimit_shot"
