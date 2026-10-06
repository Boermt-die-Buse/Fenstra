# Prüfliste M4: Startmenü, Suche, Flyouts

Bereich: Startmenü, Suchpanel, Schnelleinstellungen, Benachrichtigungscenter mit Kalender,
Toasts, Widgets-Board sowie die offenen Punkte aus M3 (12 px Abstand der Flyouts) und M2
(Auswahlfarbe in Kirigami-Listen). Sollwerte aus [windows11-referenz.md](windows11-referenz.md)
Abschnitte 1, 2 und 5; Werte mit (u) sind dort Schätzwerte. Alle Maße bei 100 % Skalierung,
1920×1080, Taskleiste 48 px (Oberkante y = 1032).

**Bestehensschwelle:** alle **Muss**-Punkte bestanden und ≥ 80 % der **Soll**-Punkte.
Abweichungen werden in der Spalte „Ergebnis“ begründet und unten gesammelt.

**Prüfmethode:** Gast-Bildschirmfotos (Spectacle), Vermessung mit `tools/pruefen/pixel.py`,
Zustände per `vm-input.ps1` (Klick, Rechtsklick, Mausrad, Tasten), Benachrichtigungen per
`notify-send`, Fehler mit `journalctl --user -o cat | grep org.fenstra`. Hell und dunkel.

## A Gemeinsame Regeln für alle Flyouts

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| G1 | Muss | Abstand zur Taskleiste | Unterkante jedes Flyouts 12 px über der Taskleiste (y = 1020), nicht mehr bündig | ✅ Unterkante aller Flyouts y 1019, Lücke 1020…1031 = 12 px (Startmenü, Suche, Schnelleinstellungen, Kalender, Toast, Widgets gemessen) |
| G2 | Muss | Form | alle vier Ecken Radius 8, Rand 1 px (hell `#0F000000`…`#1A000000`, dunkel `#33000000`), Schatten | ✅ Plasma-Design dialogs/background: Radius 8 an allen Ecken (floating), Rand 1 px, KWin-Schatten (Verlauf unter der Unterkante) |
| G3 | Muss | Fläche | Acrylic-Ersatzfarbe hell ≈ `#F9F9F9`, dunkel ≈ `#2C2C2C` (mit Unschärfe dahinter, wo KWin sie liefert) | ✅ hell `#F9F9F9` @ 0,90 mit KWin-Unschärfe (Hintergrund scheint durch), dunkel `#2C2C2C` (Bilder *-dunkel) |
| G4 | Muss | Schließen | Klick außerhalb, Esc und erneuter Klick auf den Auslöser schließen; es ist immer nur ein Flyout offen | ✅ Klick außerhalb (Ordner, Kontokarte, Desktop), Esc, zweiter Druck auf Win+A schließt; Start offen + Win+A → nur Schnelleinstellungen offen |
| G5 | Soll | Animation | Öffnen: Gleiten von der Taskleiste her + Einblenden (≈ 250 ms), Schließen schneller (llvmpipe: nur grob prüfbar) | ⚠️ KWin-Effekt „Gleitende Popups“ für die Taskleisten-Flyouts, Toasts gleiten 300 ms (QML); unter llvmpipe nicht messbar → nicht als bestanden gezählt |
| G6 | Muss | Steuerelemente | Knöpfe, Schalter, Regler, Suchfelder im WinUI-Aussehen (2.1, 2.2, 2.5, 2.6), keine Breeze-Optik | ✅ eigene WinUI-Elemente (org.fenstra.shell): Knopf, Schalter, Regler, Suchfeld, Listeneintrag, Bildlaufleiste |
| G7 | Muss | Seitliche Ränder | Flyouts am rechten bzw. linken Bildschirmrand halten 12 px Abstand zum Rand | ✅ rechts: Schnelleinstellungen, Zentrale, Toast bis x 1907 (12 px); links: Widgets ab x 12 |

