# Windows 11 (24H2) – Referenzwerte für Fenstra

Grundlage aller Prüflisten (`docs/checkliste-*.md`). Alle Maße in px bei 100 % Skalierung
(1920×1080), Farben als Hex (`#AARRGGBB` = mit Alpha), Zeiten in ms.

**Quellen** (nur gelesen, nichts übernommen):
- **WinUI** = öffentliche Themenressourcen von WinUI 3 (github.com/microsoft/microsoft-ui-xaml,
  `controls/dev/**/_themeresources*.xaml`, Stand 2026-10-05). Diese Werte sind exakt.
- **MS Learn** = Designrichtlinien learn.microsoft.com/windows/apps/design.
- **Kenntnis** = Wissen des Modells über Windows 11, ohne Primärquelle. Wo unsicher: **(u)**.
  Diese Punkte werden gegen Referenzbilder geprüft, sobald der Nutzer welche nach
  `C:\Users\Daniel\Fenstra\referenz\` legt.

**Festlegung Startmenü:** Referenz ist das klassische 24H2-Startmenü (Angeheftet mit Seiten,
Empfohlen, „Alle Apps“ als eigene Ansicht). Das Ende 2025 nachgereichte neue Startmenü
(eine scrollende Seite, Kategorien) wird nicht nachgebaut.

Inhalt: [1 Design-Tokens](#1-design-tokens) · [2 Steuerelemente](#2-steuerelemente) ·
[3 Fenster](#3-fenster) · [4 Taskleiste](#4-taskleiste) · [5 Shell-Flyouts](#5-shell-flyouts) ·
[6 Systemoberflächen](#6-systemoberflächen) · [7 Verhalten](#7-verhalten) · [8 Apps](#8-apps) ·
[Offene Punkte](#offene-punkte)

---

## 1 Design-Tokens

### 1.1 Farben (WinUI, exakt)

| Token | Hell | Dunkel | Verwendung |
|---|---|---|---|
| TextFillColorPrimary | `#E4000000` | `#FFFFFF` | Haupttext |
| TextFillColorSecondary | `#9E000000` | `#C5FFFFFF` | Beschreibungen, Untertitel |
| TextFillColorTertiary | `#72000000` | `#87FFFFFF` | Platzhalter (Rest) |
| TextFillColorDisabled | `#5C000000` | `#5DFFFFFF` | deaktiviert |
| TextOnAccentFillColorPrimary | `#FFFFFF` | `#000000` | Text auf Akzentknopf |
| TextOnAccentFillColorSecondary | `#B3FFFFFF` | `#80000000` | Akzentknopf gedrückt |
| ControlFillColorDefault | `#B3FFFFFF` | `#0FFFFFFF` | Knopf/Eingabefeld Ruhe |
| ControlFillColorSecondary | `#80F9F9F9` | `#15FFFFFF` | Hover |
| ControlFillColorTertiary | `#4DF9F9F9` | `#08FFFFFF` | gedrückt |
| ControlFillColorDisabled | `#4DF9F9F9` | `#0BFFFFFF` | deaktiviert |
| ControlFillColorInputActive | `#FFFFFF` | `#B31E1E1E` | Eingabefeld mit Fokus |
| ControlStrongFillColorDefault | `#72000000` | `#8BFFFFFF` | Kontrollkästchen-Rahmen, Schalter-Knopf |
| ControlSolidFillColorDefault | `#FFFFFF` | `#454545` | Schieberegler-Daumen außen |
| SubtleFillColorSecondary | `#09000000` | `#0FFFFFFF` | Hover auf transparenten Flächen (Listen, Menüs, Taskleiste) |
| SubtleFillColorTertiary | `#06000000` | `#0AFFFFFF` | gedrückt auf transparenten Flächen |
| ControlAltFillColorSecondary | `#06000000` | `#19000000` | Kontrollkästchen leer |
| ControlAltFillColorTertiary | `#0F000000` | `#0BFFFFFF` | Kontrollkästchen leer Hover |
| ControlAltFillColorQuarternary | `#18000000` | `#12FFFFFF` | Kontrollkästchen leer gedrückt |
| ControlStrokeColorDefault | `#0F000000` | `#12FFFFFF` | Rahmen von Knöpfen/Feldern |
| ControlStrokeColorSecondary | `#29000000` | `#18FFFFFF` | Unterkante (Elevation-Verlauf) |
| ControlStrokeColorOnAccentDefault | `#14FFFFFF` | `#14FFFFFF` | Rahmen Akzentknopf |
| ControlStrokeColorOnAccentSecondary | `#66000000` | `#23000000` | Unterkante Akzentknopf |
| ControlStrongStrokeColorDefault | `#72000000` | `#8BFFFFFF` | Eingabefeld-Unterlinie (Ruhe), Schalter-Rahmen |
| CardStrokeColorDefault | `#0F000000` | `#19000000` | Karten |
| CardBackgroundFillColorDefault | `#B3FFFFFF` | `#0DFFFFFF` | Karten (Einstellungen) |
| CardBackgroundFillColorSecondary | `#80F6F6F6` | `#08FFFFFF` | Karten Hover/zweite Ebene |
| SurfaceStrokeColorFlyout | `#0F000000` | `#33000000` | Rahmen von Flyouts/Menüs |
| SurfaceStrokeColorDefault | `#66757575` | `#66757575` | Rahmen von Fenstern/Dialogen |
| DividerStrokeColorDefault | `#0F000000` | `#15FFFFFF` | Trennlinien |
| FocusStrokeColorOuter | `#E4000000` | `#FFFFFF` | Fokusrahmen außen (2 px) |
| FocusStrokeColorInner | `#B3FFFFFF` | `#B3000000` | Fokusrahmen innen (1 px) |
| SolidBackgroundFillColorBase | `#F3F3F3` | `#202020` | Fenstergrund (Mica-Ersatz) |
| SolidBackgroundFillColorSecondary | `#EEEEEE` | `#1C1C1C` | |
| SolidBackgroundFillColorTertiary | `#F9F9F9` | `#282828` | |
| SolidBackgroundFillColorQuarternary | `#FFFFFF` | `#2C2C2C` | |
| LayerFillColorDefault | `#80FFFFFF` | `#4C3A3A3A` | Inhaltsebene auf Mica (Einstellungen-Inhalt) |
| LayerFillColorAlt | `#FFFFFF` | `#0DFFFFFF` | |
| SmokeFillColorDefault | `#4D000000` | `#4D000000` | Abdunkeln hinter Dialogen |
| SystemFillColorCritical | `#C42B1C` | `#FF99A4` | Fehler; auch Schließen-Hover (Fenster) |
| SystemFillColorCaution | `#9D5D00` | `#FCE100` | Warnung |
| SystemFillColorSuccess | `#0F7B0F` | `#6CCB5F` | Erfolg |
| SystemFillColorCriticalBackground | `#FDE7E9` | `#442726` | |
| SystemFillColorCautionBackground | `#FFF4CE` | `#433519` | |
| SystemFillColorSuccessBackground | `#DFF6DD` | `#393D1B` | |

### 1.2 Akzentfarbe

Standard-Akzent „Standardblau“ `#0078D4`; Windows erzeugt daraus eine Palette
(Quelle: winaccent-Doku, gegen WinUI-Abbildung geprüft):

| Stufe | Wert | Hell-Modus | Dunkel-Modus |
|---|---|---|---|
| Light3 | `#99EBFF` | – | Akzenttext primär/sekundär |
| Light2 | `#4CC2FF` | – | **Akzentflächen** (Knöpfe, Schalter an, Auswahlbalken), Akzenttext tertiär |
| Light1 | `#0091F8` | – | – |
| Akzent | `#0078D4` | Textauswahl-Hintergrund | Textauswahl-Hintergrund |
| Dark1 | `#0067C0` | **Akzentflächen**, Akzenttext tertiär | – |
| Dark2 | `#003E92` | Akzenttext primär (Links) | – |
| Dark3 | `#001A68` | Akzenttext sekundär | – |

- Hover auf Akzentfläche = gleiche Farbe mit Deckkraft 0,9; gedrückt 0,8 (WinUI
  `AccentFillColorSecondary/Tertiary`).
- Text auf Akzent: hell `#FFFFFF`, dunkel `#000000`.
- Die Akzentfarben-Auswahl in Einstellungen → Personalisierung → Farben zeigt 48 Farben
  (8 Spalten × 6 Zeilen) (u). Standard: Akzent manuell, „Akzentfarbe auf Start und
  Taskleiste anzeigen“ aus, „Akzentfarbe für Titelleisten und Fensterrahmen anzeigen“ aus.

