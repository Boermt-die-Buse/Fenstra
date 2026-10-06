# Prüfliste M3: Taskleiste

Bereich: Taskleiste mit Start, Suche, Task-Ansicht, App-Knöpfen, Widgets-Knopf, Infobereich,
Uhr und „Desktop anzeigen“. Sollwerte aus [windows11-referenz.md](windows11-referenz.md)
Abschnitt 4 (Maße mit (u) dort sind Schätzwerte). Werte bei 100 % Skalierung, 1920×1080.

**Bestehensschwelle:** alle **Muss**-Punkte bestanden und ≥ 80 % der **Soll**-Punkte.
Abweichungen werden in der Spalte „Ergebnis“ begründet.

**Prüfmethode:** Gast-Bildschirmfotos (Spectacle), Vermessung mit `tools/pruefen/pixel.py`,
Zustände per `vm-input.ps1` (Hover, Klick, Rechtsklick, Tasten), Fenster mit Testprogrammen
(Dolphin, Konsole, KWrite) öffnen.

## A Grundform (4.1)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T1 | Muss | Höhe | 48 px | ✅ 47 px Fläche + 1 px Oberkante = 48 (y 1032…1079) |
| T2 | Muss | Lage | unten, volle Breite, nicht schwebend | ✅ unten, volle Breite, nicht schwebend |
| T3 | Muss | Hintergrund | hell ≈ #F3F3F3 (durchscheinend), dunkel ≈ #202020; Oberkante 1 px Linie | ✅ hell #F1F2F4 (durchscheinend über dem Hintergrund), dunkel #1C1E21; 1 px Oberkante |
| T4 | Muss | Mittige Gruppe | Start…letzte App mittig zur **Bildschirmbreite** (±1 px), nicht zum freien Platz | ✅ Start-Knopf ab x 756, letzter Knopf bis 1164 → Mitte 960,0 (über Hover-Kanten gemessen); bleibt mittig, wenn Apps hinzukommen |

