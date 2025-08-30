#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.7"

# ---- utility ----
err(){ echo "ERROR: $*" >&2; exit 1; }
info(){ echo -e "\033[1;32m==>\033[0m $*"; }
warn(){ echo -e "\033[1;33m!!\033[0m $*"; }
require_cmd(){ command -v "$1" >/dev/null 2>&1 || err "Comando richiesto non trovato: $1"; }
is_arch_like(){ [[ -f /etc/arch-release || -f /etc/endeavouros-release ]]; }
timestamp(){ date +%Y%m%d-%H%M%S; }
lower(){ echo "$1" | tr '[:upper:]' '[:lower:]'; }

DRY_RUN=0
USER_TMPDIR="${TMPDIR:-}"   # sovrascrivibile con --tmpdir
EXPORT_FORMAT=""            # tzst|zip|"" (auto da estensione)

run(){ if (( DRY_RUN )); then echo "[dry-run] $*"; else "$@"; fi; }
sudorun(){ if (( DRY_RUN )); then echo "[dry-run] sudo $*"; else sudo "$@"; fi; }

sanitize_uri_to_path(){
  local uri="${1:-}"
  [[ -z "$uri" || "$uri" == "''" || "$uri" == "'none'" ]] && return 1
  uri="${uri#\'}"; uri="${uri%\'}"; uri="${uri#file://}"
  printf '%s' "$uri"
}

# ---- spazio richiesto vs disponibile ----
check_space_or_hint(){
  local base_paths=("$@")
  local tmp_base="${USER_TMPDIR:-/tmp}"
  local need_kb free_kb need_kb_safety need_mb free_mb
  need_kb=$(du -sk "${base_paths[@]}" 2>/dev/null | awk '{s+=$1} END{print s+0}')
  need_kb_safety=$(( (need_kb * 12) / 10 ))   # ~1.2x
  free_kb=$(df -Pk "$tmp_base" | awk 'NR==2{print $4+0}')
  if [[ -n "$need_kb" && -n "$free_kb" && "$free_kb" -lt "$need_kb_safety" ]]; then
    need_mb=$(( need_kb_safety / 1024 )); free_mb=$(( free_kb / 1024 ))
    warn "Spazio insufficiente su TMPDIR ($tmp_base): libero ~${free_mb}MB, richiesto ~${need_mb}MB."
    warn "Usa: --tmpdir /percorso_capiente  (o TMPDIR=/percorso)."
  fi
}

# ---- rilevamento/extract archivio ----
detect_bundle_type(){
  # echo: dir|tzst|tarzst|tar|zip|unknown
  local path="$1"; local lpath; lpath="$(lower "$path")"
  if [[ -d "$path" ]]; then echo "dir"; return; fi
  if [[ "$lpath" =~ \.tar\.zst$ || "$lpath" =~ \.tzst$ ]]; then echo "tzst"; return; fi
  if [[ "$lpath" =~ \.tar$ ]]; then echo "tar"; return; fi
  if [[ "$lpath" =~ \.zip$ ]]; then echo "zip"; return; fi
  # fallback: prova 'file'
  if command -v file >/dev/null 2>&1; then
    local f; f="$(file -b "$path" || true)"
    [[ "$f" =~ Zip\ archive ]] && { echo "zip"; return; }
    [[ "$f" =~ tar\ archive ]] && { echo "tar"; return; }
  fi
  echo "unknown"
}

extract_bundle_to(){
  # args: <bundle_or_dir> <target_tmp_dir>
  local src="$1"; local dest="$2"
  local kind; kind="$(detect_bundle_type "$src")"
  case "$kind" in
    dir)
      info "Uso directory esistente come sorgente: $src"
      # niente da estrarre, ma copio struttura in $dest/ (per consistenza)
      run rsync -a "$src"/ "$dest"/
      ;;
    tzst|tar|tarzst)
      require_cmd tar
      info "Estraggo archivio (tar) in: $dest"
      run tar -C "$dest" -xf "$src"
      ;;
    zip)
      require_cmd unzip
      info "Estraggo archivio (zip) in: $dest"
      run unzip -q "$src" -d "$dest"
      ;;
    *)
      err "Formato archivio non riconosciuto: $src (estensioni supportate: .tzst/.tar.zst, .tar, .zip, o directory)"
      ;;
  esac
}

