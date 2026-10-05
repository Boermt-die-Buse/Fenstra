# Prüfliste M2: Eigene Assets

Bereich: Symbolthema, Mauszeiger, Klangschema, Hintergrundbilder. Sollwerte aus
[windows11-referenz.md](windows11-referenz.md) (Abschnittsnummern in Klammern). Werte bei
100 % Skalierung, 1920×1080.

**Bestehensschwelle:** alle **Muss**-Punkte bestanden und ≥ 80 % der **Soll**-Punkte.
Abweichungen werden in der Spalte „Ergebnis“ begründet.

**Prüfmethode:**
- Symbole: Kontaktblätter (`kontaktblatt.py`, hell und dunkel), Abdeckungsbericht des
  Generators gegen die in der VM benutzten Namen (`tools/vm/symbolbedarf.sh`), Gast-Fotos von
  Dolphin, Systemeinstellungen, Startmenü, Taskleiste und Infobereich.
- Herkunft: `rpm -qR`/`rpm -ql` der Pakete, Suche nach fremden Quellen im Spec.
- Mauszeiger: Gast-Fotos mit eingeblendetem Zeiger (Spectacle `--pointer`), Hotspot-Werte aus
  den Xcursor-Dateien (`xcur2png`-Ersatz: eigenes Prüfskript), Animation per Bildfolge.
- Klänge: Spektrum/Länge mit Python (`wave`, numpy), Abspielen in der VM (`pw-play`),
  Zuordnung in kdeglobals/knotifyrc.

## A Herkunft (Rahmenregeln)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| H1 | Muss | Symbolthema ohne Fluent-Dateien | Spec ohne npm-Quelle, keine Datei aus @fluentui | ✅ Spec ohne npm-Quelle, Prüfsumme entfernt; Generator schreibt nur eigene SVGs |
| H2 | Muss | Symbolthema erbt nicht von Breeze | `Inherits=hicolor`, kein `Requires: breeze-icon-theme` | ✅ `Inherits=hicolor`; Requires nur hicolor-icon-theme, fenstra-logos |
| H3 | Muss | Mauszeiger selbst erzeugt | SVG/Code im Repo, Xcursor beim Bau mit xcursorgen | ✅ src/zeiger.py → rsvg-convert → xcursorgen im %build |
| H4 | Muss | Klänge selbst synthetisiert | Generator im Repo, keine Aufnahmen/Fremddateien | ✅ src/klaenge.py (numpy, fester Zufallskeim), oggenc im %build |
| H5 | Muss | Hintergrundbilder selbst erzeugt | SVG/Code im Repo | ✅ src/hintergrund.py (Blüte + Benutzerbilder) |

