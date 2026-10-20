#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
OUT="$ROOT/artifacts"
mkdir -p "$OUT"

[[ -d "$UPSTREAM/.git" ]] || { echo "upstream checkout missing" >&2; exit 1; }
cd "$UPSTREAM"

{
  echo "# Bun ARM32 source compatibility audit"
  echo
  echo "Revision: $(git rev-parse HEAD)"
  echo "Commit: $(git log -1 --oneline)"
  echo "Host: $(uname -m)"
  echo
  echo "## package.json build scripts"
  node -e 'const p=require("./package.json"); console.log(JSON.stringify({version:p.version,packageManager:p.packageManager,scripts:p.scripts},null,2))'
  echo
  echo "## Rust target configuration"
  grep -RInE 'target_arch|target_os|aarch64|arm64|armv7|x86_64|x86' \
    --include='*.rs' --include='Cargo.toml' --include='config.toml' \
    --exclude-dir=.git src crates scripts 2>/dev/null | head -n 500 || true
  echo
  echo "## Build/dependency target configuration"
  grep -RInE 'aarch64|arm64|armv7|armhf|x86_64|linux-arm|TARGET_ARCH|CMAKE_SYSTEM_PROCESSOR' \
    --include='*.ts' --include='*.js' --include='*.json' \
    --include='*.toml' --include='*.cmake' --include='*.py' \
    --exclude-dir=.git scripts src packages 2>/dev/null | head -n 700 || true
  echo
  echo "## Pinned WebKit revision/configuration"
  grep -nE 'WEBKIT_VERSION|aarch64|arm64|armv7|x86_64' scripts/build/deps/webkit.ts 2>/dev/null || true
  echo
  echo "## Conclusion"
  echo "The official documented Bun binary targets do not include Linux ARM32. This report is evidence for porting work, not proof that ARM32 is supported."
} > "$OUT/upstream-arm32-audit.md"

cat "$OUT/upstream-arm32-audit.md"
