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