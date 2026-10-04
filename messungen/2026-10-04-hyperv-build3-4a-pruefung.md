# VM-Test Build #3 (Korrekturen 4a) – 2026-10-04

ISO: `Fenstra-44-x86_64-20261004-1402.iso`, 4,0 GB,
SHA256 `d2786076ab590021510931077c23650af779d6adaf05ebce8e50dbe55a40afd2`.
Bauzeit 17 min. Pakete: fenstra-theme/-logos/-icon-theme und plymouth-theme-fenstra 44.0-2.
VM: Hyper-V „Fenstra-Test3“, gleiche Ausstattung wie Build #2 (Gen 2, 8 GB, 4 CPUs, 60 GB,
Secure Boot). Messdatei: `2026-10-04-hyperv-build3-4a.txt` (zweiter Start, 2 min Leerlauf,
Konsole offen – wie bei Build #2).

## Kennzahlen

| Wert | Build #2 | Build #3 | Ziel |
|---|---|---|---|
| Bootzeit | 6,39 s | 6,36 s | < 15 s ✅ |
| RAM belegt | 1914 MB | 1917 MB | < 1,5 GB ❌ (unverändert, Abspecken kommt in „Leistung“) |
| SELinux (2. Start) | enforcing | enforcing | ✅ |

## Korrekturen aus dem Test von Build #2

| # | Befund Build #2 | Build #3 |
|---|---|---|
| 1 | Dunkles Design: `kf.package: Path traversal` (Splash-Symlink) | ✅ keine Meldung, Splash ist Verzeichnis, Design wechselt vollständig |
| 2 | Info-Zentrum-Logo weiß, im hellen Design unsichtbar | ✅ farbiges Logo (blaue Kachel) |
| 3 | Rechnername leer → „localhost-live“ | ✅ `fenstra` (Ersteinrichtung: „Rechnername: fenstra gesetzt“), Prompt `daniel@fenstra` |
| 4a | Begrüßungsassistent mit Konqi/KDE-Text | ✅ Fenstra-Text, Fenstra-Logo, Bildunterschrift; Live-Seite „Willkommen zu Fenstra!“ |
| 4b | Installer-Symbol Fedora-„f“ | ✅ Fenstra-Logo (Desktop, Begrüßung, Kopfzeile des Installers) |
| 5 | Snapper ohne root nicht lesbar | ✅ `snapper -c root list` als daniel (wheel) möglich, fenstra-baseline zeigt Snapshot 1 |
| 6 | „Schreibtisch“ schwarzes Monitor-Symbol | ✅ Monitor in Akzentblau (Ordneransicht und Seitenleiste); Knopf „Arbeitsfläche anzeigen“ in der Taskleiste bleibt einfarbig |

## Neu beobachtet

- ✅ Plymouth-Bootscreen ist sichtbar: schwarzer Grund, Fenstra-Logo, Ladering (bei Bildern alle
  0,4 s erfasst; bei Build #2 mit 1-s-Abstand verpasst).
- ℹ️ Beim ersten Start blitzt vor Plasma Setup kurz ein Begrüßungsassistent „Plasma wurde auf
  6.6 aktualisiert“ auf (ein Einzelbild). Nach der Anmeldung des neuen Benutzers erscheint er
  nicht. Beobachten.

## Bleibt offen

- Plasma Setup: „Willkommen bei Plasma Desktop“, grauer Hintergrund, Konqi auf der
  Abschlussseite (fest im Paket plasma-setup, nur per eigenem Paket-Patch änderbar).
- Ordnername „Schreibtisch“ (xdg-user-dirs) vs. „Arbeitsfläche“ (KDE) vs. „Desktop“ (Windows): 4c.
- RAM über Ziel: plasma-keyboard 281 MB, packagekitd 187 MB, DiscoverNotifier 131 MB,
  xwaylandvideobridge 130 MB, kdeconnectd 129 MB.