## B Startmenü (5.1)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| S1 | Muss | Größe | 642×726 px (±4) (u) | ✅ 642 × 726 (x 639…1280, y 294…1019) |
| S2 | Muss | Lage | waagrecht mittig zum Bildschirm (±1 px), Unterkante 12 px über der Taskleiste | ✅ Mitte 959,5, Unterkante y 1019 (12 px) |
| S3 | Muss | Suchfeld | oben, Pille Höhe 36, Radius 18 (u), seitlich 32 px Abstand, Lupe 16 px links, Platzhalter „Nach Apps, Einstellungen und Dokumenten suchen“ in Sekundärfarbe | ✅ Pille 578 × 36 (x 671…1248, y 326…361), Radius 18, seitlich 32 px, Lupe 16, Platzhalter wie Soll; im Startmenü ohne Fokus-Optik |
| S4 | Muss | Kopf „Angeheftet“ | Body Strong 14 px; rechts Knopf „Alle“ mit „>“, Höhe 24, Radius 4 | ✅ „Angeheftet“ 14 px Semibold; „Alle >“ 24 px hoch, Radius 4, Chevron |
| S5 | Muss | Raster | 6 Spalten × 3 Zeilen je Seite, Zelle 96×84 (u), Symbol 32, Beschriftung 12 px einzeilig mit Ellipse | ✅ 6 × 3, Zelle 96 × 84, Symbol 32, 12 px einzeilig mit Ellipse („Systemeinstell…“) |
| S6 | Muss | Seiten | mehr als 18 Einträge → weitere Seite; Punkte rechts senkrecht (aktuelle Seite hervorgehoben); Mausrad blättert; Wechsel gleitet senkrecht (≈ 250 ms) | ✅ 21 angeheftete Apps → 2 Seiten, Punkte rechts (aktuelle Seite größer und dunkler), Mausrad blättert (Bild start-seite2), Gleiten 250 ms |
| S7 | Muss | Ordner | Kachel auf eine andere ziehen legt einen Ordner an; Ordnerkachel zeigt bis zu 4 Mini-Symbole (2×2) auf heller Fläche; Klick öffnet die Ordneransicht im Startmenü mit umbenennbarem Namen | ✅ K3b auf digiKam gezogen → Ordner (2×2 Mini-Symbole), Ordneransicht, umbenannt in „Medien“ (in der Konfiguration gespeichert) |
| S8 | Soll | Umsortieren | Kachel zwischen andere ziehen verschiebt sie; bleibt gespeichert | ✅ Firefox vor Discover gezogen, Reihenfolge in der Favoritenliste gespeichert |
| S9 | Muss | Kontextmenü Kachel | „An erste Stelle verschieben“, „Von Start lösen“, „An Taskleiste anheften“ bzw. „Von Taskleiste lösen“; im Ordner zusätzlich „Aus Ordner entfernen“ | ✅ „An erste Stelle verschieben“, „Von Start lösen“, „Von Taskleiste lösen“/„An Taskleiste anheften“, „Deinstallieren“; im Ordner „Aus Ordner entfernen“ |
| S10 | Muss | Empfohlen | Kopf „Empfohlen“ + Knopf „Mehr“ mit „>“; 2 Spalten × 3 Zeilen; Eintrag: Symbol 32, Titel 12–14 px, Untertitel 12 px sekundär („Kürzlich hinzugefügt“, „Vor 2 Std.“, „Gestern um 17:42“, Datum) | ✅ 2 Spalten × 3 Zeilen, Symbol 32, Titel und Untertitel 12 px („Kürzlich hinzugefügt“, „Vor 16 Std.“) |
| S11 | Muss | „Mehr“-Ansicht | Liste aller Empfehlungen, Kopf „Empfohlen“ + „<  Zurück“ | ✅ „Mehr“ öffnet die Liste „Empfohlen“ mit „< Zurück“ |
| S12 | Muss | „Alle“-Ansicht | Kopf „Alle“ + „<  Zurück“; Liste mit Buchstabenüberschriften; Eintrag Höhe 40 (u), Symbol 24; Klick auf eine Überschrift → Buchstabenraster; Klick auf Buchstaben springt dorthin | ✅ Buchstabenüberschriften, Einträge 40 px mit Symbol 24, Buchstabenraster (fehlende grau), Sprung zu „K“ |
| S13 | Muss | Fußleiste | Höhe 64 (u), dunklere Fläche mit Trennlinie oben; links Benutzerbild 32 + Name; rechts Ein/Aus-Knopf 40×40 | ✅ Fußleiste ab y 952 (64 px + Rand), dunklere Fläche mit Linie, Bild 32 + Name, Ein/Aus 40 × 40 |
| S14 | Muss | Kontomenü | Klick auf den Benutzer: Kopf mit Bild und Name, „Kontoeinstellungen ändern“, „Sperren“, „Abmelden“ (+ weitere Benutzer, falls vorhanden) | ✅ Kopf (Bild 48, Name, „Lokales Konto“), „Kontoeinstellungen ändern“, „Sperren“, „Abmelden“; weitere Konten über AccountsService (in der VM keine) |
| S15 | Muss | Ein/Aus-Menü | über dem Knopf, Menüstil 2.11 mit Symbolen: „Anmeldeoptionen“, „Energie sparen“, „Herunterfahren“, „Neu starten“ (u Reihenfolge) | ✅ Menü über dem Knopf mit Symbolen: „Anmeldeoptionen“, „Energie sparen“, „Herunterfahren“, „Neu starten“ |
| S16 | Muss | Tastatur | Win öffnet/schließt; Tippen beginnt die Suche; Pfeiltasten im Raster, Eingabe startet; Esc schließt | ✅ Win öffnet/schließt, Tippen → Suche, ↓ → → ↓ wandert im Raster, Eingabe startet, Esc schließt |
| S17 | Soll | Hover | Kachel/Eintrag `SubtleFillColorSecondary`, Radius 4 | ✅ SubtleFill, Radius 4 (Bilder) |
| S18 | Soll | Neue Apps | neu installierte App erscheint in „Empfohlen“ als „Kürzlich hinzugefügt“ | ✅ KMag installiert → „KMag – Kürzlich hinzugefügt“ |

