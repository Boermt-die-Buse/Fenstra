# Schritte 2 und 3: ISO bauen, in einer VM testen, Basiswerte messen

## Voraussetzungen

- Windows 11 mit WSL2 und der Distribution **FedoraLinux-44** (Benutzer root, 16 Kerne, 31 GB RAM).
- Etwa **30 GB frei** im Linux-Dateisystem der Distribution (nicht auf `C:`). Der Build legt ein 10-GB-ext4-Image an, packt es und baut das ISO.
- Internet: etwa **2–3 GB Download** aus den Fedora-Spiegeln pro Build. Ein lokaler Zwischenspeicher kommt später, wenn wir häufiger bauen.

## Bauen

```powershell
wsl -d FedoraLinux-44
```

```bash
git clone https://github.com/Boermt-die-Buse/Fenstra.git /root/Fenstra
cd /root/Fenstra
git checkout claude/tender-faraday-tu06gv
bash build/prepare-wsl.sh
bash build/validate.sh
bash build/build-iso.sh
```

Was die Skripte tun:

- `prepare-wsl.sh` installiert nur Pakete aus den Fedora-Quellen (lorax, lorax-lmc-novirt, pykickstart, xorriso, squashfs-tools, dosfstools, isomd5sum) und macht einen Loop-Mount-Test mit einer temporären 64-MB-Datei. Es berührt keine Platten oder Partitionen.
- `validate.sh` prüft die Kickstart-Dateien mit `ksvalidator -v F44` und die Bash-Syntax aller eingebetteten Skripte.
- `build-iso.sh` ruft `livemedia-creator --make-iso --no-virt` auf. Ergebnis und SHA256 liegen unter `/var/lib/fenstra-build/out/<Zeitstempel>/`, die Protokolle unter `/var/lib/fenstra-build/logs/<Zeitstempel>/`. Das ISO ist von Windows aus unter `\\wsl$\FedoraLinux-44\var\lib\fenstra-build\out\...` erreichbar, oder du lässt es kopieren:

```bash
FENSTRA_COPY_TO=/mnt/c/Users/<DeinName>/Fenstra bash build/build-iso.sh
```

Der Build dauert 15–45 Minuten. Die Konsole zeigt den Anaconda-Fortschritt (Pakete herunterladen, installieren, %post, dracut, squashfs, ISO).

### Wenn der Build scheitert

```bash
bash build/report.sh
git add berichte && git commit -m "Build-Bericht" && git push
```

`report.sh` legt kleine Auszüge (Fehlerzeilen, letzte 200 Zeilen des lorax-Protokolls, Paketliste) unter `berichte/<Zeitstempel>/` ab. Wenn du die ins Repo schiebst, kann ich sie in der nächsten Sitzung direkt lesen. Die häufigsten Ursachen beim ersten Build:

| Symptom im Protokoll | Ursache | Behebung |
|---|---|---|
| `No match for group package` / `No match for argument` in `anaconda/packaging.log` | Paket- oder Gruppenname passt nicht zu Fedora 44 | Name im Kickstart anpassen (ich konnte die Namen nicht live gegen F44 prüfen) |
| `losetup` / `mount` Fehler in `anaconda/program.log` | Loop-Geräte in WSL | `prepare-wsl.sh` erneut laufen lassen; ggf. `wsl --shutdown` und neu starten |
| `No space left on device` | zu wenig Platz unter `/var/lib/fenstra-build` | Platz schaffen oder `FENSTRA_WORK=/anderer/pfad` |
| Spiegelserver-Fehler in `anaconda/dnf.librepo.log` | Netzwerk/Spiegel | erneut versuchen |
| Fehler beim ISO-Bau nach erfolgreicher Installation (`livemedia.log`) | fehlende Bootloader-Dateien oder xorriso | Protokoll schicken |

Wenn es in WSL grundsätzlich nicht geht (z. B. Anaconda scheitert an fehlendem SELinux oder D-Bus), ist der nächste Weg eine Fedora-44-VM in Hyper-V, in der dieselben Skripte laufen. Das hat den Nebeneffekt, dass das Image dann SELinux-Labels bekommt und `selinux --enforcing` gesetzt werden kann.

