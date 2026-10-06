# Entscheidungen: KDE anpassen oder Eigenbau

Je Windows-Bestandteil: Was kommt dem 1:1-Ergebnis näher – eine angepasste KDE-Software oder
ein eigenes Programm? Grundlage sind die Befunde unten (geprüft am 2026-10-05 an Plasma 6.7.5,
KWin 6.7.5, KF 6.30, Qt 6.11.2, Fedora 44). Entscheidungen können sich im jeweiligen
Meilenstein ändern; dann hier mit Datum nachtragen.

## Befunde (Erweiterungspunkte)

| Befund | Beleg | Folge |
|---|---|---|
| KDecoration3 hat `setBorderRadius(BorderRadius)` (je Ecke) und `setBorderOutline()`; KWin rundet damit auch den Fensterinhalt | `/usr/include/KDecoration3/kdecoration3/decoration.h`, Breeze nutzt es (breezedecoration.cpp Z. 457/479) | 8-px-Ecken und 1-px-Rahmen für alle dekorierten Fenster ohne eigenen KWin-Effekt |
| KDecoration3 erlaubt freie Titelleistenhöhe, eigene Knöpfe, Schatten (`DecorationShadow`), Unschärfe-Region | decoration.h, decorationbutton.h, decorationshadow.h | Windows-Knöpfe 46×32, rotes Schließen, Snap-Layout-Auslöser am Maximieren-Knopf möglich |
| Die meisten Plasma-Applets sind kompiliert (QML in der .so): Taskmanager, Infobereich, Benachrichtigungen, Uhr, Kickoff, Lautstärke, Netzwerk, Akku, Bluetooth, Helligkeit, Zwischenablage | `/usr/lib64/qt6/plugins/plasma/applets/*.so` | Anpassen nur über Fork des Quellcodes (SRPM plasma-desktop/plasma-workspace/plasma-nm/plasma-pa …) als eigenes Applet |
| Öffentliche QML-Module sind installiert: `org.kde.taskmanager`, `org.kde.notificationmanager`, `org.kde.plasma.private.volume`, `org.kde.plasma.networkmanagement`, `org.kde.bluezqt`, `org.kde.plasma.private.battery`, `…brightnesscontrolplugin`, `org.kde.plasma.workspace.calendar`, `org.kde.plasma.private.kicker`, `org.kde.milou`, `org.kde.ksysguard.process` | `/usr/lib64/qt6/qml/org/kde/…` | Eigene Applets (QML) können die Plasma-Daten direkt nutzen; nur der Taskmanager-eigene C++-Teil (`…private.taskmanager`) fehlt als Modul |
| Desktop-Containment (`org.kde.desktopcontainment`) liegt als QML auf der Platte (17 Dateien) | `/usr/share/plasma/plasmoids/org.kde.desktopcontainment` | Desktop-Symbole/-Kontextmenü per QML-Fork anpassbar |
| Look-and-Feel enthält in 6.7 nur defaults, layouts, logout, previews, splash | `/usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents` | Abmeldebildschirm über LnF; Sperrbildschirm/OSD/Fensterwechsler über andere Wege prüfen (M6/M7) |
| Alt+Tab-Layouts sind QML-Pakete | `/usr/share/kwin-wayland/tabbox/thumbnail_grid` | Eigenes Fensterwechsler-Layout ohne C++ |
| KWin-JS-Effekte (fade, scale, squash, maximize, login, logout …) liegen als Pakete vor | `/usr/share/kwin-wayland/effects` | Fensteranimationen als eigene JS-Effekte |
| KWin-C++-API mit `QuickSceneEffect` (QML-Effekte), `OffscreenEffect`, `AnimationEffect` | `/usr/include/kwin/effect/quickeffect.h` u. a. | Task-Ansicht, Snap-Assist, Mica als eigene C++-Effekte möglich (an KWin-Version gebunden) |
| Plasma Login Manager 6.7.5, `plasma-setup.service`, `kscreenlocker`, `polkit-kde` (Autostart `/etc/xdg/autostart/polkit-kde-authentication-agent-1.desktop`) | rpm -qa in der VM | Anmeldung/Ersteinrichtung/Rechteabfrage ersetzbar; Details in M7 |
| `konsolepart.so` vorhanden (konsole-part) | `/usr/lib64/qt6/plugins/kf6/parts/` | Eigenes Terminal-Fenster mit Konsole als Einbettung |
| In Fedora 44 verfügbar: kvantum 1.1.6, qtermwidget 2.4, mpv-libs 0.41, haruna 1.8 | dnf list | Alternativen vorhanden |
| WSL und VM haben identische Versionen (nach `dnf upgrade` am 2026-10-05) | rpm -q | C++-Plugins für KWin/Plasma in WSL bauen, in der VM installieren |

