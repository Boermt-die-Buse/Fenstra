# VM-Test Build #2 (Baustein 4a) – 2026-10-04

ISO: `Fenstra-44-x86_64-20260929-2148.iso`, SHA256 geprüft (`256c4b7b…6b35`).
VM: Hyper-V „Fenstra-Test“, Gen 2, 8 GB fest, 4 CPUs, 60 GB, Secure Boot (Microsoft UEFI CA),
Default Switch. Grafik in der VM: `llvmpipe` (Software-Rendering, keine GPU) – fps- und
Blur-Werte sind in dieser VM nicht aussagekräftig.

Messdateien:
- `2026-10-04-hyperv-build2-4a-erststart.txt` – direkt nach Plasma Setup (PackageKit aktiv)
- `2026-10-04-hyperv-build2-4a.txt` – zweiter Start, 2 min Leerlauf nach Anmeldung (maßgeblich)

## Kennzahlen

| Wert | Erststart | Zweiter Start | Ziel |
|---|---|---|---|
| Bootzeit (systemd) | 7,36 s | 6,39 s | < 15 s ✅ |
| RAM belegt (`free -m`, used) | 2436 MB | 1914 MB | < 1,5 GB ❌ |
| Laufende Dienste | 41 | 40 | – |
| SELinux | permissive (gewollt) | enforcing, 0 AVC | enforcing ✅ |

Größte RAM-Posten (RSS, zweiter Start): plasmashell 428 MB, plasma-keyboard 280 MB,
kwin_wayland 237 MB, packagekitd 191 MB, kded6 161 MB, DiscoverNotifier 131 MB,
xwaylandvideobridge 131 MB, kdeconnectd 128 MB, kaccess 110 MB.
Kandidaten zum Abspecken (Leistungsphase): plasma-keyboard (Bildschirmtastatur),
xwaylandvideobridge, kdeconnectd, DiscoverNotifier/PackageKit-Autostart (wird durch „Updates“
ersetzt), abrt*, fprintd, ModemManager, atd.

## Prüfliste docs/04a

1. Bootmenü ✅ „Start Fenstra 44“ (Live-GRUB). Secure Boot startet ohne Eingriff.
   Bootscreen ⚠️ im installierten System nicht gesehen: Plymouth läuft (Theme `fenstra`,
   ShowDelay=0), aber bei 1-s-Bildern war zwischen Hyper-V-Logo und Anmeldung nur Schwarz.
   Vermutung: Boot zu schnell bzw. hyperv_drm übernimmt spät. Auf echter Hardware prüfen.
2. Anmeldung/Desktop ✅ Fenstra-Hintergrund, helle Fenster, blaue Akzente, Selawik
   (`kdeglobals` font=Selawik). Plasma Login Manager bereits im Windows-Aufbau (Uhr, Nutzerbild
   mittig, Aktionen unten).
3. Dolphin ✅ gelbe Ordner mit Glyphen, Fluent-Symbolleiste.
   ⚠️ Ordner „Schreibtisch“ zeigt schwarzes Monitor-Symbol statt Ordner; Seitenleiste nennt
   denselben Ort „Arbeitsfläche“. ⚠️ Textdateien als schwarze Umriss-Glyphen (4c).
   ⚠️ „2,0 GiB Internes Laufwerk“ (/boot) unter Geräte sichtbar (4c, Laufwerksbuchstaben).
4. Info-Zentrum ✅ „Fenstra 44 / Fenstra Desktop“, Projektlink.
   ❌ Logo ist weiß und auf hellem Design nahezu unsichtbar (im dunklen Design gut sichtbar).
5. Konsole ✅ Cascadia Code. `plymouth-set-default-theme` = fenstra, `fc-match "Segoe UI"` =
   Selawik, `fc-match Consolas` = Cascadia Code. os-release korrekt.
6. „Fenstra Dunkel“ ✅ Fenster, Symbole weiß, Taskleiste und dunkles Wallpaper folgen
   (Taskleiste mit Verzögerung). ❌ Splash: `kf.package: Path traversal attempt detected`
   – `org.fenstra.desktop.dark/contents/splash` ist ein Symlink ins helle Paket
   (fenstra-theme.spec:57); KDE lehnt das ab.
7. Nach Installation ✅ Sperrbildschirm (Meta+L) mit Fenstra-Hintergrund, Windows-Aufbau
   (erst Uhr, nach Taste Anmeldung).

## Weitere Befunde

- ❌ Rechnername: `/etc/hostname` leer. Plasma Setup schlägt „fenstra“ vor, schreibt ihn aber
  nicht, wenn man ihn unverändert lässt. Danach übernimmt NetworkManager per DNS den Namen der
  Live-Sitzung („localhost-live.mshome.net“ im Hyper-V-Netz). Abhilfe: Ersteinrichtung setzt
  `hostnamectl hostname fenstra`, wenn `/etc/hostname` leer ist.
- ⚠️ Branding-Lücken: Plasma Setup „Willkommen bei **Plasma Desktop**“ auf grauem Grund;
  Begrüßungsassistent und Plasma-Setup-Abschluss mit KDE-Maskottchen; Installer-Symbol auf dem
  Live-Desktop noch Fedora-„f“.
- ⚠️ `fenstra-baseline` liest Snapper ohne root nicht („keine Snapper-Konfiguration“), obwohl
  Snapshot 1 „Ausgangszustand nach Installation“ existiert. Hinweis/`sudo` ergänzen.
- ℹ️ Installer-Ablauf F44: Benutzer wird erst beim ersten Start in Plasma Setup angelegt.
- ℹ️ Plasma Setup: `scrollToCurrentLanguage is not defined` (QML), „OpenType support missing
  for Selawik, script 11“ (harmlos, Upstream).
