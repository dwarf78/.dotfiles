#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Demon Slayer Rice · GNOME + Pop Shell (EndeavourOS) =="

# ---------------- Helpers ----------------
need_root() { if ! sudo -v; then echo "❌ Sudo non disponibile (sudo)"; exit 1; fi; }
ensure_pkg() { local pkgs=("$@"); need_root; sudo pacman -S --needed --noconfirm "${pkgs[@]}"; }

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then return 0; fi
  echo "[*] Installo yay (AUR helper)…"
  ensure_pkg base-devel git
  local tmpdir; tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
}

aur_install() {
  local pkgs=("$@")
  ensure_yay
  yay -S --needed --noconfirm "${pkgs[@]}" || { echo "[!] AUR fallito per: ${pkgs[*]}"; return 1; }
}

is_installed() { pacman -Qq "$1" >/dev/null 2>&1; }

find_catppuccin_mocha_icons() {
  local found=""
  for dir in /usr/share/icons "$HOME/.local/share/icons" "$HOME/.icons"; do
    [[ -d "$dir" ]] || continue
    found=$(ls -1 "$dir" 2>/dev/null | grep -i 'catppuccin' | grep -i 'mocha' | grep -vi 'cursor' | head -n1 || true)
    [[ -n "$found" ]] && { echo "$found"; return 0; }
  done
  return 1
}

find_catppuccin_mocha_cursors() {
  local found=""
  for dir in /usr/share/icons "$HOME/.icons"; do
    [[ -d "$dir" ]] || continue
    found=$(ls -1 "$dir" 2>/dev/null | grep -i 'catppuccin' | grep -i 'mocha' | grep -i 'cursor' | head -n1 || true)
    [[ -n "$found" ]] && { echo "$found"; return 0; }
  done
  return 1
}

apply_papirus_catppuccin() {
  if ! command -v papirus-folders >/dev/null 2>&1; then return 1; fi
  local colors pick
  colors="$(papirus-folders -l 2>/dev/null || true)"
  if [[ -n "${colors:-}" ]]; then
    pick="$(echo "$colors" | tr ' ' '\n' | grep -iE 'cat.*mocha|mocha' | head -n1 || true)"
  fi
  if [[ -n "${pick:-}" ]]; then
    papirus-folders -C "$pick" -t Papirus-Dark >/dev/null 2>&1 && { echo "$pick"; return 0; }
  fi
  return 1
}

status_report() {
  echo
  echo "—— STATUS ——"
  local gtk icon cursor
  gtk=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "unknown")
  icon=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo "unknown")
  cursor=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || echo "unknown")
  echo "Temi attivi:"
  echo "  • GTK:     $gtk"
  echo "  • Icone:   $icon"
  echo "  • Cursori: $cursor"

  echo
  echo "Pacchetti installati:"
  for p in papirus-icon-theme adwaita-icon-theme hicolor-icon-theme \
           catppuccin-icon-theme-git catppuccin-icons-git catppuccin-icons catppuccin-icon-theme \
           catppuccin-cursors-mocha gnome-shell-extensions; do
    if is_installed "$p"; then printf "  ✓ %s\n" "$p"; else printf "  ✗ %s\n" "$p"; fi
  done

  echo
  echo "Catppuccin presenti in /usr/share/icons:"
  ls /usr/share/icons 2>/dev/null | grep -i catppuccin || echo "  (nessuno trovato)"

  local pop_status="non rilevato"
  if command -v gnome-extensions >/dev/null 2>&1; then
    if gnome-extensions list | grep -q '^pop-shell@system76.com$'; then
      if gnome-extensions list --enabled | grep -q '^pop-shell@system76.com$'; then
        pop_status="abilitato"
      else
        pop_status="installato (non abilitato)"
      fi
    fi
  fi
  echo
  echo "Pop Shell: $pop_status"
  echo "Gaps: inner=$(gsettings get org.gnome.shell.extensions.pop-shell gap-inner 2>/dev/null || echo '?'), outer=$(gsettings get org.gnome.shell.extensions.pop-shell gap-outer 2>/dev/null || echo '?')"
  echo "———————"
}

MODE="${1:-}"

