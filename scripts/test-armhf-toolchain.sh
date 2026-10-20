#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/artifacts"
mkdir -p "$OUT"

cat > "$OUT/armhf-probe.c" <<'C'
#include <stdio.h>
#include <stdint.h>
int main(void) {
    printf("ARMHF ABI probe: pointer=%zu bits=%zu\n",
           sizeof(void *) * 8, sizeof(uintptr_t) * 8);
    return sizeof(void *) == 4 ? 0 : 10;
}
C

arm-linux-gnueabihf-gcc -O2 -Wall -Wextra \
  "$OUT/armhf-probe.c" -o "$OUT/armhf-probe"
file "$OUT/armhf-probe" | tee "$OUT/armhf-file.txt"
arm-linux-gnueabihf-readelf -h "$OUT/armhf-probe" > "$OUT/armhf-elf-header.txt"
grep -q 'Class:.*ELF32' "$OUT/armhf-elf-header.txt"
grep -q 'Machine:.*ARM' "$OUT/armhf-elf-header.txt"

# Execute with the ARMHF sysroot supplied by Debian's cross toolchain.
SYSROOT="$(arm-linux-gnueabihf-gcc -print-sysroot)"
if [[ -z "$SYSROOT" || "$SYSROOT" == "/" ]]; then
  SYSROOT=/usr/arm-linux-gnueabihf
fi
qemu-arm -L "$SYSROOT" "$OUT/armhf-probe" | tee "$OUT/armhf-probe-run.txt"
grep -q 'pointer=32' "$OUT/armhf-probe-run.txt"

{
  echo "Host: $(uname -m)"
  echo "Target: arm-linux-gnueabihf (ARMv7 Linux hard-float)"
  echo "Compiler: $(arm-linux-gnueabihf-gcc --version | head -n1)"
  echo "Rust: $(rustc --version)"
  echo "Rust target installed:"
  rustup target list --installed
  echo "Host Bun: $(bun --version)"
} > "$OUT/arm32-diagnostics.txt"
cat "$OUT/arm32-diagnostics.txt"
echo "ARMHF compiler and QEMU probe passed. This validates the toolchain only, not Bun."
