# Fenstra – Projektgedächtnis

Diese Datei wird in jeder Sitzung zuerst gelesen. Sie hält fest, was gilt, was erreicht ist
und was als Nächstes kommt. Bei Änderungen am Stand bitte hier nachziehen.

## Ziel und Rahmen

- Fenstra: Desktop-OS auf Fedora 44 + KDE Plasma (Wayland), das Windows 11 in Aussehen und
  Bedienung so nah wie möglich nachbildet. Zielgruppe: Menschen, die nur Windows kennen.
- Fedora Remix. Keine Microsoft-Dateien, -Marken, -Wallpaper, -Schriften, kein „Windows“ im
  Namen. Nur frei lizenzierte oder eigene Assets: Fluent UI System Icons (MIT), Cascadia Code
  (OFL), Selawik (OFL), eigene Grafiken (CC-BY-SA-4.0). Systeminfo: „basiert auf Fedora Linux“.
- Bei jedem Baustein ehrlich sagen, was 1:1 geht, was nachgebaut wird, was nicht geht.
- Immer erst in der VM testen. Vor riskanten Aktionen (Partitionieren, USB-Sticks schreiben,
  Änderungen am laufenden System) ausdrücklich warnen.
- Erst messen (Baseline), dann optimieren, dann erneut messen. Richtwerte: Boot < 15 s auf SSD,
  RAM im Leerlauf < 1,5 GB, 60 fps mit Blur.
- Der Nutzer (Daniel) spricht Deutsch, hat fortgeschrittene Linux-Erfahrung, keine mit
  Distro-Build-Systemen. Antworten auf Deutsch, Kommandos kurz erklären, Schritt für Schritt.

## Entscheidungen (nicht erneut diskutieren)

- Registry: wird nicht nachgebaut, kein Registrierungs-Editor.
- „Windows Update“ = Fedora-Updates + Flatpak + fwupd in einer Oberfläche „Updates“, davor
  Snapper-Wiederherstellungspunkt.
- „Defender“: kein Echtzeitscanner. Schichten SELinux (enforcing), firewalld, signierte Pakete,
  Secure Boot, Flatpak-Sandbox. ClamAV nur als Prüfung von .exe vor dem ersten Wine-Start.
- Mica: KWin-Blur entspricht Acrylic (Startmenü, Schnelleinstellungen). Mica für
  Fensterhintergründe als getönte, verwischte Kopie des Wallpapers, neu berechnet beim
  Wallpaper-Wechsel (günstig, kein Live-Blur).
- EU OS als Basis: nein (bootc/Kinoite, unveränderlich; passt nicht zu RPM/Wine/Snapper).
- Name „Fenstra“: für privaten Test unproblematisch; vor Veröffentlichung TMview/DPMA Klassen
  9 und 42 prüfen (Fenstra AG Schweiz, fenstra.no, FENSTRA LTD UK existieren).
- fenstra-release ersetzt fedora-release NICHT (exakte Versionsabhängigkeit). Stattdessen
  RPM-Dateitrigger auf /usr/lib/os-release, der die Fenstra-Kennung nach jedem Update erneut
  schreibt. ID bleibt „fedora“.
- Fedora 44 KDE nutzt den Plasma Login Manager (nicht SDDM) und die Anaconda-Weboberfläche.
  Kein SDDM-Thema bauen. Anmeldebildschirm im Windows-Aufbau wird in 4b am Plasma Login
  Manager geprüft.
- Subvolume-Namen im grafischen Installer sind fest „root“/„home“ (nicht @/@home); gleichwertig.
- grub-btrfs ist nicht in Fedora; kommt in 4d als eigenes Paket.

## Umgebung des Nutzers

- Windows 11, WSL2 mit FedoraLinux-44. Build läuft NUR dort, als root:
  PowerShell: `wsl -d FedoraLinux-44 -u root`; Prompt muss `root@Daniel-PC` zeigen.
  Eine Ubuntu-Shell (`daniel@Daniel-PC`) ist die falsche Shell.
