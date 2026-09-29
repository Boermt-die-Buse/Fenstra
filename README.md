# Fenstra

Ein Desktop-Betriebssystem auf Basis von **Fedora Linux 44** und **KDE Plasma (Wayland)**, das Aussehen und Bedienung von Windows 11 so nah wie möglich nachbildet, ohne Microsoft-Dateien, -Marken, -Wallpaper oder -Schriften. Zielgruppe: Menschen, die nur Windows kennen und im Alltag nichts von Linux lernen wollen.

Fenstra ist ein Fedora Remix. Es ist kein Produkt von Microsoft und kein Produkt des Fedora-Projekts. In den Systeminfos steht „basiert auf Fedora Linux“.

## Stand

| Baustein | Status |
|---|---|
| Analyse, Machbarkeit, EU-OS-Prüfung, Namensprüfung | erledigt: [docs/01-analyse-und-machbarkeit.md](docs/01-analyse-und-machbarkeit.md) |
| Basis-Kickstart (KDE, Installer-Profil mit Btrfs, Snapper-Vorbereitung, zRAM, Platzhalter-Branding) | geschrieben und mit ksvalidator geprüft: [kickstart/fenstra-live.ks](kickstart/fenstra-live.ks) |
| Erster ISO-Build in WSL | **offen**, muss in FedoraLinux-44 laufen: `bash build/build-iso.sh` |
| Test in VM, Leistungs-Basiswerte | offen: [docs/02-build-und-test.md](docs/02-build-und-test.md) |
| Branding/Theme, Taskleiste/Startmenü, Dateimanager, Wiederherstellung, Wine, Einstellungen-App, Fenstra Store | geplant: [docs/roadmap.md](docs/roadmap.md) |

## Schnellstart (Windows 11 mit WSL2, Distribution FedoraLinux-44)

```powershell
wsl -d FedoraLinux-44
```

```bash
git clone https://github.com/Boermt-die-Buse/Fenstra.git /root/Fenstra
cd /root/Fenstra
git checkout claude/tender-faraday-tu06gv
bash build/prepare-wsl.sh     # Werkzeuge prüfen/installieren, Loop-Mount testen
bash build/validate.sh        # Kickstart prüfen
bash build/build-iso.sh       # ISO bauen (15–45 Minuten, ca. 3 GB Download)
```

Wichtig: Das Projekt muss im Linux-Dateisystem der WSL-Distribution liegen (z. B. `/root/Fenstra`), nicht unter `/mnt/c`. Loop-Mounts und Dateirechte funktionieren auf Windows-Laufwerken nicht.

## Aufbau

```
kickstart/
  fenstra-live.ks                Basis-Kickstart für das Live-ISO (Build #1)
  vorlage-autoinstall-btrfs.ks   Vorlage: unbeaufsichtigte Installation mit Subvolumes @ und @home
build/
  prepare-wsl.sh                 Werkzeuge in FedoraLinux-44 prüfen und installieren
  validate.sh                    ksvalidator und Bash-Syntaxprüfung der eingebetteten Skripte
  build-iso.sh                   livemedia-creator --no-virt, Ergebnis + SHA256 + Protokolle
  report.sh                      Build-Bericht (Auszüge der Protokolle) nach berichte/
docs/
  01-analyse-und-machbarkeit.md  Was geht 1:1, was wird nachgebaut, was geht nicht; EU OS; Name
  02-build-und-test.md           Bauen, in VM testen (Hyper-V/VirtualBox), Basiswerte messen
  roadmap.md                     Bausteine 4a–4g mit Messpunkten
messungen/                       Basiswerte aus VM/Hardware (fenstra-baseline)
berichte/                        Build-Berichte aus build/report.sh
```

## Arbeitsweise

Immer erst in einer VM testen. Vor riskanten Schritten (Partitionierung, USB-Sticks schreiben, Änderungen am laufenden System) wird ausdrücklich gewarnt. Nach jedem Baustein werden Bootzeit, RAM im Leerlauf und Flüssigkeit gemessen (`fenstra-baseline` im gebauten System).

## Lizenz

Noch festzulegen. Der Kickstart leitet sich strukturell von `fedora-kickstarts` (GPLv3+) ab, deshalb ist GPLv3+ für das Repo der naheliegende Vorschlag. Assets kommen nur aus frei lizenzierten Quellen (Fluent UI System Icons: MIT, Cascadia Code: OFL, Selawik: OFL) oder werden selbst erstellt.
