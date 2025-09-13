#!/bin/bash
# ig-photo-lite.sh — crea 1080x1080 / 1080x1350 / 1080x1920 (portrait-safe)
# Uso: ig-photo-lite.sh "nome file con spazi"
set -u

if [ $# -ne 1 ]; then
  echo "Uso: $0 <file>"; exit 1
fi

INPUT="$1"
if [ ! -f "$INPUT" ]; then
  echo "❌ File non trovato: $INPUT"; exit 1
fi

OUTDIR="ig_ready"
mkdir -p "$OUTDIR" || { echo "❌ Non posso creare $OUTDIR"; exit 1; }

base="$(basename "$INPUT")"
stem="${base%.*}"   # se non c'è estensione usa comunque il nome intero

# funzione: export con crop e gravity North (ritratto sicuro)
mk() {
  local w=$1 h=$2
  magick "$INPUT" -auto-orient -resize ${w}x${h}^ -gravity North -extent ${w}x${h} \
         "$OUTDIR/${stem}_${w}x${h}.jpg" || return 1
}

mk 1080 1080 || { echo "❌ errore su 1080x1080"; exit 2; }
mk 1080 1350 || { echo "❌ errore su 1080x1350"; exit 2; }
mk 1080 1920 || { echo "❌ errore su 1080x1920"; exit 2; }

echo "✅ Creati file in $OUTDIR/"

