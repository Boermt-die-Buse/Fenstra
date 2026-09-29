#!/bin/bash
# =============================================================================
# Fenstra – Build-Bericht zusammenstellen (für Fehlersuche und Nachvollziehbarkeit)
# =============================================================================
# Aufruf: bash build/report.sh [ZEITSTEMPEL]     (Standard: neuester Build)
# Legt unter berichte/<Zeitstempel>/ kleine Textauszüge ab, die ins Git können:
#   zusammenfassung.txt, fehler.txt, pakete.txt, livemedia-ende.txt
# Die vollständigen Protokolle bleiben unter $FENSTRA_WORK/logs/.
# =============================================================================
set -uo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${FENSTRA_WORK:-/var/lib/fenstra-build}"
STAMP="${1:-$(ls -1 "$WORK/logs" 2>/dev/null | sort | tail -1)}"
[ -n "$STAMP" ] || { echo "Kein Build gefunden unter $WORK/logs"; exit 1; }
LOGDIR="$WORK/logs/$STAMP"
OUTDIR="$WORK/out/$STAMP"
ZIEL="$REPO_DIR/berichte/$STAMP"
mkdir -p "$ZIEL"

{
  echo "Fenstra Build-Bericht $STAMP"
  echo "Erstellt: $(date -Is) auf $(. /etc/os-release; echo "$PRETTY_NAME") Kernel $(uname -r)"
  echo "lorax: $(rpm -q lorax 2>/dev/null), anaconda: $(rpm -q anaconda-tui 2>/dev/null), pykickstart: $(rpm -q pykickstart 2>/dev/null)"
  echo
  if ls "$OUTDIR"/*.iso >/dev/null 2>&1; then
    echo "ISO:"; ls -l "$OUTDIR"/*.iso; cat "$OUTDIR/SHA256SUMS" 2>/dev/null
  else
    echo "Kein ISO erzeugt."
  fi
  echo
  echo "Letzte Zeilen der Konsole:"; tail -n 40 "$LOGDIR/konsole.log" 2>/dev/null
} > "$ZIEL/zusammenfassung.txt"

{
  for f in "$LOGDIR"/konsole.log "$LOGDIR"/livemedia.log "$LOGDIR"/anaconda/*.log; do
    [ -f "$f" ] || continue
    grep -nHiE 'error|fehler|traceback|no match|failed|nicht gefunden|no space' "$f" | head -100
  done
} > "$ZIEL/fehler.txt"

# Paketliste aus dem %post-Protokoll ("Pakete im Live-Image:" bis zur nächsten Leerzeile)
awk '/Pakete im Live-Image:/{p=1;next} p&&/^[[:space:]]*$/{p=0} p' "$LOGDIR"/anaconda/program.log "$LOGDIR"/konsole.log 2>/dev/null \
  | sed -E 's/^[^0-9]*([0-9]+)\t/\1\t/' | sort -u -k2 > "$ZIEL/pakete.txt" || true

tail -n 200 "$LOGDIR/livemedia.log" > "$ZIEL/livemedia-ende.txt" 2>/dev/null || true

echo "Bericht unter $ZIEL:"
ls -l "$ZIEL"
echo "Ins Git aufnehmen mit: git add berichte && git commit -m 'Build-Bericht $STAMP'"
