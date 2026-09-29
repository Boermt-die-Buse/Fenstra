#!/bin/bash
# =============================================================================
# Fenstra – Live-ISO bauen (WSL2, FedoraLinux-44, als root)
# =============================================================================
# Aufruf:  bash build/build-iso.sh                       (Standard-Kickstart)
#          bash build/build-iso.sh kickstart/anders.ks   (anderer Kickstart)
#
# Umgebungsvariablen (optional):
#   FENSTRA_SQUASHFS=zstd   schnellere Kompression des Live-Images testen
#                           (Standard xz = kleinstes ISO; erst messen, dann wechseln)
#   FENSTRA_COPY_TO=/mnt/c/Users/<Name>/Fenstra   ISO zusätzlich nach Windows kopieren
#   FENSTRA_WORK=/var/lib/fenstra-build           Bau-Verzeichnis (Linux-Dateisystem!)
#
# Was passiert:
#  1. Prüfungen (root, Werkzeuge, Platz, Linux-Dateisystem statt /mnt/c,
#     lokale Paketquelle aus build/build-packages.sh)
#  2. ksvalidator
#  3. livemedia-creator --make-iso --no-virt: Anaconda installiert in ein
#     ext4-Image, lorax packt es als squashfs und baut das ISO (GRUB2 für BIOS
#     und UEFI). Läuft komplett innerhalb der WSL-Distribution.
#  4. Ergebnis + SHA256 nach $OUTDIR, Protokolle nach $LOGDIR
#
# Dauer: ca. 15–45 Minuten, Download ca. 2–3 GB, Platz ca. 25 GB unter $FENSTRA_WORK.
#
# Hinweis zum Risiko: livemedia-creator --no-virt lässt Anaconda als root auf
# dem Host laufen (Verzeichnis-Installation). lorax warnt, dass ein Anaconda-
# Fehler theoretisch echte Geräte anfassen könnte. In WSL ist "der Host" die
# WSL-Distribution selbst, nicht Windows. Trotzdem: nichts Wichtiges nur in
# FedoraLinux-44 aufbewahren.
# =============================================================================
set -euo pipefail