## B Symbolthema (5.x, 6.x)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| I1 | Muss | Strichsymbole: Strichstärke | 1 px bei 16 px (Segoe-Fluent-Stil), runde Enden | ✅ Strich 1,0 im 16er-Raster, `stroke-linecap=round` (glyphs.S) |
| I2 | Muss | Strichsymbole folgen dem Farbschema | `ColorScheme-Text`, hell `#1B1B1B`-artig, dunkel weiß; `FollowsColorScheme=true` | ✅ Klasse ColorScheme-Text, FollowsColorScheme=true; dunkel: helle Glyphen (Bild dolphin-dunkel) |
| I3 | Muss | Größen | Aktionen/Status 16, 22, 24, 32; Orte/Geräte/Programme/Dateitypen 16–256 bzw. scalable | ✅ einfarbig 16/22/24/32/48 (22/24 als 16er-Motiv mit Rand, pixelgenau), farbig scalable |
| I4 | Muss | Ordner im Windows-11-Stil | gelber Ordner mit Verlauf (vorne `#FFD45E`→`#F4AF26`), Lasche hinten dunkler | ✅ vorn #FFD45E→#FCC33D→#F4AF26, hinten #E8A31B→#D18A0F |
| I5 | Muss | Sonderordner mit Motiv | Dokumente, Downloads, Bilder, Musik, Videos, Desktop, Vorlagen, Öffentlich | ✅ alle acht mit Motiv; Bibliotheken zusätzlich mit eigenem 16-px-Motiv |
| I6 | Muss | Laufwerke und Geräte farbig | Festplatte, Systemlaufwerk, USB, optisch, Speicherkarte, Netzlaufwerk, Computer | ✅ Festplatte, Systemlaufwerk (C:-Fenster), USB, optisch, Speicherkarte, Netzlaufwerk, Computer, Laptop |
| I7 | Muss | Papierkorb leer/voll | durchscheinender Eimer, voll mit Papieren (Desktop und Explorer) | ✅ user-trash / user-trash-full (Bild symbole-ordner); Desktop-Symbole selbst erst mit dem Desktop-Meilenstein |
| I8 | Muss | Dateitypen | Text, PDF, Bild, Audio, Video, Archiv, Code, Skript, Dokument, Tabelle, Präsentation, Schrift, Programm, Paket, Abbild | ✅ 25 Dateiarten, alle 15 geforderten (Bild symbole-dateitypen), 233 Mime-Namen |
| I9 | Muss | Programmsymbole der Kern-Apps | Explorer, Einstellungen, Terminal, Editor, Rechner, Fotos, Medien, Task-Manager, Ausschneiden, Store, Hilfe, Browser | ✅ 12 eigene Motive + Kacheln für 60 weitere Programme (Bild symbole-programme) |
| I10 | Muss | Infobereich | WLAN 0–4 Balken, kabelgebunden, kein Netz; Lautsprecher 0–3 + stumm; Akku 0–100 % (10er-Stufen), laden; Bluetooth an/aus | ✅ wifi_1–4/off, Kabel, kein Internet (Globus mit Verbot); Lautsprecher 0–3 + stumm; Akku 0–100 % in 10er-Stufen + laden; Bluetooth an/aus/verbunden |
| I11 | Muss | Abdeckung | ≥ 95 % der in der VM benutzten Namen (symbolbedarf.sh) aus Plasma, Dolphin, Systemeinstellungen, Konsole, Spectacle, KWrite gefunden; Liste der Lücken dokumentiert | ✅ Kernliste (`symbolbedarf.sh --kern`, 965 Namen): 942 gefunden = 97,6 % (breite Liste: 1131/1152). Lücken siehe unten |
| I12 | Soll | Keine sichtbaren Lücken | Startmenü „Alle Apps“, Dolphin-Werkzeugleiste und -Kontextmenü, Systemeinstellungen-Seitenleiste ohne leere Symbole | ✅ Startmenü (Angeheftet, Alle Apps), Dolphin-Werkzeugleiste und -Kontextmenü, Systemeinstellungen, Konsole, KWrite, Infobereich: keine Lücke (Test mit magentafarbenem „unknown“); dabei gefunden und behoben: Helligkeits-Applet |
| I13 | Soll | Pixelraster | Strichsymbole bei 16 px scharf (Linien auf halben Pixeln) | ✅ Linien auf halben Pixeln im 16er-Raster; 22/24 ohne Skalierung, 32/48 ganzzahlig skaliert |
| I14 | Soll | Abzeichen (Badges) | Ausschnitt um das Abzeichen; in Qt (QtSvg) sichtbar korrekt | ✅ Maske (z. B. camera-off, network-unavailable) in librsvg und QtSvg (Qt 6.11) korrekt (Bild qt-symbole) |
| I15 | Soll | Symbolfamilien | `-symbolic`-Varianten und `-rtl` vorhanden; Akku/Netz/Ton/Wetter als Familien | ✅ -symbolic für alle farbigen Orte/Geräte/Hinweise eigens, sonst Namensrückfall; Familien Akku, Netz, Ton, Wetter, Helligkeit |
| I16 | Soll | Kontrast dunkel | Strichsymbole auf `#202020` deutlich lesbar | ✅ Bild glyphen-dunkel, dolphin-dunkel |

