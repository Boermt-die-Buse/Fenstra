# =============================================================================
# Fenstra – Kickstart für das Live-ISO (Build #2: Basis + Branding/Theme, Baustein 4a)
# =============================================================================
# Ergebnis: startfähiges Live-ISO mit KDE Plasma (Wayland) und Installer.
# Grundlage: Fedora Linux 44 (Remix). Der Aufbau ist an fedora-live-base.ks und
# fedora-live-kde.ks des Fedora-Projekts angelehnt (pagure.io/fedora-kickstarts,
# Branch f44), hier aber eigenständig gehalten, damit keine versteckten
# Abhängigkeiten entstehen und jede Zeile nachvollziehbar ist.
#
# Bauen (in WSL, FedoraLinux-44, als root):   bash build/build-packages.sh   (eigene RPMs)
#                                              bash build/build-iso.sh        (ISO)
# Prüfen:                                      bash build/validate.sh
#
# Eigene Pakete (packages/): fenstra-release, fenstra-logos, fenstra-backgrounds,
# fenstra-theme, plymouth-theme-fenstra, fenstra-icon-theme, selawik-fonts.
# Sie kommen aus der lokalen Paketquelle "fenstra" (siehe repo-Zeile unten).
#
# Was diese Datei bewusst NOCH NICHT enthält (kommt in späteren Bausteinen):
#   - Windows-11-Layout für Taskleiste, Startmenü, Schnelleinstellungen
#   - grub-btrfs (nicht in den Fedora-Quellen; wird als eigenes Paket gebaut)
#   - Wine/Proton, Steam, NVIDIA-Treiber (RPM Fusion)
#   - Fenstra Store, Einstellungen-App, Dateimanager-Anpassungen
# =============================================================================

# --- Sprache, Tastatur, Zeitzone des Live-Systems ----------------------------
lang de_DE.UTF-8
keyboard --vckeymap=de --xlayouts=de
timezone Europe/Berlin

# --- Sicherheit ----------------------------------------------------------------
# Build #1 läuft in WSL. Der WSL-Kernel hat kein SELinux, deshalb bekommen die
# Dateien im Image keine Sicherheitslabels. Ein Image ohne Labels würde mit
# "enforcing" nicht sauber starten. Darum hier "permissive". Das installierte
# System labelt sich beim ersten Start selbst neu und schaltet danach auf
# "enforcing" um (siehe /usr/libexec/fenstra/firstboot weiter unten).
selinux --permissive
firewall --enabled --service=mdns

# --- Grafischer Start ----------------------------------------------------------
xconfig --startxonboot

# --- Wurzeldateisystem des Live-Images (NICHT die Zielplatte des Nutzers) -----
# livemedia-creator legt eine ext4-Datei dieser Größe an, installiert hinein und
# packt sie anschließend als squashfs ins ISO. Ungenutzter Platz kostet im ISO
# praktisch nichts. 10 GB reichten für die KDE-Umgebung von Fedora 44 nicht
# (Build vom 29.09.2026: "No space left on device" beim Rettungs-initramfs).
zerombr
clearpart --all
part / --size=20480 --fstype=ext4

# --- Dienste, Netzwerk, root -----------------------------------------------------
services --enabled=NetworkManager,ModemManager --disabled=sshd
network --bootproto=dhcp --device=link --activate
# root ohne Passwort und gesperrt. Fedoras alte Vorlage "--iscrypted locked" scheitert
# seit shadow-utils 4.17 (chpasswd prüft den Hash: "invalid password hash").
rootpw --lock
shutdown

# --- Paketquellen ------------------------------------------------------------------
# "url" ist für livemedia-creator --no-virt Pflicht (Installationsmethode).
# $releasever wird von Anaconda aus der Host-Version (Fedora 44) ersetzt,
# $basearch ist x86_64.
url  --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=fedora  --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
# Eigene Fenstra-Pakete (build/build-packages.sh). Pfad wird von build-iso.sh
# ersetzt, wenn FENSTRA_WORK woanders liegt.
repo --name=fenstra --baseurl=file:///var/lib/fenstra-build/repo


