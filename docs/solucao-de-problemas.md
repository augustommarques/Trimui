# Solução de problemas

## Não consegue conectar no Trimui

**Erro:** `Não foi possível conectar em sftp://192.168.0.20:2022`

Verifique:

1. Trimui ligado e conectado ao Wi-Fi
2. SFTP ativo em **Apps** no Trimui
3. IP correto em `backup-saves.conf` (Settings → Wi-Fi no Trimui)
4. PC e Trimui na mesma rede

Teste com FileZilla usando os mesmos dados de `backup-saves.conf`.

**Erro:** `Host key verification failed`

Na primeira conexão, o script salva a chave SSH automaticamente em `~/.ssh/known_hosts_trimui`. Se o problema persistir, apague esse arquivo e rode o script de novo.

## Save não aparece no RetroArch do PC

1. **Core errado** — use **Sony - PlayStation (PCSX ReARMed)**, não DuckStation ou Beetle PSX
2. **Nome do ROM diferente** — o save segue o nome do arquivo do jogo:
   - ROM `Megaman X4.chd` precisa do save `Megaman X4.srm`
3. **Save no formato DuckStation** — saves `.mcd` do DuckStation não funcionam com PCSX. Salve de novo no Trimui usando PCSX-ReARMed
4. **Pasta errada** — o save deve estar em `saves/PCSX-ReARMed/` no RetroArch

## Save não aparece no Trimui

1. Rode `./Script/sync-saves.sh` após jogar no PC
2. Confirme que jogou com PCSX-ReARMed no PC (não outro core)
3. Verifique se o Trimui está ligado e acessível na rede

## Script backup-local muito lento ou trava

O `backup-local.sh` **não usa rede** — copia apenas no disco local. Se estiver lento, verifique espaço em disco. Se parecer travado, pode ser muitos arquivos na primeira cópia.

## sync-saves.sh lento ou cai no meio

- Wi-Fi instável pode interromper a transferência
- Rode o script de novo — ele retoma arquivos incompletos (`--continue`) e ignora os que já estão atualizados
- Mantenha o Trimui perto do roteador durante a sincronização

## RetroArch não encontrado

**Erro:** `RetroArch não encontrado. Defina RETROARCH_DIR em backup-saves.conf`

Defina o caminho manualmente:

```bash
# Flatpak
RETROARCH_DIR="$HOME/.var/app/org.libretro.RetroArch/config/retroarch"

# Instalação nativa
RETROARCH_DIR="$HOME/.config/retroarch"
```

## Restaurar backup diz que não há arquivos

**Erro:** `Nenhum backup encontrado em ...`

Rode `./Script/backup-local.sh` primeiro para criar a cópia em `Back-up/`.

## lftp ou rsync não encontrado

```bash
sudo apt install lftp rsync
```