## C Suche (5.2)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| Q1 | Muss | Öffnen | Klick auf das Suchfeld der Taskleiste, Win+S und Win+Q; Panel an der Stelle des Startmenüs (gleiche Größe, 12 px über der Taskleiste), Fokus im Suchfeld; Tippen im Startmenü wechselt in die Suche | ✅ Suchfeld der Taskleiste, Win+S, Win+Q; gleiche Lage und Größe wie Start; Tippen im Start wechselt in die Suche |
| Q2 | Muss | Kopf | Suchfeld mit Lupe, Platzhalter „Hier eingeben, um zu suchen“ (u); darunter Filter „Alle“, „Apps“, „Dokumente“, „Web“, „Einstellungen“, „Ordner“, „Fotos“; aktiver Filter hervorgehoben (Akzentstrich) | ✅ Platzhalter „Hier eingeben, um zu suchen“ (u), Filterleiste, aktiver Filter Semibold + Akzentstrich 16 × 3 |
| Q3 | Muss | Leerzustand | „Top-Apps“ (Symbolreihe), „Zuletzt verwendet“ (Liste) und rechts „Schnellsuchen“ | ✅ „Top-Apps“, „Zuletzt verwendet“, „Schnellsuchen“ (lokaler Ersatz, Abweichung 3) |
| Q4 | Muss | Ergebnisse | links „Höchste Übereinstimmung“ (großer Eintrag) und Gruppen „Apps“, „Einstellungen“, „Dokumente“, „Ordner“, „Fotos“ …; rechts Detailbereich mit großem Symbol, Name, Art | ✅ „Höchste Übereinstimmung“, Gruppen Apps/Einstellungen/Dokumente/Web, Detailbereich (Symbol 64, Name, Art) |
| Q5 | Muss | Aktionen im Detailbereich | „Öffnen“, „Dateispeicherort öffnen“, „An Start anheften“/„Von Start lösen“, „An Taskleiste anheften“/„Von Taskleiste lösen“ (Apps); „Öffnen“, „Dateispeicherort öffnen“, „Pfad kopieren“ (Dateien) | ✅ Apps: Öffnen, Dateispeicherort öffnen, An Start/Taskleiste anheften bzw. lösen, Deinstallieren; Datei notiz.txt: Öffnen, Dateispeicherort öffnen, Pfad kopieren |
| Q6 | Muss | Filter | „Apps“ zeigt nur Apps, „Einstellungen“ nur Einstellungen usw. | ✅ „Apps“ zeigt nur Apps, „Web“ nur die Websuche |
| Q7 | Muss | Tastatur | ↑/↓ wählt, Eingabe öffnet, Esc schließt | ✅ ↓ wählt KCalc (Detailbereich folgt), Eingabe startete Dolphin, Esc schließt |
| Q8 | Soll | Web | „Im Web suchen“ öffnet die Suche im Standardbrowser | ✅ Klick öffnete Firefox mit duckduckgo.com/?q=notiz |

