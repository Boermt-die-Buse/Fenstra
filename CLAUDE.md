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
- `git push` direkt aus WSL (seit 2026-10-05): GitHub CLI `gh` mit klassischem Token
  (Scopes `repo`, `read:org`; Konto Boermt-die-Buse), gespeichert in /root/.config/gh/hosts.yml,
  Git nutzt ihn über `gh auth git-credential`. Prüfen: `gh auth status`. Token läuft nach
  ~90 Tagen ab → neuen klassischen Token erzeugen, `gh auth login` (Nutzer macht das selbst,
  Token nie in Chat oder Repo). Fein-granulare Token gingen nicht (403, Schreibrecht im neuen
  GitHub-Formular nicht einstellbar). Notlösung ohne Token: Git-Bundle nach Windows, dort
  klonen und mit dem Windows-Git pushen. Vor dem Bauen: `git pull --rebase`.
- WSL belegt beim Bauen bis ~39 GB RAM als Cache; `wsl --shutdown` gibt ihn frei. Optional
  `C:\Users\Daniel\.wslconfig` mit `[wsl2]` `memory=20GB`.
- Hyper-V/VirtualBox installiert der Nutzer selbst (Admin). Hyper-V: Gen 2, 8192 MB fest,
  4 CPUs, 60 GB, Secure Boot mit Vorlage „Microsoft UEFI-Zertifizierungsstelle“.