## Test in einer VM

Beides funktioniert. Hyper-V ist auf deinem Rechner die schnellere Wahl, weil WSL2 sowieso auf Hyper-V aufsetzt; VirtualBox läuft daneben nur im langsameren Hyper-V-Kompatibilitätsmodus. Beide brauchen Admin-Rechte zur Installation (machst du selbst).

### Hyper-V (empfohlen für Boot- und RAM-Messung)

1. Windows-Features: „Hyper-V“ aktivieren, Neustart.
2. Hyper-V-Manager: Neu, Virtueller Computer, **Generation 2**.
3. Arbeitsspeicher: **8192 MB**, dynamischen Arbeitsspeicher **aus** (sonst verfälscht das die RAM-Messung).
4. Netzwerk: „Default Switch“.
5. Festplatte: neue VHDX, **60 GB**.
6. Installationsoptionen: „Betriebssystem von startbarer Image-Datei installieren“, das Fenstra-ISO wählen.
7. Nach dem Anlegen in den Einstellungen: Prozessor **4** virtuelle Prozessoren; Sicherheit: **Sicherer Start ein**, Vorlage **„Microsoft UEFI-Zertifizierungsstelle“** (die Standardvorlage „Microsoft Windows“ startet Linux nicht). Damit wird die signierte Fedora-Startkette (shim, GRUB, Kernel) real geprüft.
8. Prüfpunkte (Checkpoints) für Messungen ausschalten.

Einschränkung: Hyper-V hat keine 3D-Beschleunigung für Linux-Gäste. Plasma rendert per Software (llvmpipe). Bootzeit und RAM sind aussagekräftig, Animationen und fps nicht.

### VirtualBox (7.1 oder neuer)

1. Neu: Typ Linux, Version „Fedora (64-bit)“, 8192 MB RAM, 4 CPUs, 60 GB VDI.
2. System, Hauptplatine: **EFI aktivieren**; Secure Boot kann in VirtualBox 7.1+ ebenfalls eingeschaltet werden.
3. Anzeige: Grafikcontroller **VMSVGA**, 128 MB, **3D-Beschleunigung an**. Damit gibt es etwas GPU-Beschleunigung; für Flüssigkeit trotzdem nur ein grober Eindruck.
4. Massenspeicher: ISO als optisches Laufwerk einhängen.

### Was im Live-Modus zu prüfen ist

