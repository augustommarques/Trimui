#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_config
setup_local_paths

command -v rsync >/dev/null 2>&1 || die "rsync não encontrado. Instale com: sudo apt install rsync"

if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null || true)" ]]; then
  die "Nenhum backup encontrado em $BACKUP_DIR. Rode ./backup-local.sh primeiro."
fi

print_local_header \
  "Restaurar — Back-up → RetroArch" \
  "restaurar saves do Back-up no RetroArch local" \
  "$BACKUP_DIR" \
  "$RETROARCH_SAVES"

run_local_copy "$BACKUP_DIR" "$RETROARCH_SAVES" "Restaurando saves de PS (PCSX-ReARMed)"
cleanup_duckstation "$RETROARCH_SAVES"

echo
echo "Restauração concluída: $(date)"
echo "Saves restaurados em: $RETROARCH_SAVES"