# ---- EXPORT ----
export_bundle(){
  local bundle="${1:-}"
  [[ -z "$bundle" ]] && err "Specificare archivio output (es. ~/t480s_clone.tzst o ~/t480s_clone.zip)"
  is_arch_like || err "Script pensato per Arch/EndeavourOS."

  require_cmd pacman; require_cmd rsync; require_cmd tar; require_cmd awk

  # Decidi formato export
  local lpath; lpath="$(lower "$bundle")"
  local fmt="$EXPORT_FORMAT"
  if [[ -z "$fmt" ]]; then
    if [[ "$lpath" =~ \.zip$ ]]; then fmt="zip"
    else fmt="tzst"
    fi
  fi
  [[ "$fmt" == "zip" ]] && require_cmd zip

  # Setup TMPDIR
  local tmp_base="${USER_TMPDIR:-/tmp}"
  [[ -n "$USER_TMPDIR" && ! -d "$USER_TMPDIR" ]] && run mkdir -p "$USER_TMPDIR"
  local tmp
  if (( DRY_RUN )); then tmp="$tmp_base/tmp.archclone.DRYRUN.$(timestamp)"
  else tmp="$(mktemp -d -p "$tmp_base" tmp.archclone.XXXXXX)"
  fi
  info "Cartella temporanea: $tmp"
  run mkdir -p "$tmp/meta" "$tmp/system" "$tmp/user" "$tmp/user/wallpapers"

  # Metadati
  run bash -lc "uname -a > '$tmp/meta/uname.txt'"; true
  run bash -lc "hostnamectl > '$tmp/meta/hostnamectl.txt'"; true
  run bash -lc "lscpu > '$tmp/meta/lscpu.txt'"; true
  run bash -lc "echo 'script_version=$SCRIPT_VERSION' > '$tmp/meta/script.txt'"

  local real_user; real_user="${SUDO_USER:-$USER}"
  run bash -lc "echo '$real_user' > '$tmp/meta/username.txt'"

  # Pacchetti
  info "Rilevo pacchetti pacman (repo + AUR)…"
  pacman -Qqen | sort -u > "$tmp/system/pacman_explicit.txt" || true
  pacman -Qqm  | sort -u > "$tmp/system/aur_foreign.txt"   || true

  # Flatpak
  if command -v flatpak >/dev/null 2>&1; then
    info "Rilevo app Flatpak…"
    flatpak list --app --columns=application,ref,origin > "$tmp/system/flatpak_list.tsv" || true
    cut -f1 "$tmp/system/flatpak_list.tsv" | grep -v '^$' | sort -u > "$tmp/system/flatpak_apps.txt" || true
  fi

  # systemd (system)
  info "Rilevo servizi systemd abilitati…"
  systemctl list-unit-files --state=enabled --type=service \
    | awk 'NR>1 && $1 ~ /\.service$/ {print $1}' \
    | sort -u > "$tmp/system/systemd_enabled_system.txt" || true

  # systemd (user) – robusto anche senza user-bus
  local uid usr_bus
  uid="$(id -u "$real_user")"
  usr_bus="/run/user/${uid}/bus"
  if [[ -S "$usr_bus" ]]; then
    sudo -u "$real_user" XDG_RUNTIME_DIR="/run/user/${uid}" DBUS_SESSION_BUS_ADDRESS="unix:path=${usr_bus}" \
      systemctl --user list-unit-files --state=enabled --type=service \
      | awk 'NR>1 && $1 ~ /\.service$/ {print $1}' \
      | sort -u > "$tmp/system/systemd_enabled_user.txt" || true
  else
    sudo -u "$real_user" bash -lc '
      base="$HOME/.config/systemd/user"
      if [[ -d "$base" ]]; then
        find "$base" -type d -name "*.wants" -maxdepth 2 2>/dev/null \
          | while read -r d; do
              find "$d" -maxdepth 1 -type l -name "*.service" -printf "%f\n"
            done | sort -u
      fi
    ' > "$tmp/system/systemd_enabled_user.txt" || true
  fi

  # pacman conf/mirrorlist samples
  [[ -f /etc/pacman.conf ]] && run cp -a /etc/pacman.conf "$tmp/system/pacman.conf.sample"
  [[ -f /etc/pacman.d/mirrorlist ]] && run cp -a /etc/pacman.d/mirrorlist "$tmp/system/mirrorlist.sample"

  # Dotfiles, temi, icone, fonts, extensions
  info "Copio configurazioni utente…"
  local uhome; uhome="$(getent passwd "$real_user" | cut -d: -f6)"
  [[ -d "$uhome" ]] || err "Home utente non trovata per $real_user"

  local -a INCLUDE=(
    ".config" ".local/share"
    ".bashrc" ".zshrc" ".profile" ".bash_profile" ".inputrc"
    ".gitconfig" ".gitignore_global" ".aliases" ".exports"
    ".pam_environment"
    ".gtkrc-2.0" ".config/gtk-3.0" ".config/gtk-4.0"
    ".themes" ".icons" ".local/share/fonts"
    ".config/Code"
    ".config/kitty" ".config/alacritty" ".config/wezterm"
    ".config/xfce4" ".config/plasma*" ".local/share/konsole"
    ".local/share/gnome-shell/extensions"
    ".config/i3" ".config/sway" ".config/hypr" ".config/waybar" ".config/dunst"
    ".config/nvim" ".config/vim" ".vimrc"
  )
  local -a EXCLUDE=(
    ".cache" "*/Cache" "*/cache"
    ".local/share/Trash"
    ".npm/_logs"
    ".config/google-chrome" ".config/chromium" ".config/BraveSoftware"
    ".local/share/flatpak/repo"
    ".local/share/Steam" ".var" "node_modules"
    ".thunderbird/*/cache2" ".mozilla/*/cache2"
  )

  check_space_or_hint "$(printf "%s/%s\n" "$uhome" "${INCLUDE[@]}")"

  run rsync -a --delete \
    $(printf -- "--exclude=%q " "${EXCLUDE[@]}") \
    $(printf -- "%q " "${INCLUDE[@]/#/$uhome/}") \
    "$tmp/user/home/"

  # GNOME dconf / extensions / wallpaper
  if command -v dconf >/dev/null 2>&1; then
    info "Esporto impostazioni GNOME (dconf)…"
    dconf dump /org/gnome/ > "$tmp/system/gnome.dconf" || true
  fi
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions list > "$tmp/system/gnome_extensions_all.txt" || true
    gnome-extensions list --enabled > "$tmp/system/gnome_extensions_enabled.txt" || true
  fi
  if command -v gsettings >/dev/null 2>&1; then
    info "Rilevo wallpaper GNOME…"
    { gsettings get org.gnome.desktop.background picture-uri || true
      gsettings get org.gnome.desktop.background picture-uri-dark || true
      gsettings get org.gnome.desktop.screensaver picture-uri || true; } > "$tmp/system/gnome_wallpaper_uris.txt" || true
    : > "$tmp/system/gnome_wallpaper_files.txt"
    while read -r u; do
      p="$(sanitize_uri_to_path "$u" || true)"
      [[ -n "${p:-}" && -f "$p" ]] || continue
      run cp -a "$p" "$tmp/user/wallpapers/" || true
      basename "$p" >> "$tmp/system/gnome_wallpaper_files.txt"
    done < <(grep -E "file://" "$tmp/system/gnome_wallpaper_uris.txt" || true)
  fi

  run bash -lc "find '$tmp/user/home' -type f -print0 | xargs -0r chmod u+rw,go-rw"
  run bash -lc "find '$tmp/user/home' -type d -print0 | xargs -0r chmod u+rwx,go-rwx"

  info "Creo archivio (${fmt})…"
  run mkdir -p "$(dirname "$bundle")"
  if [[ "$fmt" == "zip" ]]; then
    # zip vuole lavorare dentro alla dir
    if (( DRY_RUN )); then
      echo "[dry-run] (cd '$tmp' && zip -r -9 '$bundle' .)"
    else
      ( cd "$tmp" && zip -r -9 "$bundle" . >/dev/null )
    fi
  else
    run tar --zstd -C "$tmp" -cf "$bundle" .
  fi

  if (( ! DRY_RUN )); then rm -rf "$tmp"; else echo "[dry-run] rm -rf '$tmp'"; fi
  info "EXPORT completato (modalità $([[ $DRY_RUN -eq 1 ]] && echo DRY-RUN || echo LIVE))."
}

