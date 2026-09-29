#!/bin/bash
# =============================================================================
# Fenstra – eigene RPM-Pakete bauen und als lokale Paketquelle bereitstellen
# =============================================================================
# Aufruf (WSL, FedoraLinux-44, als root):  bash build/build-packages.sh
#         nur ein Paket:                    bash build/build-packages.sh fenstra-logos
#
# Ergebnis: $FENSTRA_WORK/repo (Standard /var/lib/fenstra-build/repo) mit RPMs
#           und repodata. build-iso.sh bindet dieses Verzeichnis als Paketquelle
#           "fenstra" in den Kickstart ein.
#
# Externe Quellen (Fluent-Symbole von npmjs.org, Selawik von GitHub) werden
# heruntergeladen und gegen packages/sources.sha256 geprüft. Eine noch nicht
# eingetragene Datei wird NICHT blind akzeptiert: das Skript zeigt die Prüfsumme
# an und schreibt sie nach packages/sources.sha256.neu, damit du sie nach
# Sichtung in sources.sha256 übernimmst (Vertrauen beim ersten Download).
# =============================================================================
set -euo pipefail
fehler() { echo "FEHLER: $*" >&2; exit 1; }
trap 'echo "FEHLER: unerwarteter Abbruch in Zeile $LINENO (Befehl: $BASH_COMMAND)" >&2' ERR

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${FENSTRA_WORK:-/var/lib/fenstra-build}"
RELEASEVER="${FENSTRA_RELEASEVER:-44}"
TOP="$WORK/rpmbuild"
OUT="$WORK/repo"
PKGDIR="$REPO_DIR/packages"
SUMS="$PKGDIR/sources.sha256"
NEU="$PKGDIR/sources.sha256.neu"

echo "== Prüfungen =="
for b in rpmbuild rpmspec createrepo_c rsvg-convert magick python3 curl; do
  command -v "$b" >/dev/null || fehler "$b fehlt. Erst: bash build/prepare-wsl.sh"
done
case "$REPO_DIR" in /mnt/*) fehler "Projekt liegt unter /mnt (Windows-Laufwerk). Bitte ins Linux-Dateisystem klonen.";; esac
mkdir -p "$TOP"/{BUILD,RPMS,SOURCES,SPECS,SRPMS} "$OUT"

# Welche Pakete?
if [ $# -gt 0 ]; then
  PKGS=("$@")
else
  PKGS=()
  for d in "$PKGDIR"/*/; do [ -n "$(ls "$d"/*.spec 2>/dev/null)" ] && PKGS+=("$(basename "$d")"); done
fi
echo "  Pakete: ${PKGS[*]}"
echo "  Ziel:   $OUT"

pruefe_summe() {  # Datei gegen sources.sha256 prüfen
  local f="$1" name; name="$(basename "$f")"
  local ist; ist="$(sha256sum "$f" | awk '{print $1}')"
  local soll; soll="$(grep -E "[[:space:]]\*?$name\$" "$SUMS" 2>/dev/null | awk '{print $1}' | head -1 || true)"
  if [ -n "$soll" ]; then
    [ "$ist" = "$soll" ] || fehler "Prüfsumme von $name passt nicht: erwartet $soll, ist $ist. Datei nicht verwenden!"
    echo "    ok   $name (SHA256 geprüft)"
  else
    echo "    NEU  $name  SHA256 $ist  -> nach Sichtung in packages/sources.sha256 eintragen"
    grep -q "$name" "$NEU" 2>/dev/null || echo "$ist  $name" >> "$NEU"
  fi
}

rc=0
for p in "${PKGS[@]}"; do
  dir="$PKGDIR/$p"; spec="$(ls "$dir"/*.spec | head -1)"
  [ -f "$spec" ] || fehler "Kein Spec in $dir"
  echo "== $p =="
  # Quellen zusammenstellen
  rm -rf "$TOP/SOURCES"/*; cp -p "$spec" "$TOP/SPECS/"
  # lokale Dateien neben dem Spec und in src/ (flach)
  find "$dir" -maxdepth 1 -type f ! -name '*.spec' -exec cp -p {} "$TOP/SOURCES/" \;
  if [ -d "$dir/src" ]; then
    find "$dir/src" -maxdepth 1 -type f -exec cp -p {} "$TOP/SOURCES/" \;
    # Pakete mit Unterverzeichnissen bekommen src/ als Tarball (Source0: <name>-src.tar.gz)
    if grep -q "^Source0:.*${p}-src.tar.gz" "$spec"; then
      tar -C "$dir" -czf "$TOP/SOURCES/${p}-src.tar.gz" src
    fi
  fi
  # entfernte Quellen laden (nur https) und prüfen. grep liefert 1, wenn ein
  # Paket keine Download-Quelle hat; das ist kein Fehler.
  urls=$(rpmspec -P "$TOP/SPECS/$(basename "$spec")" | grep -E '^Source[0-9]*:\s*https://' || true)
  echo "$urls" | while read -r _ url; do
    [ -n "$url" ] || continue
    name="${url##*#/}"; [ "$name" = "$url" ] && name="${url##*/}"
    cache="$WORK/sources/$name"; mkdir -p "$WORK/sources"
    if [ ! -f "$cache" ]; then
      echo "    lade $url"
      curl -fsSL --proto '=https' -o "$cache.part" "$url" || fehler "Download fehlgeschlagen: $url"
      mv "$cache.part" "$cache"
    fi
    pruefe_summe "$cache"
    cp -p "$cache" "$TOP/SOURCES/$name"
  done
  # fehlende Build-Abhängigkeiten nachinstallieren
  missing=$(rpmspec -q --buildrequires "$TOP/SPECS/$(basename "$spec")" 2>/dev/null | while read -r r; do rpm -q --whatprovides "$r" >/dev/null 2>&1 || echo "$r"; done)
  if [ -n "$missing" ]; then echo "    installiere Build-Abhängigkeiten: $missing"; dnf install -y $missing; fi
  # bauen (RPMS-Verzeichnis vorher leeren, damit nur neue Pakete kopiert werden)
  rm -rf "$TOP/RPMS"/*
  if rpmbuild -ba --define "_topdir $TOP" --define "dist .fc$RELEASEVER" "$TOP/SPECS/$(basename "$spec")" > "$WORK/build-$p.log" 2>&1; then
    n=$(find "$TOP/RPMS" -name '*.rpm' -newer "$TOP/SPECS/$(basename "$spec")" | wc -l)
    find "$TOP/RPMS" -name '*.rpm' -newer "$TOP/SPECS/$(basename "$spec")" -exec cp -p {} "$OUT/" \;
    echo "    gebaut: $n RPM(s)  (Protokoll: $WORK/build-$p.log)"
  else
    echo "    FEHLER beim Bauen, letzte Zeilen von $WORK/build-$p.log:"; tail -n 30 "$WORK/build-$p.log" | sed 's/^/      /'; rc=1
  fi
done

echo "== Paketquelle aktualisieren =="
createrepo_c --update "$OUT" >/dev/null && echo "  $OUT ($(ls "$OUT"/*.rpm 2>/dev/null | wc -l) RPMs)"
[ -f "$NEU" ] && { echo; echo "Neue Prüfsummen in $NEU. Bitte prüfen und in packages/sources.sha256 übernehmen."; }
[ $rc -eq 0 ] && echo "Fertig. Nächster Schritt: bash build/build-iso.sh" || echo "Es gab Fehler."
exit $rc
