# Baustein 4b: Taskleiste, Startmenü, Schnelleinstellungen, Fenster

Ziel: Bedienung und Aufbau wie Windows 11. 4b wird in drei Schritten gebaut, jeder mit
Build und VM-Test.

| Schritt | Inhalt | Stand |
|---|---|---|
| 4b-1 | Taskleiste (Aufbau, Position, Knöpfe), Fensterrahmen, Suche | fertig, Build #4 in der VM geprüft (fenstra-theme 44.0-3) |
| 4b-2 | eigenes Startmenü (angeheftet, Empfohlen, Alle Apps, Nutzer/Ausschalten) | fertig, Build #5 in der VM geprüft (fenstra-startmenu 44.0-4) |
| 4b-3 | Schnelleinstellungen, Benachrichtigungscenter mit Kalender, Snap-Layouts, Widgets, Tastenkürzel (Win+Tab usw.) | offen |

## 4b-1: was umgesetzt ist

### Taskleiste

Layout-Skript im globalen Design (`look-and-feel/org.fenstra.desktop/contents/layouts/
org.kde.plasma.desktop-layout.js`, die dunkle Variante bekommt eine Kopie). Plasma führt es
beim ersten Anmelden eines Benutzers aus, außerdem bei „Globales Design anwenden“ mit
„Arbeitsflächen- und Fensterlayout“.

| Windows 11 | Fenstra | Umsetzung |
|---|---|---|
| Taskleiste unten, volle Breite, 48 px | ✅ 1:1 | Plasma-Panel, nicht schwebend, Höhe aus gridUnit |
| Start, Suche, Task-Ansicht, Apps mittig | ✅ nachgebaut | flexible Abstandhalter links und rechts der Gruppe; mittig zwischen linkem Rand und Infobereich, nicht exakt zur Bildschirmmitte |
| Start-Knopf | ✅ | Fenstra-Startmenü (4b-2), Symbol `start-here` |
| Suche | ⚠️ nachgebaut | Knopf startet KRunner (Apps, Dateien, Einstellungen, Rechner); schwebt in der Mitte (`/etc/xdg/krunnerrc FreeFloating=true`). Kein Websuche-Panel wie bei Windows |
| Task-Ansicht | ✅ nachgebaut | Knopf ruft die KWin-Übersicht auf (Fenster + Arbeitsflächen, „+“ für neue) |
| angeheftete Programme | ✅ | Dolphin, Firefox, Discover (Windows: Explorer, Edge, Store) |
| Infobereich, Uhr mit Datum darunter | ✅ | Systemabschnitt + Digitaluhr „Datum unter der Uhrzeit“ |
| „Desktop anzeigen“ ganz rechts | ⚠️ | Plasma-Knopf mit Monitor-Symbol; Windows hat nur einen schmalen Streifen (4b-3) |
| Widgets-Knopf, Copilot | ❌ vorerst nicht | Widgets in 4b-3, Copilot entfällt |

Die beiden Knöpfe sind normale Programmstarter (`/usr/share/applications/fenstra-search.desktop`,
`fenstra-taskview.desktop`, im Menü ausgeblendet). Task-Ansicht ruft
`qdbus-qt6 org.kde.kglobalaccel /component/kwin …invokeShortcut Overview` auf.

### Fensterrahmen (`/etc/xdg/breezerc`)

- Titel links (Windows), Knöpfe nur rechts (seit 4a), keine Seitenrahmen.
- Ecken rundum abgerundet (`RoundedCorners=true`). Radius etwa 4 px, Windows 11 hat 8 px;
  Breeze bietet keine Einstellung für den Radius.
- Dünne Umrandung, großer weicher Schatten (`ShadowLarge`, Stärke 90 von 255).
- Ehrlich: Die Fensterknöpfe bleiben Breeze-Kreise. Windows hat breite rechteckige Knöpfe
  (Schließen rot hinterlegt). Dafür braucht es eine eigene Fensterdekoration (Aurorae-Thema),
  möglich in 4b-3.

### Acrylic/Mica

Die Taskleiste ist mit dem Plasma-Stil „default“ durchscheinend mit Unschärfe dahinter
(KWin-Blur). Das entspricht Acrylic. Mica für Fensterhintergründe bleibt wie in 4a beschlossen
eine Annäherung.

## 4b-2: Startmenü

Eigenes Plasmoid `org.fenstra.startmenu` (Unterpaket `fenstra-startmenu` von fenstra-theme,
Quellen `packages/fenstra-theme/src/plasmoids/`). Reines QML, kein C++: Die Daten liefern die
Kicker-Modelle von Plasma (`org.kde.plasma.private.kicker`), dieselben wie für KDEs eigene
Menüs. Das Taskleisten-Layout setzt es statt Kickoff ein.

