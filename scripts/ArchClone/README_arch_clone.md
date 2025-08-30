# arch_clone – Guida rapida (EndeavourOS/Arch) – v1.6.1

Lo script `arch_clone.sh` clona il setup del **T480s** sullo **X220**:
pacchetti (`pacman` + AUR), Flatpak, dotfiles, temi/icone/font, **GNOME** (impostazioni, estensioni, wallpaper), servizi **systemd** (system + user).
Supporta **`--dry-run`** (simulazione) e **`--tmpdir`** (cartella temporanea personalizzata).

---

## Novità v1.6.1
- `--tmpdir <path>` per scegliere dove creare i file temporanei (utile se `/tmp` è piccolo).
- Rilevamento/abilitazione **systemd user** robusto anche **senza user-bus**:
  - se il bus esiste usa `systemctl --user`;
  - altrimenti fa fallback leggendo i symlink in `~/.config/systemd/user/*.wants`;
  - in import, abilita **linger** e dà le istruzioni per rendere effettivi i servizi al login.
- Esclusioni rsync ampliate per evitare directory pesanti/volatili (Steam, `.var`, cache browser, ecc.).

---

## Cosa viene clonato

- **Pacchetti repo** espliciti (`pacman`)
- **Pacchetti AUR** (via `yay`)
- **Flatpak** (app + remoto Flathub)
- **Configurazioni utente** (`~/.config`, dotfiles, `~/.local/share`)
- **Temi, icone, font utente** (`~/.themes`, `~/.icons`, `~/.local/share/fonts`)
- **GNOME**
  - impostazioni con `dconf`
  - estensioni (cartella + stato abilitato)
  - **wallpaper** correnti (file copiati e reimpostati)
- **Servizi systemd** abilitati (system + user)

> Non modifica partizioni/bootloader e non copia file *manuali* in `/usr/share/*`.
> Per sicurezza non copia `~/.ssh` e `~/.gnupg`.

---

## Prerequisiti

- Distro: **EndeavourOS / Arch**
- Strumenti: `bash`, `sudo`, `pacman`, `rsync`, `tar`, `awk`
- Sorgente (consigliato se usi GNOME): `flatpak`, `gnome-extensions`, `dconf`, `gsettings`
- **Spazio temporaneo**: nel TMPDIR scelto tieni **≥ 2×** la dimensione dei dati da clonare.

Stima rapida:
```bash
du -sh ~/.config ~/.local/share ~/.themes ~/.icons ~/.local/share/fonts
```

---

## Installazione dello script

```bash
nano ~/arch_clone.sh   # incolla il contenuto della versione v1.6.1
chmod +x ~/arch_clone.sh
```

---

## Opzioni chiave

- **`--dry-run`**: mostra cosa farebbe senza cambiare nulla.
- **`--tmpdir <path>`**: usa un’area temporanea alternativa (es. su un disco capiente).

Puoi anche usare la variabile d’ambiente `TMPDIR=/percorso`.

---

## Modalità DRY-RUN (simulazione)

- **Sorgente (T480s)** – export simulato:
```bash
bash ~/arch_clone.sh --dry-run export ~/t480s_clone.tzst
```

- **Destinazione (X220)** – import simulato:
```bash
bash ~/arch_clone.sh --dry-run import ~/t480s_clone.tzst
```

- Con tmpdir personalizzato:
```bash
bash ~/arch_clone.sh --dry-run --tmpdir ~/clone-tmp export ~/t480s_clone.tzst
```

---

## Procedura di EXPORT (T480s)

```bash
# se /tmp è piccolo:
mkdir -p ~/clone-tmp
bash ~/arch_clone.sh --tmpdir ~/clone-tmp export ~/t480s_clone.tzst
# altrimenti:
bash ~/arch_clone.sh export ~/t480s_clone.tzst
```

Trasferisci l’archivio sullo X220, ad es.:
```bash
scp ~/t480s_clone.tzst user@IP_X220:/home/user/
```

---

## Procedura di IMPORT (X220)

```bash
# (opzionale) simulazione:
bash ~/arch_clone.sh --dry-run import ~/t480s_clone.tzst

# import reale:
bash ~/arch_clone.sh import ~/t480s_clone.tzst
# se /tmp è piccolo:
bash ~/arch_clone.sh --tmpdir ~/clone-tmp import ~/t480s_clone.tzst
```

Al termine: **riavvia**
```bash
sudo reboot
```

---

## Verifica post-import

Pacchetti:
```bash
pacman -Q | wc -l
yay -Qm | wc -l
flatpak list
```

GNOME:
```bash
gnome-extensions list --enabled
# controlla tema, icone, layout, wallpaper
```

Servizi:
```bash
systemctl list-unit-files --state=enabled --type=service
systemctl --user list-unit-files --state=enabled --type=service
```

---

## Troubleshooting

### “No space left on device” / `rsync Broken pipe`
- Usa un tmpdir capiente:
```bash
mkdir -p ~/clone-tmp
bash ~/arch_clone.sh --tmpdir ~/clone-tmp export ~/t480s_clone.tzst
```
- Le esclusioni predefinite saltano Steam, `.var`, cache. Aggiungine altre se necessario.

### “Failed to connect to user scope bus … XDG_RUNTIME_DIR not defined”
- Lancia lo script **come utente** in sessione (non come root) oppure esporta:
```bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
```
- Con v1.6.1 lo script gestisce il caso automaticamente: se non trova il bus,
  fa fallback sui symlink in `~/.config/systemd/user/*.wants`.

### Servizi utente non partono dopo l’import
- Con v1.6.1 in assenza di bus, lo script abilita **linger**:
```bash
loginctl enable-linger "$USER"
```
- Dopo aver fatto login grafico:
```bash
systemctl --user daemon-reload
systemctl --user list-unit-files --state=enabled --type=service
```

### Estensioni GNOME non compatibili
- Alcune estensioni possono non essere compatibili tra versioni GNOME. Aggiornale o disattivale:
```bash
gnome-extensions list
gnome-extensions disable <uuid>
```

---

## Esempi rapidi

Export (tmpdir personalizzato):
```bash
bash ~/arch_clone.sh --tmpdir ~/clone-tmp export ~/t480s_clone.tzst
```

Import simulato:
```bash
bash ~/arch_clone.sh --dry-run import ~/t480s_clone.tzst
```

Import reale:
```bash
bash ~/arch_clone.sh import ~/t480s_clone.tzst
```

---

## FAQ

**È sicuro ripetere l’import?**  
Sì: pacchetti con `--needed`, file con `--ignore-existing`.

**Posso includere chiavi SSH/GPG?**  
Sconsigliato. Se necessario, aggiungi `~/.ssh` e `~/.gnupg` agli INCLUDE e proteggi l’archivio.

**Voglio includere anche `/usr/share/themes` e `/usr/share/icons` messi a mano.**  
Non incluso di default: meglio reinstallare via pacchetto. Se indispensabile, valuta un flag dedicato e attenzione ai permessi.

---

**Suggerimento:** conserva `t480s_clone.tzst` come snapshot del setup per futuri ripristini/repliche.