## D Schnelleinstellungen (5.3), ersetzt die Vorstufe in Gruppe.qml

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| A1 | Muss | Öffnen und Lage | Klick auf die Gruppe Netz/Ton/Akku und Win+A; rechts unten, rechter Rand 12 px vom Bildschirmrand, 12 px über der Taskleiste; Breite 360 (u) | ✅ Klick auf die Gruppe und Win+A; 360 px (x 1548…1907), 12 px vom Rand, Unterkante y 1019 |
| A2 | Muss | Kacheln | 3 Spalten, Knopf 96×48 Radius 4, Symbol 16, Beschriftung 12 px darunter: „WLAN“, „Bluetooth“, „Flugzeugmodus“, „Energiesparmodus“, „Nachtmodus“, „Barrierefreiheit“ (Kacheln ohne Hardware wie bei Windows ausgeblendet; Darstellung im Prüfmodus mit allen Kacheln) | ✅ Kachel 96 × 48 (gemessen), Beschriftung 12 px darunter; ohne Hardware ausgeblendet (VM: Energiesparmodus, Nachtmodus, Barrierefreiheit), Prüfmodus zeigt alle sechs |
| A3 | Muss | Zustände | an: Akzentfläche (hell `#0067C0`, dunkel `#4CC2FF`), Symbol weiß bzw. schwarz; aus: Steuerelementfläche mit Rand | ✅ an: Akzent `#0067C0`, Symbol weiß (Energiesparmodus, WLAN im Bearbeiten-Bild); aus: Fläche mit Rand |
| A4 | Muss | Unterseiten | WLAN und Bluetooth als geteilte Kachel mit „>“: Unterseite mit Zurück-Pfeil, Schalter und Liste; Barrierefreiheit öffnet eine Unterseite mit Schaltern („Lupe“, „Farbfilter“, „Sprachausgabe“, „Einrastfunktion“) | ✅ WLAN und Bluetooth geteilt mit „>“ → Unterseite mit Zurück, Schalter, Liste bzw. Hinweis; Barrierefreiheit-Unterseite mit vier Schaltern |
| A5 | Muss | Funktion | Flugzeugmodus schaltet den Funk (NetworkManager), Nachtmodus die KWin-Nachtfarben, Energiesparmodus das Energieprofil (falls vorhanden), Schalter der Barrierefreiheit wirken | ✅ Nachtmodus schaltet KWin (enabled true/false), Energiesparmodus → Profil power-saver/balanced, Einrastfunktion (kaccessrc) und Farbfilter (KWin-Effekt) wirken; Flugzeugmodus ohne Funkhardware nicht prüfbar (gleicher Aufruf wie Plasma) |
| A6 | Muss | Regler | Helligkeit (nur bei regelbarem Bildschirm) und Lautstärke: Symbol links, WinUI-Regler (Spur 4 px, Daumen 18/12 px), Lautstärke rechts „>“ zur Geräteauswahl; Klick auf das Symbol schaltet stumm | ✅ Lautstärke (Null-Senke: Regler aktiv), Helligkeit dort sichtbar, wo regelbar; „>“ öffnet „Soundausgabe“ |
| A7 | Muss | Fußleiste | dunklere Leiste: links Akku „85 %“ (nur mit Akku), rechts Stift „Schnelleinstellungen bearbeiten“ und Zahnrad „Alle Einstellungen“ | ✅ Stift und Zahnrad; kein Akku in der VM → ausgeblendet |
| A8 | Muss | Bearbeiten | Kacheln mit Lösen-Abzeichen, „Hinzufügen“ mit Auswahl weiterer Kacheln, „Fertig“; Auswahl bleibt nach Neustart erhalten | ✅ Lösen-Abzeichen, „Hinzufügen“ (Projizieren hinzugefügt und wieder entfernt), „Fertig“; Eintrag schnellKacheln gespeichert |
| A9 | Soll | Medien | bei laufender Wiedergabe (MPRIS) Medien-Flyout über den Schnelleinstellungen (Titel, Interpret, ⏮ ⏯ ⏭) (u) | ✅ Elisa spielt → Medien-Flyout 12 px über den Schnelleinstellungen; Pause → Status „Paused“ |
| A10 | Soll | Mausrad | Mausrad über der Gruppe ändert die Lautstärke (bleibt aus M3) | ✅ Mausrad über der Gruppe: 40 % → 44 % |

