# Roadmap: Meilensteinplan M0–M13 (ab 2026-10-05)

Ziel: 1:1-Klon von Windows 11 (24H2) in Aussehen und Verhalten auf Fedora 44 + KDE Plasma 6
(Wayland), privater LLM-Fähigkeitstest (siehe CLAUDE.md, „Ziel und Rahmen“). Dieser Plan
ersetzt die frühere Bausteinfolge 4a–4g/5. Erledigt war bis dahin: Build-Pipeline
(Kickstart + livemedia-creator), 4a Branding/Theme, 4b-1 Taskleiste (Grundaufbau),
4b-2 Startmenü (Grundfassung), VM-Werkzeuge (Build #5).

Jeder Meilenstein:
1. vorher Prüfliste `docs/checkliste-<bereich>.md` (messbare Punkte, Bestehensschwelle),
2. Umsetzung und Test in der laufenden Test-VM (1920×1080),
3. Abschluss: Prüfliste bestanden, Bildschirmfotos (`docs/bilder/<meilenstein>/`), Messung
   `fenstra-baseline` nach Neustart (`messungen/`), `git push`, Eintrag in
   `docs/llm-test-log.md`, kurzer Bericht an den Nutzer.

Umfang (grobe Schätzung, menschliche Arbeitstage als Maß): **S** ≈ ½ Tag, **M** ≈ 1–2 Tage,
**L** ≈ 3–5 Tage, **XL** ≈ 6–10 Tage.

| # | Meilenstein | Umfang | Kern |
|---|---|---|---|
| M0 ✅ | Vorbereitung | S | Rahmen, Arbeitskopie, VM 1920×1080, Gast-Screenshots, C++-Toolchain, Windows-11-Referenzwerte, Entscheidungen KDE/Eigenbau |
| M1 ✅ | Stil-Fundament | L | Qt-Stil, Fensterdekoration, Plasma-Design, Farben/Akzent, Menüs |
| M2 | Eigene Assets | L | Symbolthema komplett eigen, Mauszeiger, Klänge, Wallpaper |
| M3 | Taskleiste | L | eigenes Taskleisten-Applet, Infobereich, Uhr, Widgets-Knopf, Kontextmenüs |
| M4 | Startmenü, Suche, Flyouts | L | Startmenü fertig, Suchpanel, Schnelleinstellungen, Benachrichtigungen/Kalender, Widgets |
| M5 | Fenster und Multitasking | L | Alt+Tab, Task-Ansicht, virtuelle Desktops, Snap Layouts/Assist, Animationen, Mica |
| M6 | Desktop und Shell-Dialoge | M | Desktop-Symbole, Kontextmenü, Win+X, Ausführen, OSD, Win+V, Tastenkürzel |
| M7 | Systemoberflächen | L | Bootscreen, Anmeldung, Sperrbildschirm, Abmelden, UAC-Abfrage, OOBE (ISO-Build) |
| M8 | Datei-Explorer | XL | Eigenbau auf KIO: Tabs, Befehlsleiste, Navigationsbereich, „Dieser PC“ |
| M9 | Einstellungen und Updates | XL | Einstellungen-App mit allen Hauptkategorien, Updates mit Wiederherstellungspunkt |
| M10 | Werkzeug-Apps | L | Task-Manager, Terminal, Editor, Rechner, Snipping Tool |
| M11 | Medien, Store, Wine | L | Fotos, Medienwiedergabe, Store-Ersatz, .exe per Doppelklick |
| M12 | Leistung und Gesamtabnahme | M | RAM < 1,5 GB, Boot < 15 s, finales ISO, alle Prüflisten |
| M13 | USB-Stick | S | erst nach Rückfrage beim Nutzer |

## M0 Vorbereitung (S)

- CLAUDE.md „Ziel und Rahmen“ neu, überholte Entscheidungen korrigiert.
- Arbeitskopie `C:\Users\Daniel\Fenstra\ws` + `tools/sync-ws.sh`.
- Test-VM auf 1920×1080 (Gast: KScreen; Host: Hyper-V-Video), Gast-Bildschirmfotos über
  SSH (`tools/hyperv/vm-gastfoto.ps1`), `vm-input.ps1`/`vm-screenshot.ps1` für 1920×1080,
  Testsitzung ohne Dimmen/Sperren.
- WSL: C++-Toolchain (cmake, extra-cmake-modules, Qt6/KF6/KWin/KDecoration-devel),
  `build/build-packages.sh` für architekturabhängige RPMs.
- `docs/windows11-referenz.md`: Designwerte von Windows 11 (Farben hell/dunkel, Typografie,
  Radien, Abstände, Größen, Animationsdauern, Tastenkürzel) als Quelle aller Prüflisten.
- `docs/entscheidungen-komponenten.md`: KDE anpassen oder Eigenbau, je Bestandteil.
- `docs/llm-test-log.md` angelegt.

## M1 Stil-Fundament (L)

Alles Weitere baut darauf auf.
- Qt-Widget-Stil „Fenstra“ (C++, Fork von Breeze, Paket `fenstra-style`): Schaltflächen,
  Eingabefelder (Akzentlinie unten bei Fokus), Kombinationsfelder, Kontrollkästchen,
  Optionsfelder, Schieberegler, Fortschrittsbalken, Bildlaufleisten (schmal, beim Hover
  breiter), Menüs (8 px Ecken, Schatten), Tooltips, Register, Listen/Bäume (Auswahl mit
  Akzentbalken), Kopfzeilen, Werkzeugleisten. Wirkt auch für Kirigami/QtQuick-Apps
  (qqc2-desktop-style).
- Fensterdekoration „Fenstra“ (C++, KDecoration3): Titelleiste 32 px, Knöpfe 46×32 px
  rechteckig, Schließen-Hover #C42B1C, Symbole wie Segoe Fluent, inaktive Fenster blasser,
  Ecken 8 px, 1-px-Rand, Schatten wie Windows; Haken für Snap Layouts (M5).
- Plasma-Design „fenstra“ (eigene SVGs): Taskleiste, Flyouts/Popups (8 px, Acrylic),
  Tooltips, Widget-Hintergründe.
- Farbschemata hell/dunkel nachgeschärft, Akzentfarben (Windows-Palette, Ableitungen
  hell/dunkel 1–3), Umschaltung hell/dunkel.

## M2 Eigene Assets (L)

- Symbolthema `fenstra` vollständig eigen (Python-Generatoren → SVG): App-Symbole im
  Fluent-Stil (bunt, Verlauf), Ordner, Laufwerke/Geräte, Dateitypen, Aktionen (Strichsymbole
  16/20/24 px), Status/Infobereich (Netz, Ton, Akku, Bluetooth). Fluent-Paket und
  Breeze-Rückfall entfallen; Prüfwerkzeug meldet fehlende Symbolnamen.
- Mauszeiger-Thema `fenstra` (SVG + Xcursor, alle Formen, animiertes „Beschäftigt“).
- Klangschema `fenstra` (synthetisiert): Anmelden, Benachrichtigung, Hinweis, Fehler,
  Papierkorb, Gerät an/ab, Lautstärke.
- Wallpaper hell/dunkel überarbeiten (Bloom-artige Form, eigenes Motiv), Benutzerbilder.

## M3 Taskleiste (L)

- Eigenes Taskleisten-Applet (Fork des Plasma-Taskmanager-QML): Symbole 24 px in 40×40,
  Hover-Fläche, Indikator (aktiv 16×3 px Akzent, sonst 6×3 px grau), Vorschau beim Hover,
  Sprunglisten (zuletzt verwendet, Anheften, Schließen), Gruppierung, Ziehen.
- Suchfeld „Suchen“ als Pille, Start-Knopf mit eigenem Symbol, Task-Ansicht-Knopf,
  Widgets-Knopf links mit Wetter, Infobereich mit Überlauf-Flyout (^), Gruppe
  Netz/Ton/Akku, Uhr mit Datum und Glocke, schmaler „Desktop anzeigen“-Streifen,
  Kontextmenü „Taskleisteneinstellungen“, exakt mittige Ausrichtung.

## M4 Startmenü, Suche, Flyouts (L)

- Startmenü: Seiten mit Punkten, Ordner, Kontomenü, „Alle“-Ansicht, Empfohlen mit „Mehr“,
  Größe und Position wie Windows.
- Suchpanel (Windows-11-Aufbau, Backend KRunner).
- Schnelleinstellungen (WLAN, Bluetooth, Flugmodus, Energiesparen, Nachtmodus,
  Barrierefreiheit, Helligkeit, Lautstärke, Akku, Bearbeiten).
- Benachrichtigungscenter mit Kalender, Toast-Benachrichtigungen unten rechts.
- Widgets-Board von links.

## M5 Fenster und Multitasking (L)

- Alt+Tab (eigenes KWin-Fensterwechsler-Layout), Task-Ansicht Win+Tab mit Desktopleiste
  (eigener KWin-Effekt), virtuelle Desktops (Strg+Win+D/←/→/F4, Animation).
- Snap Layouts (Hover über Maximieren, Win+Z, Ziehen an den oberen Rand), Snap Assist,
  Win+Pfeiltasten, Win+D/M, Fensteranimationen (Öffnen, Schließen, Minimieren,
  Maximieren), Mica für Fensterhintergründe (eigener KWin-Effekt).

## M6 Desktop und Shell-Dialoge (M)

- Desktop-Symbole (Papierkorb oben links, Raster wie Windows), Desktop-Kontextmenü im
  Windows-11-Aufbau, Win+X-Menü, Ausführen (Win+R), Lautstärke-/Helligkeits-OSD,
  Zwischenablage-Verlauf (Win+V), Herunterfahren-Dialog (Alt+F4 auf dem Desktop),
  Tastenkürzel Win/Win+E/I/L/D/V/R/X/Tab, Druck → Snipping Tool, Doppel-/Rechtsklick.

## M7 Systemoberflächen (L)

- Bootscreen (Logo + kreisende Punkte), Anmeldebildschirm und Sperrbildschirm im
  Windows-Aufbau, Abmelde-/Herunterfahren-Bildschirme, UAC-artige Rechteabfrage (eigener
  Polkit-Agent, abgedunkelter Hintergrund), OOBE statt Plasma Setup (Region, Tastatur,
  Netzwerk, Konto, Datenschutz). Prüfung per ISO-Build #6 (Installer, erstes Anmelden).

## M8 Datei-Explorer (XL)

- Eigenbau (C++/Qt Widgets) auf KIO: Tabs in der Titelleiste, Befehlsleiste (Neu,
  Ausschneiden/Kopieren/Einfügen/Umbenennen/Teilen/Löschen, Sortieren, Anzeigen),
  Adressleiste mit Brotkrumen und Suche, Navigationsbereich (Start, Desktop, Downloads …,
  Dieser PC, Netzwerk), „Dieser PC“ mit Laufwerksbuchstaben und Füllbalken, Ansichten,
  Detailbereich, Statusleiste, Kontextmenü im Windows-11-Aufbau, Papierkorb, Kopierdialog.

## M9 Einstellungen und Updates (XL)

- Eigenbau (C++/QML): System, Bluetooth und Geräte, Netzwerk und Internet,
  Personalisierung, Apps, Konten, Zeit und Sprache, Spielen, Barrierefreiheit,
  Datenschutz und Sicherheit, Updates – mit echter Funktion (KConfig, D-Bus,
  NetworkManager, BlueZ, KScreen, PipeWire/Pulse, PowerDevil, AccountsService, timedated,
  PackageKit). Updates mit Wiederherstellungspunkt (Snapper), grub-btrfs als eigenes Paket,
  Zurücksetzen.

## M10 Werkzeug-Apps (L)

- Task-Manager (Eigenbau auf libksysguard), Terminal (eigener Rahmen mit Tabs in der
  Titelleiste + Konsole-KPart), Editor (Notepad-Nachbau), Rechner, Snipping Tool.

## M11 Medien, Store, Wine (L)

- Fotos, Medienwiedergabe (Eigenbauten), Store-Ersatz (Flatpak/dnf, Katalog),
  .exe per Doppelklick über Wine (MIME-Handler, Startmenü-Einträge).

## M12 Leistung und Gesamtabnahme (M)

- RAM im Leerlauf < 1,5 GB (heute ~1,9 GB: plasma-keyboard, xwaylandvideobridge,
  kdeconnect, DiscoverNotifier, abrt, PackageKit …), Boot < 15 s (heute 6,6 s), Effekte
  flüssig; ISO abspecken; finales ISO, Installation in frischer VM, alle Prüflisten erneut.

## M13 USB-Stick (S)

- Nur nach ausdrücklicher Rückfrage (riskante Aktion außerhalb der VM). Anleitung docs/02.
