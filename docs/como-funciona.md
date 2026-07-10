# Como funciona

Este projeto gerencia **saves de PlayStation** entre três locais:

1. **RetroArch** instalado no computador (Linux Mint, Flatpak)
2. **Back-up** — pasta local de cópia de segurança no projeto
3. **Trimui Smart Pro** — console acessado via SFTP pela rede Wi-Fi

## Visão geral

```
                    sync-saves.sh
              (SFTP — só arquivos mais recentes)
         ┌──────────────────────────────────────┐
         │                                      │
         ▼                                      ▼
┌─────────────────┐                  ┌─────────────────────┐
│  RetroArch (PC) │                  │  Trimui (SDCARD)    │
│  saves/         │                  │  RetroArch/.retroarch/saves/ │
└────────┬────────┘                  └─────────────────────┘
         │
         │  backup-local.sh  (rsync — PC → Back-up)
         │  restore-backup.sh (rsync — Back-up → PC)
         ▼
┌─────────────────┐
│  Back-up/       │
│  (cópia local)  │
└─────────────────┘
```

Os três scripts têm funções distintas e **não fazem a mesma coisa**:

| Script | Origem | Destino | Rede | Ferramenta |
|--------|--------|---------|------|------------|
| `backup-local.sh` | RetroArch (PC) | `Back-up/` | Não | `rsync` |
| `restore-backup.sh` | `Back-up/` | RetroArch (PC) | Não | `rsync` |
| `sync-saves.sh` | Trimui ↔ RetroArch | Ambos | Sim (SFTP) | `lftp` |

## O que são os saves

No RetroArch com o core **PCSX-ReARMed**, os saves de PlayStation ficam em subpastas dentro de `saves/`:

```
saves/
├── PCSX-ReARMed/          # saves gerais do core
│   ├── Megaman X4.srm
│   ├── Crash Bandicoot.srm
│   └── pcsx-card2.mcd     # memory card compartilhado
└── PS/
    └── PCSX-ReARMed/      # saves organizados por pasta de conteúdo
        └── Ace Combat 2 (USA).srm
```

### Tipos de arquivo sincronizados

| Extensão | O que é |
|----------|---------|
| `.srm` | Save in-game ou memory card por jogo |
| `pcsx-card*.mcd` | Memory card compartilhado do PCSX-ReARMed |

### O que NÃO é sincronizado

- Saves de outros consoles (SNES, GBA, N64, etc.)
- Save states (`.state`) — apenas saves in-game
- Saves do **DuckStation** — formato incompatível com o Trimui; pastas `DuckStation/` são removidas automaticamente

## Script: backup-local.sh

**Função:** criar cópia de segurança dos saves do RetroArch na pasta `Back-up/`.

**Como funciona:**

1. Detecta automaticamente onde o RetroArch guarda os saves no PC
2. Copia apenas as pastas listadas em `PS_SYNC_PATHS` (PCSX-ReARMed)
3. Usa `rsync --update` — só copia arquivos **mais recentes** que já existem no destino, ou arquivos novos
4. Não precisa do Trimui ligado

**Quando usar:** antes de reinstalar o RetroArch, formatar o PC, ou como rotina de segurança.

## Script: restore-backup.sh

**Função:** restaurar saves da pasta `Back-up/` de volta para o RetroArch do PC.

**Como funciona:**

1. Verifica se existe conteúdo em `Back-up/`
2. Copia os arquivos de `Back-up/` para a pasta de saves do RetroArch
3. Usa `rsync --update` — arquivos mais recentes no Back-up sobrescrevem os do RetroArch
4. Não precisa do Trimui ligado

**Quando usar:** após reinstalar o RetroArch, ou para recuperar um save que foi perdido no PC.

## Script: sync-saves.sh

**Função:** sincronizar saves entre o Trimui e o RetroArch do PC pela rede.

**Como funciona:**

1. Conecta ao Trimui via SFTP (`lftp` na porta 2022)
2. Compara data de modificação dos arquivos nos dois lados
3. Baixa do Trimui arquivos mais recentes que os do PC
4. Envia para o Trimui arquivos mais recentes que os do console
5. Na primeira conexão, salva a chave SSH em `~/.ssh/known_hosts_trimui`

**Regra:** o arquivo **mais recente sempre vence** — nunca sobrescreve um save novo com um antigo.

**Quando usar:**

- Antes de jogar no PC → puxa o progresso do Trimui
- Depois de jogar no PC → envia o progresso para o Trimui

**Requisitos:**

- Trimui ligado e na mesma rede Wi-Fi
- SFTP ativo no Trimui (Apps → SFTP)
- IP correto em `backup-saves.conf`

## Arquivo common.sh

Contém a lógica compartilhada usada pelos três scripts:

- `load_config` — carrega `backup-saves.conf`
- `detect_retroarch_dir` — encontra o RetroArch (Flatpak, nativo ou `~/.retroarch`)
- `run_local_copy` — cópia local com `rsync`
- `run_trimui_sync` — sincronização remota com `lftp`
- `cleanup_duckstation` — remove pastas DuckStation após operação

## Compatibilidade de saves entre PC e Trimui

Para o save funcionar nos dois dispositivos:

1. **Mesmo core:** use **PCSX-ReARMed** no PC e no Trimui
2. **Mesmo nome de ROM:** o save segue o nome do arquivo do jogo
   - ROM: `Megaman X4.chd` → Save: `Megaman X4.srm`
3. **Não use DuckStation** no Trimui — os saves ficam em formato diferente e não funcionam com PCSX

## Exemplo prático

Você jogou **Crash Bandicoot** no Trimui e quer continuar no PC:

```bash
# 1. Sincronizar — baixa o save do Trimui para o RetroArch do PC
./Script/sync-saves.sh

# 2. Abrir o RetroArch no PC com o core PCSX ReARMed
# 3. Jogar Crash Bandicoot — o save deve carregar automaticamente

# 4. Depois de jogar, sincronizar de volta
./Script/sync-saves.sh
```

Para guardar uma cópia extra sem depender do Trimui:

```bash
./Script/backup-local.sh
```