## B App-Knöpfe (4.2)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T5 | Muss | Symbol | 24×24 px | ✅ 24 px (Code; Start-Symbol eigene 24er-Zeichnung) |
| T6 | Muss | Hover-Fläche | 40×40 px, Radius 4, mittig im Knopf | ✅ 40×40 (Kanten x 758/797, y 1036…1075), Radius 4 |
| T7 | Soll | Knopfraster | 44 px je Knopf (u) | ✅ 44 px |
| T8 | Muss | Aktives Fenster | Fläche wie Hover dauerhaft + Indikator 16×3 px, Radius 1,5, Akzent (hell #0067C0, dunkel #4CC2FF) | ✅ 16×3 px, hell #0067C0 (gemessen), dunkel #4CC2FF; aktive Fläche halbweiß mit Rand |
| T9 | Muss | Läuft, nicht aktiv | Indikator 6×3 px grau | ✅ 6×3 px #848486 |
| T10 | Muss | Nur angeheftet | kein Indikator | ✅ Discover/Firefox angeheftet ohne Indikator |
| T11 | Soll | Indikator-Übergang | Breite animiert 6↔16 px, ca. 167 ms | ✅ 167 ms (Code) |
| T12 | Soll | Drücken | Symbol schrumpft kurz (ca. 85 %) und federt zurück | ✅ 85 %, 83 ms hinein, 250 ms federnd zurück (Code) |
| T13 | Soll | Aufmerksamkeit | Knopf orange hinterlegt, solange das Fenster Aufmerksamkeit verlangt | ✅ orange Fläche und Indikator #F7630C (per KWin-Skript ausgelöst, Bild) |

## C Start, Suche, Task-Ansicht (4.2)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T14 | Muss | Reihenfolge | Start · Suche · Task-Ansicht · Apps | ✅ |
| T15 | Muss | Start | eigenes Fenstra-Symbol; Klick und Windows-Taste öffnen das Startmenü, waagrecht mittig auf dem Bildschirm über der Taskleiste | ✅ eigenes Start-Symbol (blaues Fenstra-Fenster ohne Kachel, hell/dunkel); Klick und Windows-Taste öffnen das Startmenü, x 632…1288 → Mitte 960 |
| T16 | Muss | Suchfeld | Pille ca. 180×32, Radius 16, Lupe links, Text „Suchen“ in Sekundärfarbe; Klick öffnet die Suche | ✅ 180×32 (x 804…984, y 1040…1072), Radius 16, Lupe, „Suchen“ in Sekundärfarbe; Klick öffnet KRunner |
| T17 | Muss | Task-Ansicht | Symbol zwei versetzte Rechtecke; Klick öffnet die Fensterübersicht | ✅ eigenes Symbol (zwei versetzte Rechtecke); Klick öffnet die KWin-Übersicht |

## D Apps (4.2, 4.4, 4.5, 4.6)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T18 | Muss | Angeheftet ab Werk | Explorer (Dolphin), Browser, Store (Discover) | ✅ Dolphin, Browser (preferred://browser), Discover |
| T19 | Muss | Gruppierung | ein Knopf je App, auch bei mehreren Fenstern | ✅ zwei Konsole- und zwei Dolphin-Fenster je ein Knopf |
| T20 | Muss | Klick | nicht aktives Fenster → aktivieren; aktives → minimieren; mehrere Fenster → Vorschau-Auswahl | ✅ aktivieren / minimieren; Gruppe mit 2 Fenstern zeigt die Vorschau-Auswahl |
| T21 | Muss | Vorschau | nach ca. 400 ms über dem Knopf: je Fenster Symbol 16 + Titel 12 px + „X“ beim Hover, Bild ≤ 200×120; Klick aktiviert | ✅ 400 ms; Kopf Symbol 16 + Titel 12 px + „X“ (rot beim Hover); PipeWire-Livebild 200×120; Klick aktiviert |
| T22 | Muss | Sprungliste (Rechtsklick) | „Zuletzt verwendet“ (falls vorhanden), App-Aufgaben, App-Name (neue Instanz), „An Taskleiste anheften“/„Von Taskleiste lösen“, „Fenster schließen“/„Alle Fenster schließen“ | ✅ KWrite: „Zuletzt verwendet“ + notiz.txt, App-Name, „An Taskleiste anheften“, „Fenster schließen“; Firefox: Aufgaben „Neues Fenster“ … |
| T23 | Soll | Ziehen | Reihenfolge per Ziehen änderbar, bleibt gespeichert | ✅ Firefox hinter Discover gezogen, Reihenfolge in `launchers` gespeichert |
| T24 | Soll | Win+1…9 | startet bzw. wechselt zur n-ten App | ✅ Win+1 startet Dolphin (erster Eintrag) |
| T25 | Soll | Neue Instanz | Mittelklick bzw. Umschalt+Klick | ⚠️ im Code (Mittelklick, Umschalt+Klick → neue Instanz), nicht per Eingabe geprüft (vm-input kennt keine Mitteltaste) |
| T26 | Soll | Nur-angeheftet-Tooltip | Hover zeigt App-Namen | ✅ „Discover“ |

## E Infobereich (4.3)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T27 | Muss | Überlauf | Chevron „^“, Tooltip „Ausgeblendete Symbole anzeigen“, Flyout mit ausgeblendeten Symbolen | ✅ Plasma-Chevron, Tooltip „Ausgeblendete Symbole anzeigen“, Flyout mit allen Statussymbolen (Abweichung 1) |
| T28 | Soll | Infobereich-Symbole | 16 px | ✅ 16 px |
| T29 | Muss | Schnelleinstellungen-Gruppe | Netzwerk, Lautstärke (Akku falls vorhanden) mit **gemeinsamer** Hover-Fläche, Radius 4; Symbole zeigen den Zustand | ✅ Netz (Kabel: Bildschirm mit Stecker) und Ton (stumm, kein Gerät) mit einer Hover-Fläche; Tooltip mit Verbindung; Klick: Vorstufe der Schnelleinstellungen |
| T30 | Muss | Uhr | zwei Zeilen, 12 px, rechtsbündig: „HH:MM“ / „TT.MM.JJJJ“ | ✅ „01:21“ / „06.10.2026“, 12 px, rechtsbündig |
| T31 | Soll | Uhr-Hover | Hover-Fläche Radius 4; Klick öffnet Kalender | ✅ Hover-Fläche Radius 4; Klick öffnet Monatskalender, Tooltip „Dienstag, 6. Oktober 2026“ |
| T32 | Soll | Glocke | erscheint bei ungelesenen Benachrichtigungen (Zähler) bzw. „Nicht stören“ | ✅ nach `notify-send` Glocke mit Zähler „1“ |
| T33 | Muss | Desktop anzeigen | schmaler Streifen ganz rechts (8–12 px), Klick zeigt den Desktop | ✅ 10 px, Tooltip „Desktop anzeigen“, Klick blendet die Fenster aus und wieder ein |

## F Widgets-Knopf (4.2)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T34 | Muss | Lage und Inhalt | ganz links; mit Wetterdaten Symbol 24 + Temperatur + Kurztext (zwei Zeilen, 12 px), ohne Wetterdaten Widgets-Symbol | ✅ ohne Quelle Widgets-Symbol; mit DWD-Station „14 °C“ / „Bedeckt“ (Abweichung 3) |

## G Kontextmenüs (4.4)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T35 | Muss | Freie Fläche | „Task-Manager“, „Taskleisteneinstellungen“ (keine Plasma-Einträge) | ✅ nur „Task-Manager“ und „Taskleisteneinstellungen“ |
| T36 | Soll | Start (Rechtsklick) | Schnelllink-Menü wie Win+X | ✅ Schnelllink-Menü mit den Win+X-Einträgen (ohne Symbole, wie Windows) |
| T37 | Soll | Uhr (Rechtsklick) | „Datum und Uhrzeit anpassen“, „Benachrichtigungen“ … | ✅ „Datum und Uhrzeit anpassen“, „Benachrichtigungseinstellungen“ |

## H Dunkles Design, Messung

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| T38 | Muss | Dunkles Design | alle Teile mit dunklen Farben, Akzent #4CC2FF | ✅ dunkle Leiste, helle Schrift, Suchfeld dunkel, Indikator #4CC2FF (Bild taskleiste-dunkel) |
| T39 | Muss | Messung | fenstra-baseline nach Neustart: Boot < 15 s, RAM nicht schlechter als M2 + 50 MB | ✅ Boot 6,91 s; RAM 1792 MB (M2: 1767 MB, +25 MB) – messungen/2026-10-06-hyperv-m3-taskleiste.txt |
| T40 | Muss | Bildschirmfotos | docs/bilder/m3/ | ✅ docs/bilder/m3/ |

## Ergebnis

**Bestanden** (2026-10-06): alle Muss-Punkte, 12/13 Soll (T25 nur im Code, nicht per Eingabe
geprüft).

### Abweichungen

1. **Überlauf „^“:** Plasmas Systemabschnitt liefert Chevron, Tooltip und Flyout. Das Flyout ist
   eine Liste mit Namen statt eines kleinen Symbolrasters, und der Chevron steht rechts von
   gerade sichtbaren App-Symbolen statt links davon. Ein eigener Systemabschnitt bräuchte C++
   für die StatusNotifier-Schnittstelle; das folgt höchstens im Feinschliff.
2. **Flyouts liegen bündig auf der Taskleiste** (Startmenü, Kalender, Schnelleinstellungen),
   Windows lässt rund 12 px Abstand. Wird mit den Flyouts in M4 angepasst.
3. **Vorstufen:** Schnelleinstellungen (Lautstärke, Netz, Akku, Links), Kalender ohne
   Benachrichtigungen, Widgets-Knopf ohne Übersicht, Suche über KRunner – die Windows-Fassungen
   folgen in M4. Das Wettersymbol ist einfarbig (Windows farbig), der Wetterort wird in den
   Taskleisteneinstellungen eingetragen (Windows ermittelt ihn selbst).
4. **Gruppierung:** Plasmas Taskmodell nimmt Fenster, die Aufmerksamkeit verlangen, aus ihrer
   Gruppe heraus (zwei Knöpfe für eine App, bis die Aufmerksamkeit endet).
5. **Hover-Farbe:** hell als halbdurchsichtige weiße Fläche mit feinem Rand (wie ein WinUI-
   Steuerelement auf der Taskleiste) statt der in der Referenz geschätzten Abdunklung
   `#0F000000 (u)`; beides ungeprüft gegen ein Original-Bildschirmfoto.
6. **Sprunglisten-Überschriften** („Zuletzt verwendet“, „Aufgaben“) sind graue, nicht
   anklickbare Menüeinträge, weil der Fenstra-Stil Menüabschnitte (QMenu-Sections) nicht
   beschriftet.

### Nebenbefunde

- Nach einem Wechsel dunkel → hell fiel Plasma auf das Breeze-Plasma-Design zurück: Plasma
  löscht den Benutzerwert, wenn er dem Standard-Design entspricht, und es gab keine
  Systemvorgabe. Behoben mit `/etc/xdg/plasmarc` (fenstra-theme 44.0-9).
- Start-Symbol auf Hinweis des Nutzers neu gezeichnet: Das Fenstra-Logo als App-Kachel wirkte im
  Knopf wie ein beliebiges Programmsymbol. Jetzt blaues Fenster ohne Kachel wie das
  Windows-Logo (eigene SVGs, hell/dunkel).
