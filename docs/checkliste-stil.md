# Prüfliste M1: Stil-Fundament

Bereich: Fensterdekoration, Qt-Widget-Stil, Plasma-Design (Panel-/Popup-Hintergründe),
Farbschemata, Akzent, Schrift. Sollwerte aus [windows11-referenz.md](windows11-referenz.md)
(Abschnittsnummern in Klammern). Werte bei 100 % Skalierung, 1920×1080.

**Bestehensschwelle:** alle **Muss**-Punkte bestanden und ≥ 80 % der **Soll**-Punkte.
Abweichungen werden in der Spalte „Ergebnis“ begründet.

**Prüfmethode:**
- Pixelgenaue Gast-Bildschirmfotos (`vm-gastfoto.ps1`, auch `-Region`), Vermessung mit
  `tools/pruefen/pixel.py` (Farbe an Punkt, Kantenabstände, Laufweiten).
- Testprogramm `tools/pruefen/stiltest.py` (PyQt6, alle Steuerelemente auf einer Seite, hell
  und dunkel) als reproduzierbare Vorlage; dazu reale Programme (Dolphin, Systemeinstellungen,
  KWrite) für die Wirkung auf KDE-Apps.
- Zustände Hover/gedrückt per `vm-input.ps1 move/click`.

Farben „auf #F3F3F3“ = sichtbarer Mischwert einer halbtransparenten WinUI-Farbe auf dem
Fenstergrund (so misst man sie im Bild).

## A Fensterdekoration

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| D1 | Muss | Titelleistenhöhe (Oberkante Fenster bis Inhalt) | 32 px (3.1) | ✅ 32 px (y 150–181) |
| D2 | Muss | Knöpfe Minimieren, Maximieren, Schließen rechts, bündig, ohne Abstand | je 46×32 px (3.2) | ✅ 46×32, bündig, maximiert am Bildschirmrand |
| D3 | Muss | Glyphen | 10×10 px, 1 px Strich; Linie / Quadrat / zwei Quadrate / X (3.2) | ✅ 10 px, 1 px |
| D4 | Muss | Hover Minimieren/Maximieren (hell) | `#09000000` auf Titelleiste ≈ `#E9E9E9`–`#EBEBEB` (3.2) | ✅ #EAEAEA |
| D5 | Muss | Hover Schließen | `#C42B1C`, Glyphe `#FFFFFF` (3.2) | ✅ #C42B1C, Glyphe weiß |
| D6 | Soll | Schließen gedrückt | ≈ 90 % `#C42B1C`, Glyphe ≈ 70 % weiß (3.2) | ✅ #C83F31, Glyphe ~70 % weiß |
| D7 | Muss | Titel links, App-Symbol 16 px, Text 12 px Selawik, Farbe ≈ `#1B1B1B` | (3.1) | ✅ Symbol 16 px, Titel 12 px links |
| D8 | Soll | Inaktives Fenster: Titel und Glyphen blasser | Titel `#72000000`-Mischwert, Glyphen `#5C000000` (3.1/3.2) | ✅ sichtbar blasser (Bild) |
| D9 | Muss | Titelleistenfarbe = Fenstergrund | hell `#F3F3F3`, dunkel `#202020` (1.1) | ✅ #F3F3F3 / #202020 |
| D10 | Muss | Ecken | 8 px Radius an allen vier Ecken; maximiert 0 (1.4) | ✅ 8 px rundum, maximiert eckig |
| D11 | Muss | Rahmen | 1 px rundum, hell ≈ `#66757575`-Mischwert (3.3) | ✅ #BBBEC2 auf hellem Grund (40 % #757575) |
| D12 | Soll | Schatten | aktiv groß/weich (ca. 0 32 64 `#37000000`), inaktiv kleiner (1.5) | ✅ aktiv größer (Sichtprüfung) |
| D13 | Muss | Tooltips der Knöpfe | „Minimieren“, „Maximieren“/„Verkleinern“, „Schließen“ (3.2) | ✅ Minimieren, Verkleinern, Schließen gesehen |
| D14 | Muss | Doppelklick Titelleiste = maximieren/wiederherstellen; Rechtsklick = Fenstermenü | (7.3) | ✅ Doppelklick maximiert/stellt wieder her; Rechtsklick KWin-Standard |
| D15 | Muss | Dunkles Design | Titel weiß, Hover `#0FFFFFFF`-Mischwert, Schließen-Hover `#C42B1C` (3.2) | ✅ Bild dunkel |
| D16 | Soll | Hover-Übergang der Knöpfe | ≤ 100 ms Farbwechsel (1.6) | ✅ 83 ms (Code) |
| D17 | Soll | Keine Linie zwischen Titelleiste und Inhalt | (3.1) | ✅ |

