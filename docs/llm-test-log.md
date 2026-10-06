# LLM-Testprotokoll Fenstra

Fenstra ist ein privater Fähigkeitstest für LLMs: Ein Modell soll Windows 11 (24H2) auf
Fedora 44 + KDE Plasma 1:1 nachbauen und dabei alles Sichtbare selbst erstellen (siehe
CLAUDE.md, „Ziel und Rahmen“). Dieses Protokoll hält je Meilenstein fest: Ziel, Umsetzung,
Probleme, Fehlversuche, Zeitaufwand und eine ehrliche Bewertung (0–10) je Bereich.

Bewertungsskala (Nähe zum Original, nicht Aufwand):
- 0 = fehlt, 3 = erkennbar anders, 5 = Aufbau stimmt, Details deutlich abweichend,
  7 = auf den ersten Blick gleich, im Vergleich sichtbare Abweichungen,
  9 = nur im Pixelvergleich unterscheidbar, 10 = nicht unterscheidbar.

Zeitangaben: Wanduhrzeit der Arbeitssitzung (Modell arbeitet, inkl. Wartezeiten auf Builds
und VM), nicht menschliche Arbeitstage.

## Ausgangsstand vor M0 (Builds #2–#5, bis 2026-10-04)

Von früheren Sitzungen übernommen: Build-Pipeline (Kickstart, livemedia-creator in WSL),
eigene RPMs (Branding, Farbschemata, Plymouth, Wallpaper, Symbolthema aus Fluent-Symbolen),
Taskleiste als Plasma-Panel im Windows-Aufbau, eigenes Startmenü-Plasmoid (QML),
Hyper-V-Fernsteuerung. Bewertung des übernommenen Stands (2026-10-05, Bild bei 1920×1080):

| Bereich | Note | Begründung |
|---|---|---|
| Taskleiste | 4 | Aufbau mittig stimmt; Höhe 44 statt 48 px, Knöpfe/Indikatoren/Infobereich/Uhr im Plasma-Stil, kein Suchfeld, kein Widgets-Knopf |
| Startmenü | 4 | Aufbau (Suche, Angeheftet, Empfohlen, Benutzer/Ein-Aus) stimmt; Größe, Abstände, Schriftgrößen, Symbole, Acrylic, Seiten/Ordner fehlen |
| Fenster | 3 | Breeze-Kreisknöpfe statt 46×32-Rechteckknöpfe, Radius ~4 px, Titelleiste Plasma-typisch |
| Steuerelemente | 2 | Breeze-Stil |
| Symbole | 3 | gelbe Ordner nah dran; Fluent-Fremdsymbole, Breeze-Rückfall |
| Systemoberflächen | 3 | Plymouth eigenes Logo; Anmelde-/Sperrbildschirm Plasma-Aufbau |

## M0 Vorbereitung (2026-10-05)

- **Ziel:** Rahmen neu fassen, Testumgebung 1920×1080 mit pixelgenauen Gast-Bildschirmfotos,
  C++-Toolchain, Referenzwerte, Entscheidungen KDE/Eigenbau.
- **Beginn:** 2026-10-05 ca. 14:20, **Ende:** ca. 18:05 (davon ca. 45 min Unterbrechung
  durch das Nutzungslimit).
- **Umsetzung:**
  - CLAUDE.md „Ziel und Rahmen“ neu, Meilensteinplan M0–M13.
  - Arbeitskopie unter Windows (`ws/`) mit `tools/sync-ws.sh`, weil Claude Codes
    Datei-Werkzeuge `\\wsl$\…\root` nicht lesen dürfen.
  - VM-Werkzeuge: `vm-ssh.ps1`, `vm-gastfoto.ps1` (Spectacle im Gast, 1920×1080
    pixelgenau), `vm-rpm.ps1`, `fenstra-ssh-env.sh`; VM fest auf 1920×1080.
  - C++-Toolchain in WSL; Breeze 6.7.5 als Basis für Stil und Dekoration geforkt (baut).
  - Referenzwerte aus den öffentlichen WinUI-Themenressourcen (Farben hell/dunkel,
    Acrylic, Maße der Steuerelemente, Animationsdauern) + Kenntnis (markiert).
  - Entscheidungen KDE/Eigenbau mit Befunden aus VM und Headern.
