#!/bin/bash
# Fenstra: Arbeitskopie unter Windows und Repo in WSL abgleichen.
#
#   Repo (kanonisch, Git, Builds):  /root/Fenstra
#   Arbeitskopie (Windows-Editor):  C:\Users\Daniel\Fenstra\ws  (= /mnt/c/Users/Daniel/Fenstra/ws)
#
# Windows-Programme (und Claude Codes Datei-Werkzeuge) können /root in WSL nicht lesen.
# Bearbeitet wird deshalb in der Arbeitskopie; vor Build, Test und Commit wird abgeglichen.
#
#   sync-ws.sh            beide Richtungen, die neuere Datei gewinnt (rsync -u)
#   sync-ws.sh hin        nur Arbeitskopie -> Repo
#   sync-ws.sh her        nur Repo -> Arbeitskopie
#   sync-ws.sh rm PFAD…   Datei/Ordner (relativ zum Repo) in beiden Kopien löschen
#
# Gelöscht wird beim Abgleich nie etwas (sonst ginge bei einer veralteten Kopie Arbeit
# verloren). Neue Skripte aus der Arbeitskopie brauchen im Repo ein `chmod +x`
# (Windows kennt keine Ausführungsrechte; vorhandene Rechte im Repo bleiben erhalten).
set -euo pipefail
REPO=${FENSTRA_REPO:-/root/Fenstra}
WS=${FENSTRA_WS:-/mnt/c/Users/Daniel/Fenstra/ws}
EXCL=(--exclude .git/ --exclude __pycache__/ --exclude '*.pyc' --exclude '/build-local/')
mkdir -p "$WS"

nach_repo() { rsync -rtu --no-perms --chmod=ugo=rwX "${EXCL[@]}" "$WS/" "$REPO/"; }
nach_ws()   { rsync -rtu --no-perms "${EXCL[@]}" "$REPO/" "$WS/"; }

case "${1:-beide}" in
  hin) nach_repo ;;
  her) nach_ws ;;
  rm)
    shift
    for p in "$@"; do
      case "$p" in /*|*..*) echo "nur relative Pfade ohne ..: $p" >&2; exit 2 ;; esac
      rm -rf -- "${REPO:?}/$p" "${WS:?}/$p"
      echo "gelöscht: $p"
    done
    ;;
  beide) nach_ws; nach_repo ;;
  *) echo "Aufruf: $0 [beide|hin|her|rm PFAD…]" >&2; exit 2 ;;
esac
