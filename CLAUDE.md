# Fenstra – Projektgedächtnis

Diese Datei wird in jeder Sitzung zuerst gelesen. Sie hält fest, was gilt, was erreicht ist
und was als Nächstes kommt. Bei Änderungen am Stand bitte hier nachziehen.

## Ziel und Rahmen (Fassung 2026-10-05, ersetzt alle früheren)

- **Zweck:** privater Fähigkeitstest für LLMs. Fenstra wird nie veröffentlicht oder
  weitergegeben. (Frühere Annahmen – Zielgruppe „Windows-Umsteiger“, spätere
  Veröffentlichung, Markenrecht-Vorsicht – sind hinfällig.)
- **Ziel:** 1:1-Klon von Windows 11 (24H2) in Aussehen und Verhalten: Layout, Optik,
  Bedienung, Tastenkürzel, Animationen und Texte so nah am Original wie möglich. Technische
  Basis: Fedora 44 + KDE Plasma 6 (Wayland). Alle sichtbaren Texte deutsch wie in einem
  deutschen Windows 11. Wo Windows seinen Produktnamen zeigt, steht „Fenstra“;
  Microsoft-Dienste (Konto, OneDrive, Copilot, Edge, Store) werden durch Gleichwertiges
  ersetzt oder entfallen – jeweils dokumentiert.
- **Assets:** Alles Sichtbare und Hörbare wird selbst erstellt, als SVG/Code generiert, nie
  heruntergeladen: Grafiken, Symbole, Wallpaper, Mauszeiger, Klänge, Fensterdekoration,
  Aussehen aller Bedienelemente. Schriften Selawik und Cascadia Code (frei) dürfen bleiben.
- **Erlaubt:** Fedora/KDE/Qt als Unterbau (Plasma, KWin, KDE Frameworks und -Anwendungen,
  Kvantum, Wine, systemd, NetworkManager, PipeWire); KDE-Software anpassen (umstylen,
  konfigurieren, patchen, erweitern); eigener C++/QML/Python-Code; eigene RPMs.
- **Nicht erlaubt:** Microsoft-Dateien kopieren oder aus Windows-Medien extrahieren; fertige
  Windows-11-Themes, Symbolpakete oder Plasma-Designs aus dem Netz; fremde Symbolsätze. Die
  bisher genutzten Fluent UI System Icons und die Breeze-Symbole als Rückfall werden
  schrittweise durch eigene ersetzt (Meilenstein M2).
- **KDE oder Eigenbau:** Pro Windows-App und Shell-Bestandteil wird entschieden, ob eine
  angepasste KDE-Anwendung oder ein Eigenbau näher an 1:1 kommt. Entscheidungen mit
  Begründung: docs/entscheidungen-komponenten.md.
- **Abweichungen:** Wo 1:1 technisch nicht geht, die nächstbeste Annäherung bauen und die
  Abweichung dokumentieren (in der Prüfliste des Bereichs).
- **Vorgehen:** Meilensteine nach docs/roadmap.md, selbstständig. Fragen nur bei echter
  Blockade oder vor riskanten Aktionen außerhalb der Test-VMs (USB-Stick, Partitionieren,
  Host-System). Vor jedem Bereich eine Prüfliste `docs/checkliste-<bereich>.md` mit messbaren
  Punkten (px, Hex-Farben, Schriftgrößen, Radien, Animationsdauern, Verhalten, Texte) und
  Bestehensschwelle. Jeder Meilenstein endet mit: Prüfliste bestanden, Bildschirmfotos aller
  geänderten Teile (docs/bilder/<meilenstein>/), Messung (`fenstra-baseline` nach Neustart),
  `git push` aus WSL, kurzer Bericht an den Nutzer. Testprotokoll: docs/llm-test-log.md (Ziel,
  Umsetzung, Probleme, Fehlversuche, Zeitaufwand, ehrliche Bewertung 0–10 je Bereich).
- **Testen:** in der laufenden Test-VM bei 1920×1080 (SSH, plasmoid-deploy, evaluateScript,
  Programme direkt starten, `dnf install` der RPMs). Bildschirmfotos in voller Auflösung im
  Gast (Spectacle über SSH), das Hyper-V-Vorschaubild nur zur Orientierung. Ein neues ISO nur,
  wenn eine Änderung anders nicht prüfbar ist (Installer, Ersteinrichtung, Bootscreen, erstes
  Anmelden eines neuen Benutzers) und einmal ganz am Ende. USB-Stick erst ganz am Schluss.
- **Vergleich:** Referenz-Bildschirmfotos von Windows 11 legt der Nutzer ggf. nach
  C:\Users\Daniel\Fenstra\referenz\ – dann Bild-für-Bild vergleichen.
