#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUN="${1:-$ROOT/artifacts/bun}"
[[ -x "$BUN" ]] || { echo "Missing executable: $BUN" >&2; exit 1; }

# Run on the x86_64 GitHub host through QEMU and the ARMHF sysroot.
SYSROOT="$(arm-linux-gnueabihf-gcc -print-sysroot)"
if [[ -z "$SYSROOT" || "$SYSROOT" == "/" ]]; then SYSROOT=/usr/arm-linux-gnueabihf; fi
qemu-arm -L "$SYSROOT" "$BUN" --version
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/smoke.js" <<'JS'
console.log("Bun ARM32 smoke test")
console.log("arch=" + process.arch)
console.log("platform=" + process.platform)
JS
qemu-arm -L "$SYSROOT" "$BUN" "$TMP/smoke.js" | tee "$TMP/output.txt"
grep -q 'Bun ARM32 smoke test' "$TMP/output.txt"
