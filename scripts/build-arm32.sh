#!/usr/bin/env bash
# Real Bun build entry point. It intentionally requires the maintained port patch;
# a compiler triple alone cannot make Bun/JavaScriptCore ARM32-compatible.
set -Eeuo pipefail
TARGET="${1:-linux-armv7}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"

if [[ "$TARGET" != "linux-armv7" ]]; then
  echo "Unsupported target '$TARGET'. This build script targets Linux ARMHF only." >&2
  exit 2
fi
[[ -d "$UPSTREAM/.git" ]] || { echo "Missing upstream source checkout" >&2; exit 1; }
[[ -f "$ROOT/patches/arm32-port.patch" ]] || {
  echo "ARM32 runtime port patch is missing: patches/arm32-port.patch" >&2
  echo "The toolchain probe is not a Bun build. JavaScriptCore and Bun build-system support must be ported first." >&2
  exit 3
}

cd "$UPSTREAM"
# Do not guess an undocumented CMake or Cargo command. Bun's supported release
# build is invoked here only after the patch has adapted the full build graph.
# The patch must provide this explicit target-aware wrapper to prevent accidentally
# producing an x86_64 binary and labelling it ARM32.
if [[ ! -x scripts/arm32/build-release.sh ]]; then
  echo "Port patch must provide executable scripts/arm32/build-release.sh" >&2
  exit 4
fi
scripts/arm32/build-release.sh "$ROOT/artifacts/bun"
[[ -f "$ROOT/artifacts/bun" ]] || { echo "Build did not produce artifacts/bun" >&2; exit 5; }
