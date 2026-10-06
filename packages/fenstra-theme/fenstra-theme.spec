# Fenstra-Theme: globales Plasma-Design (hell/dunkel), Farbschemata, systemweite
# KDE-Vorgaben (Schriften, Symbole, Fensterknöpfe, Sperrbildschirm), Plymouth-
# Bootscreen und fontconfig-Regeln. Bindet Hintergrund, Symbole und Schriften ein.
Name:           fenstra-theme
Version:        44.0
Release:        11%{?dist}
Summary:        Erscheinungsbild von Fenstra (Plasma-Design, Farben, Bootscreen)
License:        GPL-2.0-or-later AND CC-BY-SA-4.0
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        fenstra-theme-src.tar.gz
BuildArch:      noarch
BuildRequires:  librsvg2-tools
BuildRequires:  python3
Requires:       plasma-workspace
Requires:       plasma-desktop
Requires:       plasma-breeze
# Qt-Stil und Fensterdekoration "Fenstra" (Meilenstein M1)
Requires:       fenstra-style
Requires:       fenstra-backgrounds
Requires:       fenstra-icon-theme
Requires:       fenstra-cursor-theme
Requires:       fenstra-sound-theme
Requires:       fenstra-logos
Requires:       selawik-fonts
Requires:       cascadia-code-fonts
# Taskleiste: Schnelllink-Menü und Schnelleinstellungen nutzen qdbus/kwriteconfig6
Requires:       /usr/bin/qdbus-qt6
Requires:       /usr/bin/kwriteconfig6
# Taskleiste und Infobereich (M3, enthalten das Startmenü)
Requires:       fenstra-taskleiste = %{version}-%{release}

%description
Globales Design "Fenstra" (hell und dunkel) für KDE Plasma im Stil von
Windows 11: Farbschemata, Akzentfarbe, Schriften Selawik und Cascadia Code,
Symbolthema, Fensterknöpfe rechts, Startbildschirm und Sperrbildschirm.

%package -n plymouth-theme-fenstra
Summary:        Plymouth-Bootscreen für Fenstra
Requires:       plymouth-plugin-two-step
Requires:       plymouth-scripts
Requires:       fenstra-logos
Requires(post): plymouth-scripts

%description -n plymouth-theme-fenstra
Bootscreen im Stil von Windows: Firmware-Logo (falls vorhanden) oder das
Fenstra-Logo mit einem Ladering auf schwarzem Grund.

%package -n fenstra-taskleiste
Summary:        Taskleiste, Startmenü und Infobereich im Stil von Windows 11 für Fenstra
License:        GPL-2.0-or-later
# QML-Module: Taskmanager/Kicker/Benachrichtigungen/Kalender/D-Bus (plasma-workspace),
# Plasma-Komponenten (libplasma), Datenquellen (plasma5support), Vorschaubilder (kpipewire),
# Netz (plasma-nm), Lautstärke (plasma-pa), Kirigami, Avatar, Einstellungsseite (kcmutils)
Requires:       plasma-workspace
Requires:       libplasma
Requires:       plasma5support
Requires:       kpipewire
Requires:       plasma-nm
Requires:       plasma-pa
Requires:       kf6-kirigami
Requires:       kf6-kirigami-addons
Requires:       kf6-kcoreaddons
Requires:       kf6-kcmutils
# M4: gemeinsame Bedienelemente (org.fenstra.shell), Bluetooth (bluez-qt), Energieprofil und
# Helligkeit (powerdevil-Plugins), Sitzungen, Sensoren der Systemleistung, Qt.labs-Ordnermodell
Requires:       fenstra-shell
Requires:       kf6-bluez-qt
Requires:       powerdevil
Requires:       libksysguard
Requires:       qt6-qtdeclarative
Requires:       kwin
# Wetter im Widgets-Knopf und Widgets-Board (Wetterquellen)
Recommends:     kdeplasma-addons
# Benachrichtigungsklang der Toasts
Recommends:     libcanberra-gtk3
# ersetzt das Startmenü-Applet aus 4b-2 (jetzt Teil der Taskleiste)
Obsoletes:      fenstra-startmenu < 44.0-9
Provides:       fenstra-startmenu = %{version}-%{release}

