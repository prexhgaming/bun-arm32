#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACTS="$ROOT/artifacts"
BUN_BINARY="${BUN_BINARY:-$ARTIFACTS/bun}"

[[ -f "$BUN_BINARY" ]] || { echo "ERROR: binary not found: $BUN_BINARY" >&2; exit 1; }
file "$BUN_BINARY" | tee "$ARTIFACTS/binary-file.txt"
readelf -h "$BUN_BINARY" > "$ARTIFACTS/elf-header.txt"
grep -q 'Class:.*ELF32' "$ARTIFACTS/elf-header.txt" || { echo "Not ELF32" >&2; exit 1; }
grep -q 'Machine:.*ARM' "$ARTIFACTS/elf-header.txt" || { echo "Not ARM ELF" >&2; exit 1; }
readelf -l "$BUN_BINARY" > "$ARTIFACTS/elf-program-headers.txt"
readelf -d "$BUN_BINARY" > "$ARTIFACTS/elf-dynamic.txt" 2>&1 || true
install -m 755 "$BUN_BINARY" "$ARTIFACTS/bun"
sha256sum "$ARTIFACTS/bun" > "$ARTIFACTS/SHA256SUMS"
echo "Verified ELF32 ARM executable. Runtime tests are still required."