- **Probleme:**
  - Spectacle über SSH lieferte ein weißes Bild, solange der Bildschirm im
    Energiesparmodus war → `kscreen-doctor --dpms on` vor jeder Aufnahme.
  - PowerShell hängt beim Weiterleiten an `ssh` CRLF an → `tr -d '\r'` in der VM.
  - WSL hatte Plasma 6.7.5, die VM 6.6.4 → VM per `dnf upgrade` angeglichen (nötig für
    C++-Plugins).
  - Dabei aufgedeckt: Der RPM-Dateitrigger von fenstra-release feuerte nie (RPM behandelt
    Präfixe als Verzeichnisse); Kennung ging verloren → Paket-Trigger, geprüft.
- **Fehlversuche:**
  - Ein paralleler Recherche-Workflow mit 13 Unteragenten wurde wegen des Nutzungslimits
    abgebrochen, ohne Ergebnis; die Recherche danach selbst und gezielt erledigt (WinUI-XAML
    per `gh api`/curl, Header in WSL).
  - Erste WinUI-Pfade falsch geraten (`src/controls/…`), Baum per GitHub-API ermittelt.
- **Messung:** Boot 6,10 s, RAM 1837 MB (Plasma 6.7.5; vorher 1911 MB mit 6.6.4).
- **Bewertung:** unverändert gegenüber dem Ausgangsstand (M0 ändert nichts Sichtbares).
- **Bilder:** docs/bilder/m0/ (Ausgangsstand Desktop, Startmenü).

## M1 Stil-Fundament (2026-10-05)

- **Ziel:** Qt-Widget-Stil, Fensterdekoration, Plasma-Design, Farben/Akzent im WinUI-Look
  (Prüfliste docs/checkliste-stil.md).
- **Beginn/Ende:** ca. 18:05–18:52 (Wanduhr; sehr dicht gearbeitet, viele Bauläufe parallel
  zu VM-Tests).