%packages
# --- Arbeitsumgebung: KDE Plasma (Wayland) -----------------------------------------
# Umgebungsgruppe des Fedora-KDE-Spins. Sie enthält u. a. base-x, core, standard,
# fonts, hardware-support, kde-desktop, kde-apps, kde-media, multimedia, printing,
# firefox, guest-desktop-agents und networkmanager-submodules.
@^kde-desktop-environment

# --- Live-Medium und Installer (wie fedora-live-base.ks) -----------------------------
kernel
kernel-modules
kernel-modules-extra
anaconda
anaconda-install-env-deps
anaconda-live
@anaconda-tools
# schwache Abhängigkeiten von Anaconda, die auf einem Desktop nichts verloren haben
-fcoe-utils
-device-mapper-multipath
-sdubby
# Schrift für die Anaconda-Hinweisgrafiken
aajohan-comfortaa-fonts
# ohne dracut-live scheitert die initramfs-Erzeugung für das Live-Image
dracut-live
# Anaconda braucht alle Locales, um in anderen Sprachen installieren zu können
glibc-all-langpacks
# Startskripte des Live-Systems (Benutzer "liveuser", Autologin, Installer-Symbol)
livesys-scripts
# Bootloader-Bausteine für das ISO: BIOS (GRUB2-Module) und UEFI (shim + GRUB)
grub2-pc-modules
grub2-efi-x64-cdboot
shim-x64

# --- Fenstra: Wiederherstellungspunkte, Btrfs -----------------------------------------
snapper
libdnf5-plugin-actions
btrfs-progs

# --- Fenstra: Leistung -----------------------------------------------------------------
tuned
tuned-ppd
zram-generator-defaults

# --- Fenstra: Sprache und Schrift ---------------------------------------------------------
langpacks-de
cascadia-code-fonts
selawik-fonts

# --- Fenstra: Branding und Theme (eigene Pakete, Baustein 4a) -----------------------------
fenstra-release
fenstra-logos
fenstra-backgrounds
fenstra-theme
fenstra-icon-theme
plymouth-theme-fenstra
# Fedora-Grafiken weichen den Fenstra-Paketen (system-logos, system-backgrounds-kde).
# desktop-backgrounds-compat bleibt erlaubt (sddm verlangt es), es kollidiert nicht.
-fedora-logos
-desktop-backgrounds-kde
-f44-backgrounds-kde

# --- Ausschlüsse: schlankeres System -------------------------------------------------------
# keine X11-Sitzung (Fenstra ist Wayland)
-plasma-workspace-x11
-kwin-x11
# E-Mail-/Kalender-Suite (Fenstra bekommt später eigene bzw. Web-Apps)
-kmail
-kontact
-korganizer
-kaddressbook
-akregator
-kmail-account-wizard
%end


%post
# =============================================================================
# Teil 1: Live-System einrichten (entspricht fedora-live-base.ks / -kde.ks)
# =============================================================================
systemctl enable livesys.service
systemctl enable livesys-late.service
# KDE-Sitzung für die Live-Startskripte auswählen
sed -i 's/^livesys_session=.*/livesys_session="kde"/' /etc/sysconfig/livesys

# /tmp im RAM; /var/tmp ebenfalls, damit nicht ins Overlay geschrieben wird
systemctl enable tmp.mount
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

# Paketliste ins Build-Protokoll (hilft später beim Abspecken)
rm -f /var/lib/rpm/__db*
echo "Pakete im Live-Image:"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' | sort -rn
rm -f /var/lib/rpm/__db*