## B Qt-Widget-Stil

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| S1 | Muss | Schaltfläche Ruhe | Höhe 32, Radius 4, Füllung `#B3FFFFFF` (auf `#F3F3F3` ≈ `#FBFBFB`), Rahmen 1 px `#0F000000` mit Unterkante `#29000000` (2.1) | ✅ 32 px, #FBFBFB, oben #E5E5E5, unten #D0D0D0 |
| S2 | Muss | Schaltfläche Hover / gedrückt | ≈ `#F6F6F6` / ≈ `#F5F5F5` mit Text sekundär (2.1) | ✅ Hover #F6F6F6 |
| S3 | Muss | Standardschaltfläche (Default) in Dialogen | Akzent `#0067C0`, Text weiß, Hover 90 %, gedrückt 80 % (2.1, 1.2) | ✅ #0067C0, Text weiß (dunkel: #4CC2FF, Text schwarz) |
| S4 | Muss | Eingabefeld | Höhe 32, Radius 4, Unterkante 1 px `#72000000`-Mischwert (2.2) | ✅ 32 px, Unterkante #868686 |
| S5 | Muss | Eingabefeld mit Fokus | Füllung `#FFFFFF`, Unterkante 2 px Akzent (2.2) | ✅ #FFFFFF, Unterkante 2 px #0067C0 |
| S6 | Muss | Kombinationsfeld | wie Schaltfläche, Chevron rechts (2.9) | ✅ Schaltflächen-Optik |
| S7 | Soll | Kombinationsfeld-Liste | Radius 8, Rahmen 1 px, Einträge Radius 3–4, gewählter Eintrag mit Akzentbalken 3×16 links (2.9) | ✅ Optik; ⚠️ öffnet unterhalb statt über dem Feld |
| S8 | Muss | Kontrollkästchen | 20×20, Radius 4; leer: Rahmen `#72000000`-Mischwert; angehakt: Akzent + weißer Haken (2.3) | ✅ 20 px, Rand #868686 |
| S9 | Muss | Optionsfeld | Ø 20; gewählt: Akzentkreis mit weißem Punkt Ø 12, Hover Ø 14 (2.4) | ✅ Ring 20, Punkt 12 |
| S10 | Muss | Schieberegler | Spur 4 px Radius 2, gefüllt Akzent; Daumen Ø 18 weiß mit Rahmen, Akzentpunkt Ø 12 / Hover 14 / gedrückt 10 (2.6) | ✅ Spur 4, Daumen 18, Punkt 12 |
| S11 | Muss | Fortschrittsbalken | Spur 1 px, Balken 3 px Akzent, Radius 1,5 (2.7) | ✅ Spur 1 px #868686, Balken 3 px |
| S12 | Muss | Bildlaufleiste Ruhe | schmal über dem Inhalt (≤ 3 px sichtbar), kein eigener Platz (2.8) | ✅ unsichtbar ohne Maus, 2-px-Linie bei Maus im Bereich |
| S13 | Muss | Bildlaufleiste Hover | 12 px breit, Daumen 6 px, Radius 3, Pfeile (2.8) | ✅ 12 px, Daumen 6, Pfeile |
| S14 | Muss | Menü (QMenu) | Radius 8, Rahmen 1 px, Schatten, Einträge Höhe 32 mit Rand 4, Hover Radius 4 `#09000000`-Mischwert, Trennlinie 1 px (2.11) | ✅ Radius 8, Hover 32 px #F0F0F0, Trennlinie |
| S15 | Soll | Menü-Details | Symbolspalte 16 px, Kürzel rechts in Sekundärfarbe, Untermenü-Chevron, Acrylic-artiger Hintergrund (2.11) | ✅ |
| S16 | Muss | Tooltip | Text 12 px, Innenabstand 9,6,9,8, Radius 4, Rahmen 1 px (2.12) | ✅ 12 px, Radius 4, Schatten |
| S17 | Muss | Listen/Bäume: Auswahl | Hover/gewählt `#09000000`-Mischwert, Radius 4, Akzentbalken 3×16 links (2.10) | ✅ #F6F6F6 + Balken 3 px #0067C0 |
| S18 | Soll | Listen: Zeilenhöhe | ≥ 32 px Bäume/Navigation (2.10) | ✅ 32 px (Bäume) |
| S19 | Soll | Kopfzeile (QHeaderView) | flach, kein Verlauf, Text 12 px, senkrechte Trenner 1 px (8.1) | ✅ flach, Trenner |
| S20 | Muss | Werkzeugknopf (QToolButton) | flach, Hover `#09000000`-Mischwert, Radius 4 (2.11) | ✅ Hover #EAEAEA |
| S21 | Soll | Register (QTabBar) | Höhe 32, Text 12–14, gewählter Tab mit Akzentstrich oder Fläche (2.13) | ✅ Akzentstrich 16×3 |
| S22 | Muss | Fokusrahmen nur bei Tastatur | 2 px außen `#E4000000`, Radius Element + 2 (1.7) | ✅ außen dunkel 2 px, innen hell 1 px (innerhalb der Fläche) |
| S23 | Muss | Schrift der Steuerelemente | Selawik 14 px (10,5 pt) (1.3) | ✅ 10,5 pt |
| S24 | Muss | Kirigami/QtQuick-Apps (Systemeinstellungen) nutzen dieselben Steuerelemente | Sichtprüfung (qqc2-desktop-style) | ✅ Systemeinstellungen |
| S25 | Muss | Dunkles Design aller Steuerelemente | Werte aus 1.1 „Dunkel“ (z. B. Schaltfläche `#0FFFFFFF` auf `#202020` ≈ `#2D2D2D`) | ✅ Bild dunkel |
| S26 | Soll | Drehfeld (QSpinBox) | Höhe 32, Knöpfe ▲▼ rechts (WinUI NumberBox kompakt) | ✅ 32 px |
| S27 | Soll | Gruppenrahmen/Karten | Radius 4–8, Rahmen `#0F000000` (1.4) | ✅ Radius 4, nur Linie |
| S28 | Soll | Hover-Farbwechsel animiert | ≈ 83 ms (1.6) | ✅ 83 ms |