### 1.3 Typografie (MS Learn „Typography“, Schrift Segoe UI Variable → Fenstra: Selawik)

| Stil | Größe / Zeilenhöhe | Gewicht | Verwendung |
|---|---|---|---|
| Caption | 12 / 16 | Regular | Taskleistenuhr, Tooltips, Beschriftungen in Startmenü-Kacheln |
| Body | 14 / 20 | Regular | Standardtext aller Steuerelemente |
| Body Strong | 14 / 20 | Semibold | Abschnittstitel in Flyouts („Angeheftet“) |
| Body Large | 18 / 24 | Regular | |
| Subtitle | 20 / 28 | Semibold | Dialogtitel (ContentDialog) |
| Title | 28 / 36 | Semibold | Seitentitel (Einstellungen) |
| Title Large | 40 / 52 | Semibold | |
| Display | 68 / 92 | Semibold | Uhrzeit Sperrbildschirm (u: dort größer, s. 6) |

- Symbolschrift Segoe Fluent Icons (Fenstra: eigene SVG-Strichsymbole): 16 px Standard,
  10 px in Titelleistenknöpfen, 12 px in Chevrons/Kontrollkästchen-Haken.
- Fenstra-Abweichung: Selawik (frei, metrisch wie Segoe UI) statt Segoe UI Variable.
  Qt rechnet in pt: 14 px = 10,5 pt bei 96 dpi; 12 px = 9 pt. Plasma-Vorgabe deshalb
  „Selawik 10,5 pt“ (u: Rundung prüfen).

### 1.4 Geometrie

| Wert | px | Quelle |
|---|---|---|
| ControlCornerRadius (Knöpfe, Felder, Listeneinträge) | 4 | WinUI |
| OverlayCornerRadius (Flyouts, Menüs, Dialoge, Startmenü) | 8 | WinUI |
| Fensterecken | 8 | MS Learn „Geometry“ |
| Ecken maximiert/eingerastet an Bildschirmrand | 0 | MS Learn |
| Rahmenstärke Steuerelemente | 1 | WinUI |
| Raster | 4 (Abstände 4/8/12/16/24/32) | MS Learn „Spacing“ |
| Standard-Steuerelementhöhe | 32 | WinUI |

### 1.5 Elevation und Schatten (MS Learn „Layering and elevation“, Werte (u))

| Ebene | Elevation | Schatten (hell) |
|---|---|---|
| Karte | 2 | kein bis sehr schwach |
| Tooltip | 16 | 0 4 8 `#24000000` |
| Flyout/Menü | 32 | 0 8 16 `#24000000` |
| Dialog | 128 | 0 32 64 `#37000000` |
| Fenster aktiv | 128 | großer weicher Schatten, ca. 0 32 64 `#37000000` plus 0 2 21 `#21000000` |
| Fenster inaktiv | 32 | deutlich kleiner, ca. 0 16 32 `#24000000` |

Dunkelmodus: gleiche Geometrie, höhere Deckkraft (ca. ×2) (u).

### 1.6 Bewegung (WinUI, exakt, wo angegeben)

| Wert | Dauer | Quelle |
|---|---|---|
| ControlFasterAnimationDuration | 83 | WinUI |
| ControlFastAnimationDuration | 167 | WinUI |
| ControlNormalAnimationDuration | 250 | WinUI |
| ControlFastOutSlowInKeySpline | cubic-bezier(0,0,0,1) | WinUI |
| Hover-Farbwechsel (Knöpfe, Listen) | 83 | WinUI (Brush-Transitions) |
| Bildlaufleiste ausklappen/einklappen | 167 / 167 | WinUI ScrollBar |
| Flyout öffnen | 250–367, von unten/oben 50 px + Einblenden, Kurve (0,0,0,1) (u) | Kenntnis |
| Flyout schließen | 167, Ausblenden (u) | Kenntnis |
| Startmenü öffnen | ca. 250–300, hochgleiten ca. 100 px + Einblenden (u) | Kenntnis |
| Seitenwechsel „Drill-in“ | 333 Einblenden + Skalierung 0,94→1 (u) | MS Learn Motion |

### 1.7 Fokus

- Fokusrahmen nur bei Tastaturbedienung: außen 2 px `FocusStrokeColorOuter`, innen 1 px
  `FocusStrokeColorInner`, Radius = Radius des Elements + 2 (bei 4 → 6, bei 8 → 10) (u),
  Abstand außen 3 px vor Knopfkante (WinUI FocusVisualMargin -3).

### 1.8 Materialien (WinUI AcrylicBrush, exakt)

| Material | Hell | Dunkel |
|---|---|---|
| Acrylic Standard (Flyouts, Menüs, Startmenü, Kontextmenüs) | Tint `#FCFCFC` Deckkraft 0,0, Luminosität 0,85, Ersatzfarbe `#F9F9F9` | Tint `#2C2C2C` Deckkraft 0,15, Luminosität 0,96, Ersatzfarbe `#2C2C2C` |
| Acrylic Basis (Taskleiste (u), Startmenü-Fußleiste) | Tint `#F3F3F3` 0,0, Luminosität 0,9, Ersatz `#EEEEEE` | Tint `#202020` 0,5, Luminosität 0,96, Ersatz `#1C1C1C` |
| Akzent-Acrylic | Light3 0,8 / 0,9 | Dark1 0,8 / 0,8 |
| Mica (Fensterhintergrund) | Basis `#F3F3F3`, Tint-Deckkraft 0,5, Luminosität 1,0 (u) | Basis `#202020`, Tint-Deckkraft 0,8, Luminosität 1,0 (u) |
| Mica Alt (Titelleiste mit Tabs) | etwas dunkler/kräftiger getönt als Mica (u) | |

Acrylic = Hintergrund weichgezeichnet (Radius ca. 30 px (u)) + Luminositätsschicht +
Tönung + 2 % Rauschen. Ohne Transparenz (Energiesparen/Einstellung aus) gilt die Ersatzfarbe.

---

## 2 Steuerelemente

Alle Werte WinUI, sofern nicht (u). Zustände: Ruhe / Hover / gedrückt / deaktiviert.

### 2.1 Schaltfläche (Button)

- Höhe 32, Innenabstand 11,5,11,6, Radius 4, Rahmen 1 px, Text Body 14.
- Füllung: ControlFillColorDefault / Secondary / Tertiary / Disabled.
- Rahmen: ControlElevationBorder = Verlauf oben `ControlStrokeColorDefault`, unten
  (letzte 1–2 px) `ControlStrokeColorSecondary`; gedrückt nur `ControlStrokeColorDefault`.
- Text: Primary; gedrückt Secondary; deaktiviert Disabled.
- **Akzentschaltfläche:** Füllung Akzent (1.2), Hover ×0,9, gedrückt ×0,8; Rahmen
  `ControlStrokeColorOnAccentDefault` mit Unterkante `ControlStrokeColorOnAccentSecondary`;
  Text `TextOnAccentFillColorPrimary`, gedrückt `…Secondary`.

### 2.2 Eingabefeld (TextBox, PasswordBox, Suchfeld)

- Höhe 32, Radius 4, Innenabstand ca. 10,5,6,6 (u), Platzhalter `TextFillColorSecondary`.
- Rahmen 1 px `ControlStrokeColorDefault`, Unterkante 1 px `ControlStrongStrokeColorDefault`.
- Fokus: Füllung `ControlFillColorInputActive`, Unterkante **2 px Akzent** (WinUI
  `TextControlBorderThemeThicknessFocused` 1,1,1,2), übrige Kanten bleiben 1 px.
- Löschen-Knopf („X“) rechts im Feld bei Fokus und Inhalt (Rand 0,4,4,4, Symbol 12).
- Kennwortfeld: Auge-Knopf „Kennwort anzeigen“ rechts.

### 2.3 Kontrollkästchen (CheckBox)

- Kästchen 20×20, Radius 4, Rahmen 1 px, Haken 12 px; Zeile Höhe 32, Abstand Text 8.
- Leer: Füllung `ControlAltFillColorSecondary`, Rahmen `ControlStrongStrokeColorDefault`.
- Angehakt: Füllung Akzent, Haken `TextOnAccentFillColorPrimary`, kein Rahmen.
- Haken-Animation: Strich zeichnet sich von links ein (ca. 167) (u).

