# Configuração

Todas as opções ficam em `Script/backup-saves.conf`.

## Conexão com o Trimui

```bash
TRIMUI_HOST="192.168.0.20"   # IP do Trimui na rede Wi-Fi
TRIMUI_PORT="2022"            # Porta SFTP padrão do Trimui
TRIMUI_USER="trimui"          # Usuário SFTP
TRIMUI_PASS="trimui"           # Senha SFTP
```

O IP pode mudar se o roteador atribuir outro endereço. Confira em **Settings → Wi-Fi** no Trimui.

Para testar a conexão manualmente com FileZilla:

- Protocolo: SFTP
- Host: `192.168.0.20`
- Porta: `2022`
- Usuário: `trimui`
- Senha: `trimui`

## RetroArch no PC

```bash
RETROARCH_DIR="$HOME/.var/app/org.libretro.RetroArch/config/retroarch"
```

Se o RetroArch estiver instalado de outra forma, ajuste o caminho. Se deixar vazio ou comentar, o script tenta detectar automaticamente nesta ordem:

1. Caminho definido em `RETROARCH_DIR`
2. `~/.var/app/org.libretro.RetroArch/config/retroarch` (Flatpak)
3. `~/.config/retroarch` (instalação nativa)
4. `~/.retroarch` (legado)

## Pasta de backup local

```bash
# BACKUP_DIR="/home/augusto/Documentos/Trimui/Back-up"
```

Por padrão, usa `Back-up/` na raiz do projeto (um nível acima de `Script/`). Descomente e edite para usar outro caminho.

## Pasta RetroArch no Trimui

```bash
REMOTE_RETROARCH="SDCARD/RetroArch/.retroarch"
```

Caminho no cartão SD do Trimui onde o CrossMix OS guarda os dados do RetroArch. Não altere a menos que use outro firmware.

## Pastas sincronizadas

```bash
PS_SYNC_PATHS=(
  "PCSX-ReARMed"
  "PS/PCSX-ReARMed"
)
```

Lista de subpastas dentro de `saves/` que serão copiadas/sincronizadas.

### Mapear pastas com nomes diferentes

Se a estrutura no PC for diferente da do Trimui, use o formato `origem|destino`:

```bash
PS_SYNC_PATHS=(
  "PS/PCSX-ReARMed|PCSX-ReARMed"
)
```

Isso copia de `PS/PCSX-ReARMed` no Trimui para `PCSX-ReARMed` no PC.

## Segurança

O arquivo `backup-saves.conf` contém a senha do Trimui. Ele está listado no `.gitignore` para não ser commitado no git. Não compartilhe este arquivo.