- Test-VM „Fenstra-Test5“ (Build #5, Entwicklungs-VM; Dateien C:\Users\Daniel\Fenstra\vm\).
  Ältere VMs und ISOs (Builds #2–#4) am 2026-10-05 gelöscht; ISO #5 liegt in
  C:\Users\Daniel\Fenstra\ und /var/lib/fenstra-build/out/20261004-1608/. In Test5 ist das
  Startmenü 44.0-5 zusätzlich als Benutzerkopie (~/.local/share/plasma/plasmoids) installiert. Überall Benutzer
  daniel (Passwort kennt der Nutzer; nicht ins Repo schreiben). sudo per `echo <pw> | sudo -S`.
- VM-Werkzeuge im Repo: **tools/README.md** (Ablauf eines VM-Tests, Stolpersteine).
  tools/hyperv/*.ps1 (Windows, Admin): neue-vm, vm-screenshot, vm-input (Maus/Tastatur mit
  DE-Belegung), vm-bootshots, vm-ip, vm-von-platte-starten, vm-ssh-einrichten.
  tools/vm/*.sh (in der VM): plasmoid-deploy, testsitzung. Windows kann /root in WSL nicht
  lesen → Arbeitskopie: `wsl -d FedoraLinux-44 -u root -- cp -r /root/Fenstra/tools/hyperv
  /mnt/c/Users/Daniel/Fenstra/tools/`, Aufruf aus C:\Users\Daniel\Fenstra\tools\hyperv\.
  SSH: `ssh -i ~\.ssh\fenstra-vm -o UserKnownHostsFile=~\.ssh\known_hosts_<vm> daniel@<IP>`,
  IP mit vm-ip.ps1 (wechselt nach jedem Neustart).
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
- Korrekturen 4a umgesetzt (2026-10-04, Pakete Release 2, Kickstart „Build #3“):
  Dark-Splash als Kopie; Info-Zentrum-Logo farbig; Ersteinrichtung setzt Rechnername
  `fenstra`; Begrüßungsassistent mit Fenstra-Logo/-Text; Installer-Symbol = Fenstra-Logo
  (Symbolthema „apps/scalable“ verlinkt fenstra-logo-icon); Snapper für wheel lesbar
  (ALLOW_GROUPS, SYNC_ACL) + Hinweis in fenstra-baseline; Arbeitsfläche-Symbol in
  Akzentblau (Generator-Art „accent:“).
- Build #3 erfolgreich: Fenstra-44-x86_64-20261004-1402.iso, 4,0 GB, SHA256
  d2786076ab590021510931077c23650af779d6adaf05ebce8e50dbe55a40afd2. In VM „Fenstra-Test3“
  installiert und geprüft: alle Korrekturen bestätigt, Plymouth-Bootscreen sichtbar,
  Boot 6,36 s, RAM 1917 MB, SELinux enforcing. Protokoll:
  messungen/2026-10-04-hyperv-build3-4a-pruefung.md. Baustein 4a damit abgeschlossen.
- Bleibt offen: Plasma Setup „Willkommen bei Plasma Desktop“ + Konqi-Abschlussbild (nur per
  Paket-Patch), grauer Hintergrund in Plasma Setup, Ordnername „Schreibtisch“ vs.
  „Arbeitsfläche“ (Windows: „Desktop“, 4c).
- Baustein 4b in drei Schritten (docs/04b-taskleiste-und-fenster.md). 4b-1 fertig: Taskleiste
  im Windows-11-Aufbau (Layout-Skript im globalen Design), Fensterrahmen (/etc/xdg/breezerc),
  Suche mittig (krunnerrc). Build #4 (20261004-1509, SHA256 af418d67…5b35f) in VM
  „Fenstra-Test4“ geprüft, RAM 1919 MB, Boot 6,83 s.
- 4b-2 umgesetzt: Startmenü-Plasmoid org.fenstra.startmenu (Unterpaket fenstra-startmenu,
  Quellen packages/fenstra-theme/src/plasmoids/), reines QML auf Kicker-Modellen; in VM
  „Fenstra-Test4“ per RPM geprüft (Suche, Angeheftet, Alle Apps, Empfohlen, Ein/Aus,
  Anheften/Lösen, Windows-Taste). Build #5 (20261004-1608, SHA256 9a7b68a8…1028) in VM
  „Fenstra-Test5“: erstes Anmelden ok, RAM 1911 MB, Boot 6,60 s. 4b-2 abgeschlossen.
- Präsentation des Fortschritts (Vorher/Nachher, orange Markierungen) liegt lokal unter
  C:\Users\Daniel\Fenstra\praesentation\fenstra-fortschritt.html (nicht im Repo).
- Danach 4b-3 (Schnelleinstellungen, Benachrichtigungen, Snap-Layouts, Win+Tab usw.).
- Lehren QML/Plasma 6: Avatar kommt aus org.kde.kirigamiaddons.components (nicht Kirigami);
  „Alle Apps“ = rootModel.modelForRow(0) nach onRefreshed (eigenes AppsModel zeigt
  Kategorien); plasmashell cacht QML → nach Änderung `systemctl --user restart
  plasma-plasmashell`; QIcon-Rollen (decoration) nur über Kirigami.Icon anzeigen.
- Test-VM-Sitzung: Autolock/Bildschirm aus für den Testbenutzer abgeschaltet
  (kscreenlockerrc/powerdevilrc im Benutzerordner), sonst sperrt die VM beim Entwickeln.
- Schnelles Testen ohne ISO: Prototyp per SSH in die laufende VM, Layout per
  `qdbus-qt6 org.kde.plasmashell /PlasmaShell …evaluateScript`, Paket per `dnf install` der
  neuen RPM und `plasma-apply-lookandfeel --resetLayout -a org.fenstra.desktop`.
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
- Der ISO-Bau löscht in WSL die binfmt-Registrierung `WSLInterop`: danach starten keine
  Windows-Programme mehr aus WSL („Exec format error“). Wiederherstellen:
  `echo ':WSLInterop:M::MZ::/init:PF' > /proc/sys/fs/binfmt_misc/register` oder `wsl --shutdown`.
- KDE-Pakete (Look-and-Feel, kf.package) lehnen Symlinks aus dem Paketverzeichnis hinaus ab
  („Path traversal attempt detected“): Dateien kopieren, nicht verlinken.
- Begrüßungsassistent: /usr/share/plasma/plasma-welcome/intro-customization.desktop
  (Name = Einleitungstext, Comment = Bildunterschrift, Icon = Bild statt Konqi, URL).
- Plasma Setup: „Willkommen bei Plasma Desktop“ und Konqi-Bild auf der Abschlussseite sind
  fest im Paket (nicht anpassbar ohne eigenen Paket-Patch); es schreibt den Rechnernamen
  nur, wenn man ihn ändert.
- Info-Zentrum-Logo kommt aus /etc/xdg/kcm-about-distrorc (kde-settings) →
  /usr/share/pixmaps/system-logo-white.png (liefert fenstra-logos, farbig).
- Das Symbol `user-desktop` nutzt auch der Taskleistenknopf „Arbeitsfläche anzeigen“:
  keine Ordnergrafik dafür verwenden.

## Roadmap (Kurzform, Details docs/roadmap.md)

0 Build+Baseline → 4a Branding (fertig, Test offen) → 4b Taskleiste/Startmenü/Schnell-
einstellungen/KWin → 4c Dateimanager mit Laufwerksbuchstaben → 4d Wiederherstellungspunkte
(grub-btrfs, Zurücksetzen) → 4e Wine/Proton → 4f Einstellungen-App → 4g Fenstra Store →
5 Abschluss: USB-Stick erst, wenn alles in der VM läuft.