### 2.4 Optionsfeld (RadioButton)

- Außenkreis 20, Rahmen 1 px `ControlStrongStrokeColorDefault`.
- Gewählt: Außenkreis Akzent, innerer Punkt `TextOnAccentFillColorPrimary`
  (hell: weiß) Ø 12 (Ruhe), 14 (Hover), 10 (gedrückt) – WinUI exakt.

### 2.5 Umschalter (ToggleSwitch)

- Spur 40×20, Radius 10. Aus: Rahmen 1 px `ControlStrongStrokeColorDefault`, Knopf
  `ControlStrongFillColorDefault` Ø 12 (Hover 14, gedrückt 17×14) (u Größen).
- Ein: Spur Akzent, Knopf `TextOnAccentFillColorPrimary`.
- Text rechts: „Ein“ / „Aus“, Abstand 10 (Pre/PostContentMargin), Mindestbreite 154.
- Knopf gleitet in ca. 167 (u).

### 2.6 Schieberegler (Slider)

- Höhe 32, Spur 4 px, Radius 2, Spur Rest `ControlStrongFillColorDefault`, gefüllter
  Teil Akzent.
- Daumen außen 18×18 (Radius 10 → Kreis), Füllung `ControlSolidFillColorDefault`, Rahmen
  1 px Elevation; innerer Akzentpunkt Ø 12 (Ruhe), 14 (Hover), 10 (gedrückt).
- Wert-Tooltip beim Ziehen.

### 2.7 Fortschritt

- ProgressBar: Spur 1 px (`ControlStrongStrokeColorDefault`), Balken 3 px, Radius 1,5,
  Farbe Akzent; unbestimmt: zwei Segmente laufen von links nach rechts (ca. 2 s Zyklus) (u).
- ProgressRing: Strichstärke 4 (bei 32 px) (u), Akzent, kreisender Bogen.

### 2.8 Bildlaufleiste (ScrollBar)

- Breite ausgeklappt 12 (`ScrollBarSize`), Daumen 6 px (`ScrollBarThumbStrokeThickness`
  ausgeklappt), Radius 3, Mindestlänge 30, Pfeile Schriftgröße 8, Abstand Pfeile 4.
- Eingeklappt (Maus nicht darüber): nur dünne Linie ca. 2 px (u) am Rand, über dem Inhalt
  (überlagernd, nimmt keinen Platz weg).
- Ausklappen beim Hover 167, Einklappen 167 (nach ca. 1–2 s Verzögerung (u)),
  Farbwechsel 83.
- Farbe Daumen: `ControlStrongFillColorDefault` (hell `#72000000`) (u).

### 2.9 Kombinationsfeld (ComboBox)

- Höhe 32, Mindestbreite 64, Innenabstand 12,5,0,7, Radius 4, Pfeil-Glyphe rechts
  (Schriftgröße 21 → sichtbar ca. 12), Aussehen wie Schaltfläche.
- Popup: Mindestbreite 80, Rahmen 1 px, Radius 8, Acrylic; **öffnet über dem Feld**, der
  gewählte Eintrag liegt deckungsgleich auf dem Feld.
- Einträge: Innenabstand 11,5,11,7, Radius 3, Rand 4 px, gewählter Eintrag mit
  Auswahlbalken links 3×16 px, Radius 1,5, Akzent; Hover `SubtleFillColorSecondary`.

### 2.10 Listen (ListView, TreeView)

- Eintrag Mindesthöhe 40 (Listen) bzw. 32 (Baum/Navigation (u)), Radius 4,
  Rand ca. 4,2 (u).
- Hover `SubtleFillColorSecondary`, gedrückt `SubtleFillColorTertiary`,
  gewählt `SubtleFillColorSecondary` + **Auswahlbalken** links 3×16 px, Radius 1,5, Akzent;
  Balken wächst beim Wechsel (Animation 167) (u).

### 2.11 Menüs (MenuFlyout, Kontextmenüs)

- Rahmen 1 px `SurfaceStrokeColorFlyout`, Radius 8, Acrylic, Schatten Flyout.
- Innenabstand des Menüs oben/unten 2 (+ Eintragsrand 2 → effektiv 4).
- Eintrag: Rand 4,2,4,2, Innenabstand 11,8,11,9, Mindesthöhe 32, Radius 4,
  Hover `SubtleFillColorSecondary`.
- Symbolspalte: Platzhalter 28 px vor dem Text, wenn ein Eintrag ein Symbol hat (Symbol 16).
- Tastenkürzel rechtsbündig in `TextFillColorSecondary`, Abstand ≥ 24.
- Untermenü-Chevron rechts (Rand 24 links), Trennlinie 1 px `DividerStrokeColorDefault`
  über die volle Breite (Innenabstand -4,1,-4,1).
- Öffnen: von oben/unten einblenden + 10–50 px gleiten (u).

### 2.12 Tooltip

- Schrift 12, Innenabstand 9,6,9,8, Rahmen 1 px, Radius 4 (u), Max-Breite 320,
  Hintergrund Acrylic/`SolidBackgroundFillColorQuarternary` (u).
- Verzögerung ca. 400–1000 (u).

### 2.13 Register (TabView, z. B. Explorer/Terminal/Editor)

- Tab Höhe 32, Breite 100–240, Innenabstand 8,3,4,3, Text 12, Symbol 16 (Abstand 10),
  Schließen-Knopf 32×24 (Glyphe 12), Hinzufügen-Knopf „+“ 32×24.
- Gewählter Tab: Füllung = Inhaltsfläche darunter (verschmilzt), Radius 8 oben, kleine
  äußere Rundungen unten (u); nicht gewählte Tabs transparent, Trenner 1 px zwischen
  ihnen (Rand 0,8,0,8).

### 2.14 Navigationsbereich (NavigationView, Einstellungen)

- Eintrag Höhe 36, Rand 4,2, Symbolbox 40 breit (Symbol 16), Auswahlbalken 3×16 links,
  Inhalt ab Spalte Symbol; Chevron 8 bei Untereinträgen.
- Inhaltsbereich rechts mit Radius 8 oben links (`NavigationViewContentGridCornerRadius`).

### 2.15 Dialoge und Flyouts

- ContentDialog: Breite 320–548, Höhe 184–756, Innenabstand 24, Titel (Subtitle 20)
  mit Abstand 12, Rahmen 1 px, Radius 8; Schaltflächenleiste unten auf
  `SolidBackgroundFillColorBase` mit Trennlinie, Knöpfe gleich breit; Hintergrund abgedunkelt
  `SmokeFillColorDefault`.
- Flyout: Innenabstand 16,15,16,17, Rahmen 1 px, Radius 8.
- Expander/Einstellungskarte: Mindesthöhe 48 (Expander) bzw. 68 (Einstellungskarte mit
  Beschreibung (u)), Innenabstand 16, Chevron-Knopf 32 (Glyphe 12).
- InfoBar: Mindesthöhe 48, Symbol 16, Titel und Text 14.

---

## 3 Fenster

### 3.1 Titelleiste

| Typ | Höhe | Inhalt |
|---|---|---|
| Win32 klassisch (Systemsteuerung, alter Editor) | 30–31 + 1 px Rand (u) | Symbol 16 bei x=8, Titel 12 px Segoe UI, links |
| WinUI-App (Einstellungen) | 48 (u) | Zurück-Knopf, Symbol 16, Titel 12 |
| Mit Tabs (Explorer, Terminal, Editor 24H2) | 48 Explorer / 40 Terminal (u) | Tabs ab x≈8, „+“ hinter dem letzten Tab |

- Fenstra legt fest: klassische Titelleiste **32 px** (Knopfhöhe), Titel 12 px, links mit
  Symbol 16 px.
- Titeltext aktiv `TextFillColorPrimary`, inaktiv `TextFillColorTertiary` (u).

### 3.2 Titelleistenknöpfe

| Knopf | Größe | Glyphe | Hover hell | gedrückt hell | Hover dunkel |
|---|---|---|---|---|---|
| Minimieren | 46×32 | waagrechte Linie 10 px, 1 px | `SubtleFillColorSecondary` (`#09000000`) (u) | `SubtleFillColorTertiary` | `#0FFFFFFF` |
| Maximieren | 46×32 | Quadrat 10×10, 1 px, Ecken 1 px rund (u) | wie oben | wie oben | wie oben |
| Wiederherstellen | 46×32 | zwei versetzte Quadrate 8×8 (u) | wie oben | wie oben | wie oben |
| Schließen | 46×32 | X 10×10, 1 px | **`#C42B1C`**, Glyphe weiß | `#C42B1C` mit 90 % (≈`#C83C31`) (u), Glyphe weiß ~70 % | `#C42B1C` |