# man-Index vorbereiten, Reste entfernen
/usr/bin/mandb
rm -f /core*
rm -f /var/lib/systemd/random-seed
echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated >/var/.updated
# Rettungskernel wird auf dem Live-Medium nicht gebraucht
rm -f /boot/*-rescue*
systemctl disable network
# machine-id muss auf jedem installierten System neu entstehen
rm -f /etc/machine-id
touch /etc/machine-id

# =============================================================================
# Teil 2: Fenstra-Kennung und Bootscreen
# =============================================================================
# os-release, /etc/issue, Logos, Theme und Symbole kommen aus den eigenen Paketen
# (fenstra-release, fenstra-logos, fenstra-theme, ...). Hier nur Kontrolle und
# Bootscreen-Vorgabe.
grep -q '^VARIANT_ID=fenstra' /usr/lib/os-release || echo "WARNUNG: os-release trägt nicht die Fenstra-Kennung (fenstra-release fehlt?)"
grep -E '^(PRETTY_NAME|VARIANT_ID)=' /usr/lib/os-release

# Plymouth: Fenstra-Bootscreen als Vorgabe. Das Live-initramfs baut lorax selbst;
# das installierte System erzeugt beim Installieren ein neues initramfs mit
# diesem Theme (deshalb hier kein dracut-Lauf).
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme fenstra || echo "WARNUNG: Plymouth-Thema fenstra nicht gefunden"
fi

# =============================================================================
# Teil 3: Installer-Profil (Anaconda) für Fenstra
# =============================================================================
# Erbt vom Fedora-KDE-Profil und greift über VARIANT_ID=fenstra. Standard bei der
# Installation: ein Btrfs-Volume mit den Subvolumes für / und /home und
# zstd-Kompression. Hinweis: Anaconda benennt die Subvolumes fest "root" und
# "home"; die Namen "@"/"@home" lassen sich im grafischen Installer nicht
# vorgeben (siehe kickstart/vorlage-autoinstall-btrfs.ks für den Weg per
# unbeaufsichtigter Installation).
mkdir -p /etc/anaconda/profile.d
cat > /etc/anaconda/profile.d/fenstra.conf << 'EOF'
# Anaconda-Profil für Fenstra (erbt vom Fedora-KDE-Profil)
[Profile]
profile_id = fenstra
base_profile = fedora-kde

[Profile Detection]
os_id = fedora
variant_id = fenstra

[Storage]
default_scheme = BTRFS
btrfs_compression = zstd:1
default_partitioning =
    / (min 1 GiB, max 70 GiB)
    /home (min 500 MiB, free 50 GiB)
EOF

# =============================================================================
# Teil 4: Leistung – zRAM, Speicherverwaltung, Energieprofile
# =============================================================================
# Komprimierter Auslagerungsspeicher im RAM statt Swap-Partition.
cat > /etc/systemd/zram-generator.conf << 'EOF'
# Fenstra: komprimierter Auslagerungsspeicher im RAM (Richtwert, wird gemessen)
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# Kernel-Speicherparameter für den zRAM-Betrieb (Richtwerte, werden gemessen)
cat > /etc/sysctl.d/60-fenstra-vm.conf << 'EOF'
# Fenstra: Speicherverwaltung für zRAM-Betrieb
vm.swappiness = 150
vm.page-cluster = 0
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
EOF

# Energieprofile (tuned-ppd stellt die Profile in der KDE-Oberfläche bereit)
systemctl enable tuned.service tuned-ppd.service 2>/dev/null || true
# Wöchentliches TRIM für SSDs (Fedora-Standard, hier ausdrücklich)
systemctl enable fstrim.timer

# =============================================================================
# Teil 5: Wiederherstellungspunkte (Snapper) und Btrfs-Pflege
# =============================================================================
mkdir -p /usr/libexec/fenstra /etc/dnf/libdnf5-plugins/actions.d /var/lib/fenstra

# 5a) Vor und nach jeder Paketänderung (dnf5, Discover/PackageKit) ein
#     Wiederherstellungspunkt. Läuft über das DNF5-Actions-Plugin.
#     Format: hook:paketfilter:richtung:optionen:befehl
cat > /etc/dnf/libdnf5-plugins/actions.d/fenstra-snapper.actions << 'EOF'
# Fenstra: Wiederherstellungspunkt vor und nach jeder Paketänderung
pre_transaction:::enabled=host-only:/usr/libexec/fenstra/snapshot-hook pre
post_transaction:::enabled=host-only:/usr/libexec/fenstra/snapshot-hook post
EOF

cat > /usr/libexec/fenstra/snapshot-hook << 'EOF'
#!/bin/bash
# Fenstra: Wiederherstellungspunkte rund um Paketänderungen (DNF5-Actions-Plugin).
# Gibt nichts auf stdout aus, damit das Plugin die Ausgabe nicht als Variablen liest.
set -u
CONF=root
STATE=/run/fenstra-snapper-pre
command -v snapper >/dev/null 2>&1 || exit 0
# Keine Snapper-Konfiguration (z. B. Live-System, ext4-Installation): nichts tun
snapper -c "$CONF" get-config >/dev/null 2>&1 || exit 0
case "${1:-}" in
  pre)
    n=$(snapper -c "$CONF" create -t pre -c number -p \
          -d "Vor Systemupdate" --userdata important=yes 2>/dev/null) || exit 0
    echo "$n" > "$STATE"
    ;;
  post)
    if [ -s "$STATE" ]; then
      snapper -c "$CONF" create -t post -c number --pre-number "$(cat "$STATE")" \
          -d "Nach Systemupdate" --userdata important=yes >/dev/null 2>&1
      rm -f "$STATE"
    fi
    ;;
esac
exit 0
EOF
chmod 0755 /usr/libexec/fenstra/snapshot-hook

# 5b) Wöchentlicher Wiederherstellungspunkt
cat > /usr/libexec/fenstra/snapshot-weekly << 'EOF'
#!/bin/bash
# Fenstra: wöchentlicher Wiederherstellungspunkt des Systems
snapper -c root get-config >/dev/null 2>&1 || exit 0
exec snapper -c root create -c number -d "Wöchentlicher Wiederherstellungspunkt"
EOF
chmod 0755 /usr/libexec/fenstra/snapshot-weekly

cat > /usr/lib/systemd/system/fenstra-snapshot-weekly.service << 'EOF'
[Unit]
Description=Fenstra: wöchentlicher Wiederherstellungspunkt
ConditionKernelCommandLine=!rd.live.image

[Service]
Type=oneshot
ExecStart=/usr/libexec/fenstra/snapshot-weekly
EOF

cat > /usr/lib/systemd/system/fenstra-snapshot-weekly.timer << 'EOF'
[Unit]
Description=Fenstra: wöchentlicher Wiederherstellungspunkt

[Timer]
OnCalendar=weekly
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
EOF

# 5c) Wöchentliche Btrfs-Prüfung (scrub) mit niedriger Priorität
cat > /usr/libexec/fenstra/btrfs-scrub << 'EOF'
#!/bin/bash
# Fenstra: prüft die Datenintegrität des Btrfs-Systemvolumes
[ "$(findmnt -no FSTYPE /)" = btrfs ] || exit 0
exec nice -n 19 ionice -c 3 btrfs scrub start -Bd /
EOF
chmod 0755 /usr/libexec/fenstra/btrfs-scrub

cat > /usr/lib/systemd/system/fenstra-btrfs-scrub.service << 'EOF'
[Unit]
Description=Fenstra: Btrfs-Datenprüfung (scrub)
ConditionKernelCommandLine=!rd.live.image
ConditionACPower=true

[Service]
Type=oneshot
ExecStart=/usr/libexec/fenstra/btrfs-scrub
EOF

cat > /usr/lib/systemd/system/fenstra-btrfs-scrub.timer << 'EOF'
[Unit]
Description=Fenstra: wöchentliche Btrfs-Datenprüfung

[Timer]
OnCalendar=Sun *-*-* 03:00:00
Persistent=true
RandomizedDelaySec=2h

[Install]
WantedBy=timers.target
EOF

# 5d) Ersteinrichtung nach der Installation (läuft NICHT im Live-Modus).
#     - Btrfs-Mount-Optionen (noatime, compress=zstd:1) in /etc/fstab
#     - Snapper-Konfiguration "root" für das System (nicht für /home)
#     - Snapshots in ein eigenes Top-Level-Subvolume "snapshots" legen, damit sie
#       ein späteres Zurücksetzen von "/" überleben
#     - SELinux: fehlende Labels nachziehen, dann auf enforcing
cat > /usr/libexec/fenstra/firstboot << 'EOF'
#!/bin/bash
# Fenstra: Ersteinrichtung nach der Installation. Idempotent; läuft bei jedem
# Start, bis /var/lib/fenstra/firstboot.done geschrieben wurde.
set -uo pipefail
LOG=/var/log/fenstra-firstboot.log
STATE=/var/lib/fenstra
mkdir -p "$STATE"
exec >>"$LOG" 2>&1
echo "== $(date -Is) Fenstra Ersteinrichtung =="

ROOT_FSTYPE=$(findmnt -no FSTYPE /)

if [ "$ROOT_FSTYPE" = btrfs ]; then
  # 1) Mount-Optionen für alle Btrfs-Einträge ergänzen
  #    (discard=async ist seit Kernel 6.2 bei SSDs Standard und wird nicht gesetzt)
  if ! grep -q 'fenstra-fstab-done' "$STATE/firstboot.state" 2>/dev/null; then
    cp -a /etc/fstab "$STATE/fstab.vor-fenstra"
    sed -i -E '/[[:space:]]btrfs[[:space:]]/ { /noatime/! s/([[:space:]]btrfs[[:space:]]+)([^[:space:]]+)/\1noatime,\2/ }' /etc/fstab
    sed -i -E '/[[:space:]]btrfs[[:space:]]/ { /compress=/! s/([[:space:]]btrfs[[:space:]]+)([^[:space:]]+)/\1compress=zstd:1,\2/ }' /etc/fstab
    systemctl daemon-reload
    echo fenstra-fstab-done >> "$STATE/firstboot.state"
    echo "fstab: noatime/compress ergänzt (Sicherung: $STATE/fstab.vor-fenstra)"
  fi

  # 2) Snapper-Konfiguration für das System anlegen
  if ! snapper -c root get-config >/dev/null 2>&1; then
    snapper -c root create-config / \
      && snapper -c root set-config TIMELINE_CREATE=no NUMBER_CLEANUP=yes \
           NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5 NUMBER_MIN_AGE=1800 \
      && echo "snapper: Konfiguration 'root' angelegt"
  fi

  # 3) Snapshots in ein eigenes Top-Level-Subvolume legen und einhängen
  if snapper -c root get-config >/dev/null 2>&1 && ! findmnt -no TARGET /.snapshots >/dev/null 2>&1; then
    dev=$(findmnt -no SOURCE / | sed 's/\[.*//')
    uuid=$(findmnt -no UUID /)
    top=$(mktemp -d)
    if mount -o subvolid=5 "$dev" "$top"; then
      [ -d "$top/snapshots" ] || btrfs subvolume create "$top/snapshots"
      # von create-config verschachtelt angelegtes /.snapshots ersetzen
      if btrfs subvolume show /.snapshots >/dev/null 2>&1; then
        btrfs subvolume delete /.snapshots
      fi
      mkdir -p /.snapshots
      if ! grep -q '[[:space:]]/\.snapshots[[:space:]]' /etc/fstab; then
        echo "UUID=$uuid /.snapshots btrfs subvol=snapshots,noatime,compress=zstd:1,nofail 0 0" >> /etc/fstab
        systemctl daemon-reload
      fi
      umount "$top"; rmdir "$top"
      mount /.snapshots && echo "snapper: /.snapshots als eigenes Subvolume eingehängt"
      # Ausgangspunkt festhalten
      snapper -c root create -c number -d "Ausgangszustand nach Installation" --userdata important=yes
    else
      rmdir "$top"
      echo "WARNUNG: Top-Level-Volume konnte nicht eingehängt werden"
    fi
  fi
