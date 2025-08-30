# Demon Slayer Rice – GNOME + Pop Shell (EndeavourOS)

Questo pacchetto contiene:
- `setup-demonslayer-rice.sh` → script principale per applicare il rice  
- `DemonSlayer-AcquaRosa.json` → preset Gradience (accenti blu/rosa)  
- `README.md` → istruzioni e spiegazioni  

---

## 🎨 Palette (Gradience)

Preset **Demon Slayer – Acqua & Rosa**:

- Background: `#1E1E2E`  
- Foreground: `#CDD6F4`  
- Accent (Acqua): `#1E90FF`  
- Destructive (Rosa): `#FF4DA6`  
- Headerbar bg: `#1E1E2E`  
- Headerbar fg: `#CDD6F4`  

---

## 🖼️ Wallpaper consigliato

Tanjiro & Nezuko (4K) da posizionare in:

```
~/Pictures/Wallpapers/
```

Impostalo manualmente dalle impostazioni GNOME.

---

## ⚙️ Cosa fa lo script

1. **Pacchetti base**  
   Installa `zenity`, `gnome-tweaks`, `gnome-shell-extensions`, `papirus-icon-theme`, `gnome-icon-theme`.  
   Se manca `yay`, lo installa come AUR helper.  

2. **Pop Shell**  
   Installa `gnome-shell-extension-pop-shell-git` da AUR.  
   Configura: `tile-by-default=true`, `gap-inner=4`, `gap-outer=2`, `active-hint=true`.  

3. **GTK/Shell Theme**  
   Imposta **Orchis-Dark** come tema GTK e GNOME Shell.  

4. **Icone**  
   - Fallback: **Papirus-Dark**.  
   - Prova ad installare **Catppuccin Mocha** (`catppuccin-icon-theme-git`, `catppuccin-icons-git`).  
   - Se trova una variante Mocha, la applica.  

5. **Cursori**  
   Installa `catppuccin-cursors-mocha`.  
   Fallback: `Adwaita`.  

6. **Papirus Folders**  
   Se presente `papirus-folders`, applica un profilo Mocha.  

7. **Gradience**  
   Copia `DemonSlayer-AcquaRosa.json` in `~/.config/presets/`.  
   Importa manualmente dalla GUI di Gradience (se la CLI non funziona).  

8. **Report finale**  
   Mostra:  
   - Tema GTK attivo  
   - Tema icone attivo  
   - Tema cursori attivo  
   - Stato Pop Shell (installato/abilitato, gaps correnti)  
   - Pacchetti installati  
   - Icone Catppuccin presenti in `/usr/share/icons`  

---

## 🚀 Modalità dello script

### Setup completo
```bash
./setup-demonslayer-rice.sh
```

### Reset sicuro
```bash
./setup-demonslayer-rice.sh --reset
```
Ripristina:
- Papirus-Dark (icone)  
- Adwaita (cursori)  
- Orchis-Dark (GTK)  

### Status report
```bash
./setup-demonslayer-rice.sh --status
```
Mostra temi attivi e pacchetti installati.  

### Autopilot
```bash
./setup-demonslayer-rice.sh --autopilot
```
Installazione automatica senza domande.  

---

## 📦 Requisiti

- EndeavourOS / Arch con GNOME  
- Connessione internet (AUR)  
- Permessi `sudo`  

---

## ❓ Troubleshooting

- **AUR lento o timeout** → resta Papirus-Dark; riprova più tardi per Catppuccin.  
- **Gradience CLI non applica** → importa `DemonSlayer-AcquaRosa.json` dalla GUI.  
- **Pop Shell non compare** → riavvia GNOME Shell (`Alt+F2`, `r`, Invio) o logout/login.  
