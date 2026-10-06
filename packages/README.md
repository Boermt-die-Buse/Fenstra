# Eigene Pakete von Fenstra

Alle Fenstra-eigenen Bestandteile kommen als RPM ins Image, nicht als Dateien
im Kickstart. So lassen sie sich sauber aktualisieren, entfernen und mit
`rpm -V` prüfen. Gebaut wird in WSL mit `bash build/build-packages.sh`, das
Ergebnis landet als lokale Paketquelle unter `/var/lib/fenstra-build/repo`
und wird von `build/build-iso.sh` in den Kickstart eingebunden.

| Paket | Inhalt | Ersetzt / ergänzt |
|---|---|---|
| `fenstra-release` | os-release mit Fenstra-Namen (per RPM-Dateitrigger, übersteht fedora-release-Updates), deutsches `/etc/issue` | ergänzt `fedora-release` |
| `fenstra-logos` | Logo (SVG + PNG in allen Größen), Startmenü-Symbol `start-here`, Systeminfo-Logo, Anaconda-Grafiken, Plymouth-Wasserzeichen, Favicon | ersetzt `fedora-logos` (Provides `system-logos`) |
| `fenstra-backgrounds` | Wallpaper „Fenstra“ (Blüte) hell/dunkel aus `hintergrund.py`, 18 Auflösungen, `/usr/share/wallpapers/Default`, sechs Benutzerbilder | ersetzt `desktop-backgrounds-kde` (Provides `system-backgrounds-kde`) |
| `fenstra-theme` | Globale Designs `org.fenstra.desktop` (hell) und `.dark`, Farbschemata, `/etc/xdg`-Vorgaben (Schriften, Symbole, Fensterknöpfe, Sperrbildschirm), fontconfig | ergänzt Breeze |
| `fenstra-taskleiste` (aus `fenstra-theme`) | Taskleiste `org.fenstra.taskbar` (Start mit Startmenü, Suche, Task-Ansicht, Apps, Widgets-Knopf) und Infobereich `org.fenstra.infobereich` (Netz/Ton/Akku, Uhr, Glocke, Desktop anzeigen) | ersetzt Kickoff, Taskmanager, Digitaluhr; früher `fenstra-startmenu` |
| `plymouth-theme-fenstra` (aus `fenstra-theme`) | Bootscreen: Firmware-Logo oder Fenstra-Logo, Ladering, deutsche Update-Texte | wie `bgrt`/`spinner` |
| `fenstra-icon-theme` | Symbolthema `fenstra`, komplett eigene Motive aus Code (`glyphs.py`, `farbig.py`, `generate.py`, `mapping.json`), erbt nur von hicolor | ersetzt Breeze-Symbole |
| `fenstra-cursor-theme` | Mauszeiger `fenstra-cursors` aus `zeiger.py` (SVG → Xcursor, 24–96 px) | ersetzt Breeze-Zeiger |
| `fenstra-sound-theme` | Klangschema `fenstra` aus `klaenge.py` (synthetisiert, Ogg Vorbis) | ersetzt Ocean |
| `selawik-fonts` | Selawik (OFL), fontconfig-Alias „Segoe UI“ → Selawik | – |

Quellen externer Inhalte und ihre Prüfsummen stehen in `sources.sha256`.
Eigene Grafiken und Klänge (Logo, Wallpaper, Symbole, Zeiger, Klänge) sind unter CC-BY-SA-4.0
veröffentlicht, Skripte und Specs unter MIT.

## Ein Paket ändern

1. Datei unter `packages/<paket>/` bearbeiten (Specs, `src/`).
2. `bash build/validate.sh` (JSON, XML, Python-Syntax, `rpmspec`).
3. `bash build/build-packages.sh <paket>`; Protokoll unter `/var/lib/fenstra-build/build-<paket>.log`.
4. `bash build/build-iso.sh`.

Zum schnellen Ausprobieren ohne neues ISO: das RPM aus `/var/lib/fenstra-build/repo`
in die Test-VM kopieren und dort mit `sudo dnf install ./<datei>.rpm` einspielen.