else
  echo "Systemvolume ist $ROOT_FSTYPE (kein Btrfs): keine Wiederherstellungspunkte möglich"
fi

# 4) SELinux: Ein in WSL gebautes Image hat keine Sicherheitslabels.
#    Stufe 1: Neu-Labeling für den nächsten Start planen (bleibt permissive).
#    Stufe 2 (nächster Start, Labels vorhanden): auf enforcing umstellen.
selinux_done=1
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" != Disabled ] && [ -f /etc/selinux/config ]; then
  ctx=$(stat -c %C /etc/passwd 2>/dev/null || echo '?')
  case "$ctx" in *unlabeled_t*|'?'*|'') labels_fehlen=1;; *) labels_fehlen=0;; esac
  if [ "$labels_fehlen" = 1 ]; then
    if [ ! -f /.autorelabel ]; then
      touch /.autorelabel
      echo "SELinux: Labels fehlen, Neu-Labeling beim nächsten Start geplant"
    fi
    selinux_done=0
  else
    if grep -q '^SELINUX=permissive' /etc/selinux/config; then
      sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
      echo "SELinux: Labels vorhanden, ab dem nächsten Start enforcing"
    fi
  fi
fi

if [ "$selinux_done" = 1 ]; then
  touch "$STATE/firstboot.done"
  echo "Ersteinrichtung abgeschlossen"