# ---- helper ----
install_yay_if_missing(){
  if ! command -v yay >/dev/null 2>&1; then
    info "Installo yay (AUR helper)…"
    sudorun pacman -Sy --needed --noconfirm git base-devel
    local tmpd
    if (( DRY_RUN )); then tmpd="${USER_TMPDIR:-/tmp}/yay.build.DRYRUN.$(timestamp)"
    else tmpd="$(mktemp -d -p "${USER_TMPDIR:-/tmp}" yay.build.XXXXXX)"
    fi
    run git clone https://aur.archlinux.org/yay.git "$tmpd/yay"
    run bash -lc "cd '$tmpd/yay' && makepkg -si --noconfirm"
    if (( ! DRY_RUN )); then rm -rf "$tmpd"; else echo "[dry-run] rm -rf '$tmpd'"; fi
  fi
}

# ---- IMPORT ----
import_bundle(){
  local bundle="${1:-}"
  [[ -z "$bundle" ]] && err "Specificare archivio o directory di input (es. ~/t480s_clone.tzst | ~/t480s_clone.zip | ~/estratto_dir)"
  is_arch_like || err "Script pensato per Arch/EndeavourOS."
  require_cmd rsync; require_cmd awk; require_cmd sudo; require_cmd pacman

  # Setup TMPDIR
  local tmp_base="${USER_TMPDIR:-/tmp}"
  [[ -n "$USER_TMPDIR" && ! -d "$USER_TMPDIR" ]] && run mkdir -p "$USER_TMPDIR"
  local tmp
  if (( DRY_RUN )); then tmp="$tmp_base/tmp.archclone.import.DRYRUN.$(timestamp)"
  else tmp="$(mktemp -d -p "$tmp_base" tmp.archclone.import.XXXXXX)"
  fi
  info "Estraggo/sincronizzo sorgente in: $tmp"
  extract_bundle_to "$bundle" "$tmp"

  local src_user dest_user
  src_user="$(cat "$tmp/meta/username.txt" 2>/dev/null || true)"
  dest_user="${SUDO_USER:-$USER}"
  [[ -n "$src_user" ]] || warn "username sorgente non trovato (meta/username.txt). Continuo."
  info "Utente sorgente: ${src_user:-?} | Utente destinazione: $dest_user"

  info "Aggiorno database pacman…"
  sudorun pacman -Syu --noconfirm || true

  # Repo packages
  if [[ -s "$tmp/system/pacman_explicit.txt" ]]; then
    info "Installo pacchetti dai repo ufficiali…"
    mapfile -t TO_INSTALL < <(grep -v '^$' "$tmp/system/pacman_explicit.txt" | xargs -r -n1)
    ((${#TO_INSTALL[@]})) && sudorun pacman -S --needed --noconfirm "${TO_INSTALL[@]}" || true
  fi

  # AUR
  install_yay_if_missing
  if [[ -s "$tmp/system/aur_foreign.txt" ]]; then
    info "Installo pacchetti AUR…"
    awk '{print $1}' "$tmp/system/aur_foreign.txt" | grep -v '^$' | sort -u > "$tmp/system/aur_names.txt"
    mapfile -t AUR_TO_INSTALL < <(cat "$tmp/system/aur_names.txt")
    ((${#AUR_TO_INSTALL[@]})) && run yay -S --needed --noconfirm "${AUR_TO_INSTALL[@]}" || true
  fi

  # Flatpak
  if [[ -s "$tmp/system/flatpak_apps.txt" ]]; then
    if ! command -v flatpak >/dev/null 2>&1; then
      info "Installo Flatpak…"; sudorun pacman -S --needed --noconfirm flatpak
    fi
    if ! flatpak remotes | grep -q flathub; then
      info "Aggiungo remoto Flathub…"
      sudorun flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    fi
    info "Installo app Flatpak…"
    run xargs -r -a "$tmp/system/flatpak_apps.txt" -I{} flatpak install -y flathub "{}" || true
  fi

  # Ripristino home
  info "Ripristino configurazioni utente…"
  local dest_home; dest_home="$(getent passwd "$dest_user" | cut -d: -f6)"
  [[ -d "$dest_home" ]] || err "Home utente non trovata per $dest_user"
  run rsync -a --info=progress2 --ignore-existing "$tmp/user/home/." "$dest_home/" || true
  sudorun chown -R "$dest_user":"$dest_user" "$dest_home"

  # GNOME base pkgs
  sudorun pacman -S --needed --noconfirm gsettings-desktop-schemas gnome-shell-extensions dconf || true

  # Wallpaper
  local bgdir="$dest_home/.local/share/backgrounds/clone"
  run mkdir -p "$bgdir"
  if [[ -d "$tmp/user/wallpapers" ]]; then
    run cp -a "$tmp/user/wallpapers/." "$bgdir/"
    sudorun chown -R "$dest_user":"$dest_user" "$dest_home/.local/share/backgrounds"
  fi

  # dconf import
  if command -v dconf >/dev/null 2>&1 && [[ -s "$tmp/system/gnome.dconf" ]]; then
    info "Importo impostazioni GNOME (dconf)…"
    run sudo -u "$dest_user" dconf load /org/gnome/ < "$tmp/system/gnome.dconf" || warn "Import dconf con warning."
  fi

  # wallpaper re-apply (primo disponibile)
  if command -v gsettings >/dev/null 2>&1 && [[ -s "$tmp/system/gnome_wallpaper_files.txt" ]]; then
    info "Reimposto wallpaper…"
    while read -r fname; do
      [[ -z "$fname" ]] && continue
      run sudo -u "$dest_user" gsettings set org.gnome.desktop.background picture-uri "file://$bgdir/$fname" || true
      run sudo -u "$dest_user" gsettings set org.gnome.desktop.background picture-uri-dark "file://$bgdir/$fname" || true
      run sudo -u "$dest_user" gsettings set org.gnome.desktop.screensaver picture-uri "file://$bgdir/$fname" || true
      break
    done < "$tmp/system/gnome_wallpaper_files.txt"
  fi

  # Abilito servizi utente – robusto anche senza user-bus
  if [[ -s "$tmp/system/systemd_enabled_user.txt" ]]; then
    info "Abilito servizi utente…"
    local uid_dest usr_bus; uid_dest="$(id -u "$dest_user")"; usr_bus="/run/user/${uid_dest}/bus"
    if [[ -S "$usr_bus" ]]; then
      while read -r svc; do
        [[ -z "$svc" ]] && continue
        run sudo -u "$dest_user" XDG_RUNTIME_DIR="/run/user/${uid_dest}" DBUS_SESSION_BUS_ADDRESS="unix:path=${usr_bus}" \
          systemctl --user enable "$svc" || true
      done < "$tmp/system/systemd_enabled_user.txt"
    else
      warn "Nessun user-bus attivo per ${dest_user}. Abilito linger e registro i servizi (effettivi al prossimo login)."
      sudorun loginctl enable-linger "$dest_user" || true
      while read -r svc; do
        [[ -z "$svc" ]] && continue
        run sudo -u "$dest_user" systemctl --user enable "$svc" || true
      done < "$tmp/system/systemd_enabled_user.txt"
      warn "Dopo il login grafico:
  systemctl --user daemon-reload && systemctl --user list-unit-files --state=enabled --type=service"
    fi
  fi

  # systemd enable (system)
  if [[ -s "$tmp/system/systemd_enabled_system.txt" ]]; then
    info "Abilito servizi di sistema…"
    while read -r svc; do
      [[ -z "$svc" ]] && continue
      sudorun systemctl enable "$svc" || warn "Impossibile abilitare $svc (system)."
    done < "$tmp/system/systemd_enabled_system.txt"
  fi

  # pacman/mirrorlist notice
  if [[ -f "$tmp/system/pacman.conf.sample" ]] || [[ -f "$tmp/system/mirrorlist.sample" ]]; then
    warn "Esportati pacman.conf/mirrorlist come *sample*. Confrontali manualmente se necessario:
  - $tmp/system/pacman.conf.sample
  - $tmp/system/mirrorlist.sample"
  fi

  if (( ! DRY_RUN )); then rm -rf "$tmp"; else echo "[dry-run] rm -rf '$tmp'"; fi
  info "IMPORT completato (modalità $([[ $DRY_RUN -eq 1 ]] && echo DRY-RUN || echo LIVE)). Riavvio consigliato."
}

usage(){
  cat <<EOF
Uso: $0 [--dry-run] [--tmpdir PATH] [--format tzst|zip] export <output.{tzst|zip}>
     $0 [--dry-run] [--tmpdir PATH] import <input.{tzst|tar.zst|tar|zip}|/percorso/dir>

Esempi:
  # EXPORT (auto formato da estensione)
  $0 export ~/t480s_clone.tzst
  $0 --format zip export ~/t480s_clone.zip
  # IMPORT (accetta tzst/tar.zst/tar/zip/dir)
  $0 import ~/t480s_clone.tzst
  $0 import ~/t480s_clone.zip
  $0 import ~/estratto_dir
  # Sposta temporanei su disco capiente
  $0 --tmpdir ~/clone-tmp export ~/t480s_clone.tzst
  TMPDIR=~/clone-tmp $0 --dry-run import ~/t480s_clone.zip
EOF
}

main(){
  local mode=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1; shift;;
      --tmpdir) shift; [[ $# -gt 0 ]] || err "--tmpdir richiede un percorso"; USER_TMPDIR="$1"; shift;;
      --format) shift; [[ $# -gt 0 ]] || err "--format richiede tzst|zip"; EXPORT_FORMAT="$(lower "$1")"; [[ "$EXPORT_FORMAT" =~ ^(tzst|zip)$ ]] || err "Formato export non valido"; shift;;
      export|import) mode="$1"; shift; break;;
      *) break;;
    esac
  done
  case "$mode" in
    export) export_bundle "${1:-}";;
    import) import_bundle "${1:-}";;
    *) usage; exit 1;;
  esac
}

main "$@"