- **Umsetzung:**
  - Paket **fenstra-style** (neu, x86_64): Fork von Breeze 6.7.5. Dekoration komplett neu
    geschrieben (Titelleiste 32 px, Knöpfe 46×32, Glyphen 10 px, Schließen #C42B1C, Ecken 8 px
    über die KDecoration3-Radius-API, Umriss, Schatten, Tooltips „Verkleinern“ usw.).
    Qt-Stil: zentrale WinUI-Farbtabelle (fenstrawinui.h, Werte aus den WinUI-Ressourcen),
    neu gezeichnet: Schaltflächen (Elevation-Rand), Eingabefelder (Akzent-Unterkante),
    Kontrollkästchen, Optionsfelder, Schieberegler, Fortschritt, überlagernde Bildlaufleisten
    (Qt-Transient-Modus + eigenes Ein-/Ausblenden), Menüs, Menüleiste, Tooltips, Listen
    (graue Auswahl + Akzentbalken), Register (Akzentstrich), Kopfzeilen, Gruppenrahmen,
    Kombinationsfeld-Liste, Fokusrahmen.
  - **Plasma-Designs** fenstra/fenstra-dark aus Code (generate.py): Flyouts, Taskleiste,
    Tooltips, Widgets.
  - fenstra-theme: Vorgaben auf Fenstra-Stil/-Dekoration/-Design, Schrift 10,5 pt,
    Farbschemata (Auswahl #0078D4, Linkfarben).
  - Werkzeuge: vm-dev.ps1 (Build direkt in die VM, optional KWin-Neustart),
    fenster-setzen.sh (Fenster per KWin-Skript platzieren), Stiltest (PyQt6),
    pixel.py/nebeneinander.py, Messskripte m1-messen.ps1/m1-nachpruefen.ps1,
    vm-input.ps1 down/up (gedrückt halten).
- **Probleme / Erkenntnisse:**
  - KWin lädt Dekorations-Plugins nur beim Start → neue .so wirken erst nach KWin-Neustart
    (kill -9 kwin_wayland; Sitzung bleibt, Programme werden beendet).
  - KWin 6.7 mischt die Umrissfarbe der Dekoration vormultipliziert (40 % Grau wurde Weiß).
  - Plasma mischt eine in kdeglobals gesetzte AccentColor mit 30 % Weiß in die Auswahlfarbe.
  - Eine früher von Hand geänderte /etc/xdg-Datei ließ RPM die neue Fassung als .rpmnew ablegen
    (nur Test-VM).
  - QMenu ignoriert die ersten Mausbewegungen nach dem Öffnen (Hover-Test braucht mehrere
    Bewegungen); QComboMenuDelegate zeichnet mit dem QComboBox als Widget.
- **Fehlversuche:** Füllung per CompositionMode_Source „ausgestanzt“ (hätte Löcher in den
  Fensterhintergrund gerissen, vor dem Test verworfen); erster Test der Dekoration lief noch
  mit dem alten Plugin im Speicher (siehe oben); SetButtonState-Parameter falsch geraten.
- **Messung:** Boot 6,47 s, RAM 1793 MB (M0: 6,10 s / 1837 MB), messungen/2026-10-05-hyperv-m1-stil.txt.
- **Bewertung (0–10):**

| Bereich | vorher | nachher | Begründung |
|---|---|---|---|
| Fensterrahmen | 3 | 8 | Maße, Farben, Knöpfe, Tooltips wie Windows; ohne Mica, Schatten nach Augenmaß |
| Steuerelemente | 2 | 7 | WinUI-Werte gemessen; Fokusrahmen innen, Kombinationsliste unterhalb, Dolphin-Ansicht eigen |
| Menüs/Tooltips | 2 | 8 | Aufbau und Maße wie WinUI; kein echtes Acrylic in Menüs |
| Plasma-Flächen | 3 | 6 | Taskleisten-/Popup-Grafik passt; Popups noch am Panel angedockt, Applets selbst noch Plasma (M3/M4) |
## M2 Eigene Assets (2026-10-05/06)

- **Ziel:** Symbole, Mauszeiger, Klänge und Hintergründe vollständig selbst erzeugen; Fluent UI
  System Icons, Breeze-Symbole/-Zeiger und Ocean-Klänge ablösen (Prüfliste
  docs/checkliste-assets.md).
- **Beginn/Ende:** abends 05.10. bis ca. 01:00 am 06.10. (Wanduhr, über einen Sitzungswechsel
  hinweg; genaue Zeit nicht erfasst).
- **Umsetzung:**
  - **Symbolthema** (fenstra-icon-theme 44.0-3): eigene Glyphenbibliothek glyphs.py (321
    Strichmotive im 16er-Raster, Abzeichen über SVG-Masken), farbig.py (Ordner mit Motiven,
    Laufwerke, Computer, Papierkorb, 25 Dateiarten, 12 App-Motive + Kacheln, Hinweise,
    Abzeichen), generate.py (einfarbig 16/22/24/32/48 pixelgenau, farbig scalable, eigene
    16-px-Bibliothekssymbole, Akzent-Glyphen für Einstellungen, Abdeckungsbericht).
    mapping.json neu gegliedert: 1591 Namen. Kein Fluent, kein Breeze-Rückfall.
  - **Mauszeiger** (fenstra-cursor-theme, neu): zeiger.py zeichnet 25 Formen (Pfeil, Hand,
    I-Balken, Doppelpfeile, Beschäftigt-Ring mit 24 Bildern …), xcursorgen, 112 Verweisnamen.
  - **Klänge** (fenstra-sound-theme, neu): klaenge.py synthetisiert 58 Ereignisklänge
    (Glocke/Marimba/Pad mit Faltungshall, Rascheln aus gefiltertem Rauschen), Lautheit
    normiert, Abmelden still.
  - **Hintergründe** (fenstra-backgrounds 44.0-2): hintergrund.py erzeugt eine eigene Blüte
    (hell/dunkel) und sechs Benutzerbilder.
  - fenstra-theme 44.0-8: Vorgaben Zeiger/Klänge; Werkzeuge: kontaktblatt.py (auch für fertige
    Themen), symbolbedarf.sh --kern.
- **Probleme / Erkenntnisse:**
  - Kirigami.Icon zeigt fehlende Symbole als „unknown“. Ein vorübergehend magentafarbenes
    „unknown“ im Benutzerordner macht Lücken auf Bildschirmfotos sofort sichtbar (so wurde
    das fehlende Helligkeits-Symbol gefunden).
  - KWin lädt das Zeiger-Thema nicht neu, wenn nur die Datei geändert wird; erst
    `plasma-apply-cursortheme` (mit einem Wechsel hin und zurück) wirkt sofort.
  - Die statische Bedarfsliste (strings über Bibliotheken) enthält viel Wortrauschen.
    Deshalb gibt es eine Kernliste, und Lücken werden per Laufzeit-Sichtprüfung bestätigt.
  - QIcon ohne Plattform-Thema sucht nur in `:/icons`; für den Qt-Test muss der Suchpfad gesetzt
    werden.
- **Fehlversuche:** Verlauf-ID-Fehler im Laufwerkssymbol (Definition statt ID eingesetzt,
  per Kontaktblatt gefunden); Verweise, die auf sich selbst zeigten; eine Zeile der Spec-Datei
  im falschen Abschnitt; das erste Zeigerfoto zeigte noch Breeze (KWin nicht neu geladen).
- **Messung:** Boot 5,56 s, RAM 1767 MB (M1: 6,47 s / 1793 MB),
  messungen/2026-10-06-hyperv-m2-assets.txt.
- **Bewertung (0–10):**

| Bereich | vorher | nachher | Begründung |
|---|---|---|---|
| Symbole (Strich) | 6 | 7 | eigene, stimmige Glyphen im Segoe-Fluent-Stil; einzelne Motive (Puzzle, Tacho) noch grob |
| Symbole (farbig) | 3 | 7 | Ordner, Laufwerke, Dateitypen, Hinweise wie Windows 11; App-Symbole teils nur Kacheln |
| Mauszeiger | 5 | 8 | Formen und Größen wie Windows; Beschäftigt-Ring vereinfacht |
| Klänge | 2 | 6 | Charakter getroffen, aber nur rechnerisch geprüft (VM ohne Ton) |
| Hintergrund | 4 | 7 | eigene Blüte, Bloom-artig; weniger plastisch als das Original |

## M3 Taskleiste (2026-10-06)

- **Ziel:** Taskleiste im Aufbau und Verhalten von Windows 11 (Prüfliste
  docs/checkliste-taskleiste.md).
- **Beginn/Ende:** ca. 01:00–01:30 und 12:30–12:50 (Wanduhr; dazwischen lag die VM wegen einer
  Pause des Rechners still).
- **Umsetzung:**
  - **org.fenstra.taskbar** (reines QML): Widgets-Knopf links (Wetter aus der Plasma-Wetter-
    Engine), mittig Start · Suchfeld · Task-Ansicht · App-Knöpfe, zur Bildschirmbreite zentriert
    (eigene Rechnung, Plasma-Abstandhalter zentrieren nur im freien Platz). App-Knöpfe auf
    `TasksModel`: Hover 40×40, Indikator 16/6×3 mit Breitenanimation, Aufmerksamkeit orange,
    Drück-Animation, Vorschau mit PipeWire-Livebildern, Sprungliste über Kickers
    `SimpleFavoritesModel` (Aufgaben, zuletzt verwendete Dateien), Ziehen, Win+1…9
    (`org.kde.plasma.multitasking`). Das Startmenü aus 4b-2 ist eingezogen und öffnet als eigener
    Dialog mittig auf dem Bildschirm; Windows-Taste über `org.kde.plasma.launchermenu`.
    Kontextmenüs: freie Fläche (Task-Manager, Taskleisteneinstellungen), Start (Win+X-Inhalt).
  - **org.fenstra.infobereich**: Gruppe Netz/Ton/Akku mit gemeinsamer Hover-Fläche und Vorstufe
    der Schnelleinstellungen, Uhr zweizeilig 12 px mit Kalender, Glocke mit Zähler, 10-px-Streifen
    „Desktop anzeigen“. Plasmas Systemabschnitt bleibt für „^“, App-Symbole und
    Benachrichtigungs-Popups (alle Statussymbole ausgeblendet).
  - Paket fenstra-taskleiste (ersetzt fenstra-startmenu), Layout-Skript des globalen Designs,
    eigenes Start-Symbol, /etc/xdg/plasmarc, Kabelnetz-Glyphe im Symbolthema (44.0-4).
- **Probleme / Erkenntnisse:**
  - `PlasmaCore.Dialog` nimmt keine Timer/Connections als Kinder (Standard-Eigenschaft ist
    `mainItem`) → Steuer-Item drumherum. `visible` lässt sich nicht per Alias überschreiben.
  - Eine Row kennt ihre Breite erst nach dem Layout-Durchlauf; „Dialog nur bei Breite > 0
    zeigen“ verhinderte die Vorschau beim Klick → Größe aus der Fensterzahl berechnen.
  - `PlasmaExtras.Menu` hat kein `addSeparator()`; Abschnittstitel zeichnet der Fenstra-Stil nicht.
  - Plasma 6: Der Systemabschnitt ist selbst die verschachtelte Containment; `hiddenItems` direkt
    in seine Konfiguration schreiben (kein `SystrayContainmentId` mehr).
  - `Qt.formatDate` lieferte englische Namen; `Date.toLocaleDateString(Qt.locale(), …)` ist
    deutsch.
  - Plasma löscht beim Anwenden des Standard-Designs den Benutzerwert des Plasma-Designs; ohne
    `/etc/xdg/plasmarc` fiel es nach dunkel → hell auf Breeze zurück (seit M1 unbemerkt).
  - Plasmas Gruppierung nimmt Fenster mit Aufmerksamkeit aus der Gruppe.
- **Fehlversuche:** erster Layout-Versuch für den Systemabschnitt über `desktopById` (Plasma 5);
  Vorschau-Dialog mit Timern als Kindern; Start-Symbol zuerst als App-Kachel (Hinweis des
  Nutzers: nicht als Fenstra-Symbol erkennbar) → neu als blaues Fenster ohne Kachel.
- **Messung:** Boot 6,91 s, RAM 1792 MB (M2: 5,56 s / 1767 MB; Boot schwankt in Hyper-V um ±1 s),
  messungen/2026-10-06-hyperv-m3-taskleiste.txt.
- **Bewertung (0–10):**

| Bereich | vorher | nachher | Begründung |
|---|---|---|---|
| Taskleiste (Aufbau, Knöpfe) | 5 | 8 | Maße, Zentrierung, Indikatoren, Suchfeld gemessen wie Windows; Hover-Farbe angenommen |
| Vorschau/Sprunglisten | 3 | 7 | Livebilder, Aufgaben, zuletzt verwendet; keine „Peek“-Vorschau des Fensters |
| Infobereich/Uhr | 4 | 7 | Gruppe, Uhr, Glocke, Streifen wie Windows; Überlauf und Flyouts noch Plasma/Vorstufe |
| Start-Knopf/-Menü | 5 | 6 | eigenes Symbol, mittig; Menüinhalt erst in M4 auf Windows-Stand |
