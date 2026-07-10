#!/usr/bin/env bash

load_config() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  CONFIG_FILE="${SCRIPT_DIR}/backup-saves.conf"

  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
  fi

  TRIMUI_HOST="${TRIMUI_HOST:-192.168.0.20}"
  TRIMUI_PORT="${TRIMUI_PORT:-2022}"
  TRIMUI_USER="${TRIMUI_USER:-trimui}"
  TRIMUI_PASS="${TRIMUI_PASS:-trimui}"
  BACKUP_DIR="${BACKUP_DIR:-${SCRIPT_DIR}/../Back-up}"
  REMOTE_RETROARCH="${REMOTE_RETROARCH:-SDCARD/RetroArch/.retroarch}"

  if [[ -z "${PS_SYNC_PATHS:-}" ]]; then
    PS_SYNC_PATHS=(
      "PCSX-ReARMed"
      "PS/PCSX-ReARMed"
    )
  fi
}

detect_retroarch_dir() {
  local candidates=()
  [[ -n "${RETROARCH_DIR:-}" ]] && candidates+=("$RETROARCH_DIR")
  candidates+=(
    "${HOME}/.var/app/org.libretro.RetroArch/config/retroarch"
    "${XDG_CONFIG_HOME:-${HOME}/.config}/retroarch"
    "${HOME}/.retroarch"
  )

  local dir
  for dir in "${candidates[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

resolve_sync_paths() {
  local entry="$1"
  if [[ "$entry" == *"|"* ]]; then
    REMOTE_REL="${entry%%|*}"
    LOCAL_REL="${entry#*|}"
  else
    REMOTE_REL="$entry"
    LOCAL_REL="$entry"
  fi
}

die() {
  echo "Erro: $*" >&2
  exit 1
}

setup_local_paths() {
  RETROARCH_DIR="$(detect_retroarch_dir)" || die "RetroArch não encontrado. Defina RETROARCH_DIR em backup-saves.conf"
  BACKUP_DIR="$(cd "$BACKUP_DIR" && pwd)"
  RETROARCH_SAVES="${RETROARCH_DIR}/saves"
  mkdir -p "$BACKUP_DIR" "$RETROARCH_SAVES"
}

setup_trimui_paths() {
  command -v lftp >/dev/null 2>&1 || die "lftp não encontrado. Instale com: sudo apt install lftp"
  [[ -n "$TRIMUI_HOST" ]] || die "TRIMUI_HOST não definido"
  [[ -n "$TRIMUI_USER" ]] || die "TRIMUI_USER não definido"
  [[ -n "$TRIMUI_PASS" ]] || die "TRIMUI_PASS não definido (use backup-saves.conf)"
  setup_local_paths
  REMOTE_SAVES="${REMOTE_RETROARCH}/saves"
  mkdir -p "${HOME}/.ssh"
}

print_local_header() {
  local title="$1"
  local mode="$2"
  local from="$3"
  local to="$4"
  echo "$title — $(date)"
  echo "Origem:  $from"
  echo "Destino: $to"
  echo "Modo:    $mode"
  echo "Pastas PS:"
  for entry in "${PS_SYNC_PATHS[@]}"; do
    resolve_sync_paths "$entry"
    echo "  ${from}/${LOCAL_REL} → ${to}/${LOCAL_REL}"
  done
  echo
}

print_sync_header() {
  local title="$1"
  local mode="$2"
  echo "$title — $(date)"
  echo "RetroArch: $RETROARCH_SAVES"
  echo "Trimui:    sftp://${TRIMUI_HOST}:${TRIMUI_PORT}/${REMOTE_SAVES}"
  echo "Modo:      $mode"
  echo "Pastas PS:"
  for entry in "${PS_SYNC_PATHS[@]}"; do
    resolve_sync_paths "$entry"
    echo "  ${REMOTE_SAVES}/${REMOTE_REL} ↔ ${RETROARCH_SAVES}/${LOCAL_REL}"
  done
  echo
}

run_local_copy() {
  local src_base="$1"
  local dest_base="$2"
  local label="$3"

  echo "$label..."
  for entry in "${PS_SYNC_PATHS[@]}"; do
    resolve_sync_paths "$entry"
    local src="${src_base}/${LOCAL_REL}"
    local dest="${dest_base}/${LOCAL_REL}"

    if [[ ! -d "$src" ]]; then
      echo "  Ignorado: $src (não existe)"
      continue
    fi

    mkdir -p "$dest"
    rsync -av --update \
      --include='*/' \
      --include='*.srm' \
      --include='pcsx-card*.mcd' \
      --exclude='*' \
      "${src}/" "${dest}/"
    echo "  OK: ${LOCAL_REL}"
  done
}

run_trimui_sync() {
  local sync_mode="$1"
  local action_label="$2"

  KNOWN_HOSTS="${HOME}/.ssh/known_hosts_trimui"
  LFTP_BATCH="$(mktemp)"
  trap 'rm -f "$LFTP_BATCH"' RETURN

  {
    echo "set net:timeout 30"
    echo "set net:max-retries 5"
    echo "set net:reconnect-interval-base 5"
    echo "set sftp:connect-program \"ssh -a -x -p ${TRIMUI_PORT} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${KNOWN_HOSTS}\""
    echo "open -u ${TRIMUI_USER},${TRIMUI_PASS} sftp://${TRIMUI_HOST}:${TRIMUI_PORT}"
    echo "cls"

    for entry in "${PS_SYNC_PATHS[@]}"; do
      resolve_sync_paths "$entry"
      remote_path="${REMOTE_SAVES}/${REMOTE_REL}"
      local_path="${RETROARCH_SAVES}/${LOCAL_REL}"
      mkdir -p "$local_path"

      if [[ "$sync_mode" == "both" || "$sync_mode" == "from-trimui" ]]; then
        echo "mirror --verbose --only-newer --parallel=1 --continue --exclude-glob '*' --include-glob '*.srm' --include-glob 'pcsx-card*.mcd' \"${remote_path}\" \"${local_path}\""
      fi

      if [[ "$sync_mode" == "both" || "$sync_mode" == "to-trimui" ]]; then
        echo "mirror --verbose --only-newer --parallel=1 --continue -R --exclude-glob '*' --include-glob '*.srm' --include-glob 'pcsx-card*.mcd' \"${local_path}\" \"${remote_path}\""
      fi
    done

    echo "bye"
  } > "$LFTP_BATCH"

  echo "$action_label..."
  if ! lftp -f "$LFTP_BATCH"; then
    die "Falha durante a sincronização"
  fi
}

cleanup_duckstation() {
  local base="$1"
  if [[ -d "${base}/DuckStation" ]]; then
    rm -rf "${base}/DuckStation"
    echo "Removido: ${base}/DuckStation"
  fi
  if [[ -d "${base}/PS/DuckStation" ]]; then
    rm -rf "${base}/PS/DuckStation"
    echo "Removido: ${base}/PS/DuckStation"
  fi
}
