# Roadmap: Bausteine nach dem ersten ISO

Reihenfolge wie besprochen. Jeder Baustein endet mit einem Build, einem VM-Test und einer Messung (`fenstra-baseline`, Bootzeit, RAM, fps). Bei jedem Baustein steht, was 1:1 geht, was nachgebaut wird und was nicht geht.

## 0. Erster Build und Basiswerte (jetzt)

- `build/build-packages.sh` und `build/build-iso.sh` in WSL, ISO in Hyper-V testen, installieren, `fenstra-baseline` nach `messungen/`.
- Ergebnis: Fedora-KDE-Live-ISO mit Fenstra-Branding (4a), Btrfs-Installer-Profil, Snapper-Vorbereitung, zRAM.
- Erledigt: alle Paketnamen des Kickstarts gegen die Fedora-44-Paketdaten geprüft (vorhanden).
- Offen: SELinux-Labels prüfen, Bootzeit/RAM als Vergleichsbasis.
- Erkenntnisse aus den F44-Paketdaten: der KDE-Spin nutzt den **Plasma Login Manager** (nicht SDDM) und die **Anaconda-Weboberfläche** als Installer. Beides beeinflusst 4a/4b (Anmeldebildschirm) und die Installer-Optik.

## 4a. Branding und Theme (Paketquellen fertig, Build und VM-Test offen)

Details: [04a-branding-und-theme.md](04a-branding-und-theme.md), Pakete: [../packages/README.md](../packages/README.md).

- Erledigt: Pakete `fenstra-release` (os-release per Dateitrigger, ergänzt fedora-release), `fenstra-logos` (ersetzt fedora-logos), `fenstra-backgrounds` (ersetzt Fedora-Hintergründe, auch Anmelde-/Sperrbildschirm), `fenstra-theme` (globales Design hell/dunkel, Farbschemata, Vorgaben, Plymouth-Thema), `fenstra-icon-theme` (Fluent UI System Icons, MIT), `selawik-fonts`. Lokale RPM-Quelle im Build (`build/build-packages.sh`, `createrepo_c`, `repo --baseurl=file://…`).
- Offen: erster Build mit den Paketen, VM-Test nach Prüfliste, Messung. Cursor-Thema verschoben (Breeze Light ist nah dran).
- Geändert gegenüber Plan: kein SDDM-Thema, weil Fedora 44 KDE den Plasma Login Manager nutzt. Anmeldebildschirm im Windows-Aufbau wird in 4b am Plasma Login Manager geprüft.
- Ehrlich: Segoe UI, Windows-Icons, Windows-Wallpaper bleiben außen vor. Selawik ist Microsofts eigener freier Segoe-Ersatz, die Metrik passt, die Formen sind etwas anders.
- Messpunkt: Bootzeit (Plymouth), RAM unverändert.

## 4b. Taskleiste, Startmenü, Schnelleinstellungen, Benachrichtigungen

Details und Stand: [04b-taskleiste-und-fenster.md](04b-taskleiste-und-fenster.md). Schritt 4b-1 (Taskleiste, Fensterrahmen, Suche) umgesetzt; 4b-2 Startmenü und 4b-3 Schnelleinstellungen/Snap-Layouts offen.

- Panel unten, Symbole zentriert, Start-Schaltfläche, Suche, Task-Ansicht, Widgets-Knopf, Systray rechts mit Uhr.
- Startmenü als eigenes Plasma-Applet (QML): angepinnte Apps, „Empfohlen“, Nutzer und Ausschalten unten, Suche oben, „Alle Apps“.
- Schnelleinstellungen (WLAN, Bluetooth, Flugmodus, Helligkeit, Lautstärke) als eigenes Applet; Benachrichtigungscenter mit Kalender.
- KWin: Fensterrundungen, Schatten, Blur, Animationsgeschwindigkeit; Snap-Layouts als KWin-Skript; Widgets-Panel links ausklappbar.
- Ehrlich: Mica nur angenähert (Blur + Farbüberlagerung). Copilot-Knopf entfällt. Windows-Suche wird zu KRunner mit Windows-Optik.
- Messpunkt: RAM (eigene Applets), fps mit Blur.

## 4c. Dateimanager mit Laufwerksbuchstaben

- Dolphin als Basis: Adressleiste im Windows-Stil, Navigationsleiste „Schnellzugriff“, Detailansicht, Kontextmenü angepasst.
- „Dieser PC“: Einhängepunkte als C: (System), D:, E: … (weitere Laufwerke, USB). Rein Darstellung (KIO-Worker oder Places-Erweiterung), Pfade darunter bleiben Linux.
- Deutsche Benutzerordner, „Desktop“ statt „Schreibtisch“, Papierkorb, Standardprogramme wie unter Windows (Fotos, Videos, Musik).
- Ehrlich: Kein NTFS-Systemlaufwerk, Pfade in Programmen bleiben `/home/…`. Wenn ein Programm einen Pfad anzeigt, sieht man Linux.
- Messpunkt: Dolphin-Startzeit.

## 4d. Wiederherstellungspunkte