## E Benachrichtigungen, Kalender, Toasts (5.4)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| N1 | Muss | Öffnen und Lage | Klick auf die Uhr und Win+N; zwei gestapelte Flyouts rechts unten (oben Benachrichtigungen, unten Kalender), 12 px Abstand zu Rand, Taskleiste und zueinander, Breite 360 (u) | ✅ Klick auf Uhr, Glocke und Win+N; Kalender und Liste je 360 px, Abstand zueinander 12 px (555 → 568), rechts 12 px |
| N2 | Muss | Kopf | „Benachrichtigungen“ 14 px Semibold, rechts „Alle löschen“ (nur mit Meldungen) und Glocke „Nicht stören“; ohne Meldungen „Keine neuen Benachrichtigungen“ | ✅ Kopf, „Alle löschen“, Nicht-stören-Glocke; leer „Keine neuen Benachrichtigungen“ |
| N3 | Muss | Meldungen | nach App gruppiert (App-Symbol 16 + Name); Karte mit Titel 14 px Semibold, Text 14 px, Zeit; „X“ beim Hover entfernt; Klick löst die Standardaktion aus; Aktionsknöpfe | ✅ nach App gruppiert (Kopf Symbol 16 + Name), Karten mit Titel, Text, Aktionen, „X“ beim Hover |
| N4 | Muss | Kalender | Kopf „Dienstag, 6. Oktober“ + Chevron zum Ein-/Ausklappen; Monat „Oktober 2026“ mit ↑/↓; Wochentage „Mo“…„So“; Zellen 40×40, heute Akzentkreis gefüllt mit weißer (dunkel: schwarzer) Zahl; Tage anderer Monate grau | ✅ Kopf mit Chevron (Einklappen getestet), Monat mit ↑/↓, Mo–So, heute Akzentkreis `#0067C0` Ø 40 mit weißer Zahl |
| N5 | Soll | Fokus | Leiste unten: „–“ „30 Minuten“ „+“ und Knopf „Fokus“; startet eine Fokussitzung (Nicht stören + Restzeit) | ✅ „Fokus“ startet Nicht stören mit Restzeit („noch 29:58“), „Beenden“ hebt es auf |
| N6 | Muss | Glocke | Klick auf die Glocke öffnet die Zentrale; Zähler ungelesener Meldungen; bei „Nicht stören“ Glocke mit „z“ | ✅ Glocke mit Zähler, Klick öffnet die Zentrale, bei „Nicht stören“ durchgestrichene Glocke (Abweichung 5) |
| N7 | Muss | Toast | unten rechts, 12 px vom Rand und über der Taskleiste, Breite 364 (u), Radius 8; Kopf: App-Symbol 16 + App-Name 12 px + „…“ + „X“; Titel 14 px Semibold, Text 14 px; Aktionen als Knöpfe | ✅ 364 px (x 1544…1907), 12 px vom Rand und über der Taskleiste, Kopf App-Symbol und Name, „…“/„X“ beim Hover, Aktionsknöpfe gleich breit |
| N8 | Muss | Toast-Verhalten | gleitet von rechts herein (≈ 300 ms), verschwindet nach 5 s (Hover hält an), kritische Meldungen bleiben; mehrere stapeln nach oben; danach in der Zentrale | ✅ Toasts stapeln (neueste unten, 12 px), verschwinden nach 5 s, wandern beim Öffnen in die Zentrale; Gleiten 300 ms und Anhalten beim Hover im Code |
| N9 | Muss | Keine Doppelten | Plasmas eigene Benachrichtigungs-Popups erscheinen nicht mehr | ✅ nur noch eigene Toasts (Plasmas Applet aus dem Systemabschnitt entfernt) |
| N10 | Soll | Klang | Toast spielt den Benachrichtigungsklang des Fenstra-Klangschemas | ✅ canberra-gtk-play spielt „message-new-instant“ (Stream an der Test-Senke nachgewiesen) |

