# Baustein 4a: Branding und Theme

Stand: Paketquellen geschrieben und geprüft (Syntax, JSON, XML, Kickstart), Symbolthema
mit den echten Fluent-Dateien erzeugt (3663 Symbole). Gebaut und im Bild getestet ist
noch nichts, weil der Build in deiner WSL läuft. Dieser Baustein ersetzt die
Platzhalter aus Build #1 durch richtige Pakete.

## Was der Baustein liefert

| Bereich | Fenstra | Windows 11 im Vergleich, ehrlich |
|---|---|---|
| Logo | Eigenes Motiv: ein Fenster mit geöffnetem Flügel auf blauem Kachelgrund (`packages/fenstra-logos/src/fenstra-logo.svg`). Weiß- und Dunkelvariante, Wortmarke | Kein Vier-Felder-Logo, kein Windows-Schriftzug. Bewusst anders, gleiche Anmutung |
| Systemname | `PRETTY_NAME="Fenstra 44 (basiert auf Fedora Linux)"`, `VARIANT_ID=fenstra`, Verweise auf das Projekt | Erscheint in Systeminfo, Installer, Terminal-Anmeldung. `ID=fedora` bleibt, damit dnf, Anaconda und Skripte funktionieren |
| Hintergrund | Eigene abstrakte Verläufe hell/dunkel, 18 Auflösungen, auch Anmelde- und Sperrbildschirm | Kein Bloom-Motiv von Microsoft. Ähnlicher Charakter (weich, blau/violett) |
| Farben | Farbschemata „Fenstra Hell“ (Fenster #F3F3F3, Listen #FFFFFF, Text #1B1B1B, Akzent #0078D4) und „Fenstra Dunkel“ (#202020, Akzent #4CC2FF mit schwarzem Text) | Werte aus den Windows-11-Designrichtlinien nachgebildet, keine Microsoft-Dateien |
| Schriften | Oberfläche Selawik 10 pt, Monospace Cascadia Code 10 pt. fontconfig leitet „Segoe UI“ auf Selawik um (hilft Wine und Webseiten) | Selawik ist Microsofts eigener freier Segoe-Ersatz (OFL). Metrik gleich, Formen etwas anders. Segoe UI Variable gibt es nicht frei |
| Symbole | Symbolthema `fenstra`: Aktionen, Status, Geräte aus Fluent UI System Icons (MIT, einfarbig, folgen dem Farbschema), Ordner als eigener gelber Ordner mit Fluent-Glyphe. Programme und Dateitypen aus Breeze | Windows-Ordner und -Gerätesymbole sind nicht frei. Unsere Ordner sehen ähnlich aus, sind aber eigene Grafiken. Bunte Gerätesymbole („Dieser PC“) folgen in 4c |
| Fensterknöpfe | Nur rechts: Minimieren, Maximieren, Schließen; keine Fensterrahmen | Rundungen, Schatten, Mica-Näherung und Animationen kommen in 4b (KWin) |
| Cursor | `Breeze_Light` (weißer Cursor mit dunklem Rand, wie Windows) | Eigenes Cursor-Thema ist verschoben; Breeze Light kommt dem Windows-Cursor nahe |
| Bootscreen | Plymouth-Thema `fenstra`: zeigt das Firmware-Logo des Herstellers (wie Windows auf UEFI-Rechnern), ohne Firmware-Logo (VMs) das Fenstra-Logo, darunter ein Ladering. Deutsche Texte bei Offline-Updates | 1:1 bis auf die Form des Laderings (Windows: kreisende Punkte; hier: Bogen) |
| Plasma-Start | Startbildschirm nach der Anmeldung: schwarz, Logo, Ladering | wie der Windows-Übergang nach der Anmeldung |
| Anmeldung | Fedora 44 KDE benutzt den **Plasma Login Manager** (nicht mehr SDDM). Er zeigt den Fenstra-Hintergrund. Aufbau (Uhr, Nutzerbild) ist der von Plasma | Ein Anmeldebildschirm im Windows-Aufbau ist nicht mehr per SDDM-Thema möglich; das prüfen wir in 4b am Plasma Login Manager |
| Installer | Fedora 44 KDE nutzt die **Anaconda-Weboberfläche**. Sie liest den Produktnamen aus os-release („Fenstra 44 …“). Für die klassische GTK-Oberfläche liegen Seitenleiste und Logo bei | Ob die Weboberfläche ein Logo aus `system-logos` übernimmt, sehen wir erst in der VM |

## Wie es technisch gemacht ist

- Alles sind RPMs unter `packages/`, gebaut mit `build/build-packages.sh`, eingebunden über die
  Kickstart-Zeile `repo --name=fenstra --baseurl=file:///var/lib/fenstra-build/repo`.
  Übersicht in `packages/README.md`.
- `fenstra-release` ersetzt `fedora-release` **nicht**. Fedora verlangt für seine
  Identitätspakete die exakte Version von `fedora-release`; ein Fremdpaket würde bei jedem
  Fedora-Update brechen. Stattdessen schreibt ein RPM-Dateitrigger nach jedem Update von
  `/usr/lib/os-release` die Fenstra-Kennung erneut hinein. Nebenwirkung: `rpm -V
  fedora-release-identity-kde-desktop` meldet die Datei als geändert. Beabsichtigt.
- `fenstra-logos` stellt `system-logos` bereit und verdrängt `fedora-logos` (wie Fedoras
  eigenes `generic-logos`). `fenstra-backgrounds` stellt `system-backgrounds-kde` bereit und
  legt `/usr/share/wallpapers/Default` an; darauf zeigt Fedoras Symlink
  `/usr/share/wallpapers/Fedora`, den Anmelde- und Sperrbildschirm benutzen. So bleiben
  Fedoras Konfigurationsdateien unangetastet.
- Die Vorgaben liegen in `/etc/xdg/kdeglobals`, `kwinrc`, `kcminputrc`, `kscreenlockerrc`,
  `ksplashrc`. KConfig liest `/etc/xdg` vor Fedoras Profil (`/etc/kderc` →
  `/usr/share/kde-settings/…`). Nutzer können alles in `~/.config` überschreiben, die
  Systemeinstellungen funktionieren normal.
- Das globale Design `org.fenstra.desktop` (und `.dark`) setzt Farbschema, Symbole, Cursor,
  Fensterknöpfe, Startbildschirm und Hintergrund. Es lässt sich in den Systemeinstellungen
  unter „Globales Design“ wechseln.
- Symbolthema: `packages/fenstra-icon-theme/src/generate-icons.py` erzeugt aus dem
  npm-Paket `@fluentui/svg-icons` (nur SVGs, 13 MB, Prüfsumme in `packages/sources.sha256`)
  anhand von `mapping.json` die Symbole. Einfarbige Symbole nutzen den Breeze-Mechanismus
  (`<style id="current-color-scheme">`), damit sie im dunklen Design weiß werden.

## Bauen und testen

```bash
wsl -d FedoraLinux-44
cd /root/Fenstra && git pull
git checkout claude/gifted-bell-sylvb0
bash build/prepare-wsl.sh        # installiert zusätzlich rpm-build, createrepo_c, librsvg, ImageMagick
bash build/validate.sh
bash build/build-packages.sh     # lädt Fluent-Symbole (npm) und Selawik (GitHub), baut 7 RPMs
bash build/build-iso.sh
```

`build-packages.sh` zeigt beim ersten Lauf die Prüfsumme des Selawik-Archivs an
(GitHub war aus meiner Umgebung nicht erreichbar, ich konnte sie nicht vorab eintragen).
Bitte in `packages/sources.sha256` übernehmen, dann ist der Download ab da abgesichert.

Ohne neues ISO lässt sich ein einzelnes Paket in der VM testen:
`sudo dnf install ./fenstra-theme-44.0-1.fc44.noarch.rpm` (RPMs liegen unter
`/var/lib/fenstra-build/repo`, von Windows aus `\\wsl$\FedoraLinux-44\var\lib\fenstra-build\repo`).

### Prüfliste in der VM (Live-Modus reicht für die Optik)

1. Bootmenü, dann Bootscreen: schwarz mit Logo und Ladering? (Im Live-Modus kann der
   Bootscreen fehlen, weil lorax das Live-initramfs ohne Plymouth baut. Im installierten
   System muss er da sein.)
2. Anmeldung/Desktop: Fenstra-Hintergrund, helle Fenster, blaue Akzentfarbe, Schrift Selawik
   (Systemeinstellungen → Schriftarten zeigt „Selawik“).
3. Dolphin: gelbe Ordner mit Glyphen für Dokumente, Downloads, Bilder, Musik, Videos.
   Symbolleiste mit Fluent-Symbolen (Pfeile, Suche, Zahnrad).
4. Systeminfo (Info-Zentrum): Name „Fenstra 44 (basiert auf Fedora Linux)“, Fenstra-Logo.
5. Konsole: Schrift Cascadia Code. `cat /etc/os-release`, `plymouth-set-default-theme`
   (muss `fenstra` ausgeben), `fc-match "Segoe UI"` (muss Selawik liefern).
6. Globales Design auf „Fenstra Dunkel“ umstellen: Symbole werden weiß, Auswahl hellblau.
7. Nach der Installation: Bootscreen, Sperrbildschirm (Meta+L) mit Fenstra-Hintergrund.

### Messung

`fenstra-baseline` nach 2 Minuten Leerlauf, Datei nach `messungen/` mit Namen
`<Datum>-hyperv-build2-4a.txt`. Erwartung: RAM und Bootzeit wie Build #1 (ein Symbolthema
und Schriften kosten nichts Messbares). Wenn die Bootzeit steigt, liegt es nicht an 4a.

## Bekannte Lücken und nächste Schritte

- Anmeldebildschirm und Sperrbildschirm im Windows-Aufbau (Uhr unten links, Nutzerbild
  mittig): hängt am Plasma Login Manager, Prüfung in 4b.
- Cursor-Thema, bunte Gerätesymbole, Windows-ähnliche Dateitypsymbole: 4c.
- Symbolzuordnung ist ein Anfang (rund 400 Namen). Fehlende Symbole kommen aus Breeze und
  fallen als „andere Stilrichtung“ auf. Liste im Test notieren, dann nachziehen.
- Mica/Blur, Rundungen, Animationen, Taskleiste: 4b.
