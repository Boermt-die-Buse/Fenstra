#!/bin/bash
# =============================================================================
# Fenstra – Werkzeuge in der WSL-Distribution FedoraLinux-44 prüfen/installieren
# =============================================================================
# Aufruf (in Windows):  wsl -d FedoraLinux-44
# dann als root:        bash build/prepare-wsl.sh
#
# Installiert nur Pakete aus den Fedora-Quellen und macht einen Loop-Mount-Test
# mit einer temporären Datei. Es werden keine Platten oder Partitionen berührt.
# =============================================================================
set -euo pipefail

fehler() { echo "FEHLER: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fehler "Bitte als root ausführen."

. /etc/os-release
echo "System: ${PRETTY_NAME:-?}"
[ "${ID:-}" = fedora ] || echo "WARNUNG: kein Fedora. Der Build ist nur auf Fedora 44 vorgesehen."
[ "${VERSION_ID:-}" = 44 ] || echo "WARNUNG: Fedora ${VERSION_ID:-?} statt 44. livemedia-creator --no-virt ist nur zuverlässig, wenn Host- und Zielversion gleich sind."

echo "== Pakete =="
PFLICHT=(lorax lorax-lmc-novirt anaconda-tui pykickstart squashfs-tools xorriso dosfstools isomd5sum e2fsprogs util-linux git
         rpm-build rpmdevtools createrepo_c librsvg2-tools ImageMagick python3 fonts-rpm-macros curl)
dnf install -y "${PFLICHT[@]}"
# C++/Qt/KDE-Entwicklung für eigene Programme und Plugins (Qt-Stil, Fensterdekoration,
# KWin-Effekte, Apps). Die meisten Specs ziehen ihre BuildRequires ohnehin selbst nach
# (build-packages.sh); diese Liste macht WSL vorab vollständig.
ENTWICKLUNG=(gcc-c++ cmake ninja-build extra-cmake-modules
         qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtdeclarative-devel qt6-qtsvg-devel
         qt6-qttools-devel qt6-qtwayland-devel qt6-qtmultimedia-devel
         kf6-kconfig-devel kf6-kconfigwidgets-devel kf6-kcoreaddons-devel kf6-kguiaddons-devel
         kf6-ki18n-devel kf6-kiconthemes-devel kf6-kwindowsystem-devel kf6-kcmutils-devel
         kf6-kio-devel kf6-kxmlgui-devel kf6-knotifications-devel kf6-kcolorscheme-devel
         kf6-kirigami-devel kf6-kpackage-devel kf6-kglobalaccel-devel kf6-kservice-devel
         kf6-kparts-devel kf6-kitemviews-devel kf6-kwidgetsaddons-devel kf6-frameworkintegration-devel
         kf6-networkmanager-qt-devel kf6-bluez-qt-devel kf6-solid-devel
         kdecoration-devel kwin-devel libplasma-devel plasma-workspace-devel libksysguard-devel
         libkscreen-devel pulseaudio-qt-qt6-devel polkit-qt6-1-devel
         xcursorgen python3-numpy python3-pillow optipng rsync)
dnf install -y "${ENTWICKLUNG[@]}"
# Referenz-Kickstarts des Fedora-Projekts (nur zum Vergleichen, nicht Pflicht)
dnf install -y --skip-unavailable fedora-kickstarts || true

echo "== Werkzeuge =="
for b in livemedia-creator ksvalidator ksflatten mksquashfs xorriso mkfs.ext4 mkfs.vfat losetup implantisomd5 rpmbuild rpmspec createrepo_c rsvg-convert magick python3; do
  command -v "$b" >/dev/null || fehler "$b fehlt"
  echo "  ok  $b"
done

echo "== Kernel-Funktionen =="
grep -q squashfs /proc/filesystems || modprobe squashfs 2>/dev/null || echo "WARNUNG: squashfs nicht im Kernel (wird beim Bauen nicht gebraucht, aber beim Prüfen des ISO)"
[ -e /dev/loop-control ] || fehler "/dev/loop-control fehlt: keine Loop-Geräte"

img=$(mktemp /var/tmp/fenstra-looptest.XXXXXX)
truncate -s 64M "$img"
mkfs.ext4 -q "$img"
dev=$(losetup --find --show "$img")
m=$(mktemp -d)
if mount "$dev" "$m"; then
  echo "  ok  Loop-Mount ($dev)"
  umount "$m"
else
  losetup -d "$dev"; rm -rf "$img" "$m"
  fehler "Loop-Mount fehlgeschlagen"
fi
losetup -d "$dev"
rm -rf "$img" "$m"

echo "== Ablageort =="
case "$(pwd)" in
  /mnt/*) echo "WARNUNG: Du bist unter /mnt (Windows-Laufwerk). Projekt und Bau-Verzeichnis müssen im Linux-Dateisystem liegen, z. B. /root/Fenstra." ;;
  *)      echo "  ok  Linux-Dateisystem ($(pwd))" ;;
esac
echo "Freier Platz unter /var (Bau-Verzeichnis): $(df -h /var | awk 'NR==2{print $4}')"
echo "RAM: $(free -g | awk 'NR==2{print $2}') GB, CPUs: $(nproc)"

if [ -d /usr/share/spin-kickstarts ]; then
  echo "Referenz-Kickstarts von Fedora liegen unter /usr/share/spin-kickstarts/ (fedora-live-kde.ks, fedora-live-base.ks)."
fi
echo "Fertig. Nächste Schritte: bash build/build-packages.sh, dann bash build/build-iso.sh"