- Knöpfe bündig oben rechts, keine Abstände, Schließen-Knopf folgt oben rechts der
  Fensterrundung (8 px).
- Glyphen inaktiver Fenster: `TextFillColorDisabled` (u).
- Tooltips: „Minimieren“, „Maximieren“, „Verkleinern“ (bei maximiertem Fenster),
  „Schließen“.

### 3.3 Rahmen, Ecken, Schatten

- Rahmen 1 px: hell ca. `#33757575` bis `#66757575` (`SurfaceStrokeColorDefault`) (u),
  dunkel ca. `#66757575`; mit „Akzentfarbe für Titelleisten“ an: Akzent.
- Ecken 8 px (nicht bei Maximiert/Kachel am Rand).
- Schatten aktiv groß (1.5), inaktiv kleiner; Größenänderung über unsichtbaren Rand ca. 8 px
  außerhalb (u).

### 3.4 Fensteranimationen (Kenntnis (u))

| Vorgang | Animation |
|---|---|
| Öffnen | Skalierung 0,95→1 + Einblenden, ca. 250, Kurve (0,0,0,1) |
| Schließen | Skalierung 1→0,95 + Ausblenden, ca. 167 |
| Minimieren | Gleiten/Schrumpfen zum Taskleistenknopf + Ausblenden, ca. 250 |
| Wiederherstellen aus Taskleiste | umgekehrt, ca. 250 |
| Maximieren/Wiederherstellen | Rechteck-Morph ca. 250 |
| Aero Shake | Standard aus |

### 3.5 Andocken (Snap)

- Ziehen an linken/rechten Rand: Hälfte; Ecke: Viertel; oberer Rand: Maximieren.
  Vorschau: halbtransparentes Rechteck mit Acrylic, Radius 8, kurzer Einblendeffekt.
- **Snap-Layouts:** Hover über Maximieren ≥ ca. 500 ms (u) → Flyout unter dem Knopf
  mit Layouts (bei 1920×1080, 16:9): ½+½, ⅔+⅓, ⅓+⅓+⅓, ½+¼+¼, ¼×4, ⅓+⅔ (u); Zonen
  hellgrau, Hover Akzent; auch mit **Win+Z** (Ziffern 1–6 wählbar).
- 24H2: Fenster an den oberen Bildschirmrand ziehen zeigt eine Layout-Leiste oben mittig.
- **Snap-Assistent:** nach dem Einrasten zeigt die freie Zone Vorschaubilder der übrigen
  Fenster (Acrylic-Fläche, Klick setzt Fenster ein, Esc beendet).
- Snap-Gruppen: Hover über Taskleistenknopf zeigt die Gruppe als eine Vorschau.

### 3.6 Fenstermenü (Alt+Leertaste / Rechtsklick Titelleiste)

„Wiederherstellen“, „Verschieben“, „Größe ändern“, „Minimieren“, „Maximieren“,
Trennlinie, „Schließen  Alt+F4“ (Schließen fett).

---

## 4 Taskleiste

Werte Kenntnis, Maße (u) bis Referenzbild.

### 4.1 Grundform

- Höhe **48**, volle Breite, unten, nicht schwebend.
- Hintergrund: Mica/Acrylic-Basis; hell ca. `#F3F3F3` mit 85 % (u), dunkel ca. `#202020`
  mit 85 %; Oberkante 1 px `#0F000000` (hell) bzw. `#19000000`/`#33FFFFFF` (dunkel) (u).
- Ausrichtung **zentriert**: die Gruppe (Widgets ausgenommen) liegt mittig zur
  **Bildschirmbreite**, nicht zum freien Platz.

### 4.2 Knöpfe in der Mitte (von links): Start · Suche · Task-Ansicht · Apps

| Element | Maße |
|---|---|
| Knopf-Grundfläche | 44 breit × 48 hoch (u), Hover-Fläche 40×40, Radius 4, mittig |
| Symbol | 24×24 |
| Hover | hell `SubtleFillColorSecondary`-ähnlich, ca. `#0F000000` + 1 px Rahmen `#0A000000` (u); dunkel `#0FFFFFFF` |
| gedrückt | Symbol schrumpft kurz auf ca. 85 % und federt zurück (ca. 200) |
| aktives Fenster | Hintergrund wie Hover (dauerhaft) + **Indikator 16×3 px**, Radius 1,5, Akzent (hell Dark1, dunkel Light2) (u), 2 px über Unterkante (u) |
| läuft, nicht aktiv | Indikator **6×3 px** grau (hell `#8A8A8A`/`#72000000`, dunkel `#9D9D9D`) (u) |
| nur angeheftet | kein Indikator |
| Aufmerksamkeit | Hintergrund orange/rot blinkend → dauerhaft (u) |
| Indikator-Wechsel | Breite animiert 6↔16, ca. 167 (u) |

- Start-Symbol: vier blaue Kacheln (Fenstra: eigenes Fenster-Logo in Akzentblau).
- **Suchfeld** (24H2-Standard): Pille ca. 180×32, Radius 16 (u), Lupe links, Text
  „Suchen“ in `TextFillColorSecondary`, Hintergrund hell `#FFFFFF` mit leichtem Rahmen
  (u). Alternativ nur Lupen-Symbol (Einstellung „Nur Suchsymbol“).
- Task-Ansicht-Symbol: zwei versetzte Rechtecke.
- Widgets-Knopf ganz **links** (bei zentrierter Taskleiste): Wettersymbol 24 + Temperatur
  „14 °C“ und Kurztext (zweizeilig, 12 px) (u); Breite ca. 140.

### 4.3 Infobereich rechts (von links)

| Element | Maße/Text |
|---|---|
| Überlauf-Chevron „^“ | Knopf ca. 24×40 (u), Tooltip „Ausgeblendete Symbole anzeigen“; Flyout mit Symbolraster (Acrylic, Radius 8, Symbole 16 in 40×40-Zellen (u)) |
| Infobereich-Symbole | 16×16 in 24×40 (u) |
| Schnelleinstellungen-Gruppe | Netzwerk, Lautstärke, (Akku) **gemeinsamer** Hover-Hintergrund, Radius 4 |
| Uhr | zwei Zeilen rechtsbündig, 12 px: „17:42“ / „05.10.2026“; Hover-Hintergrund Radius 4 |
| Glocke | 24H2: Glocke rechts neben der Uhr nur bei „Nicht stören“ bzw. als Zähler (u) |
| Desktop anzeigen | schmaler Streifen ganz rechts, ca. 8–12 px breit; dünne senkrechte Linie (u) |

### 4.4 Kontextmenüs der Taskleiste

- Rechtsklick auf freie Fläche (24H2): „Task-Manager“, „Taskleisteneinstellungen“.
- Rechtsklick auf Start: Win+X-Menü (siehe 5.8).
- Rechtsklick auf App-Knopf = **Sprungliste**: oben Abschnitte „Zuletzt verwendet“ /
  „Angeheftet“ / app-eigene Aufgaben, dann Trennlinie, App-Name (startet neue Instanz),
  „Von Taskleiste lösen“ bzw. „An Taskleiste anheften“, „Fenster schließen“ bzw.
  „Alle Fenster schließen“. Acrylic-Menü, Radius 8, Breite ca. 260 (u), öffnet über dem Knopf.
- Rechtsklick auf Uhr: „Datum und Uhrzeit anpassen“, „Benachrichtigungen“ … (u).

### 4.5 Vorschau (Hover über App-Knopf)

- Verzögerung ca. 400 (u). Acrylic-Panel über dem Knopf, Radius 8, je Fenster: Kopfzeile
  mit App-Symbol 16 + Titel (12 px) + Schließen-„X“ beim Hover; Vorschaubild max. ca.
  200×120 (u). Hover über Vorschau zeigt das Fenster („Peek“) (u).

### 4.6 Tastatur

Win+T (Fokus auf Taskleiste), Win+1…9 (App n starten/umschalten), Win+B (Fokus
Infobereich), Umschalt+Klick/Mittelklick = neue Instanz, Strg+Umschalt+Klick = als
Administrator.

---

## 5 Shell-Flyouts

### 5.1 Startmenü (klassisch 24H2)