## C Mauszeiger (6.8)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| C1 | Muss | Normale Auswahl | weißer Pfeil, 1 px schwarzer Rand, sichtbar ca. 12×19 in 32×32, Hotspot Spitze | ✅ 12,5×19,5 px sichtbar, Hotspot (1,1); Nenngröße 24 = Windows-Größe 1 (siehe Abweichungen) |
| C2 | Muss | Alle Rollen der Tabelle 6.8 | eigene Form je Rolle, alle Linux-Namen als Verweise vorhanden | ✅ 25 Formen, 112 Verweisnamen (alle der Tabelle 6.8 außer Position/Person ohne Linux-Gegenstück) |
| C3 | Muss | Beschäftigt animiert | blauer Ring Ø ca. 24, Umlauf ca. 1 s, ≥ 18 Bilder | ✅ Ring Ø 21 px bei Nenngröße 24, 24 Bilder × 42 ms = 1,0 s |
| C4 | Muss | Hintergrundaktivität | Pfeil + kleiner Ring, animiert | ✅ Pfeil + Ring Ø 11, 24 Bilder |
| C5 | Muss | Größen | 24, 32, 48, 64 (Skalierung 0,75–2) | ✅ 24, 32, 36, 48, 64, 72, 96 |
| C6 | Muss | Als Standard eingestellt | `cursorTheme=fenstra` in Sitzung und Anmeldebildschirm | ✅ /etc/xdg/kcminputrc und beide globalen Designs `cursorTheme=fenstra-cursors`; in der Sitzung und auf dem Anmeldebildschirm gesehen (Bilder zeiger-in-vm, anmeldebildschirm) |
| C7 | Soll | Hotspots | Textcursor Mitte, Hand Fingerspitze, Doppelpfeile Mitte, Fadenkreuz Mitte (±1 px) | ✅ Text (12,12), Hand (7,1) Fingerspitze, Doppelpfeile/Fadenkreuz/Verschieben (12,12) |
| C8 | Soll | Schatten | leichter Schlagschatten wie Windows (Sichtprüfung) | ✅ Schlagschatten (Unschärfe 0,8, Versatz 0,6/1, 35 %) |