| Windows 11 | Fenstra | Umsetzung |
|---|---|---|
| Suchfeld oben, Ergebnisse beim Tippen | ✅ | `RunnerModel` (dieselbe Suche wie KRunner), Enter startet den ersten Treffer, Pfeiltasten |
| Angeheftet als Raster (6 Spalten) | ✅ | `RootModel.favoritesModel` (KActivities); Rechtsklick „Von Start lösen“ |
| „Alle Apps“ alphabetisch mit Buchstaben | ✅ | Zeile 0 des `RootModel` (flach, sortiert); Rechtsklick „An Start anheften“ |
| Empfohlen (zuletzt benutzt) | ✅ nachgebaut | `RecentUsageModel` (Dateien und Programme, max. 6); Windows zeigt zusätzlich neu installierte Apps |
| Benutzer unten links | ⚠️ | Bild und Name; Klick öffnet noch nichts (Windows: Kontomenü) |
| Ein/Aus unten rechts | ✅ | `SystemModel`: Sperren, Abmelden, Benutzer wechseln, Standby, Neu starten, Herunterfahren |
| Windows-Taste öffnet Start | ✅ | `X-Plasma-Provides: org.kde.plasma.launchermenu` |
| Menü mittig auf dem Bildschirm | ⚠️ | Plasma setzt das Popup mittig über den Start-Knopf; der sitzt links von der Mitte |
| Acrylic-Hintergrund | ⚠️ | Plasma-Dialog mit Unschärfe plus fast deckende Fläche (lesbar auch ohne GPU/Blur) |
| Seiten im Angeheftet-Bereich, Ordner | ❌ vorerst nicht | Raster scrollt stattdessen |

Bekannt: Die Vorgabe-Liste „Angeheftet“ aus `main.xml` greift nur, wenn KActivities noch keine
Favoriten hat; sonst übernimmt Plasma die globalen Vorgaben (Discover, Dolphin, Konsole, KWrite,
Systemeinstellungen, Firefox).

Entwickeln ohne Paket: `kpackagetool6 -t Plasma/Applet -u <verzeichnis>`, danach
`systemctl --user restart plasma-plasmashell` (plasmashell hält geladene QML-Dateien im
Speicher), Fehler mit `journalctl --user | grep -i startmenu`.

## Prototyp in der laufenden VM

Layout ohne neues ISO ausprobieren (Benutzersitzung, über SSH):

```
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
{ echo 'panels().forEach(function (p) { p.remove(); });'; cat org.kde.plasma.desktop-layout.js; } > run.js
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat run.js)"
```

Fensterrahmen neu laden: `qdbus-qt6 org.kde.KWin /KWin reconfigure`. Das installierte Paket
prüfen: `plasma-apply-lookandfeel --resetLayout -a org.fenstra.desktop`.

## Prüfliste 4b-1 in der VM

1. Erstes Anmelden eines neuen Benutzers: Taskleiste wie oben, ohne Arbeitsflächen-Umschalter.
2. Start öffnet das Menü, Suche öffnet KRunner in der Mitte, Task-Ansicht die Übersicht.
3. Fenster: Titel links, Ecken unten und oben rund, Schatten.
4. Dunkles Design: Taskleiste dunkel, Layout bleibt.
5. `fenstra-baseline`: RAM und Bootzeit wie Build #3 (keine neuen Dienste).

## Ergebnis Build #4 (2026-10-04)

ISO `Fenstra-44-x86_64-20261004-1509.iso`, SHA256
`af418d67857461981101ee113c1d8bb6ebe936ff1e138799ac7dcfc00df5b35f`, VM „Fenstra-Test4“.

- ✅ Live-Sitzung und erstes Anmelden des neuen Benutzers: Taskleiste und Fensterrahmen wie
  oben, ohne Nacharbeit; bleibt nach Neustart erhalten.
- ✅ Start, Suche (KRunner mittig), Aktive Anwendungen (KWin-Übersicht) funktionieren.
- ✅ Ecken oben und unten rund, Titel links.
- ✅ Messung (`messungen/2026-10-04-hyperv-build4-4b1.txt`): Boot 6,83 s, RAM 1919 MB
  (Build #3: 6,36 s / 1917 MB), SELinux enforcing. Die Taskleiste kostet nichts Messbares.

## Ergebnis Build #5 (2026-10-04)

ISO `Fenstra-44-x86_64-20261004-1608.iso`, SHA256
`9a7b68a8500efe5656b590bcbe0ee9358af4ecaa7b775232cf9c70531f351028`, VM „Fenstra-Test5“.

- ✅ Live-Sitzung und erstes Anmelden: Fenstra-Startmenü in der Taskleiste, Windows-Taste öffnet es.
- ✅ Angeheftet zeigt Plasmas Vorgaben (Firefox, Systemeinstellungen, Dolphin, KWrite, Konsole, Discover).
- ✅ Messung (`messungen/2026-10-04-hyperv-build5-4b2.txt`): Boot 6,60 s, RAM 1911 MB
  (Build #4: 1919 MB), plasmashell 423 MB statt 431 MB mit Kickoff. SELinux enforcing.
