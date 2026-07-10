#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_config
setup_trimui_paths

print_sync_header \
  "Sincronização — Trimui ↔ RetroArch" \
  "nos dois sentidos (mais recente vence)"

run_trimui_sync "both" "Sincronizando saves de PS (PCSX-ReARMed)"
cleanup_duckstation "$RETROARCH_SAVES"

echo
echo "Sincronização concluída: $(date)"
echo "Saves em: $RETROARCH_SAVES"
