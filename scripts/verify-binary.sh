#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACTS="$ROOT/artifacts"

mkdir -p "$ARTIFACTS"

if [[ -z "${BUN_BINARY:-}" ]]; then
    echo "ERROR: BUN_BINARY must identify the built executable." >&2
    exit 1
fi

if [[ ! -f "$BUN_BINARY" ]]; then
    echo "ERROR: Binary not found: $BUN_BINARY" >&2
    exit 1
fi

file "$BUN_BINARY"

readelf -h "$BUN_BINARY" > "$ARTIFACTS/elf-header.txt"

readelf -h "$BUN_BINARY" | grep -q 'Class:.*ELF32' || {
    echo "ERROR: Expected a 32-bit ELF executable." >&2
    exit 1
}

readelf -h "$BUN_BINARY" | grep -q 'Machine:.*ARM' || {
    echo "ERROR: Expected an ARM executable." >&2
    exit 1
}

install -m 755 "$BUN_BINARY" "$ARTIFACTS/bun"

sha256sum "$ARTIFACTS/bun" > "$ARTIFACTS/SHA256SUMS"

echo "ARM32 ELF verification passed."