## D Klänge (6.7)

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| K1 | Muss | Klangschema nach freedesktop-Spezifikation | `/usr/share/sounds/fenstra/index.theme` + `stereo/*.oga` | ✅ /usr/share/sounds/fenstra/index.theme + stereo/*.oga (58 Namen, alle von Plasma benutzten und alle aus Ocean) |
| K2 | Muss | Ereignisse | Anmelden (2–3 s, aufsteigend), Benachrichtigung (~0,5 s, zwei helle Töne), Hinweis, Fehler (tiefer Doppelton), Achtung, Gerät an/ab (auf-/absteigend ~0,4 s), Papierkorb (Rascheln ~1 s), Lautstärke („Ding“), Akku niedrig/kritisch | ✅ alle; Längen inkl. Nachhall: Anmelden 3,7 s (Klangkörper ~2,6 s), Benachrichtigung 1,1 s (zwei Töne in 0,1 s), Fehler 1,0 s, Gerät 0,9 s, Papierkorb 1,2 s (Bild klaenge-huellkurven) |
| K3 | Muss | Als Standard eingestellt | kdeglobals `[Sounds] Theme=fenstra`; Plasma-Lautstärke-Rückmeldung nutzt es | ✅ kdeglobals `[Sounds] Theme=fenstra` (kreadconfig6 in der VM); hörbar nicht prüfbar (VM ohne Audiogerät) |
| K4 | Muss | Keine Übersteuerung | Spitzenpegel ≤ −1 dBFS, kein Knacken (Ein-/Ausblendung ≥ 5 ms) | ✅ Spitze ≤ −1,5 dBFS; Einblenden 5 ms, Ausblenden ≥ 20 ms |
| K5 | Soll | Abmelden still | kein Klang beim Abmelden (wie Windows 11) | ✅ desktop-logout/service-logout = 50 ms Stille (kein Rückfall auf fremde Klänge) |
| K6 | Soll | Lautheit einheitlich | Ereignisklänge innerhalb ±3 dB RMS zueinander (außer Anmelden) | ✅ Ereignisklänge auf −21 dB RMS (lauter Anteil) normiert; Begrenzung nur beim Anmeldeklang |

## E Hintergrundbilder und Benutzerbilder

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| W1 | Muss | Hell und dunkel | eigenes Bloom-artiges Motiv, hell auf Hellblau, dunkel auf Dunkelblau | ✅ eigene Blüte aus 16 durchscheinenden Blättern, hell auf #CFDFF3…#F2F4FB, dunkel auf #0C2148…#03060F |
| W2 | Muss | Auflösungen | SVG + PNG 1920×1080, 2560×1440, 3840×2160 | ✅ SVG + 18 Auflösungen (u. a. 1920×1080, 2560×1440, 3840×2160) als JPEG q92 (siehe Abweichungen) |
| W3 | Soll | Benutzerbilder | mindestens 4 eigene Profilbilder (Standard = graue Person auf hellem Kreis) | ✅ sechs Bilder („Fenstra Person“ = Windows-Standard, Blüte, Berge, Welle, Blatt, Planet) |

## F Messung und Abschluss

| # | Prio | Prüfpunkt | Sollwert | Ergebnis |
|---|---|---|---|---|
| F1 | Muss | Pakete bauen und installieren sich | build-packages.sh ohne Fehler; `dnf install` in der VM | ✅ fenstra-icon-theme 44.0-3, -cursor-theme 44.0-1, -sound-theme 44.0-1, -backgrounds 44.0-2, -theme 44.0-8 gebaut und per dnf installiert |
| F2 | Muss | fenstra-baseline nach Neustart | Boot < 15 s; RAM nicht schlechter als M1 + 50 MB | ✅ Boot 5,56 s; RAM 1767 MB (M1: 1793 MB) – messungen/2026-10-06-hyperv-m2-assets.txt |
| F3 | Muss | Bildschirmfotos | docs/bilder/m2/ | ✅ docs/bilder/m2/ (22 Bilder) |
| F4 | Soll | Paketgröße Symbolthema | ≤ 15 MB installiert | ✅ 5,0 MB installiert (Symbole), 6,5 MB (Zeiger), 1,2 MB (Klänge) |

## Ergebnis

**Bestanden** (2026-10-06): 31/31 Muss, 11/11 Soll.

### Abweichungen

1. **Zeiger-Nenngröße 24 statt 32:** Plasma arbeitet mit Nenngröße 24. Die Formen sind so
   gezeichnet, dass der Pfeil bei 24 genauso groß ist wie unter Windows bei Größe 1 (32×32-Bild,
   Pfeil ca. 12×19 px).
2. **Klänge nur rechnerisch geprüft:** Die Hyper-V-VM hat kein Audiogerät. Länge, Pegel und
   Hüllkurven sind gemessen; der Hörtest folgt auf echter Hardware (USB-Stick, M13).
3. **Benutzerbilder:** Die KDE-Bilder (Konqi) aus plasma-workspace bleiben in der Auswahl. Sie
   werden mit der eigenen Konto-/Ersteinrichtung (M7) ausgeblendet.
4. **Ordnerfarben:** KDE-Ordnerfarben (folder-red usw.) sind alle gelb wie unter Windows, wo es
   keine Ordnerfarben gibt.
5. **Dolphin-Navigationsbereich:** Dolphin fragt die Orte mit 22 px ab und zeigt deshalb die gelben
   Ordner. Die 16-px-Bibliothekssymbole wie im Explorer kommen mit dem Explorer (M8) zum Einsatz.
6. **Hintergründe als JPEG (q92) statt PNG:** wie bisher; spart rund 80 % Platz, ohne sichtbare
   Stufen.
7. **Nicht abgedeckt (23 Namen der Kernliste):** atmosphere, blur, boost, charcoaltool,
   colors-luma, coordinate, discrete, embosstool, food, gnumeric-ungroup, kdenlive-custom-effect,
   know, linear, multiple, newline, restoration, roll, smooth, strong, verb, verbatim,
   view-time-schedule-baselined-remove (Bildfilter fremder Programme oder Wörter aus
   Bibliothekstexten ohne Symbolbezug) sowie „empty“. Fehlende Namen zeigt Plasma als leeres Blatt
   („unknown“).

### Nebenbefund (nicht M2)

- Kirigami-Listen (Systemeinstellungen-Seitenleiste): Der ausgewählte Eintrag hat weiße Schrift auf
  der hellgrauen WinUI-Auswahlfläche aus M1 und ist kaum lesbar. Grund: Kirigami färbt ausgewählten
  Text mit `highlightedTextColor`, der Qt-Stil zeichnet aber die WinUI-Fläche. Das wird im
  nächsten Stil-Durchgang behoben (vorgemerkt in CLAUDE.md).

