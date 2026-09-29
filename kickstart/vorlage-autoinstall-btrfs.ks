# =============================================================================
# Fenstra – VORLAGE für eine unbeaufsichtigte Installation (NICHT für das Live-ISO)
# =============================================================================
# Zweck: zeigt die gewünschte Plattenaufteilung mit den Btrfs-Subvolumes
#   "@"     -> /       (System)
#   "@home" -> /home   (persönliche Daten)
# Der grafische Installer (Anaconda) auf dem Live-ISO benennt Subvolumes fest
# "root" und "home"; die Namen lassen sich dort nicht vorgeben. Funktional ist
# das gleichwertig (Snapper und das Zurücksetzen arbeiten mit beiden Namen).
# Diese Vorlage ist der Weg, wenn Fenstra später einen eigenen Installations-
# ablauf bekommt oder eine Test-VM vollautomatisch aufgesetzt werden soll.
#
# ACHTUNG: "clearpart --all" LÖSCHT ALLE PLATTEN DER MASCHINE VOLLSTÄNDIG.
#          Nur in einer VM mit einer leeren virtuellen Platte verwenden.
#
# Verwendung (Beispiel): Fedora-Netzinstaller starten und am Bootmenü
#   inst.ks=https://…/vorlage-autoinstall-btrfs.ks
# anhängen. Der Testbenutzer heißt "nutzer" mit dem Passwort "fenstra".
# Diese Vorlage enthält NICHT die Fenstra-Anpassungen aus fenstra-live.ks
# (%post). Sie dokumentiert nur das Plattenlayout.
# =============================================================================

lang de_DE.UTF-8
keyboard --vckeymap=de --xlayouts=de
timezone Europe/Berlin

url  --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch

network --bootproto=dhcp --device=link --activate --hostname=fenstra
selinux --enforcing
firewall --enabled

# Nur für Tests in einer VM. Vor jeder echten Nutzung ersetzen.
rootpw --lock
user --name=nutzer --gecos="Fenstra Nutzer" --groups=wheel --plaintext --password=fenstra

# --- Plattenaufteilung -----------------------------------------------------------
zerombr
clearpart --all --initlabel --disklabel=gpt
# Plattformabhängige Startpartitionen automatisch (UEFI: /boot/efi, BIOS: biosboot)
# plus separates /boot (Fedora-Standard; Kernel liegen damit außerhalb der Snapshots,
# siehe docs/roadmap.md, Baustein Wiederherstellungspunkte).
reqpart --add-boot
# Rest der Platte: ein Btrfs-Volume mit zwei Subvolumes
part btrfs.01 --fstype=btrfs --grow --size=8192
btrfs none  --label=fenstra btrfs.01
btrfs /     --subvol --name=@     fenstra
btrfs /home --subvol --name=@home fenstra

bootloader --timeout=1
reboot

%packages
@^kde-desktop-environment
snapper
libdnf5-plugin-actions
btrfs-progs
tuned
tuned-ppd
zram-generator-defaults
langpacks-de
cascadia-code-fonts
-plasma-workspace-x11
-kwin-x11
-kmail
-kontact
-korganizer
-kaddressbook
-akregator
-kmail-account-wizard
%end
