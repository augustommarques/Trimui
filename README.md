# Trimui — Backup e Sincronização de Saves PS

Scripts para gerenciar saves de PlayStation (PCSX-ReARMed) entre o **RetroArch local**, a pasta **Back-up** e o **Trimui Smart Pro**.

📖 [Documentação completa](docs/README.md) — como funciona, configuração e solução de problemas.

## Requisitos

- Linux Mint (ou outra distro com bash)
- `rsync` — backup e restauração local
- `lftp` — sincronização com o Trimui via SFTP
- Trimui ligado e na mesma rede Wi-Fi (apenas para `sync-saves.sh`)

```bash
sudo apt install rsync lftp
```

## Estrutura

```
Trimui/
├── Back-up/                  # cópia local dos saves
│   ├── PCSX-ReARMed/
│   └── PS/PCSX-ReARMed/
└── Script/
    ├── backup-saves.conf     # configuração (senha, IP, pastas)
    ├── backup-local.sh       # RetroArch → Back-up
    ├── restore-backup.sh     # Back-up → RetroArch
    └── sync-saves.sh         # Trimui ↔ RetroArch
```

## Configuração

Edite `Script/backup-saves.conf` com os dados do seu Trimui:

```bash
TRIMUI_HOST="192.168.0.20"
TRIMUI_PORT="2022"
TRIMUI_USER="trimui"
TRIMUI_PASS="trimui"
```

No Trimui, ative o SFTP em **Apps** e confira o IP em **Settings → Wi-Fi**.

## Comandos

Entre na pasta do projeto:

```bash
cd ~/Documentos/Trimui
```

### 1. Backup local (RetroArch → Back-up)

Copia os saves do RetroArch do PC para a pasta `Back-up/`. Rápido, sem rede.

```bash
./Script/backup-local.sh
```

### 2. Restaurar backup (Back-up → RetroArch)

Restaura os saves da pasta `Back-up/` no RetroArch do PC.

```bash
./Script/restore-backup.sh
```

### 3. Sincronizar com o Trimui (Trimui ↔ RetroArch)

Sincroniza saves entre o Trimui e o RetroArch local. Só atualiza arquivos mais recentes.

```bash
./Script/sync-saves.sh
```

## Fluxo recomendado

**Antes de jogar no PC** — puxar saves do Trimui:

```bash
./Script/sync-saves.sh
```

**Depois de jogar no PC** — enviar saves para o Trimui:

```bash
./Script/sync-saves.sh
```

**Fazer cópia de segurança no PC** (sem depender do Trimui):

```bash
./Script/backup-local.sh
```

**Recuperar saves no RetroArch** após perda ou reinstalação:

```bash
./Script/restore-backup.sh
```

## O que é sincronizado

- Apenas saves de **PlayStation** (PCSX-ReARMed)
- Arquivos `.srm` e memory cards `pcsx-card*.mcd`
- **DuckStation** é ignorado (incompatível com o Trimui)

## Pastas

| Local | Caminho |
|-------|---------|
| Back-up | `~/Documentos/Trimui/Back-up/` |
| RetroArch (Flatpak) | `~/.var/app/org.libretro.RetroArch/config/retroarch/saves/` |
| Trimui (remoto) | `SDCARD/RetroArch/.retroarch/saves/` |

## Dicas

- Use o core **Sony - PlayStation (PCSX ReARMed)** no RetroArch do PC
- O nome do save deve coincidir com o nome do ROM (ex.: `Megaman X4.chd` → `Megaman X4.srm`)
- O arquivo `backup-saves.conf` contém senha — não compartilhe nem commite no git