| Teil | Wert (u, bis Referenzbild) |
|---|---|
| Größe | ca. 642 × 726, Radius 8, Rahmen 1 px, Acrylic Standard |
| Position | horizontal mittig zum Bildschirm, Unterkante 12 px über der Taskleiste |
| Suchfeld | oben, Abstand 32 seitlich/oben, Höhe 36, Radius 18 (Pille), Lupe, Text „Nach Apps, Einstellungen und Dokumenten suchen“ |
| Kopfzeile „Angeheftet“ | Body Strong 14; rechts Knopf „Alle >“ (24H2; früher „Alle Apps >“), Höhe 24, Radius 4 |
| Raster | 6 Spalten × 3 Zeilen pro Seite, Zelle ca. 96×84, Symbol 32, Beschriftung 12 (eine Zeile, Ellipse) |
| Seiten | Punkte rechts senkrecht, Mausrad blättert, Wechsel gleitet senkrecht (ca. 250) |
| Ordner | Kachel zeigt bis zu 4 Mini-Symbole (2×2) auf heller Fläche; Klick öffnet Ordner-Ansicht im Startmenü, Titel umbenennbar |
| „Empfohlen“ | Body Strong; rechts „Mehr >“; 2 Spalten × 3 Zeilen; Eintrag: Symbol 32, Titel 12–14, Untertitel 12 sekundär („Kürzlich hinzugefügt“, „Vor 2 Std.“, „Gestern um 17:42“) |
| Fußleiste | Höhe ca. 64, Hintergrund etwas dunkler (Acrylic Basis / `#0A000000` Ebene), Trennlinie oben; links Benutzerbild 32 + Name; rechts Ein/Aus-Knopf 40×40 |
| Öffnen/Schließen | gleitet von unten (ca. 100 px) + Einblenden, ca. 250 / schneller zurück |
| Tastatur | Tippen startet sofort die Suche; Pfeiltasten im Raster; Esc/Win schließt |

- **Kontomenü** (Klick auf Benutzer): „Kontoeinstellungen ändern“, „Sperren“, „Abmelden“,
  weitere Benutzer zum Wechseln; Kopf mit Bild und Name (u).
- **Ein/Aus-Menü:** „Energie sparen“, „Herunterfahren“, „Neu starten“ (+ ggf.
  „Anmeldeoptionen“ ganz oben) (u Reihenfolge: Anmeldeoptionen, Energie sparen,
  Herunterfahren, Neu starten).
- **Alle Apps:** Liste mit Buchstaben-Überschriften; Klick auf einen Buchstaben öffnet ein
  Buchstabenraster zum Springen; Eintrag Höhe ca. 40, Symbol 24; Knopf „< Zurück“ oben rechts.
- Rechtsklick auf angeheftete App: „An Start anheften“/„Von Start lösen“, „An erste Stelle
  verschieben“, „An Taskleiste anheften“, „Deinstallieren“, „App-Einstellungen“ (u).

### 5.2 Suche (Win+S, Suchfeld)

- Panel gleicher Größe/Position wie Startmenü (u); oben Suchfeld mit Fokus, darunter
  Filter-Register „Alle, Apps, Dokumente, Web, Einstellungen, Ordner, Fotos“ (u).
- Leer: links „Zuletzt verwendet“, rechts „Schnellsuchen“/„Top-Apps“ (u).
- Beim Tippen: links Ergebnisliste („Höchste Übereinstimmung“ groß, dann Gruppen „Apps“,
  „Einstellungen“, „Dokumente“), rechts Detailbereich mit großem Symbol, Name, Typ und
  Aktionen („Öffnen“, „Als Administrator ausführen“, „Dateispeicherort öffnen“, „An Start
  anheften“, „An Taskleiste anheften“, „Deinstallieren“).

### 5.3 Schnelleinstellungen (Win+A)

- Flyout rechts unten über dem Infobereich, Breite ca. 360, Radius 8, Acrylic (u).
- Kacheln: Raster 3 Spalten, Kachel ca. 96×48 Knopfteil + Beschriftung darunter (u);
  Standard: „WLAN“, „Bluetooth“, „Flugzeugmodus“, „Energiesparmodus“, „Barrierefreiheit“,
  „Nachtmodus“ (u). Aktiv = Akzentfüllung, Symbol weiß. WLAN/Bluetooth haben rechts einen
  Pfeil „>“ für eine Unterseite (Netzliste).
- Schieberegler: Helligkeit (Sonnensymbol), Lautstärke (Lautsprechersymbol, rechts Pfeil
  zur Geräteauswahl).
- Fußleiste: Akkustand „85 %“ links (nur mit Akku), rechts Stift „Schnelleinstellungen
  bearbeiten“ und Zahnrad „Alle Einstellungen“.

### 5.4 Benachrichtigungen und Kalender (Win+N, Klick auf Uhr)

- Zwei gestapelte Flyouts rechts: oben „Benachrichtigungen“ mit „Alle löschen“, darunter
  Kalender. Breite ca. 360 (u).
- Ohne Meldungen: „Keine neuen Benachrichtigungen“ (u).
- Kalender: Kopf „Montag, 5. Oktober“ mit Ein-/Ausklapp-Chevron; Monatsraster 7 Spalten
  (Mo–So), Zellen ca. 40×40, heute = Akzentkreis gefüllt, Text weiß; Pfeile ↑↓ für Monate;
  unten Fokus-Sitzung („Fokus“) (u).
- „Nicht stören“: Glocke mit „z“ in der Kopfzeile (u).
- **Toast:** unten rechts über der Taskleiste, Breite 364 (u), Radius 8, Acrylic; Kopf:
  App-Symbol 16 + App-Name 12 + „…“ + „X“; Inhalt: Titel fett 14, Text 14, optional Bild/
  Knöpfe; Einblenden: von rechts hereingleiten (ca. 300); Anzeige ca. 5 s.

### 5.5 Widgets (Win+W)

- Panel von **links**, volle Höhe über der Taskleiste minus Ränder, Breite ca. 760 (u),
  Acrylic, Radius 8; Kopf mit Uhrzeit, Profilbild, „+“ (Widgets hinzufügen); Raster aus
  Widget-Karten (klein 1×1, mittel 2×1, groß 2×2), Feed darunter (Fenstra: ohne Feed).

### 5.6 Alt+Tab und Task-Ansicht

- **Alt+Tab:** Vollbild-Dimmung? Nein – mittig ein Acrylic-Panel (u) mit Fenstervorschauen
  in einer Reihe (Höhe ca. 150–200 (u)), über jeder Vorschau Symbol + Titel; Auswahl =
  Rahmen 2–3 px weiß/Akzent mit Radius 8; Loslassen von Alt wechselt.
- **Task-Ansicht (Win+Tab):** Hintergrund abgedunkelt/weichgezeichnet; Fenster als
  Vorschau-Raster mit Titelzeile (Symbol + Titel, „X“ beim Hover); unten Leiste der
  virtuellen Desktops („Desktop 1“, „Desktop 2“ …, Kachel mit Hintergrund-Miniatur,
  „+ Neuer Desktop“); Hover über Desktop zeigt dessen Fenster; Umbenennen per Klick auf Namen.
- Desktop wechseln (Strg+Win+←/→): ganzer Bildschirm gleitet horizontal (ca. 400) (u).

### 5.7 OSD (Lautstärke/Helligkeit, 24H2)

- Kleine Pille unten mittig über der Taskleiste, ca. 196×52 (u), Radius 8 (u), Acrylic:
  Symbol links, Balken in Akzent, Wert rechts („42“); blendet nach ca. 2 s aus.

### 5.8 Kontextmenüs der Shell

- **Desktop** (Rechtsklick): Symbolzeile entfällt; Einträge: „Ansicht >“, „Sortieren nach >“,
  „Aktualisieren“, Trennlinie, „Neu >“, Trennlinie, „Anzeigeeinstellungen“, „Anpassen“,
  Trennlinie, „Im Terminal öffnen“, Trennlinie, „Weitere Optionen anzeigen“ (Umschalt+F10).
  Menüstil 2.11 (Symbole 16 vor jedem Eintrag).
- **Datei/Ordner im Explorer**: oben Symbolzeile „Ausschneiden“, „Kopieren“,
  „Umbenennen“, „Teilen“, „Löschen“ (Symbole ohne Text, Tooltips); darunter „Öffnen“,
  „Öffnen mit >“, „Als Favorit hinzufügen“, „In ZIP-Datei komprimieren“, „Als Pfad kopieren“,
  „Eigenschaften“, Trennlinie, „Im Terminal öffnen“ (Ordner), „Weitere Optionen anzeigen“.
