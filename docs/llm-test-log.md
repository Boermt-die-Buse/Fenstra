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
- **Beginn:** 2026-10-05 ca. 14:20