fehler() { echo "FEHLER: $*" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KS="${1:-$REPO_DIR/kickstart/fenstra-live.ks}"
[ -f "$KS" ] || fehler "Kickstart nicht gefunden: $KS"
KS="$(readlink -f "$KS")"

RELEASEVER="${FENSTRA_RELEASEVER:-44}"
STAMP="$(date +%Y%m%d-%H%M)"
WORK="${FENSTRA_WORK:-/var/lib/fenstra-build}"
TMPDIR_LMC="$WORK/tmp"
OUTDIR="$WORK/out/$STAMP"
LOGDIR="$WORK/logs/$STAMP"
ISO_NAME="Fenstra-${RELEASEVER}-x86_64-${STAMP}.iso"
VOLID="Fenstra-${RELEASEVER}-x86_64"

echo "== Prüfungen =="
[ "$(id -u)" -eq 0 ] || fehler "Bitte als root ausführen (wsl -d FedoraLinux-44)."
command -v livemedia-creator >/dev/null || fehler "livemedia-creator fehlt. Erst: bash build/prepare-wsl.sh"
command -v ksvalidator >/dev/null || fehler "ksvalidator fehlt. Erst: bash build/prepare-wsl.sh"
case "$REPO_DIR" in /mnt/*) fehler "Das Projekt liegt unter /mnt (Windows-Laufwerk). Bitte ins Linux-Dateisystem klonen, z. B.: git clone https://github.com/Boermt-die-Buse/Fenstra.git /root/Fenstra";; esac
case "$WORK" in /mnt/*) fehler "FENSTRA_WORK darf nicht unter /mnt liegen (Loop-Mounts und Rechte funktionieren dort nicht).";; esac
[ -e /dev/loop-control ] || fehler "Keine Loop-Geräte (/dev/loop-control fehlt)."
[ -e "$OUTDIR" ] && fehler "$OUTDIR existiert schon (livemedia-creator verlangt ein neues Verzeichnis)."
mkdir -p "$TMPDIR_LMC" "$LOGDIR" "$WORK/out"
avail_gb=$(df -BG --output=avail "$WORK" | tail -1 | tr -dc '0-9')
[ "$avail_gb" -ge 30 ] || fehler "Zu wenig Platz unter $WORK: ${avail_gb} GB frei, 30 GB nötig."
echo "  Kickstart:   $KS"
echo "  Ergebnis:    $OUTDIR/$ISO_NAME"
echo "  Protokolle:  $LOGDIR"
echo "  Freier Platz: ${avail_gb} GB, CPUs: $(nproc), RAM: $(free -g | awk 'NR==2{print $2}') GB"

echo "== Lokale Paketquelle (eigene Fenstra-Pakete) =="
LOCAL_REPO="$WORK/repo"
if [ -d "$LOCAL_REPO/repodata" ]; then
  echo "  $LOCAL_REPO ($(ls "$LOCAL_REPO"/*.rpm 2>/dev/null | wc -l) RPMs)"
else
  fehler "Keine Paketquelle unter $LOCAL_REPO. Erst: bash build/build-packages.sh"
fi
# Jedes Fenstra-Paket, das der Kickstart verlangt, muss als RPM vorliegen
fehlend=""
for p in $(grep -E '^(fenstra-|plymouth-theme-fenstra|selawik-fonts)' "$KS" | awk '{print $1}'); do
  ls "$LOCAL_REPO/$p"-[0-9]*.rpm >/dev/null 2>&1 || fehlend="$fehlend $p"
done
if [ -n "$fehlend" ]; then
  fehler "In der Paketquelle fehlen:$fehlend. Bitte nachbauen: bash build/build-packages.sh (Paketverzeichnis: fenstra-fonts-selawik baut selawik-fonts, fenstra-theme baut plymouth-theme-fenstra)"
fi
# Der Kickstart enthält den Standardpfad; bei abweichendem FENSTRA_WORK ersetzen.
KS_USED="$KS"
if [ "$LOCAL_REPO" != /var/lib/fenstra-build/repo ]; then
  KS_USED="$LOGDIR/$(basename "$KS")"
  sed "s|file:///var/lib/fenstra-build/repo|file://$LOCAL_REPO|" "$KS" > "$KS_USED"
  echo "  Kickstart-Kopie mit angepasstem Pfad: $KS_USED"
fi

echo "== Kickstart prüfen =="
ksvalidator -v "F${RELEASEVER}" "$KS_USED" || fehler "Kickstart ungültig."
echo "  ok"

EXTRA=()
case "${FENSTRA_SQUASHFS:-xz}" in
  xz)   echo "  Kompression: xz (lorax-Standard)";;
  zstd) echo "  Kompression: zstd Stufe 19"
        EXTRA+=(--compression zstd --compress-arg="-Xcompression-level 19");;
  *)    fehler "FENSTRA_SQUASHFS muss xz oder zstd sein.";;
esac

# Alte Reste eines abgebrochenen Builds aufräumen (nur im eigenen Bau-Verzeichnis)
if ls "$TMPDIR_LMC"/lmc-* >/dev/null 2>&1; then
  echo "  Räume alte Zwischenstände auf: $TMPDIR_LMC/lmc-*"
  for d in "$TMPDIR_LMC"/lmc-*; do
    findmnt -R -no TARGET "$d" 2>/dev/null | sort -r | xargs -r -n1 umount 2>/dev/null || true
    rm -rf "$d"
  done
fi

echo "== Build startet: $(date) =="
# livemedia-creator legt ./anaconda/ mit den Anaconda-Protokollen im aktuellen Verzeichnis an
cd "$LOGDIR"
set +e
livemedia-creator \
  --make-iso --no-virt --nomacboot \
  --ks "$KS_USED" \
  --project "Fenstra" --releasever "$RELEASEVER" \
  --volid "$VOLID" \
  --iso-only --iso-name "$ISO_NAME" \
  --resultdir "$OUTDIR" --tmp "$TMPDIR_LMC" \
  --logfile "$LOGDIR/livemedia.log" \
  "${EXTRA[@]}" 2>&1 | tee "$LOGDIR/konsole.log"
rc=${PIPESTATUS[0]}
set -e
echo "== Build beendet: $(date), Rückgabewert $rc =="

if [ "$rc" -ne 0 ]; then
  cat <<EOT

BUILD FEHLGESCHLAGEN (Rückgabewert $rc).
Bitte diese Protokolle sichern und weitergeben (bash build/report.sh $STAMP):
  $LOGDIR/konsole.log
  $LOGDIR/livemedia.log
  $LOGDIR/anaconda/{anaconda,program,packaging,storage,dnf.librepo}.log
Häufige Ursachen:
  - Paket oder Gruppe nicht gefunden      -> packaging.log ("No match for")
  - Loop-Mount / Rechte                   -> program.log (losetup, mount)
  - Spiegelserver / Netzwerk              -> dnf.librepo.log
  - Zu wenig Platz in $TMPDIR_LMC         -> "No space left on device"
EOT
  exit "$rc"
fi

echo "== Ergebnis =="
ISO="$OUTDIR/$ISO_NAME"
[ -f "$ISO" ] || fehler "ISO nicht gefunden unter $OUTDIR"
( cd "$OUTDIR" && sha256sum "$ISO_NAME" > SHA256SUMS )
ls -lh "$ISO"
cat "$OUTDIR/SHA256SUMS"

if [ -n "${FENSTRA_COPY_TO:-}" ]; then
  mkdir -p "$FENSTRA_COPY_TO"
  cp -v "$ISO" "$OUTDIR/SHA256SUMS" "$FENSTRA_COPY_TO/"
  echo "Kopiert nach $FENSTRA_COPY_TO (in Windows: $(wslpath -w "$FENSTRA_COPY_TO" 2>/dev/null || echo "$FENSTRA_COPY_TO"))"
else
  echo "Von Windows erreichbar unter: \\\\wsl\$\\FedoraLinux-44${OUTDIR//\//\\}"
  echo "Oder kopieren mit: FENSTRA_COPY_TO=/mnt/c/Users/<Name>/Fenstra bash build/build-iso.sh"
fi
echo "Nächster Schritt: docs/02-build-und-test.md, Abschnitt 'Test in einer VM'."