- **Win+X** (Reihenfolge 24H2, Kennbuchstaben unterstrichen): „Installierte Apps“,
  „Mobilitätscenter“ (nur Laptop), „Energieoptionen“, „Ereignisanzeige“, „System“,
  „Geräte-Manager“, „Netzwerkverbindungen“, „Datenträgerverwaltung“,
  „Computerverwaltung“, „Terminal“, „Terminal (Administrator)“, Trennlinie,
  „Task-Manager“, „Einstellungen“, „Explorer“, „Suchen“, „Ausführen“, Trennlinie,
  „Herunterfahren oder abmelden >“ (Abmelden, Energie sparen, Herunterfahren, Neu starten),
  „Desktop“. Altes Win32-artiges Menü am Start-Knopf (u: Win11-Optik mit Radius 8).

### 5.9 Ausführen (Win+R)

- Klassischer Dialog unten links über dem Start-Knopf (u), Titel „Ausführen“, Symbol,
  Text „Geben Sie den Namen eines Programms, Ordners, Dokuments oder einer
  Internetressource an.“, Feld „Öffnen:“ (Kombinationsfeld mit Verlauf), Knöpfe „OK“,
  „Abbrechen“, „Durchsuchen...“. Größe ca. 400×210 (u).

### 5.10 Herunterfahren-Dialog (Alt+F4 auf dem Desktop)

- Titel „Windows herunterfahren“ (Fenstra: „Fenstra herunterfahren“), Logo-Streifen,
  Text „Was soll der Computer tun?“, Auswahlliste („Benutzer wechseln“, „Abmelden“,
  „Energie sparen“, „Herunterfahren“, „Neu starten“), Beschreibung darunter, Knöpfe „OK“,
  „Abbrechen“, „Hilfe“.

---

## 6 Systemoberflächen

### 6.1 Bootscreen

- Schwarz, Logo mittig (Hersteller-Logo über BGRT, sonst Windows-Logo ca. 120 px), darunter
  bei ca. 70 % der Höhe ein Ladekreis aus **5 weißen Punkten** (Ø ca. 6 px, Kreis Ø ca.
  40 px), die nacheinander mit Beschleunigung kreisen, Zyklus ca. 2 s (u).
- Updates: „Updates werden bearbeitet  42 %“, „Schalten Sie den Computer nicht aus.“ (u).

### 6.2 Sperrbildschirm

- Hintergrund Vollbild (Spotlight/eigenes Bild), **Uhrzeit oben mittig** (24H2), sehr groß
  (ca. 120–130 px, Semibold), darunter Datum „Montag, 5. Oktober“ (ca. 24 px) (u).
- Unten rechts: Netzwerk-, (Akku-)Symbole; unten mittig ggf. Medien/Widgets (u).
- Taste/Klick/Hochwischen → Anmeldebildschirm (Hintergrund wird unscharf, Inhalt gleitet
  hoch, ca. 300).

### 6.3 Anmeldebildschirm

- Hintergrund = Sperrbild, weichgezeichnet (Acrylic, dunkler).
- Mittig: Benutzerbild rund Ø **192** (u), darunter Name (ca. 28 px, Semibold),
  Kennwortfeld ca. 296×32 (u), Platzhalter „Kennwort“, rechts Pfeil-Knopf „→“ (Senden),
  darunter Link „Anmeldeoptionen“ und ggf. „Ich habe mein Kennwort vergessen“.
- Falsches Kennwort: „Das Kennwort ist falsch. Versuchen Sie es erneut.“ + Knopf „OK“.
- Unten rechts: Sprache (ggf.), Netzwerk, Barrierefreiheit, Ein/Aus.
- Unten links: weitere Benutzer.
- Nach Anmeldung: „Willkommen“ mit Ladekreis.

### 6.4 Abmelden/Herunterfahren

- Volle Fläche in Akzent-Dunkel bzw. Hintergrund, mittig Ladekreis + „Wird abgemeldet“,
  „Wird heruntergefahren“, „Wird neu gestartet“ (u).

### 6.5 Benutzerkontensteuerung (UAC)

- Bildschirm abgedunkelt (sicherer Desktop: Standbild des Desktops, abgedunkelt).
- Dialog mittig ca. 456 breit (u), Radius 8, Kopf „Benutzerkontensteuerung“ (12 px),
  Frage „Möchten Sie zulassen, dass durch diese App Änderungen an Ihrem Gerät vorgenommen
  werden?“ (20 px Semibold), App-Symbol + Name, „Verifizierter Herausgeber: …“,
  „Weitere Details anzeigen“; Knöpfe „Ja“ (Akzent) und „Nein“.
- Unbekannter Herausgeber: gelber Kopfbalken, „Herausgeber: Unbekannt“, „Dateiursprung:
  Festplatte auf diesem Computer“.
- Ohne Adminrechte: zusätzlich Benutzername + Kennwortfeld.

### 6.6 OOBE (Ersteinrichtung, Deutsch)

- Vollbild, dunkelblauer Grund, großes Fenster mit Radius 8: links Illustration, rechts
  Titel (28) und Inhalt, unten rechts Knöpfe „Ja“/„Weiter“ (Akzent), „Überspringen“ (u).
- Seiten (Reihenfolge 24H2, Privatkonto): „Ist das das richtige Land bzw. die richtige
  Region?“ → „Ist dies die richtige Tastaturlayout- oder Eingabemethode?“ → „Möchten Sie ein
  zweites Tastaturlayout hinzufügen?“ → „Verbinden Sie sich mit einem Netzwerk“ →
  Gerätename „Geben Sie Ihrem Gerät einen Namen“ → Konto „Wer wird dieses Gerät verwenden?“
  → „Erstellen Sie ein sicheres Kennwort“ → Sicherheitsfragen → „Wählen Sie die
  Datenschutzeinstellungen für Ihr Gerät aus“ → „Dies kann einige Minuten dauern.“ (u).
- Fenstra: lokales Konto ohne Microsoft-Konto, ohne Sicherheitsfragen (Abweichung).

### 6.7 Klänge (Ereignisse, Deutsch)

| Ereignis | Charakter (Kenntnis) |
|---|---|
| Windows-Anmeldung | weicher, aufsteigender Akkord, ca. 2–3 s |
| Benachrichtigung (Standard) | zwei kurze helle Töne, ca. 0,5 s |
| Hinweis (Asterisk) | kurzer weicher Glockenton |
| Kritischer Abbruch / Fehler | kurzer tiefer Doppelton |
| Frage / Achtung (Exclamation) | kurzer Ton mittlerer Höhe |
| Gerät angeschlossen / getrennt | aufsteigend / absteigend, je ca. 0,4 s |
| Papierkorb leeren | Papierrascheln, ca. 1 s |
| Lautstärkeänderung | kurzes „Ding“ |
| Batterie niedrig / kritisch | zwei bzw. drei Warntöne |
| Abmelden | Windows 11: standardmäßig still |

### 6.8 Mauszeiger

| Windows-Rolle | Form | Linux-Namen (Xcursor) |
|---|---|---|
| Normale Auswahl | weißer Pfeil, 1 px schwarzer Rand, ca. 12×19 sichtbar in 32×32 | default, left_ptr, arrow |
| Hilfeauswahl | Pfeil + „?“ | help, question_arrow, whats_this |
| Arbeiten im Hintergrund | Pfeil + kleiner blauer Ring (animiert) | progress, left_ptr_watch, half-busy |
| Beschäftigt | blauer Ring Ø ca. 24 (animiert, ca. 1 s) | wait, watch |
| Präzisionsauswahl | dünnes Fadenkreuz | crosshair, cross, tcross |
| Textauswahl | I-Balken | text, xterm, ibeam |
| Handschrift | Stift | pencil |
| Nicht verfügbar | Kreis mit Schrägstrich | not-allowed, no-drop, forbidden, circle |
| Vertikal skalieren | Doppelpfeil ↕ | ns-resize, size_ver, n-resize, s-resize, sb_v_double_arrow, row-resize |
| Horizontal skalieren | Doppelpfeil ↔ | ew-resize, size_hor, e-resize, w-resize, sb_h_double_arrow, col-resize |
| Diagonal 1 | ↖↘ | nwse-resize, size_fdiag, nw-resize, se-resize |
| Diagonal 2 | ↗↙ | nesw-resize, size_bdiag, ne-resize, sw-resize |
| Verschieben | Vierfachpfeil | move, fleur, all-scroll, size_all |
| Alternative Auswahl | Pfeil nach oben | up-arrow, center_ptr |
| Linkauswahl | Hand mit Zeigefinger | pointer, hand2, pointing_hand |
| Position/Person | Pfeil + Stecknadel / Person | (kein Linux-Gegenstück) |
| Ziehen/Kopieren/Verknüpfen | Pfeil + „+“ / Pfeil + Bogen | copy, dnd-copy, alias, link, dnd-link, dnd-move, grabbing, grab (offene/geschlossene Hand) |

