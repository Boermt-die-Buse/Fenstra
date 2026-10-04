# Baustein 4b: Taskleiste, Startmenü, Schnelleinstellungen, Fenster

Ziel: Bedienung und Aufbau wie Windows 11. 4b wird in drei Schritten gebaut, jeder mit
Build und VM-Test.

| Schritt | Inhalt | Stand |
|---|---|---|
| 4b-1 | Taskleiste (Aufbau, Position, Knöpfe), Fensterrahmen, Suche | umgesetzt (fenstra-theme 44.0-3) |
| 4b-2 | eigenes Startmenü (angeheftet, Empfohlen, Alle Apps, Nutzer/Ausschalten) | offen |
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
| Start-Knopf | ✅ (Menü vorerst KDE) | Kickoff mit Symbol `start-here`; eigenes Startmenü in 4b-2 |
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