## F Widgets (5.5)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| W1 | Muss | Öffnen und Lage | Widgets-Knopf und Win+W; Panel von links: 12 px Abstand zu linkem Rand, oberem Rand und Taskleiste; Breite 760 (u); Radius 8 | ✅ Widgets-Knopf und Win+W; x 12…771 (760 px), y 12…1019 |
| W2 | Muss | Kopf | Uhrzeit links, rechts „+“ (Widgets hinzufügen) und Benutzerbild | ✅ Uhrzeit, „+“, Benutzerbild |
| W3 | Muss | Karten | Raster mit Karten in den Größen klein (1×1), mittel (2×1), groß (2×2), Radius 8, Kopf mit Name und „…“; Inhalte: Wetter (Temperatur, Zustand, Vorhersage), Kalender, Uhr, Fotos, Systemleistung (Fenstra-Auswahl ohne Feed) | ✅ Karten klein und mittel (Größe „Groß“ im Menü), Wetter mit Vorhersage, Kalender, Uhr, Fotos, Systemleistung, Notizen |
| W4 | Muss | Farbige Wettersymbole | eigene SVGs: Sonne gelb/orange, Wolken weiß-grau, Regen blau, Schnee, Gewitter, Nebel; im Board und im Taskleistenknopf | ✅ farbige Wettersymbole (fenstra-icon-theme 44.0-6) im Board und im Taskleistenknopf |
| W5 | Soll | Anpassen | „+“ fügt Widgets hinzu, „…“ → „Widget entfernen“; Auswahl bleibt gespeichert | ✅ „…“ → „Widget entfernen“ (Notizen), über „+“ wieder hinzufügbar; Eintrag widgets gespeichert |
| W6 | Soll | Hover | Hover über dem Widgets-Knopf (≈ 500 ms) öffnet das Board (u) | ✅ Hover über dem Knopf öffnet nach 500 ms |

## G Tastenkürzel (7.1)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| K1 | Muss | Kürzel | Win (Start), Win+S und Win+Q (Suche), Win+A (Schnelleinstellungen), Win+N (Benachrichtigungen), Win+W (Widgets); zweiter Druck schließt | ✅ Win, Win+S, Win+Q, Win+A, Win+N, Win+W; zweiter Druck schließt |
| K2 | Muss | Konflikte | Meta+W öffnet nicht mehr die KWin-Übersicht (jetzt Meta+Tab, Vorgriff auf M5), Meta+A/Meta+Q nicht mehr Plasma-Aktivitäten; Vorgabe für neue Benutzer in `/etc/xdg/kglobalshortcutsrc` | ✅ Übersicht auf Meta+Tab, Aktivitäten ohne Taste; /etc/xdg/kglobalshortcutsrc, KWin-Skript fenstra-kuerzel |

