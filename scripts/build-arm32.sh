#!/usr/bin/env bash

set -Eeuo pipefail

TARGET="${1:-linux-armv7}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
ARTIFACTS="$ROOT/artifacts"

mkdir -p "$ARTIFACTS"

if [[ ! -d "$UPSTREAM/.git" ]]; then
    echo "::error::Bun source checkout not found."
    exit 1
fi

case "$TARGET" in
    linux-armv7)
        TARGET_TRIPLE="arm-linux-gnueabihf"
        ;;
    android-armv7)
        TARGET_TRIPLE="armv7a-linux-androideabi"
        ;;
    *)
        echo "::error::Unsupported target: $TARGET"
        exit 2
        ;;
esac

echo "Target: $TARGET"
echo "Target triple: $TARGET_TRIPLE"

cd "$UPSTREAM"

echo
echo "=== Bun source revision ==="
git log -1 --oneline

echo
echo "=== Repository structure ==="
find . -maxdepth 3 \
    \( -name build.zig -o -name CMakeLists.txt \
       -o -name package.json -o -name Makefile \
       -o -name '*.zig' \) \
    -not -path './.git/*' \
    | head -n 150

echo
echo "=== Bun build scripts ==="
node -e '
const p = require("./package.json");
console.log(JSON.stringify({
  name: p.name,
  version: p.version,
  packageManager: p.packageManager,
  scripts: p.scripts
}, null, 2));
'

echo
echo "=== Architecture references ==="

grep -RInE \
    'aarch64|arm64|armv7|armhf|x86_64|linux-arm' \
    --include='*.zig' \
    --include='*.json' \
    --include='*.toml' \
    --include='*.sh' \
    --exclude-dir=.git \
    . 2>/dev/null \
    | head -n 250 || true

echo
echo "=== Available compiler tools ==="

for tool in zig clang gcc cmake ninja python3 node npm; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '%-10s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '%-10s unavailable\n' "$tool"
    fi
done

echo
echo "=== Available ARM cross-compilers ==="

for tool in \
    arm-linux-gnueabihf-gcc \
    arm-linux-gnueabihf-g++ \
    arm-linux-gnueabihf-ld \
    arm-linux-gnueabihf-as; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '%s: %s\n' "$tool" "$(command -v "$tool")"
    fi
done

echo
echo "=== ELF and platform information ==="

uname -a
getconf LONG_BIT || true
node -p '"Node architecture: " + process.arch'

echo
echo "=== Save diagnostic report ==="

{
    echo "Target: $TARGET"
    echo "Target triple: $TARGET_TRIPLE"
    git log -1 --oneline
    uname -a
    getconf LONG_BIT || true
    node --version
    npm --version
} > "$ARTIFACTS/arm32-diagnostics.txt"

echo
echo "Diagnostics completed."
echo "This step does not claim to have built Bun."
echo "Report: artifacts/arm32-diagnostics.txt"