fi
exit 0
EOF
chmod 0755 /usr/libexec/fenstra/firstboot

cat > /usr/lib/systemd/system/fenstra-firstboot.service << 'EOF'
[Unit]
Description=Fenstra: Ersteinrichtung nach der Installation
ConditionPathExists=!/var/lib/fenstra/firstboot.done
ConditionKernelCommandLine=!rd.live.image
After=local-fs.target dbus.service
Wants=dbus.service
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/libexec/fenstra/firstboot
RemainAfterExit=yes
TimeoutStartSec=10min

[Install]
WantedBy=multi-user.target
EOF

systemctl enable fenstra-firstboot.service
systemctl enable fenstra-snapshot-weekly.timer
systemctl enable fenstra-btrfs-scrub.timer
systemctl enable snapper-cleanup.timer

# =============================================================================
# Teil 6: Messwerkzeug für die Leistungs-Basiswerte
# =============================================================================
cat > /usr/bin/fenstra-baseline << 'EOF'
#!/bin/bash
# Fenstra: Leistungs-Basiswerte erfassen (Bootzeit, RAM, Dienste, Grafik).
# Aufruf im Terminal (Konsole) nach ca. 2 Minuten Leerlauf auf dem Desktop:
#   fenstra-baseline            -> schreibt ~/fenstra-baseline-<Datum>.txt
#   fenstra-baseline pfad.txt   -> eigener Dateiname
out="${1:-$HOME/fenstra-baseline-$(date +%Y%m%d-%H%M%S).txt}"
{
  echo "Fenstra Basiswerte – $(date -Is)"
  grep -E '^(PRETTY_NAME|VARIANT_ID)=' /etc/os-release
  echo "Kernel: $(uname -r)"
  echo "Sitzung: ${XDG_SESSION_TYPE:-?} / ${XDG_CURRENT_DESKTOP:-?}"
  echo "Live-Modus: $(grep -q rd.live.image /proc/cmdline && echo ja || echo nein)"
  echo; echo "== Bootzeit (systemd) =="; systemd-analyze time 2>/dev/null
  echo; echo "== Größte Bremsen beim Start =="; systemd-analyze blame 2>/dev/null | head -20
  echo; echo "== Kritischer Pfad =="; systemd-analyze critical-chain 2>/dev/null | head -30
  echo; echo "== Speicher (MB) =="; free -m
  echo; echo "== zRAM / Swap =="; zramctl 2>/dev/null; swapon --show 2>/dev/null
  echo; echo "== Prozesse nach Speicher (RSS in KB) =="; ps -eo rss,pid,comm --sort=-rss | head -15
  echo; echo "== Laufende Dienste ($(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)) =="
  systemctl list-units --type=service --state=running --no-pager --no-legend
  echo; echo "== Grafik =="; lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display'
  ls /sys/class/drm 2>/dev/null | tr '\n' ' '; echo
  echo; echo "== Dateisysteme =="; findmnt -t btrfs,ext4,vfat,overlay -o TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null
  echo; echo "== SELinux =="; getenforce 2>/dev/null; ls -Z /etc/passwd 2>/dev/null
  echo; echo "== Wiederherstellungspunkte =="; snapper -c root list 2>/dev/null || echo "(keine Snapper-Konfiguration)"
  echo; echo "== Ersteinrichtung =="; tail -n 20 /var/log/fenstra-firstboot.log 2>/dev/null || echo "(kein Protokoll)"
} | tee "$out"
echo; echo "Gespeichert: $out"
EOF
chmod 0755 /usr/bin/fenstra-baseline

echo "Fenstra %post abgeschlossen"
%end
