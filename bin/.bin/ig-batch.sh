#!/bin/bash
# ig-batch.sh — batch che usa SOLO ig-photo.sh (portrait-safe by default)
# Output: <CWD>/ig_export/<stem_pulito>/<nomi_originali_da_ig_ready>
# Pulisce ig_ready/ dagli *_1080x*.jpg (disattivalo con --keep)

set -euo pipefail
IFS=$'\n\t'

# ----- requisiti -----
if ! command -v ig-photo.sh >/dev/null 2>&1; then
  echo "❌ ig-photo.sh non trovato nel PATH." >&2
  exit 1
fi

# ----- opzioni -----
OUTROOT="$(pwd)/ig_export"   # cartella di export assoluta
VERBOSE=0
KEEP=0                       # 0 = pulisci ig_ready, 1 = tienilo

usage(){ echo "Uso: $0 [-o outdir] [-v] [--keep] <file|cartella> [altri ...]"; exit 1; }
expand_path(){ case "$1" in "~") printf "%s\n" "$HOME";; "~/"*) printf "%s/%s\n" "$HOME" "${1:2}";; *) printf "%s\n" "$1";; esac; }
abs_path(){ (cd "$(dirname "$1")" >/dev/null 2>&1 && printf "%s/%s" "$PWD" "$(basename "$1")"); }
sanitize_stem(){ echo "$1" | sed 's/^[[:space:]]\+//; s/[[:space:]]\+$//' | tr '[:upper:]' '[:lower:]' | sed 's|/|_|g; s/[[:space:]]\+/_/g; s/[^a-z0-9._-]/_/g'; }

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--out) [[ $# -ge 2 ]] || usage; OUTROOT="$(expand_path "$2")"; shift 2;;
    -v|--verbose) VERBOSE=1; shift;;
    --keep) KEEP=1; shift;;
    -h|--help) usage;;
    -*) usage;;
    *) ARGS+=("$(expand_path "$1")"); shift;;
  esac
done
[[ ${#ARGS[@]} -gt 0 ]] || usage

mkdir -p "$OUTROOT"
OUTROOT_ABS="$(abs_path "$OUTROOT")"

# ----- costruisci lista file (ricorsivo) -----
INPUTS=()
for a in "${ARGS[@]}"; do
  if [[ -d "$a" ]]; then
    while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "$a" -type f -print0)
  elif [[ -f "$a" ]]; then
    INPUTS+=("$a")
  else
    echo "⚠️  Ignoro: $a (non trovato)" >&2
  fi
done
[[ ${#INPUTS[@]} -gt 0 ]] || { echo "❌ Nessun file valido trovato."; exit 1; }

# ----- loop -----
for INPUT in "${INPUTS[@]}"; do
  ABS_IN="$(abs_path "$INPUT")"
  DIR_IN="$(dirname "$ABS_IN")"
  BASE="$(basename "$ABS_IN")"
  STEM_CLEAN="$(sanitize_stem "$BASE")"
  DEST_DIR="$OUTROOT_ABS/$STEM_CLEAN"
  mkdir -p "$DEST_DIR"

  [[ $VERBOSE -eq 1 ]] && echo "▶️  $ABS_IN" && echo "   → eseguo ig-photo.sh in: $DIR_IN"

  # esegui ig-photo.sh nella cartella del file (output in ./ig_ready/)
  (
    cd "$DIR_IN"
    mkdir -p ig_ready
    ig-photo.sh "$ABS_IN" >/dev/null 2>&1 || true
  )

  IG_READY="$DIR_IN/ig_ready"
  if [[ ! -d "$IG_READY" ]]; then
    echo "   ⚠️  Nessuna cartella ig_ready in $DIR_IN (export non riuscito?)" >&2
    continue
  fi

  # raccogli output *_1080x*.jpg (mantieni nomi originali)
  shopt -s nullglob
  MOVED=0
  FILES=()  # per eventuale pulizia
  while IFS= read -r -d '' f; do
    base_out="$(basename "$f")"
    cp -f -- "$f" "$DEST_DIR/$base_out"
    FILES+=("$f")
    ((MOVED++)) || true
  done < <(find "$IG_READY" -maxdepth 1 -type f -name "*_1080x*.jpg" -print0)
  shopt -u nullglob

  if [[ $MOVED -eq 0 ]]; then
    echo "   ⚠️  Nessun file *_1080x*.jpg trovato in $IG_READY" >&2
    [[ $VERBOSE -eq 1 ]] && { echo "   Contenuto ig_ready:"; find "$IG_READY" -maxdepth 1 -type f -printf "     %f\n"; }
  else
    [[ $VERBOSE -eq 1 ]] && echo "   ✅ Salvati in: $DEST_DIR"
    # pulizia, se richiesta
    if [[ $KEEP -eq 0 ]]; then
      for f in "${FILES[@]}"; do rm -f -- "$f"; done
      # rimuovi ig_ready se vuota
      rmdir "$IG_READY" 2>/dev/null || true
      [[ $VERBOSE -eq 1 ]] && echo "   🧹 Pulito: $(basename "$DIR_IN")/ig_ready"
    fi
  fi
done

echo "🎉 Batch completato. Tutto in: $OUTROOT_ABS/"

