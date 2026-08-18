#!/usr/bin/env bash
set -euo pipefail
DEST="${1:-Ativos/Marca}"
mkdir -p "$DEST"
cat > /tmp/icon.b64 <<'EOF_ICON'
PLACEHOLDER
EOF_ICON
