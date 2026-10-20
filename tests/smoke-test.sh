#!/usr/bin/env bash

set -Eeuo pipefail

BUN="${1:-./artifacts/bun}"

if [[ ! -x "$BUN" ]]; then
    echo "ERROR: Bun executable is missing or not executable." >&2
    exit 1
fi

"$BUN" --version

TMPDIR_TEST="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_TEST"' EXIT

cat > "$TMPDIR_TEST/test.js" <<'EOF'
console.log("ARM32 runtime test passed");
console.log("Architecture:", process.arch);
console.log("Platform:", process.platform);
EOF

"$BUN" "$TMPDIR_TEST/test.js"