- Baut auf Build #1 auf (Snapper-Konfiguration, dnf5-Hook, wöchentlicher Punkt, Top-Level-Subvolume `snapshots`).
- Eigenes Paket `fenstra-grub-btrfs` (grub-btrfs ist nicht in Fedora): Bootmenü-Eintrag „Fenstra von einem Wiederherstellungspunkt starten“ mit verständlichen Namen.
- Zurücksetzen: Skript, das aus einem Snapshot heraus das Subvolume `root` ersetzt (`root` → `root.alt`, Snapshot → `root`), nur System, `/home` bleibt. Grafisch in der Einstellungen-App (4f).
- Offene Frage: `/boot` separat (Fedora-Standard, Kernel liegen außerhalb des Snapshots) oder in `/`. Entscheidung nach Test in der VM.
- rpmdb-WAL-Problem mit dem dnf5-Backend von PackageKit (Fedora 44) prüfen und lösen.
- Ehrlich: Kein Windows-„Systemwiederherstellung“-Dienst, sondern Btrfs-Snapshots. Zurücksetzen erfordert einen Neustart. Wiederherstellungspunkte von Windows-Programmen unter Wine liegen in `/home` und werden nicht zurückgesetzt (Absicht).
- Messpunkt: Update-Dauer mit/ohne Snapshot, Bootzeit.

## 4e. Windows-Programme (Wine/Proton)

- Wine (Fedora) + optional Proton-GE; `.exe`-Doppelklick über MIME-Handler; Installer-Wrapper legt Startmenü-Einträge an; Kompatibilitätsliste (JSON) mit Bewertung „läuft / eingeschränkt / läuft nicht“.
- Steam aus RPM Fusion (nonfree) mit Proton, DXVK/VKD3D vorkonfiguriert, Shader-Cache aktiv, `vm.max_map_count` hoch.
- Ehrlich: Anti-Cheat, Office-365-Desktop, Adobe, Programme mit Treibern laufen nicht. Vor dem Start wird das dem Nutzer angezeigt.
- RPM Fusion ist nicht Fedora; für ein verteiltes ISO ist zu klären, ob nonfree-Pakete im Image liegen dürfen (für deinen privaten Test egal).
- Messpunkt: RAM (Wine-Dienste dürfen im Leerlauf nicht laufen).

## 4f. Einstellungen-App

- Qt/QML im Windows-11-Stil, Kategorien wie Windows: System (Anzeige, Ton, Benachrichtigungen, Energie, Speicher, Wiederherstellung), Bluetooth und Geräte, Netzwerk, Personalisierung, Apps, Konten, Zeit und Sprache, Barrierefreiheit, Datenschutz und Sicherheit, Updates.
- Steuert im Hintergrund KDE (kwriteconfig6, D-Bus), systemd, NetworkManager, PackageKit/dnf5, Snapper.
- Ehrlich: Für Sonderfälle bleibt „Erweiterte Einstellungen“ (KDE Systemeinstellungen) erreichbar. Linux-Begriffe werden umschrieben (z. B. „Laufwerk C:“ statt `/`, „Administratorrechte“ statt sudo).
- Messpunkt: Startzeit der App, RAM.

## 4g. Fenstra Store

- Qt/QML-Oberfläche, Backend Python (schneller Start, Zugriff auf Flatpak-, dnf5- und Wine-Werkzeuge). Katalog als YAML im Repo: Name, Hersteller, Kategorie, Beschreibung, offizielle Webseite, Installationsart, Quelle, Prüfsumme/Signatur.
- Installationsarten: Flatpak (Flathub, bevorzugt), AppImage, RPM (Fedora/RPM Fusion), .exe über Wine, Web-App (eigenständiges Fenster mit Startmenü-Eintrag, z. B. WhatsApp Web).
- Fallback für Nicht-Katalogisiertes: Web-Suche, Prüfung, ob die Domain zum Hersteller passt (Allowlist bekannter Hersteller-Domains, HTTPS-Pflicht), deutliche Warnung und Bestätigung. Nie das erste Suchergebnis blind installieren.
- Bot (`store/tools/check-catalog.py`): prüft Links, Versionen, Prüfsummen. Keine erfundenen Hashes; wo der Hersteller keine veröffentlicht, wird die Signatur des Paketsystems (Flatpak/RPM) genutzt oder der Eintrag als „ungeprüfter Direkt-Download“ markiert.
- Ehrlich: Kein Microsoft-Store-Konto, keine Käufe. Programme kommen von Flathub, Fedora oder der Hersteller-Webseite.
- Messpunkt: Store-Startzeit, RAM.

## Querschnitt: Leistung (nach jedem Baustein)

- `systemd-analyze blame/critical-chain`: Dienste abschalten, die nichts bringen (z. B. `ModemManager` ohne Modem, Bluetooth-Warteschleifen, `abrt`, Drucker-Browsing falls kein Drucker).
- Baloo (Dateiindex) auf Dokumente beschränken, Inhalte-Indexierung aus.
- Compositor: Blur/Animationen mit Fallback bei llvmpipe; Mesa aktuell; VA-API im Browser; NVIDIA-Weg dokumentieren.
- Live-Image: squashfs xz → zstd testen (`FENSTRA_SQUASHFS=zstd`), initramfs zstd, Bootmenü-Timeout kurz.
- Btrfs: `noatime`, `compress=zstd:1`, `discard=async` (Kernel-Standard), wöchentlich `fstrim` und `scrub`, `nodatacow` für VM-Images und Datenbanken per Ordnerattribut.

## 5. Abschluss: fertiges ISO auf den USB-Stick

- Erst wenn alle Bausteine in der VM laufen und die Messwerte passen: finaler Build, Prüfsumme, Test des ISOs in Hyper-V mit Secure Boot, dann Stick schreiben (Anleitung in docs/02, Abschnitt USB-Stick).
- Bis dahin kein Stick. Zwischenstände bleiben in der VM.