Standardgröße 32×32 (Größe 1), Hotspot Pfeilspitze (0,0 bzw. 1,1).

---

## 7 Verhalten

### 7.1 Tastenkürzel (global)

| Kürzel | Funktion |
|---|---|
| Win | Start öffnen/schließen |
| Win+A | Schnelleinstellungen |
| Win+B | Fokus Infobereich |
| Win+D | Desktop anzeigen/ausblenden |
| Win+E | Explorer |
| Win+I | Einstellungen |
| Win+K | Umwandeln (Cast) |
| Win+L | Sperren |
| Win+M / Win+Umschalt+M | alle minimieren / wiederherstellen |
| Win+N | Benachrichtigungen + Kalender |
| Win+P | Projizieren (Anzeigemodus) |
| Win+R | Ausführen |
| Win+S / Win+Q | Suche |
| Win+T | Taskleiste durchlaufen |
| Win+U | Barrierefreiheit-Einstellungen |
| Win+V | Zwischenablage-Verlauf |
| Win+W | Widgets |
| Win+X | Schnelllink-Menü |
| Win+Z | Snap-Layouts |
| Win+. / Win+; | Emoji-Auswahl |
| Win+Pause | Einstellungen → System → Info |
| Win+Pos1 | alle außer aktivem Fenster minimieren |
| Win+↑ / Win+↓ | maximieren / wiederherstellen bzw. minimieren |
| Win+← / Win+→ | links/rechts andocken |
| Win+Umschalt+← / → | Fenster auf anderen Bildschirm |
| Win+Umschalt+↑ | vertikal maximieren |
| Win+1…9 | Taskleisten-App n |
| Win+Tab | Task-Ansicht |
| Win+Strg+D / F4 | neuer / aktueller Desktop schließen |
| Win+Strg+← / → | Desktop wechseln |
| Win+Umschalt+S | Ausschnitt (Snipping Tool) |
| Win+Druck | Vollbildfoto nach Bilder\Screenshots |
| Druck | Snipping Tool (24H2 Standard) |
| Win+Plus / Win+Minus / Win+Esc | Lupe |
| Win+Leertaste | Eingabesprache wechseln |
| Win+H | Diktieren |
| Win+G | Game Bar (Fenstra: entfällt) |
| Win+C | Copilot (Fenstra: entfällt) |
| Alt+Tab / Alt+Umschalt+Tab | Fenster wechseln |
| Strg+Alt+Tab | Alt+Tab ohne Halten |
| Alt+F4 | Fenster schließen; auf Desktop: Herunterfahren-Dialog |
| Alt+Leertaste | Fenstermenü |
| Strg+Esc | Start |
| Strg+Umschalt+Esc | Task-Manager |
| Strg+Alt+Entf | Sicherheitsbildschirm: „Sperren“, „Benutzer wechseln“, „Abmelden“, „Kennwort ändern“, „Task-Manager“, unten „Abbrechen“ |

### 7.2 Explorer

Strg+N neues Fenster, Strg+T neuer Tab, Strg+W Tab schließen, Strg+Tab Tab wechseln,
Strg+L/Alt+D/F4 Adressleiste, Strg+F/F3/Strg+E Suche, Alt+↑ übergeordneter Ordner,
Alt+←/→ zurück/vor, Rücktaste zurück, F2 umbenennen, F5 aktualisieren, F11 Vollbild,
Strg+Umschalt+N neuer Ordner, Alt+Eingabe Eigenschaften, Entf Papierkorb (ohne Rückfrage,
Standard 11), Umschalt+Entf endgültig („Möchten Sie diese Datei endgültig löschen?“),
Strg+Mausrad Ansichtsgröße, Strg+A alles, Strg+Z/Y rückgängig/wiederholen,
Strg+Umschalt+1…8 Ansichtsmodi, Alt+P Vorschaufenster, Alt+Umschalt+P Detailbereich.

### 7.3 Maus

- Doppelklick öffnet, Einfachklick wählt (Explorer, Desktop).
- Doppelklick Titelleiste: maximieren/wiederherstellen; Doppelklick Fenstersymbol oben
  links: schließen; Rechtsklick Titelleiste: Fenstermenü.
- Mittelklick oder Umschalt+Klick auf Taskleistenknopf: neue Instanz.
- Mausrad über Lautstärkesymbol: Lautstärke ändern (24H2).
- Datei auf Taskleistenknopf ziehen und halten: Fenster kommt nach vorn.
- Desktop: Rahmen aufziehen markiert, F2 umbenennen, Entf → Papierkorb.
- Verzögerungen: Tooltip ca. 500 (u), Taskleistenvorschau ca. 400 (u),
  Snap-Layouts ca. 500 (u).

---

## 8 Apps

### 8.1 Explorer

- Titelleiste mit Tabs (Höhe 48 (u)): Tab mit Ordnersymbol + Name, „+“; rechts
  Fensterknöpfe.
- Zeile 2 (Adresse, Höhe ca. 48): „←“ „→“ „↑“ „⟳“, Brotkrumen-Adressleiste
  („> Dieser PC > Lokaler Datenträger (C:) >“), rechts Suchfeld „Durchsuchen: <Ordner>“
  (Breite ca. 220 (u)).
- Zeile 3 (Befehlsleiste, Höhe ca. 48): „Neu ▾“ (Text+Symbol), Ausschneiden, Kopieren,
  Einfügen, Umbenennen, Teilen, Löschen (nur Symbole), Trenner, „Sortieren ▾“,
  „Anzeigen ▾“, (24H2: „Filter ▾“ in bestimmten Ordnern), „…“; rechts „Details“
  (Detailbereich).
- Navigationsbereich (Breite ca. 220–250): „Start“, „Katalog“, „OneDrive“ (Fenstra:
  entfällt), Trennlinie, angeheftet mit Stecknadel: „Desktop“, „Downloads“, „Dokumente“,
  „Bilder“, „Musik“, „Videos“; Trennlinie; „Dieser PC“ (aufklappbar: Laufwerke),
  „Netzwerk“, (Linux). Einträge Höhe 32 (u), Einrückung 16 je Ebene, Chevron vor
  aufklappbaren Einträgen.
- **Dieser PC:** Abschnitt „Geräte und Laufwerke“, Kacheln ca. 256×64 (u): Laufwerkssymbol
  48, Name „Lokaler Datenträger (C:)“, Füllbalken 1 Zeile ca. 6 px hoch (Akzentblau;
  ≥ 90 % rot `#DA2626` (u)), Text „120 GB frei von 237 GB“.
- Startseite „Start“: „Schnellzugriff“ (angeheftete Ordner als Kacheln), „Favoriten“,
  „Zuletzt verwendet“ als Liste.
- Detailansicht: Spalten „Name“, „Änderungsdatum“, „Typ“, „Größe“; Zeilenhöhe ca. 32
  (Kompakt 24) (u); Kopfzeile mit Sortierpfeil oben mittig über der Spalte.
- Ansichten („Anzeigen“): „Extra große Symbole“, „Große Symbole“, „Mittelgroße Symbole“,
  „Kleine Symbole“, „Liste“, „Details“, „Kacheln“, „Inhalt“, „Kompaktansicht“,
  „Einblenden >“ (Navigationsbereich, Detailbereich, Vorschaufenster, Elementkontrollkästchen,
  Dateinamenerweiterungen, Ausgeblendete Elemente).
- Statusleiste: „12 Elemente“, „1 Element ausgewählt  2,3 MB“, rechts Umschalter Details/
  Kacheln.
- Kopierdialog: „x Elemente werden von A nach B kopiert“, Prozent, Diagramm der Rate,
  „Weniger Details“; Konfliktdialog „Dateien ersetzen oder überspringen“ mit „Die Dateien im
  Ziel ersetzen“, „Diese Dateien überspringen“, „Für jede Datei eine Entscheidung treffen“.
- Eigenschaften: Register „Allgemein“, „Freigabe“, „Sicherheit“, „Vorgängerversionen“,
  „Anpassen“.