- **Leistung:** Boot < 15 s, RAM im Leerlauf < 1,5 GB, flüssige Effekte. Hyper-V hat keine GPU
  (llvmpipe): Leistung dort nur grob prüfbar; Feinschliff auf echter Hardware am Ende.
- Passwort des Testbenutzers und GitHub-Zugangsdaten nie ins Repo. Hilfsskripte gehören ins
  Repo (tools/), nicht in temporäre Ordner.
- Kommunikation mit dem Nutzer auf Deutsch; Berichte kurz, mit den wichtigsten Bildern.

## Entscheidungen (nicht erneut diskutieren)

- Registry: wird nicht nachgebaut, kein Registrierungs-Editor.
- „Windows Update“ = Fedora-Updates + Flatpak + fwupd in der Einstellungen-Seite „Updates“,
  davor Snapper-Wiederherstellungspunkt (M9).
- „Defender“: kein Echtzeitscanner. Schichten SELinux (enforcing), firewalld, signierte Pakete,
  Secure Boot, Flatpak-Sandbox. ClamAV nur als Prüfung von .exe vor dem ersten Wine-Start.
- Mica: KWin-Blur entspricht Acrylic (Startmenü, Schnelleinstellungen). Mica für
  Fensterhintergründe als getönte, verwischte Kopie des Wallpapers, neu berechnet beim
  Wallpaper-Wechsel (günstig, kein Live-Blur).
- EU OS als Basis: nein (bootc/Kinoite, unveränderlich; passt nicht zu RPM/Wine/Snapper).
- Name „Fenstra“ bleibt; Markenprüfung entfällt (nie veröffentlicht).
- fenstra-release ersetzt fedora-release NICHT (exakte Versionsabhängigkeit). Stattdessen
  RPM-Dateitrigger auf /usr/lib/os-release, der die Fenstra-Kennung nach jedem Update erneut
  schreibt. ID bleibt „fedora“.
- Fedora 44 KDE nutzt den Plasma Login Manager (nicht SDDM) und die Anaconda-Weboberfläche.
  Kein SDDM-Thema bauen. Anmelde-/Sperrbildschirm im Windows-Aufbau: M7.
- Plasma Setup (Ersteinrichtung) wird durch eine eigene OOBE im Windows-Aufbau ersetzt (M7);
  die früheren Notizen zu „Willkommen bei Plasma Desktop“/Konqi sind damit hinfällig.
- Symbole, Mauszeiger, Klänge: eigene Sätze (M2) statt Fluent UI System Icons, Breeze-Symbole,
  Breeze_Light-Cursor und Ocean-Klängen.
- Subvolume-Namen im grafischen Installer sind fest „root“/„home“ (nicht @/@home); gleichwertig.
- grub-btrfs ist nicht in Fedora; kommt mit den Wiederherstellungspunkten (M9) als eigenes Paket.

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
  C:\Users\Daniel\Fenstra\ und /var/lib/fenstra-build/out/20261004-1608/. Test5 hat alle
  Fenstra-Pakete per RPM (keine Benutzerkopien von Plasmoids mehr). Überall Benutzer
  daniel (Passwort kennt der Nutzer; nicht ins Repo schreiben). sudo per `echo <pw> | sudo -S`.