- Repo liegt unter /root/Fenstra (Linux-Dateisystem, nicht /mnt/c). Branch: claude/gifted-bell-sylvb0.
- Bau-Verzeichnis /var/lib/fenstra-build (repo/, rpmbuild/, sources/, out/, logs/, tmp/).
  955 GB frei. ISO von Windows aus: `\\wsl$\FedoraLinux-44\var\lib\fenstra-build\out\…`.
- `git push` aus WSL braucht ein Token (Credential Manager von Git für Windows oder
  Personal Access Token). Unversendete lokale Commits können vorliegen (Build-Bericht
  20260929-2042). Vor dem Bauen: `git pull --rebase`.
- WSL belegt beim Bauen bis ~39 GB RAM als Cache; `wsl --shutdown` gibt ihn frei. Optional
  `C:\Users\Daniel\.wslconfig` mit `[wsl2]` `memory=20GB`.
- Hyper-V/VirtualBox installiert der Nutzer selbst (Admin). Hyper-V: Gen 2, 8192 MB fest,
  4 CPUs, 60 GB, Secure Boot mit Vorlage „Microsoft UEFI-Zertifizierungsstelle“.
- Test-VM „Fenstra-Test“ existiert (Dateien C:\Users\Daniel\Fenstra\vm\, Skript
  C:\Users\Daniel\Fenstra\neue-vm.ps1). Installiert mit Build #2, Benutzer daniel (Passwort
  kennt der Nutzer; nicht ins Repo schreiben). SSH vom Windows-PC:
  `ssh -i ~\.ssh\fenstra-vm -o UserKnownHostsFile=~\.ssh\known_hosts_fenstra daniel@<IP>`
  (IP per Default Switch, wechselt; im Gast `ip -4 -br a`). sudo per `echo <pw> | sudo -S`.
- Claude Code kann die VM auch direkt bedienen (Windows-Sitzung mit Admin): Screenshots über
  Msvm_VirtualSystemManagementService.GetVirtualSystemThumbnailImage, Eingaben über
  Msvm_Keyboard/Msvm_SyntheticMouse. Lehren: Maus-Koordinaten = Gastpixel, aber das
  vmconnect-Fenster muss in Ruhe sein (Nutzer-Maus stört); TypeText kommt im Gast nicht an,
  einzelne TypeKey-Aufrufe schon; Gast hat DE-Belegung (y/z, Sonderzeichen umrechnen,
  AltGr = rechte Alt-Taste VK 0xA5, <>|-Taste nur per Scancode 0x56); Qt-Knöpfe per
  Leertaste, Tab-Fokus kann auf „Neu starten“ landen.
- Aus der Claude-Umgebung sind GitHub, invent.kde.org, download.kde.org und jsdelivr
  gesperrt; src.fedoraproject.org, dl.fedoraproject.org, npmjs.org, pypi erreichbar.
  Fedora-44-Paketdaten lassen sich von dl.fedoraproject.org laden und auswerten.

## Arbeitsablauf

```
bash build/prepare-wsl.sh      # Werkzeuge
bash build/validate.sh         # ksvalidator, Bash, JSON, SVG/XML, Python, rpmspec
bash build/build-packages.sh   # 7 RPMs -> /var/lib/fenstra-build/repo (createrepo_c)
bash build/build-iso.sh        # livemedia-creator --no-virt, ~20 min, ISO + SHA256
bash build/report.sh <stamp>   # Auszüge nach berichte/ bei Fehlern
```
Fehlersuche: `grep -n 'return code [1-9]' logs/<stamp>/anaconda/dnf.log`, dann konsole.log,
livemedia.log, packaging.log. Anaconda loggt chpasswd nicht; Passwortfehler mit Kopie von
/etc/passwd,shadow in /tmp/t und `chpasswd -e -R /tmp/t` nachstellen.

## Stand (zuletzt 2026-10-04)

- Schritt 1+2 erledigt: Analyse (docs/01), Kickstart, Build-Skripte, Doku.
- Baustein 4a (Branding/Theme) als Pakete fertig: fenstra-release, fenstra-logos,
  fenstra-backgrounds, fenstra-theme (+ plymouth-theme-fenstra), fenstra-icon-theme,
  selawik-fonts. Alle 7 RPMs gebaut. Details docs/04a-branding-und-theme.md, packages/README.md.