### 8.2 Einstellungen

- Fenster ca. 1100×750 (u); Titelleiste 48 mit „←“ und „Einstellungen“.
- Navigation links (Breite ca. 280–320): oben Benutzerbild 64 + Name + „Lokales Konto“,
  Suchfeld „Einstellung suchen“, dann Kategorien mit farbigen Symbolen:
  „Startseite“, „System“, „Bluetooth und Geräte“, „Netzwerk und Internet“,
  „Personalisierung“, „Apps“, „Konten“, „Zeit und Sprache“, „Spielen“,
  „Barrierefreiheit“, „Datenschutz und Sicherheit“, „Windows Update“
  (Fenstra: „Updates“).
- Inhalt: Brotkrumen-Titel 28 („System > Anzeige“), Karten (Höhe 68 mit Beschreibung,
  48 ohne), Abstand 4 zwischen Karten, Symbol 20 links, Steuerelement rechts, Chevron „>“
  für Unterseiten.
- Unterseiten (Auszug 24H2):
  - System: Anzeige, Sound, Benachrichtigungen, Fokus, Energie (und Akku), Speicher,
    Geräte in der Nähe teilen, Multitasking, Aktivierung, Problembehandlung,
    Wiederherstellung, Projizieren auf diesen PC, Remotedesktop, Zwischenablage, Info.
  - Bluetooth und Geräte: Geräte, Drucker und Scanner, Smartphone-Link, Kameras, Maus,
    Touchpad, Eingabe, Stift und Windows Ink, Automatische Wiedergabe, USB.
  - Netzwerk und Internet: WLAN, Ethernet, VPN, Mobiler Hotspot, Flugzeugmodus, Proxy,
    DFÜ, Erweiterte Netzwerkeinstellungen.
  - Personalisierung: Hintergrund, Farben, Designs, Dynamische Beleuchtung,
    Sperrbildschirm, Texteingabe, Start, Taskleiste, Schriftarten, Gerätenutzung.
  - Apps: Installierte Apps, Erweiterte App-Einstellungen, Standard-Apps, Offlinekarten,
    Optionale Features, Apps für Websites, Videowiedergabe, Autostart.
  - Konten: Ihre Infos, E-Mail- und andere Konten, Anmeldeoptionen, Andere Benutzer,
    Windows-Sicherung.
  - Zeit und Sprache: Datum und Uhrzeit, Sprache und Region, Eingabe, Spracherkennung.
  - Barrierefreiheit: Textgröße, Visuelle Effekte, Mauszeiger und Toucheingabe,
    Textcursor, Lupe, Farbfilter, Kontrastdesigns, Sprachausgabe, Audio, Untertitel, …
  - Datenschutz und Sicherheit: Windows-Sicherheit, Gerät suchen, Für Entwickler, …
  - Windows Update: „Nach Updates suchen“ (Akzent), „Sie sind auf dem neuesten Stand“,
    „Zuletzt geprüft: heute, 17:42“, Karten „Updates aussetzen“, „Updateverlauf“,
    „Erweiterte Optionen“.
- Personalisierung → Farben: „Modus auswählen“ (Hell/Dunkel/Benutzerdefiniert),
  „Transparenzeffekte“, „Akzentfarbe“ (Manuell/Automatisch), Farbraster.

### 8.3 Task-Manager (22H2+)

- Navigation links (einklappbar „☰“): „Prozesse“, „Leistung“, „App-Verlauf“,
  „Autostart-Apps“, „Benutzer“, „Details“, „Dienste“, unten „Einstellungen“.
- Kopf: Titel der Seite, Suchfeld „Suchen Sie nach einem Namen, Herausgeber oder einer PID“
  (in der Titelleiste), rechts „Neuen Task ausführen“, „Task beenden“, „Effizienzmodus“,
  „…“.
- Prozesse: Spalten „Name“, „Status“, „CPU“, „Arbeitsspeicher“, „Datenträger“,
  „Netzwerk“ (Summen in der Kopfzeile, z. B. „12%“); Gruppen „Apps (5)“,
  „Hintergrundprozesse (80)“, „Windows-Prozesse (100)“; Zellen in Gelb-/Orangetönen nach
  Last (Heatmap).
- Leistung: links Liste (CPU, Arbeitsspeicher, Datenträger 0 (C:), Ethernet, GPU 0) mit
  Mini-Diagramm; rechts großes Diagramm (60 s) und Kennzahlen.

### 8.4 Editor (Notepad 24H2)

- Tabs in der Titelleiste, „+“; Menüleiste „Datei“, „Bearbeiten“, „Anzeigen“, rechts
  Zahnrad; Statuszeile „Zeile 1, Spalte 1“, „100%“, „Windows (CRLF)“, „UTF-8“;
  Schrift Consolas 11 pt Standard (Fenstra: Cascadia Mono).

### 8.5 Terminal

- Tabs in der Titelleiste (Tab mit Profilsymbol + Titel), „+“ und „▾“ (Profile,
  „Einstellungen“, „Befehlspalette“), Schrift Cascadia Mono 12 pt, Innenabstand 8.
- Farbschema „Campbell“: Hintergrund `#0C0C0C`, Vordergrund `#CCCCCC`; Schwarz `#0C0C0C`,
  Rot `#C50F1F`, Grün `#13A10E`, Gelb `#C19C00`, Blau `#0037DA`, Magenta `#881798`,
  Cyan `#3A96DD`, Weiß `#CCCCCC`, hell: `#767676`, `#E74856`, `#16C60C`, `#F9F1A5`,
  `#3B78FF`, `#B4009E`, `#61D6D6`, `#F2F2F2`.

### 8.6 Snipping Tool (24H2)

- Aufnahme: Bildschirm abgedunkelt, oben mittig Werkzeugleiste (Acrylic, Radius 8):
  Foto/Video-Umschalter, Modi „Rechteck“, „Fenster“, „Vollbild“, „Freiform“, „X“.
- Danach Editor-Fenster mit Bild, Werkzeugleiste (Kugelschreiber, Textmarker, Radierer,
  Lineal, Zuschneiden, Texterkennung), „Speichern“, „Kopieren“, „Teilen“.
- Kurz unten rechts Toast mit Miniatur („Ausschnitt in die Zwischenablage kopiert“) (u).

### 8.7 Fotos, Medienwiedergabe, Rechner, Store

- **Fotos:** Navigation links („Alle Fotos“, „Favoriten“, Ordner), Raster-Galerie,
  Betrachter mit Werkzeugleiste oben (Zoom, Löschen, Drehen, Bearbeiten, „…“) und
  Filmstreifen unten (u).
- **Medienwiedergabe:** Navigation „Startseite“, „Musikbibliothek“, „Videobibliothek“,
  „Wiedergabewarteschlange“, „Wiedergabelisten“; Wiedergabeleiste unten (Cover, Titel,
  ⇄ ⏮ ⏯ ⏭ ↻, Zeitleiste, Lautstärke).
- **Rechner:** „Standard“-Modus, Anzeige rechtsbündig groß (ca. 46 px), Speichertasten
  (MC MR M+ M- MS), Raster 4×6 Tasten mit 2 px Abstand, Radius 4, „=“ in Akzent.
- **Store:** Navigation links schmal („Startseite“, „Apps“, „Spiele“, „Downloads“/
  „Bibliothek“), Suchfeld oben mittig in der Titelleiste, Karten-Raster.

---

## Offene Punkte

Alle mit **(u)** markierten Werte, vor allem:
1. Taskleiste: Knopfbreiten, Hover-Farben, Indikator-Farben und -Position, Suchfeldbreite,
   Breite des „Desktop anzeigen“-Streifens.
2. Startmenü: exakte Größe, Rasterzellen, Fußleistenhöhe, Text des Knopfs „Alle“.
3. Schnelleinstellungen/Kalender/Toasts: Breiten und Kachelmaße.
4. Fenster: Schatten-Parameter, Rahmenfarbe hell, Snap-Layout-Verzögerung.
5. Sperr-/Anmeldebildschirm: Schriftgrößen, Avatar-Größe, Feldbreite.
6. Mica-Parameter (nicht in WinUI-XAML, nur über Referenzbilder).
7. Animationsdauern der Shell (Startmenü, Flyouts, Fenster).

Vorgehen: Wenn Referenzbilder vorliegen, je Bereich nachmessen und hier eintragen; bis
dahin gelten die angegebenen Werte als Ziel.
