#!/usr/bin/env bash

set -Eeuo pipefail

TARGET="${1:-linux-armv7}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
ARTIFACTS="$ROOT/artifacts"

mkdir -p "$ARTIFACTS"

if [[ ! -d "$UPSTREAM/.git" ]]; then
    echo "ERROR: Bun upstream source was not checked out." >&2
    exit 1
fi

case "$TARGET" in
    linux-armv7)
        echo "Target: Linux ARMv7 / ARM32"
        echo "ABI: Linux ARMHF must be configured explicitly."
        ;;

    android-armv7)
        echo "Target: Android ARMv7 / armeabi-v7a"
        echo "An Android NDK toolchain must be configured."
        ;;

    *)
        echo "ERROR: Unsupported target: $TARGET" >&2
        exit 2
        ;;
esac

echo
echo "Checking for the actual Bun build entry points..."

cd "$UPSTREAM"

for candidate in build.zig Makefile package.json; do
    if [[ -f "$candidate" ]]; then
        echo "Found: $candidate"
    fi
done

echo
echo "Build configuration inspection:"
git log -1 --oneline

if [[ -f build.zig ]]; then
    sed -n '1,200p' build.zig
fi

cat <<'EOF'

STOPPED: ARM32 compilation is not implemented yet.

Before this script can produce Bun, the port must implement and
validate the target configuration, compatible JavaScriptCore,
native dependencies, and the actual upstream build invocation.

No binary has been produced.
EOF

exit 1