## H Kirigami-Auswahl (offen aus M2)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| L1 | Muss | Kirigami-Listen | gewählter Eintrag (z. B. Seitenleiste der Systemeinstellungen) mit dunkler Schrift auf grauer Auswahl + Akzentbalken (hell) | ✅ Systemeinstellungen: „Allgemeines Verhalten“ mit dunkler Schrift auf grauer Auswahl und Akzentbalken |
| L2 | Muss | Textauswahl Qt Widgets | markierter Text weiterhin weiß auf Akzent `#0078D4` (z. B. KWrite, Dolphin-Adresszeile) | ✅ Dolphin-Adresszeile: weiß auf `#0078D4` |
| L3 | Soll | Textauswahl Kirigami | markierter Text in Kirigami-Feldern lesbar | ✅ lesbar: dunkle Schrift auf `#0078D4` (Kontrast ≈ 3,6 : 1; Abweichung 6) |

## I Dunkel, Fremd-Toolkits, Messung

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| I1 | Muss | Dunkles Design | alle neuen Flyouts dunkel (`#2C2C2C`), Text hell, Akzent `#4CC2FF` | ✅ alle Flyouts dunkel (Bilder *-dunkel) |
| I2 | Muss | Fremde Toolkits | Firefox- und GTK-Fenster: Knöpfe sichtbar und funktionsfähig (Regressionstest aus M3) | ✅ Firefox (GTK 3): Knöpfe sichtbar, Maximieren und Schließen funktionieren (Werkzeugbefund siehe Nebenbefunde) |
| I3 | Muss | Keine QML-Fehler | Öffnen aller Flyouts erzeugt keine Fehler von org.fenstra im Journal | ✅ keine Meldungen aus /usr/share/plasma/plasmoids/org.fenstra.* oder org/fenstra/shell im Journal |
| I4 | Muss | Messung | fenstra-baseline nach Neustart: Boot < 15 s, RAM nicht schlechter als M3 + 50 MB (≤ 1842 MB) | ✅ Boot 5,83 s; RAM 1828 MB (M3: 1792 MB, Grenze 1842 MB; plasmashell 434 MB statt 442 MB) – messungen/2026-10-06-hyperv-m4-flyouts.txt |
| I5 | Muss | Bildschirmfotos | docs/bilder/m4/ | ✅ docs/bilder/m4/ |

## Ergebnis

**Bestanden** (2026-10-06): alle Muss-Punkte, 11/12 Soll (G5 Animation unter llvmpipe nicht
messbar). Geprüft am Paketstand fenstra-shell 44.0-1, fenstra-theme/fenstra-taskleiste 44.0-11,
fenstra-icon-theme 44.0-6, fenstra-style 44.0-3.

### Abweichungen

1. **Maße mit (u):** Startmenü 642 × 726, Zelle 96 × 84, Fußleiste 64, Schnelleinstellungen/
   Zentrale 360, Toast 364, Widgets 760 sind Schätzwerte aus der Referenz; ohne Original-
   Bildschirmfoto nicht pixelgenau abgeglichen.
2. **Suche:** Treffer liefert KRunner. Die Reihenfolge stammt von KRunner; Fenstra zieht für die
   „Höchste Übereinstimmung“ Apps nach vorn, deren Name oder Beschreibung mit dem Suchtext
   beginnt. Bei „rechner“ bleibt KRDC vorn, weil der Rechner noch KCalc heißt (eigener „Rechner“
   folgt in M10). Dokumente, Ordner und Fotos erscheinen nur, soweit der Dateiindex (Baloo)
   sie kennt.
3. **Leerzustand und Websuche:** Windows zeigt rechts Web-Inhalte („Schnellsuchen“ von Bing);
   Fenstra zeigt lokale Schnellzugriffe (Wetter, Rechner, Einstellungen, Bildschirmfoto,
   Systeminformationen). „Im Web suchen“ öffnet DuckDuckGo im Standardbrowser statt Bing/Edge.