## Entscheidungen

| Bestandteil | Entscheidung | Begründung |
|---|---|---|
| Qt-Widget-Stil (WinUI-Steuerelemente) | **Fork von Breeze kstyle** → Stil „Fenstra“ (C++, Paket `fenstra-style`) | Volle Kontrolle über Maße, Zeichnung, Animationen, überlagernde Bildlaufleisten, Menüs mit 8 px + Acrylic; wirkt auch in Kirigami/QtQuick-Apps über qqc2-desktop-style. Kvantum (SVG) kann Metriken und Verhalten nur begrenzt steuern |
| Fensterdekoration | **Fork der Breeze-Dekoration** → „Fenstra“ (KDecoration3, im selben Paket) | Radius-/Umriss-API, Knöpfe frei zeichenbar; Aurorae (SVG/QML) ist langsamer und kann keinen Snap-Layout-Auslöser |
| Plasma-Design (Panel, Popups, Tooltips) | **Eigenes Plasma-SVG-Design** „fenstra“ | Offizieller Weg, alle Grafiken selbst erzeugt |
| Taskleiste (App-Knöpfe) | **Eigenes Applet `org.fenstra.taskbar`** (reines QML, kein Fork) | Umgesetzt in M3: TasksModel liefert Fenster/Starter, KPipeWire die Vorschaubilder, Kicker-`SimpleFavoritesModel` die Sprunglisten (Aufgaben, zuletzt verwendet) – der private C++-Teil des Plasma-Taskmanagers wird nicht gebraucht. Das Applet enthält auch Start (mit Startmenü als eigenem Dialog), Suche, Task-Ansicht und Widgets-Knopf und zentriert die Gruppe selbst zur Bildschirmbreite |
| Start-, Such-, Widgets-Knopf, Uhr, Schnelleinstellungen, Infobereich-Überlauf | **Eigene Applets** (QML) auf den öffentlichen Plasma-Modulen | Umgesetzt in M3: `org.fenstra.infobereich` (Gruppe Netz/Ton/Akku, Uhr, Glocke, Desktop-Streifen). Der Überlauf „^“ bleibt Plasmas Systemabschnitt (StatusNotifier-Symbole und Benachrichtigungs-Popups hängen daran; ein eigener bräuchte C++) |
| Startmenü | **Eigenbau** (besteht, QML auf Kicker-Modellen) | |
| Suche | **Eigenbau** (Panel, Backend KRunner/RunnerModel) | KRunner-Oberfläche hat einen anderen Aufbau |
| Benachrichtigungen (Center + Toasts) | **Eigenes Applet + Fork der Popup-QML** des Benachrichtigungs-Applets | Daten über `org.kde.notificationmanager` |
| Alt+Tab | **Eigenes Fensterwechsler-Layout** (QML-Paket) | offizieller Erweiterungspunkt |
| Task-Ansicht, virtuelle Desktops | **Eigener KWin-Effekt** (C++ QuickSceneEffect + QML), Vorbild Overview | Aufbau (Desktopleiste unten) weicht vom Overview ab |
| Snap Layouts / Snap Assist | **Eigenes KWin-Skript bzw. -Effekt** + Auslöser in der Dekoration (Hover Maximieren) und Win+Z | KWin-Kachel-API vorhanden |
| Fensteranimationen | **Eigene KWin-JS-Effekte** | offizieller Weg |
| Mica | **Eigener KWin-Effekt** (vorgerechnetes, weichgezeichnetes Wallpaper hinter Fenstern) | wie in CLAUDE.md beschlossen |
| Desktop-Symbole, Desktop-Kontextmenü | **Fork der Desktop-Containment-QML** | liegt als QML vor |
| Win+X, Ausführen, Herunterfahren-Dialog | **Eigenbau** (kleine Qt-Programme) | existiert in KDE nicht in dieser Form |
| Lautstärke-/Helligkeits-OSD | **Eigenbau** (OSD-Dienst ersetzt Plasmas OSD) (Weg in M6 prüfen) | |
| Zwischenablage (Win+V) | **Eigenes Flyout** auf Klipper-Daten | |
| Bootscreen | **Eigenes Plymouth-Thema** (besteht, Punkte-Animation ergänzen) | |
| Anmeldebildschirm | **Plasma Login Manager anpassen** (Theme/Greeter, Weg in M7 prüfen) | Fedora-Standard, kein SDDM |
| Sperrbildschirm | **kscreenlocker-Greeter anpassen** (Weg in M7 prüfen) | |
| Abmelde-Bildschirm | **Look-and-Feel `logout`** | offizieller Weg |
| UAC-Rechteabfrage | **Eigener Polkit-Agent** (C++, polkit-qt6) statt polkit-kde | Aufbau und Abdunkeln wie Windows |
| OOBE | **Eigenbau** statt plasma-setup | |
| Datei-Explorer | **Eigenbau** (C++/Qt Widgets) auf KIO | Tabs in der Titelleiste, Befehlsleiste, „Dieser PC“ und Windows-Kontextmenü erfordern einen tiefen Umbau von Dolphin; KIO liefert die eigentliche Dateiarbeit (Auflisten, Kopieren, Papierkorb, Vorschau, Öffnen mit, Rückgängig) |
| Gemeinsame Titelleiste mit Tabs | **Eigene Bibliothek** (rahmenloses Fenster, Tabs + Fensterknöpfe, KWindowShadow) für Explorer, Terminal, Editor | einheitlich wie Windows |
| Einstellungen | **Eigenbau** (C++/QML) | Aufbau der KDE-Systemeinstellungen ist grundverschieden; Backends: KConfig, D-Bus, NetworkManagerQt, BluezQt, libkscreen, PulseAudioQt, PowerDevil, AccountsService, timedated/localed, PackageKit |
| Updates / Wiederherstellungspunkte | **Teil der Einstellungen** + Snapper, eigenes grub-btrfs-Paket | |
| Task-Manager | **Eigenbau** (QML) auf `org.kde.ksysguard.process` und Sensoren | plasma-systemmonitor hat anderen Aufbau |
| Terminal | **Eigenbau-Rahmen + Konsole-KPart** | Konsole-Funktion, Windows-Terminal-Aufbau |
| Editor (Notepad) | **Eigenbau** (Qt Widgets) | klein; KWrite ist KXmlGui-Programm mit anderem Aufbau |
| Rechner | **Eigenbau** (QML) | klein |
| Snipping Tool | **Eigenbau**, Aufnahme über KWin-ScreenShot2 | Spectacle-Oberfläche weicht stark ab |
| Fotos | **Eigenbau** (QML) | Gwenview-Aufbau weicht stark ab |
| Medienwiedergabe | **Eigenbau** (QML, QtMultimedia oder libmpv – in M11 entscheiden) | |
| Store | **Eigenbau** (Python/QML, Flatpak/dnf) | |
| .exe per Doppelklick | **Wine aus Fedora + MIME-Handler** | |
| Mauszeiger, Symbole, Klänge, Wallpaper | **Eigene Generatoren** (Python → SVG/Xcursor/Ogg) | Vorgabe des Projekts; umgesetzt in M2: glyphs.py/farbig.py/generate.py, zeiger.py, klaenge.py, hintergrund.py |
| Firefox (statt Edge) | **bleibt Firefox**, nur Voreinstellungen (Titelleiste mit Tabs, Design hell/dunkel) | Browser-Nachbau außerhalb des Rahmens |

## Folgen für die Pakete

- `fenstra-style` (neu, x86_64): Qt-Stil + Fensterdekoration (+ später gemeinsame Titelleisten-Bibliothek).
- Shell-Applets als Unterpakete von `fenstra-theme` (QML) bzw. eigenes Paket `fenstra-shell` (mit C++-Teilen).
- KWin-Erweiterungen in `fenstra-kwin` (JS-Effekte, Skripte, Fensterwechsler, C++-Effekte).
- Apps je eigenes Paket (`fenstra-explorer`, `fenstra-settings`, …).
- C++-Pakete hängen exakt an der gebauten KWin/Plasma/Qt-Version (`Requires: kwin = %{version}`
  bzw. Qt-Private-API); bei Fedora-Updates neu bauen.