%description -n fenstra-taskleiste
Taskleiste im Aufbau von Windows 11 (Plasma-Applets org.fenstra.taskbar und
org.fenstra.infobereich): Widgets-Knopf links; Start, Suchfeld, Task-Ansicht und
App-Knöpfe mittig zur Bildschirmbreite mit Indikatoren, Vorschaubildern und
Sprunglisten; rechts Schnelleinstellungen-Gruppe, Uhr mit Datum, Glocke und
Streifen „Desktop anzeigen“. Flyouts wie Windows 11: Startmenü mit Seiten und
Ordnern, Suchpanel, Schnelleinstellungen, Benachrichtigungscenter mit Kalender,
Toasts und Widgets-Board; Tastenkürzel Win+S/Q/A/N/W (KWin-Skript).

%prep
%setup -q -n src

%build
# Plymouth: Ladering-Bilder und Dialoggrafiken rendern
python3 plymouth/make-frames.py plymouth/frames
for f in plymouth/frames/*.svg; do
  rsvg-convert -o "${f%.svg}.png" "$f"
done
rsvg-convert -w 128 -h 128 -o plymouth/frames/watermark.png look-and-feel/org.fenstra.desktop/contents/splash/images/fenstra-logo-white.svg
# Plasma-Designs fenstra / fenstra-dark (Taskleiste, Popups, Tooltips) aus Code erzeugen
python3 desktoptheme/generate.py desktoptheme-build
# GTK-Design „Fenstra“ (Breeze-GTK + Windows-Titelleistenknöpfe)
python3 gtk/erzeuge.py --out gtk-build

%install
# Globale Designs (Look-and-Feel)
install -d %{buildroot}%{_datadir}/plasma/look-and-feel
cp -a look-and-feel/org.fenstra.desktop %{buildroot}%{_datadir}/plasma/look-and-feel/
cp -a look-and-feel/org.fenstra.desktop.dark %{buildroot}%{_datadir}/plasma/look-and-feel/
# dunkle Variante nutzt denselben Startbildschirm. Als Kopie, nicht als Symlink:
# KDE (kf.package) lehnt Verweise aus dem Paketverzeichnis heraus als
# "Path traversal" ab, der Startbildschirm fehlte dann im dunklen Design.
cp -a look-and-feel/org.fenstra.desktop/contents/splash %{buildroot}%{_datadir}/plasma/look-and-feel/org.fenstra.desktop.dark/contents/
# ebenso das Taskleisten-Layout (Windows-11-Aufbau, beim ersten Anmelden)
cp -a look-and-feel/org.fenstra.desktop/contents/layouts %{buildroot}%{_datadir}/plasma/look-and-feel/org.fenstra.desktop.dark/contents/
# Taskleiste und Infobereich (Plasmoids)
install -d %{buildroot}%{_datadir}/plasma/plasmoids
cp -a plasmoids/org.fenstra.taskbar plasmoids/org.fenstra.infobereich %{buildroot}%{_datadir}/plasma/plasmoids/
# KWin-Skript: Tastenkürzel Win+S/Q/A/N/W für die Flyouts (M4)
install -d %{buildroot}%{_datadir}/kwin-wayland/scripts
cp -a kwin/fenstra-kuerzel %{buildroot}%{_datadir}/kwin-wayland/scripts/
# Begrüßungsassistent (plasma-welcome): Fenstra-Logo und -Text statt KDE-Maskottchen
install -D -p -m 0644 plasma-welcome/intro-customization.desktop %{buildroot}%{_datadir}/plasma/plasma-welcome/intro-customization.desktop
# Farbschemata
install -d %{buildroot}%{_datadir}/color-schemes
install -p -m 0644 color-schemes/*.colors %{buildroot}%{_datadir}/color-schemes/
# systemweite Vorgaben (KConfig liest /etc/xdg vor den Fedora-Profilen)
install -d %{buildroot}%{_sysconfdir}/xdg
install -p -m 0644 xdg/kdeglobals xdg/kcminputrc xdg/kwinrc xdg/kscreenlockerrc xdg/ksplashrc xdg/krunnerrc xdg/plasmarc xdg/kglobalshortcutsrc %{buildroot}%{_sysconfdir}/xdg/
# Plasma-Designs
install -d %{buildroot}%{_datadir}/plasma/desktoptheme
cp -a desktoptheme-build/fenstra desktoptheme-build/fenstra-dark %{buildroot}%{_datadir}/plasma/desktoptheme/
# GTK-Design „Fenstra“; Vorgabe für neue Benutzer (KDE übernimmt den Namen aus settings.ini)
install -d %{buildroot}%{_datadir}/themes
cp -a gtk-build/Fenstra %{buildroot}%{_datadir}/themes/
install -D -p -m 0644 skel/gtk-settings.ini %{buildroot}%{_sysconfdir}/skel/.config/gtk-3.0/settings.ini
install -D -p -m 0644 skel/gtk-settings.ini %{buildroot}%{_sysconfdir}/skel/.config/gtk-4.0/settings.ini
# Firefox: normale Titelleiste mit Fenstra-Knöpfen
install -D -p -m 0644 firefox/fenstra-prefs.js %{buildroot}%{_sysconfdir}/firefox/pref/fenstra-prefs.js
# fontconfig
install -D -p -m 0644 fontconfig/61-fenstra-ui.conf %{buildroot}%{_sysconfdir}/fonts/conf.d/61-fenstra-ui.conf
# Plymouth
install -d %{buildroot}%{_datadir}/plymouth/themes/fenstra
install -p -m 0644 plymouth/fenstra.plymouth plymouth/frames/*.png %{buildroot}%{_datadir}/plymouth/themes/fenstra/

%post -n plymouth-theme-fenstra
# Nur die Vorgabe setzen; das initramfs baut der Kickstart bzw. der Installer neu.
if [ "$1" -eq 1 ] && command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme fenstra || :
fi

%postun -n plymouth-theme-fenstra
if [ "$1" -eq 0 ] && command -v plymouth-set-default-theme >/dev/null 2>&1; then
  if [ "$(plymouth-set-default-theme)" = fenstra ]; then
    plymouth-set-default-theme --reset || :
  fi
fi

%files
%{_datadir}/plasma/look-and-feel/org.fenstra.desktop/
%{_datadir}/plasma/look-and-feel/org.fenstra.desktop.dark/
%{_datadir}/color-schemes/FenstraLight.colors
%{_datadir}/color-schemes/FenstraDark.colors
%dir %{_datadir}/plasma/plasma-welcome
%{_datadir}/plasma/plasma-welcome/intro-customization.desktop
%config(noreplace) %{_sysconfdir}/xdg/kdeglobals
%config(noreplace) %{_sysconfdir}/xdg/kcminputrc
%config(noreplace) %{_sysconfdir}/xdg/kwinrc
%config(noreplace) %{_sysconfdir}/xdg/kscreenlockerrc
%config(noreplace) %{_sysconfdir}/xdg/ksplashrc
%config(noreplace) %{_sysconfdir}/xdg/krunnerrc
%config(noreplace) %{_sysconfdir}/xdg/plasmarc
%config(noreplace) %{_sysconfdir}/xdg/kglobalshortcutsrc
%{_datadir}/plasma/desktoptheme/fenstra/
%{_datadir}/plasma/desktoptheme/fenstra-dark/
%config(noreplace) %{_sysconfdir}/fonts/conf.d/61-fenstra-ui.conf
%{_datadir}/themes/Fenstra/
%config(noreplace) %{_sysconfdir}/skel/.config/gtk-3.0/settings.ini
%config(noreplace) %{_sysconfdir}/skel/.config/gtk-4.0/settings.ini
%config(noreplace) %{_sysconfdir}/firefox/pref/fenstra-prefs.js

%files -n fenstra-taskleiste
%{_datadir}/plasma/plasmoids/org.fenstra.taskbar/
%{_datadir}/plasma/plasmoids/org.fenstra.infobereich/
%{_datadir}/kwin-wayland/scripts/fenstra-kuerzel/

%files -n plymouth-theme-fenstra
%{_datadir}/plymouth/themes/fenstra/

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-11
- M4: Startmenü im Windows-11-Stand (642×726, 12 px über der Taskleiste, Seiten mit
  Punkten, Ordner, „Alle“, „Empfohlen“ mit „Mehr“, Kontokarte, Ein/Aus-Menü)
- Suchpanel (KRunner) mit Filtern, höchster Übereinstimmung und Detailbereich
- Schnelleinstellungen mit Kacheln, Reglern, Unterseiten und „Bearbeiten“
- Benachrichtigungscenter mit Kalender und Fokus, eigene Toasts unten rechts; Plasmas
  Benachrichtigungs-Applet entfällt im Systemabschnitt
- Widgets-Board von links (Wetter, Kalender, Uhr, Fotos, Systemleistung, Notizen)
- KWin-Skript fenstra-kuerzel und /etc/xdg/kglobalshortcutsrc (Win+S/Q/A/N/W; Übersicht
  auf Meta+Tab, Aktivitäten ohne Taste)
- helles Farbschema: dunkle Auswahlschrift (Kirigami-Listen auf grauer Auswahl)

* Tue Oct 06 2026 Fenstra-Projekt - 44.0-10
- Firefox: normale Titelleiste (Fenstra-Dekoration), weil die eigenen Firefox-Knöpfe winzig
  waren und das Schließen-X unsichtbar (Nutzerbefund)
- GTK-Design „Fenstra“ (Breeze-GTK + Titelleistenknöpfe 46×32 wie Windows) als Vorgabe für
  neue Benutzer; KDE erzeugt damit keine unbrauchbaren Knopfbilder aus der Dekoration mehr

* Tue Oct 06 2026 Fenstra-Projekt - 44.0-9
- M3: eigene Taskleiste (org.fenstra.taskbar, mit Startmenü) und eigener Infobereich
  (org.fenstra.infobereich) im Unterpaket fenstra-taskleiste; ersetzt fenstra-startmenu
- Layout: Taskleiste, Plasma-Systemabschnitt (nur „^“), Infobereich; Starter für Suche
  und Task-Ansicht entfallen (direkt per D-Bus)
- eigenes Start-Symbol (blaues Fenstra-Fenster ohne Kachel, hell/dunkel)
- /etc/xdg/plasmarc: Plasma-Design fenstra als Systemvorgabe (nach Wechsel dunkel→hell
  fiel Plasma sonst auf Breeze zurück)

* Tue Oct 06 2026 Fenstra-Projekt - 44.0-8
- M2: eigene Mauszeiger (fenstra-cursors) und eigenes Klangschema (fenstra) als Vorgabe,
  Breeze-Zeiger entfallen

* Mon Oct 05 2026 Fenstra-Projekt - 44.0-7
- Linkfarben wie Windows (hell #003E92, dunkel #99EBFF)

* Mon Oct 05 2026 Fenstra-Projekt - 44.0-6
- M1: Qt-Stil und Fensterdekoration "Fenstra" (fenstra-style) als Vorgabe,
  Plasma-Designs fenstra/fenstra-dark (aus Code erzeugt), Schrift 10,5 pt,
  kein AccentColor-Schlüssel mehr (Plasma hellte die Auswahlfarbe auf),
  dunkles Farbschema: Textauswahl #0078D4 mit weißer Schrift, breezerc entfällt

* Mon Oct 05 2026 Fenstra-Projekt - 44.0-5
- Startmenü: Fenstra-Vorgaben für "Angeheftet" werden ergänzt, auch wenn Plasma
  schon eigene Favoriten mitbringt (vorher wirkungslos)
- Startmenü: in den Suchergebnissen gehen Tippen, Rücktaste und Escape zurück
  ins Suchfeld

* Sun Oct 04 2026 Fenstra-Projekt - 44.0-4
- Baustein 4b-2: eigenes Startmenü (Unterpaket fenstra-startmenu, Plasmoid
  org.fenstra.startmenu) statt Kickoff in der Taskleiste

* Sun Oct 04 2026 Fenstra-Projekt - 44.0-3
- Baustein 4b, Schritt 1: Taskleiste im Aufbau von Windows 11 (Layout im globalen
  Design: unten, volle Breite, nicht schwebend, Programme mittig, Start, Suche,
  Aktive Anwendungen, Uhr mit Datum darunter)
- Fensterrahmen: Titel links, Ecken rundum abgerundet, Umrandung, weicher Schatten
- Suche (KRunner) schwebt in der Bildschirmmitte

* Sun Oct 04 2026 Fenstra-Projekt - 44.0-2
- Startbildschirm der dunklen Variante als Kopie statt Symlink (KDE: Path traversal)
- Begrüßungsassistent: Fenstra-Logo und -Text (intro-customization.desktop)

* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: Look-and-Feel hell/dunkel, Farbschemata, Vorgaben, Plymouth