if [[ "$MODE" == "--reset" ]]; then
  echo "[*] Modalità reset: ripristino temi sicuri…"
  need_root
  ensure_pkg papirus-icon-theme adwaita-icon-theme hicolor-icon-theme
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
  gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
  gsettings set org.gnome.desktop.interface gtk-theme "Orchis-Dark"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  echo "✅ Reset completato"
  status_report
  exit 0
fi

if [[ "$MODE" == "--status" ]]; then
  status_report
  exit 0
fi

AUTOPILOT=0
[[ "$MODE" == "--autopilot" ]] && AUTOPILOT=1

# ---------------- Base packages ----------------
need_root
sudo pacman -Sy --noconfirm >/dev/null 2>&1 || true
ensure_pkg zenity gnome-tweaks gnome-shell-extensions papirus-icon-theme adwaita-icon-theme hicolor-icon-theme

# ---------------- Pop Shell ----------------
aur_install gnome-shell-extension-pop-shell-git || true
POP_ID="pop-shell@system76.com"
gnome-extensions enable "$POP_ID" 2>/dev/null || true

PS_SCHEMA="org.gnome.shell.extensions.pop-shell"
gs_set_if() { local k="$1" v="$2"; gsettings set "$PS_SCHEMA" "$k" "$v" 2>/dev/null || true; }
gs_set_if tile-by-default true
gs_set_if gap-inner 4
gs_set_if gap-outer 2
gs_set_if active-hint true

# ---------------- GTK/Shell Theme: Orchis ----------------
GTK_THEME='Orchis-Dark'
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name "$GTK_THEME" 2>/dev/null || true

# ---------------- ICON THEME ----------------
echo "[*] Applico subito Papirus-Dark come fallback…"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

echo "[*] Provo ad installare le icone Catppuccin Mocha da AUR…"
ICON_THEME="Papirus-Dark"
if aur_install catppuccin-icon-theme-git || aur_install catppuccin-icons-git; then
  CAND_ICON="$(find_catppuccin_mocha_icons || true)"
  if [[ -n "${CAND_ICON:-}" ]]; then
    ICON_THEME="$CAND_ICON"
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    echo "✅ Trovato e applicato Catppuccin Mocha: $ICON_THEME"
  fi
fi

# ---------------- CURSORS ----------------
echo "[*] Installo cursori Catppuccin Mocha…"
aur_install catppuccin-cursors-mocha || true
CURSOR_THEME="Adwaita"
CAND_CUR="$(find_catppuccin_mocha_cursors || true)"
[[ -n "${CAND_CUR:-}" ]] && CURSOR_THEME="$CAND_CUR"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
echo "[*] Tema cursore impostato su: $CURSOR_THEME"

# ---------------- Papirus folders → Catppuccin Mocha ----------------
if command -v papirus-folders >/dev/null 2>&1; then
  PICK="$(apply_papirus_catppuccin || true)"
  [[ -n "${PICK:-}" ]] && echo "[*] Papirus folders impostato su: $PICK (Papirus-Dark)"
fi

# ---------------- Gradience preset (copia file esterno) ----------------
PRESET_SRC="$SCRIPT_DIR/DemonSlayer-AcquaRosa.json"
PRESET_DST="$HOME/.config/presets/DemonSlayer-AcquaRosa.json"
mkdir -p "$(dirname "$PRESET_DST")"

if [[ -f "$PRESET_SRC" ]]; then
  cp "$PRESET_SRC" "$PRESET_DST"
  echo "✅ Copiato preset Gradience in: $PRESET_DST"
else
  echo "[!] Preset JSON mancante in $SCRIPT_DIR → assicurati di avere DemonSlayer-AcquaRosa.json"
fi

# ---------------- Report finale ----------------
status_report
echo
echo "🎨 Palette Gradience:"
echo "  • Background:  #1E1E2E"
echo "  • Foreground:  #CDD6F4"
echo "  • Accent:      #1E90FF (Acqua)"
echo "  • Destructive: #FF4DA6 (Rosa)"
echo
echo "🖼️ Consiglio: usa come wallpaper Tanjiro & Nezuko (4K) in ~/Pictures/Wallpapers/"
echo
echo "ℹ️ Riavvia GNOME Shell (Alt+F2, r, Invio) oppure logout/login."
echo "   Reset rapido: ./$(basename "$0") --reset"
echo "   Solo stato:   ./$(basename "$0") --status"
echo "   Autopilot:    ./$(basename "$0") --autopilot"

