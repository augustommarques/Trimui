#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_config
setup_local_paths

command -v rsync >/dev/null 2>&1 || die "rsync não encontrado. Instale com: sudo apt install rsync"

print_local_header \
  "Backup local — RetroArch → Back-up" \
  "copiar saves do RetroArch para Back-up" \
  "$RETROARCH_SAVES" \
  "$BACKUP_DIR"

run_local_copy "$RETROARCH_SAVES" "$BACKUP_DIR" "Copiando saves de PS (PCSX-ReARMed)"
cleanup_duckstation "$BACKUP_DIR"

echo
echo "Backup concluído: $(date)"
echo "Saves em: $BACKUP_DIR"