- Build #2 erfolgreich: Fenstra-44-x86_64-20260929-2148.iso, 4,0 GB,
  SHA256 256c4b7b696cb993a689540a221da012b68c20883bdae08350921a4ac51b6d35.
- 2026-10-04 VM-Test Build #2 in Hyper-V durchgeführt, installiert, gemessen. Protokoll:
  messungen/2026-10-04-hyperv-build2-4a-pruefung.md. Kurz: Secure Boot ok, Boot 6,4 s,
  SELinux enforcing ohne AVC, Snapper-Snapshot 1 da, Branding/Theme/Schriften/Symbole ok,
  Sperr-/Anmeldebildschirm bereits Windows-artig. RAM 1914 MB (Ziel 1,5 GB verfehlt).
- Offen vor 4b (Korrekturen 4a, dann Build #3):
  1. fenstra-theme.spec:57 Symlink splash im Dark-Paket → KDE „Path traversal“; kopieren.
  2. Logo weiß, im hellen Design unsichtbar (Info-Zentrum) → farbige/dunkle Variante.
  3. Rechnername leer → Ersteinrichtung setzt `fenstra`, wenn /etc/hostname leer.
  4. Branding: Plasma Setup „Willkommen bei Plasma Desktop“, KDE-Maskottchen im
     Begrüßungsassistenten, Installer-Symbol Fedora-„f“.
  5. fenstra-baseline: Snapper nur mit root lesbar.
  6. „Schreibtisch“-Ordner mit Monitor-Symbol / Doppelname Arbeitsfläche.
  Danach Baustein 4b (Taskleiste, Startmenü, Schnelleinstellungen, KWin-Rundungen/Blur).
  RAM-Abspecken (plasma-keyboard, xwaylandvideobridge, kdeconnect, DiscoverNotifier, abrt …)
  im Querschnitt Leistung. Hyper-V hat nur llvmpipe: fps/Blur dort nicht messbar.
- Notiert für später: ISO 4 GB ist größer als Fedoras KDE-Spin (abspecken, Querschnitt
  Leistung); squashfs-Packen 6 min, zstd testen (`FENSTRA_SQUASHFS=zstd`); Cursor-Thema,
  bunte Gerätesymbole (4c); Selawik-Archiv ist unversioniertes master (Prüfsumme eingetragen).

## Lehren aus den Builds (Fehler, die nicht wiederkommen sollen)

- Bau-Image: 10 GB reichen für Fedora-44-KDE nicht; 20 GB gesetzt.
- `rootpw --lock --iscrypted locked` (Fedoras alte Vorlage) scheitert, chpasswd in F44 prüft
  den Hash. Richtig: `rootpw --lock`.
- livemedia-creator in lorax 44 kennt `--title` nicht.
- RPM expandiert Makros auch in Kommentaren: nie `%fontpkg` o. ä. in Kommentare schreiben.
- `%fontpkg` erzeugt Name/Summary/License/BuildArch/BuildRequires selbst; keine Duplikate.
- Selawik-Repo enthält nur UFO-Quellen; TTFs werden mit fontmake gebaut.
- rpm 6: `%license` braucht eine Datei im Bauverzeichnis, kein `%{SOURCEn}`.
- Mit `set -euo pipefail` bricht `cmd | grep` bei „nichts gefunden“ still ab; `|| true` setzen.
- desktop-backgrounds-compat nicht ausschließen (sddm/sddm-breeze verlangen es).
- Paketnamen des Kickstarts sind gegen die F44-Paketdaten geprüft (alle vorhanden).

## Roadmap (Kurzform, Details docs/roadmap.md)

0 Build+Baseline → 4a Branding (fertig, Test offen) → 4b Taskleiste/Startmenü/Schnell-
einstellungen/KWin → 4c Dateimanager mit Laufwerksbuchstaben → 4d Wiederherstellungspunkte
(grub-btrfs, Zurücksetzen) → 4e Wine/Proton → 4f Einstellungen-App → 4g Fenstra Store →
5 Abschluss: USB-Stick erst, wenn alles in der VM läuft.