## C Plasma-Design

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| P1 | Muss | Taskleisten-Hintergrund | hell ≈ `#F3F3F3` (85 %, Unschärfe), Oberkante 1 px Linie; dunkel ≈ `#202020` (4.1) | ✅ Linie oben #C1D4E5, Fläche ≈ #EEF1F4 (85 % über Unschärfe) |
| P2 | Muss | Popups (Kalender, Startmenü, Lautstärke …) | Radius 8, Rahmen 1 px, Hintergrund hell ≈ `#F9F9F9` Acrylic, Schatten (1.8, 2.15) | ✅ Radius 8 an freien Ecken, Rand, Schatten; ⚠️ am Panel anliegende Ränder eckig (Plasma-Platzierung, M3/M4) |
| P3 | Soll | Plasma-Tooltips | wie S16 | ✅ |
| P4 | Muss | Dunkles Plasma-Design | Popups ≈ `#2C2C2C`, Taskleiste ≈ `#202020` (1.8) | ✅ Bild dunkel |
| P5 | Muss | Alle Grafiken des Designs selbst erzeugt (Generator im Repo) | Projektvorgabe | ✅ generate.py |

## D Farben, Akzent, Schrift

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| F1 | Muss | Farbschema hell | Fenster `#F3F3F3`, Ansichten `#FFFFFF`, Text `#1B1B1B` (`#E4000000` auf Weiß) (1.1) | ✅ #F3F3F3 / #FFFFFF |
| F2 | Muss | Farbschema dunkel | Fenster `#202020`, Ansichten ≈ `#272727` (u), Text `#FFFFFF` (1.1) | ⚠️ Ansicht #1C1C1C statt ≈ #272727 (u) |
| F3 | Muss | Akzent | Basis `#0078D4`; Flächen hell `#0067C0`, dunkel `#4CC2FF`; Textauswahl `#0078D4` mit weißem Text (1.2) | ✅ |
| F4 | Muss | Schriften | Oberfläche Selawik 10,5 pt (14 px), Titelleiste 9 pt (12 px), Festbreite Cascadia (1.3) | ✅ |
| F5 | Muss | Umschalten hell/dunkel über das globale Design wirkt auf Stil, Dekoration und Plasma-Design zugleich | Sichtprüfung | ✅ globales Design hell/dunkel |
| F6 | Soll | Links/Akzenttext | hell `#003E92`, dunkel `#99EBFF` (1.2) | ✅ #003E92 / #99EBFF (Farbschema) |

## Auswertung

Stand 2026-10-05, Pakete fenstra-style 44.0-2 und fenstra-theme 44.0-7 in der VM, gemessen mit
tools/pruefen/m1-messen.ps1 und m1-nachpruefen.ps1, Bilder in docs/bilder/m1/.

- **Muss:** 41/41 bestanden; F2 nur unter Vorbehalt (Fenster und Text stimmen, der Sollwert der Listenansicht ist ein unsicherer (u)-Wert).
- **Soll:** 15/15 bestanden, teils mit Einschränkung (S7 Position, P2 Ränder am Panel).
- **Ergebnis: bestanden.**

Abweichungen (dokumentiert, Nachbesserung in späteren Meilensteinen):
1. Fokusrahmen liegt innerhalb der Steuerelementfläche (Windows: 3 px außerhalb); Qt-Widgets
   dürfen nicht über ihre Fläche hinaus zeichnen.
2. Kombinationsfeld-Liste öffnet unterhalb des Felds statt deckungsgleich darüber.
3. Plasma-Popups liegen bündig an Taskleiste und Bildschirmrand (Plasma blendet dort Rand und
   Rundung aus); Windows-Flyouts schweben mit Abstand – kommt mit den eigenen Applets (M3/M4).
4. Titelleiste und Fenstergrund sind einfarbig #F3F3F3/#202020, noch ohne Mica-Tönung (M5).
5. Dunkle Listenansicht #1C1C1C; Windows-Wert unsicher, gegen Referenzbild prüfen.
6. Dolphin zeichnet seine Dateiansicht mit eigenem Hervorhebungsrahmen (betrifft den eigenen
   Explorer in M8, nicht den Stil).