1. Bootmenü zeigt „Start Fenstra 44“ (kommt aus `--title`).
2. Desktop startet automatisch als Benutzer `liveuser`, deutsche Tastatur, deutsche Oberfläche.
3. Auf dem Desktop liegt das Installer-Symbol (heißt in Build #1 noch „Auf Festplatte installieren“; wird im Branding-Baustein zu „Fenstra installieren“).
4. Terminal (Konsole) öffnen und `fenstra-baseline` ausführen. Die Datei landet in `~/`. Im Live-Modus ist das ein erster Eindruck; die echten Basiswerte kommen vom installierten System.
5. `cat /etc/os-release` zeigt `PRETTY_NAME="Fenstra 44 (basiert auf Fedora Linux)"`.

### Installation in der VM

1. Installer starten. Er sollte „Fenstra“ im Titel zeigen und unter Ziel „Automatisch“ ein Btrfs-Volume mit den Subvolumes `root` und `home` anlegen (Profil `/etc/anaconda/profile.d/fenstra.conf`, zstd-Kompression).
2. Benutzer anlegen, installieren, neu starten, ISO auswerfen.
3. **Erster Start**: `fenstra-firstboot` ergänzt `noatime` in `/etc/fstab`, legt die Snapper-Konfiguration an, verschiebt die Snapshots in ein eigenes Top-Level-Subvolume und erstellt den Punkt „Ausgangszustand nach Installation“. Weil das WSL-Image keine SELinux-Labels hat, plant es ein Neu-Labeling: die VM **startet einmal automatisch neu** und labelt dabei alle Dateien (1–3 Minuten, Textausgabe). Das ist gewollt.
4. **Zweiter Start**: `fenstra-firstboot` sieht die Labels und stellt SELinux auf `enforcing`. Ab dem dritten Start ist es aktiv. Protokoll: `/var/log/fenstra-firstboot.log`. Prüfen mit `getenforce` und `snapper -c root list`.

Das gilt alles nur für die Test-VM. Auf deinem echten PC wird nichts installiert.

## Basiswerte messen

Nach der Installation, VM neu starten, 2 Minuten warten, dann in der Konsole:

```bash
fenstra-baseline
```

Die Datei (`~/fenstra-baseline-<Datum>.txt`) enthält `systemd-analyze time/blame/critical-chain`, `free -m`, zRAM-Status, die 15 größten Prozesse, laufende Dienste, Dateisysteme mit Mount-Optionen, SELinux-Status, Snapper-Liste und das Ersteinrichtungs-Protokoll. Bitte in `messungen/` ablegen (z. B. `messungen/2026-10-01-hyperv-baseline.txt`) und pushen.

Zusätzlich von Hand:

| Messwert | Wie | Zielwert (echte SSD-Hardware) |
|---|---|---|
| Boot bis Desktop | Stoppuhr vom Einschalten der VM bis zum fertig gezeichneten Desktop (Autologin bitte in der VM aktivieren, damit die Passworteingabe die Zeit nicht verfälscht) | unter 15 s |
| RAM im Leerlauf | `free -m`, Spalte `used`, nach 2 Minuten ohne offene Programme | unter 1500 MB |
| Flüssigkeit | KDE Systemeinstellungen, Arbeitsflächen-Effekte, „FPS anzeigen“ aktivieren; Fenster verschieben, Startmenü öffnen | 60 fps; in Hyper-V nicht messbar, in VirtualBox nur grob |
| App-Start | Konsole, Dolphin, Firefox jeweils dreimal starten, Zeit bis zum sichtbaren Fenster | so kurz wie möglich, Vergleichswert |

Die VM-Werte sind Vergleichsbasis für die folgenden Bausteine, keine absoluten Aussagen über Hardware. Sobald das Grundsystem steht, lohnt ein Test von einem USB-Stick auf echter Hardware (davor warne ich beim Schreiben des Sticks ausdrücklich, weil dabei das Zielgerät überschrieben wird).

## Auf einen USB-Stick schreiben (erst wenn Fenstra fertig ist)

Dieser Schritt kommt zum Schluss. Alle Zwischenstände werden nur in der VM getestet; erst das fertige Fenstra kommt auf den Stick.

**Warnung:** Beim Schreiben wird der gesamte Inhalt des Sticks gelöscht. Vorher den Laufwerksbuchstaben des Sticks im Explorer prüfen und alle anderen USB-Laufwerke abziehen. Stick mit mindestens 8 GB.

Das Schreiben passiert unter Windows, nicht in WSL (WSL sieht USB-Sticks nicht als Blockgeräte):

- **Rufus** (rufus.ie): Gerät = der Stick, „Auswahl“ = das Fenstra-ISO, Partitionsschema GPT, Zielsystem UEFI. Beim Start fragt Rufus nach „ISO-Modus“ oder „DD-Modus“: **DD-Modus** wählen. Fedora-ISOs sind Hybrid-Images und werden 1:1 geschrieben.
- Alternativ **Fedora Media Writer** (getfedora.org): „Eigenes Image auswählen“, dann das Fenstra-ISO, dann den Stick. Der schreibt ebenfalls 1:1.

Vom Stick starten: PC neu starten und das Bootmenü öffnen (je nach Hersteller F12, F8, Esc oder F2), den Stick unter „UEFI: …“ wählen. Oder in Windows: Einstellungen, System, Wiederherstellung, „Erweiterter Start“, dann „Ein Gerät verwenden“. Secure Boot kann eingeschaltet bleiben; die Fedora-Startkette ist signiert.

**Live-Modus ist gefahrlos**: Solange du nicht auf „Auf Festplatte installieren“ klickst, wird die Platte des PCs nicht angefasst. Änderungen im Live-System liegen im RAM und sind nach dem Neustart weg. Der Installer gehört auf dem echten PC vorerst nicht angeklickt; installiert wird nur in der VM.