- VM-Werkzeuge im Repo: **tools/README.md** (Ablauf eines VM-Tests, Stolpersteine).
  tools/hyperv/*.ps1 (Windows, Admin): neue-vm, vm-screenshot, vm-input (Maus/Tastatur mit
  DE-Belegung), vm-bootshots, vm-ip, vm-von-platte-starten, vm-ssh-einrichten.
  tools/vm/*.sh (in der VM): plasmoid-deploy, testsitzung.
  SSH: `ssh -i ~\.ssh\fenstra-vm -o UserKnownHostsFile=~\.ssh\known_hosts_fenstra daniel@<IP>`,
  IP mit vm-ip.ps1 (wechselt nach jedem Neustart).
- **Arbeitskopie für Windows-Werkzeuge** (seit 2026-10-05): Windows (und Claude Codes
  Read/Edit/Write) kann /root in WSL nicht lesen. Bearbeitet wird in
  `C:\Users\Daniel\Fenstra\ws` (Spiegel ohne .git), abgeglichen mit
  `wsl -d FedoraLinux-44 -u root -- /root/Fenstra/tools/sync-ws.sh` (beide Richtungen, neuere
  Datei gewinnt, löscht nie; `sync-ws.sh rm <pfad>` löscht in beiden). Vor jedem Build,
  VM-Test und Commit abgleichen. Neue Skripte im Repo mit `chmod +x` versehen.
  Hyper-V-Skripte direkt aus `C:\Users\Daniel\Fenstra\ws\tools\hyperv\` aufrufen.
- Aus der Claude-Umgebung sind GitHub, invent.kde.org, download.kde.org und jsdelivr
  gesperrt; src.fedoraproject.org, dl.fedoraproject.org, npmjs.org, pypi erreichbar.
  Fedora-44-Paketdaten lassen sich von dl.fedoraproject.org laden und auswerten.

## Arbeitsablauf

```
bash build/prepare-wsl.sh      # Werkzeuge
bash build/validate.sh         # ksvalidator, Bash, JSON, SVG/XML, Python, rpmspec
bash build/build-packages.sh [paket …]  # alle oder einzelne RPMs -> /var/lib/fenstra-build/repo
bash build/build-iso.sh        # livemedia-creator --no-virt, ~20 min, ISO + SHA256
bash build/report.sh <stamp>   # Auszüge nach berichte/ bei Fehlern
```
Fehlersuche: `grep -n 'return code [1-9]' logs/<stamp>/anaconda/dnf.log`, dann konsole.log,
livemedia.log, packaging.log. Anaconda loggt chpasswd nicht; Passwortfehler mit Kopie von
/etc/passwd,shadow in /tmp/t und `chpasswd -e -R /tmp/t` nachstellen.

## Stand M3 (abgeschlossen 2026-10-06) – nächster Schritt: M4 Startmenü, Suche, Flyouts

- **Taskleiste eigen** (Prüfliste docs/checkliste-taskleiste.md bestanden, Abweichungen dort):
  Unterpaket **fenstra-taskleiste** von fenstra-theme (ersetzt fenstra-startmenu) mit
  - `org.fenstra.taskbar` (src/plasmoids/org.fenstra.taskbar): main.qml (Modelle, Farben,
    D-Bus), Bar.qml (Zentrierung zur Bildschirmbreite, Startmenü-Dialog), TaskButton,
    PreviewDialog (PipeWire), JumpList (Kicker-SimpleFavoritesModel), QuickLinkMenu (Win+X),
    WidgetsButton (Wetter: Konfig `weatherSource`, z. B. `dwd|weather|Berlin-Tempelhof|10384`),
    StartMenu & Co. aus 4b-2, icons/start*.svg (eigenes Start-Symbol).
  - `org.fenstra.infobereich`: Gruppe (Netz/Ton/Akku + Vorstufe Schnelleinstellungen), Uhr
    (+ Kalender), Glocke, Desktop-Streifen.
  - Layout-Skript im globalen Design: Taskleiste, Plasma-Systemabschnitt (alle Statussymbole in
    `hiddenItems`), Infobereich. `/etc/xdg/plasmarc` (Plasma-Design fenstra) ist Pflicht.
- Entwicklungsschleife: Plasmoid-Ordner nach `~/.local/share/plasma/plasmoids/` in der VM kopieren
  (Benutzerkopie hat Vorrang), `systemctl --user restart plasma-plasmashell`, Fehler mit
  `journalctl --user -o cat | grep org.fenstra`. Danach die Benutzerkopie wieder löschen.
- Messung M3: Boot 6,91 s, RAM 1792 MB.
- Offen für M4: Flyouts mit 12 px Abstand, Schnelleinstellungen/Benachrichtigungszentrale/
  Widgets/Suche in Windows-Fassung, farbige Wettersymbole; Kirigami-Auswahlfarbe (aus M2).

## Stand M2 (abgeschlossen 2026-10-06)

- **Alle Assets eigen, aus Code erzeugt** (Prüfliste docs/checkliste-assets.md bestanden,
  31/31 Muss, 11/11 Soll, Abweichungen dort):
  - fenstra-icon-theme 44.0-3: src/glyphs.py (Strichmotive, 16er-Raster), src/farbig.py
    (farbige Motive), src/generate.py (Thema + Abdeckungsbericht), src/mapping.json (Name →
    Motiv; Format im `_comment`). `Inherits=hicolor`, kein Fluent, kein Breeze. Sichtprüfung:
    `kontaktblatt.py AUS.png [--dunkel]` bzw. `--verzeichnis <thema>/apps/scalable`.
    Bedarf: `tools/vm/symbolbedarf.sh --kern` in der VM, dann
    `generate.py --out … --bedarf symbolbedarf-kern.txt --fehlend fehlend.txt` (97,6 %).
  - fenstra-cursor-theme 44.0-1 (neu): src/zeiger.py → /usr/share/icons/fenstra-cursors.
  - fenstra-sound-theme 44.0-1 (neu): src/klaenge.py → /usr/share/sounds/fenstra (oggenc).
  - fenstra-backgrounds 44.0-2: src/hintergrund.py (Blüte hell/dunkel, sechs Benutzerbilder
    unter /usr/share/plasma/avatars/Fenstra *.png).
  - fenstra-theme 44.0-8: `cursorTheme=fenstra-cursors`, `[Sounds] Theme=fenstra`.
- Fehlende Symbole finden: in der VM `~/.local/share/icons/fenstra/mimetypes/scalable/unknown.svg`
  als Magenta-Quadrat anlegen (Kirigami zeigt fehlende Symbole als „unknown“), Oberflächen
  fotografieren, danach den Ordner wieder löschen.
- Messung M2: Boot 5,56 s, RAM 1767 MB.
- Offene Punkte aus M2: Kirigami-Listen zeigen den ausgewählten Eintrag mit weißer Schrift auf
  der hellgrauen WinUI-Auswahl (z. B. Seitenleiste der Systemeinstellungen) → beim nächsten
  Stil-Durchgang beheben (M3/M4). Konqi-Benutzerbilder ausblenden (M7). Dolphin-Orte mit 16 px
  (M8). Klänge auf echter Hardware anhören (M13).

## Stand M1 (abgeschlossen 2026-10-05)

- **fenstra-style** (packages/fenstra-style, x86_64, Fork Breeze 6.7.5): Qt-Stil „Fenstra“
  (kstyle/, WinUI-Farbwerte zentral in kstyle/fenstrawinui.h, Änderungen im Code mit
  „Fenstra:“ kommentiert, alte Breeze-Pfade teils unerreichbar dahinter) und Dekoration
  org.fenstra.decoration (kdecoration/, komplett neu, schlank). Prüfliste
  docs/checkliste-stil.md bestanden (41/41 Muss, 15/15 Soll), Abweichungen dort.
- **fenstra-theme 44.0-7**: Vorgaben widgetStyle=Fenstra, Dekoration, Plasma-Designs
  fenstra/fenstra-dark (desktoptheme/generate.py, Bau im %build), Schrift 10,5 pt,
  kein AccentColor-Schlüssel.
- Entwicklungsschleife Stil/Dekoration: `cmake -S packages/fenstra-style/src -B
  /var/lib/fenstra-build/cmake-style -G Ninja …` (einmal), dann
  `tools/hyperv/vm-dev.ps1 -Build /var/lib/fenstra-build/cmake-style [-KWin]`; Stiltest
  `~/.local/bin/stiltest.py` + `fenster-setzen.sh "Fenstra Stiltest" 460 150`; Messen mit
  tools/pruefen/*.ps1 und pixel.py.
- Messung M1: Boot 6,47 s, RAM 1793 MB.
- Offene Punkte aus M1 für später: Kombinationsliste über dem Feld, Fokusrahmen außen,
  Mica (M5), Plasma-Popups schwebend (M3/M4), Dolphin-Ansicht (M8).

## Stand M0 (abgeschlossen 2026-10-05)

- Rahmen neu, Roadmap M0–M13 (docs/roadmap.md), Arbeitskopie ws + sync-ws.sh,
  VM-Helfer (vm-ssh.ps1, vm-gastfoto.ps1, vm-rpm.ps1, fenstra-shot.sh, fenstra-ssh-env.sh,
  testsitzung.sh für Plasma 6), C++-Toolchain in WSL (prepare-wsl.sh),
  build-packages.sh lässt Debug-RPMs weg, docs/llm-test-log.md.
- **docs/windows11-referenz.md**: Designwerte (WinUI-Werte exakt aus den öffentlichen
  Themenressourcen, Rest aus Kenntnis mit (u) markiert). **docs/entscheidungen-komponenten.md**:
  KDE anpassen oder Eigenbau je Bestandteil, mit Befunden.
- VM „Fenstra-Test5“ per `dnf upgrade` auf Plasma 6.7.5 / Qt 6.11.2 / KF 6.30 / Kernel 7.2.8
  (= Stand WSL), Hyper-V-Video fest 1920×1080 (Set-VMVideo Single). Messung M0:
  Boot 6,10 s, RAM 1837 MB (messungen/2026-10-05-hyperv-m0-plasma675.txt).
- Befund Update: fenstra-release 44.0-1 verlor die Kennung (Dateitrigger auf
  /usr/lib/os-release feuert nie) → 44.0-2 mit Paket-Trigger, in der VM geprüft.
  Befund Snapper: beim großen Update entstand nur der „Vor“-Punkt, der „Nach“-Punkt fehlte
  (dbus/systemd wurden mitten in der Transaktion neu gestartet) → in M9 lösen.
  Befund Plasma 6.7: Begrüßungsassistent zeigt nach Updates „Plasma wurde auf 6.7
  aktualisiert“ → abschalten (M12).
- Breeze 6.7.5 als `packages/fenstra-style/src` geforkt (kstyle, kdecoration,
  libfenstracommon; Breeze→Fenstra umbenannt, eigene CMakeLists, baut in WSL) – Basis für M1.
- Ad-hoc-Skripte für WSL: in C:\Users\Daniel\Fenstra\tmp schreiben und mit
  `wsl -d FedoraLinux-44 -u root -- bash /mnt/c/Users/Daniel/Fenstra/tmp/<x>.sh` ausführen
  (mehrzeilige Argumente und `|`/`"` über PowerShell an wsl gehen kaputt).
  WinUI-Ressourcen zum Nachschlagen: /var/tmp/winui in WSL (tmp/winui-grep.sh).

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
- (M1) KWin lädt Dekorations-/Effekt-Plugins nur beim Start: nach neuer .so
  `kill -9 $(pgrep -x kwin_wayland)` (Wrapper startet neu, Sitzung bleibt, Programme enden).
- (M1) KWin 6.7 mischt `setBorderOutline`-Farben vormultipliziert → RGB selbst mit Alpha
  multiplizieren.
- (M1) Gesetzte `AccentColor` in kdeglobals → Plasma hellt die Auswahlfarbe um 30 % auf.
  Akzent nur im Farbschema führen.
- (M1) RPM legt geänderte %config(noreplace)-Dateien als .rpmnew ab: in der Test-VM keine
  Systemdateien von Hand ändern (oder danach .rpmnew einsetzen).
- (M1) Hyper-V-Maus: `SetButtonState(ButtonIndex, IsDown)` zum Gedrückthalten; QMenu ignoriert
  die ersten Bewegungen nach dem Öffnen (mehrere `move` senden).
- (M1) PowerShell → wsl: `|`, `"`, mehrzeilige Argumente gehen kaputt; Skripte als Datei
  übergeben. PowerShell 7 bricht bei stderr-Ausgabe nativer Befehle mit `$ErrorActionPreference
  = 'Stop'` ab (dnf-Warnungen).
- (M2) KWin lädt das Zeiger-Thema nicht neu, wenn sich nur kcminputrc ändert:
  `plasma-apply-cursortheme Breeze_Light; plasma-apply-cursortheme fenstra-cursors`.
- (M2) Symbol-Cache: nach neuem Symbolpaket `rm ~/.cache/icon-cache.kcache` und
  `systemctl --user restart plasma-plasmashell`.
- (M2) Fehlende Klangnamen fallen sonst auf das freedesktop-Thema zurück (fremde Klänge):
  jeden benutzten Namen selbst liefern, „still“ als 50 ms Stille.
- (M2) In SVG-Generatoren Verlaufs-IDs nie mit der Definition verwechseln (`url(#{id})`);
  jedes erzeugte SVG mit rsvg-convert rendern lassen (Fehler zeigen sich sonst erst in Qt).
- (M3) `PlasmaCore.Dialog` nimmt nur ein `mainItem`: Timer/Connections in ein umgebendes Item.
- (M3) Plasma löscht beim Anwenden des Standard-Designs Benutzerwerte, die der Vorgabe
  entsprechen: jede LnF-Vorgabe braucht eine Systemvorgabe in /etc/xdg (sonst Breeze-Rückfall).
- (M3) Plasma-6-Systemabschnitt: `hiddenItems` direkt am Applet schreiben (es ist selbst die
  Containment). Datum deutsch nur mit `toLocaleDateString(Qt.locale(), …)`.
- (M3) In der Test-VM kann sich nach einer Pause des Rechners die IP ändern; vm-ssh.ps1
  ermittelt sie neu, vm-rpm.ps1 bricht dann einmal ab (erneut aufrufen).

## Roadmap (Kurzform, Details docs/roadmap.md)

Bis 2026-10-04 erledigt: Build-Pipeline, 4a Branding, 4b-1 Taskleiste (Grundaufbau),
4b-2 Startmenü (Grundfassung). Seit 2026-10-05 gilt der Meilensteinplan M0–M13 in
docs/roadmap.md (Stil zuerst, dann Assets, Shell, Systemoberflächen, Explorer/Einstellungen,
übrige Apps, Leistung, finales ISO, USB-Stick).