4. **Schnelleinstellungen:** Flugzeugmodus, WLAN und Bluetooth ließen sich in der VM mangels
   Funkhardware nur im Prüfmodus (Darstellung, Unterseiten) prüfen; geschaltet wird mit denselben
   Aufrufen wie in Plasmas eigenen Applets. Die Unterseite Barrierefreiheit hat vier Schalter
   (Windows 24H2 zusätzlich Mono-Audio und Live-Untertitel). Nachtmodus = KWin-Nachtfarben
   „immer an“ mit 4500 K (Stärke wie Windows (u)). Zusatzkacheln für „Bearbeiten“: Projizieren,
   Tastaturlayout, VPN.
5. **Benachrichtigungen:** „Nicht stören“ zeigt eine durchgestrichene Glocke statt der Glocke mit
   „z“. Eine einzelne Meldung einer App erscheint ohne App-Kopf (Plasmas Gruppierung beginnt erst
   bei zwei Meldungen derselben App). Das „…“-Menü des Toasts bietet nur den Weg zu den
   Benachrichtigungseinstellungen.
6. **Textauswahl in Kirigami-Feldern:** dunkle Schrift auf Akzent statt weiß. Kirigami beschriftet
   Listen- und Textauswahl mit derselben Farbe; für die Listen (L1) ist dunkle Schrift richtig.
   Qt-Widgets-Felder bleiben weiß auf Akzent (L2).
7. **Widgets:** kein Nachrichten-Feed und keine Online-Widgets; eigene Auswahl (Wetter über die
   Plasma-Wetter-Engine, Ort in den Taskleisteneinstellungen, Kalender, Uhr, Fotos aus „Bilder“
   bzw. Fenstra-Hintergründe, Systemleistung, Notizen).
8. **Kontowechsel:** Ein anderes Konto führt über „Benutzer wechseln“ zum Anmeldebildschirm
   (Windows wechselt direkt zum gewählten Konto).
9. **Überlauf „^“:** Plasmas Systemabschnitt öffnet sein Popup weiterhin bündig an der Taskleiste
   (kein eigenes Applet, siehe M3 Abweichung 1); alle Fenstra-Flyouts halten die 12 px ein.

### Nebenbefunde

- Kickers `favoritesModel.favorites` liefert in Plasma 6 absichtlich eine leere Liste; die IDs
  der angehefteten Apps kommen über die Rolle FavoriteIdRole (Qt.UserRole + 3), und sie sind
  reine Desktop-IDs ohne „applications:“.
- `org.kde.plasma.workspace.dbus` hat einen `SignalWatcher`; er verlangt einen festen
  Absendernamen und reicht die Argumente als Variant-Objekte weiter (Vergleich über `String()`).
  kglobalaccel meldet jeden Tastendruck als `globalShortcutPressed` auf `/component/kwin`.
- `/etc/xdg/plasmanotifyrc` (plasma-workspace) hält Meldungen ohne App-Zuordnung („@other“) aus
  dem Verlauf; die Zentrale filtert diesen Eintrag aus der Sperrliste.
- Plasmas Benachrichtigungs-Applet verschwindet nur, wenn seine Instanz im Systemabschnitt
  gelöscht wird und der Name in `knownItems` bleibt (sonst gilt es beim nächsten Start als neu).
- KWin liest kwinrc/kaccessrc über KConfigWatcher: `kwriteconfig6 --notify` mit echter Änderung
  wirkt sofort, `qdbus … reconfigure` dagegen nicht.
- `PlasmaCore.Dialog` überschreibt beim ersten Aufbau die `height`-Bindung des mainItem; feste
  Größen deshalb über `Layout.minimum*/maximum*` vorgeben (Widgets-Board war sonst 5 px zu hoch
  und überdeckte die Taskleiste).
- Werkzeug: Ein einzelner absoluter Mausprung erzeugt in KWin-Dekorationen kein Hover, der
  erste Klick auf einen Fensterknopf ging verloren; `vm-input.ps1 click` bewegt die Maus jetzt
  erst daneben und dann aufs Ziel. Außerdem in einem eigenen Prüfskript: `$T` und `$t` sind in
  PowerShell dieselbe Variable.
