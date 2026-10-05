# Fenstra-Theme: globales Plasma-Design (hell/dunkel), Farbschemata, systemweite
# KDE-Vorgaben (Schriften, Symbole, Fensterknöpfe, Sperrbildschirm), Plymouth-
# Bootscreen und fontconfig-Regeln. Bindet Hintergrund, Symbole und Schriften ein.
Name:           fenstra-theme
Version:        44.0
Release:        7%{?dist}
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
Requires:       breeze-cursor-theme
# Qt-Stil und Fensterdekoration "Fenstra" (Meilenstein M1)
Requires:       fenstra-style
Requires:       fenstra-backgrounds
Requires:       fenstra-icon-theme
Requires:       fenstra-logos
Requires:       selawik-fonts
Requires:       cascadia-code-fonts
# Taskleiste: Suche = KRunner, Aktive Anwendungen = KWin-Übersicht per qdbus
Requires:       /usr/bin/krunner
Requires:       /usr/bin/qdbus-qt6
# Startmenü der Taskleiste
Requires:       fenstra-startmenu = %{version}-%{release}

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

%package -n fenstra-startmenu
Summary:        Startmenü im Stil von Windows 11 für Fenstra
License:        GPL-2.0-or-later
# QML-Module: Kicker-Modelle (plasma-workspace), Plasma-Komponenten (libplasma),
# Kirigami, Avatar (kirigami-addons), Benutzerdaten (kcoreaddons)
Requires:       plasma-workspace
Requires:       libplasma
Requires:       kf6-kirigami
Requires:       kf6-kirigami-addons
Requires:       kf6-kcoreaddons

%description -n fenstra-startmenu
Plasma-Startmenü im Aufbau von Windows 11: Suche oben, angeheftete Apps als
Raster, Empfohlen (zuletzt benutzt), alle Apps alphabetisch, unten Benutzer
und Ein/Aus. Öffnet auch mit der Windows-Taste.

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
# Startmenü (Plasmoid)
install -d %{buildroot}%{_datadir}/plasma/plasmoids
cp -a plasmoids/org.fenstra.startmenu %{buildroot}%{_datadir}/plasma/plasmoids/
# Knöpfe der Taskleiste: Suche und Aktive Anwendungen (nicht im Startmenü sichtbar)
install -d %{buildroot}%{_datadir}/applications
install -p -m 0644 applications/fenstra-search.desktop applications/fenstra-taskview.desktop %{buildroot}%{_datadir}/applications/
# Begrüßungsassistent (plasma-welcome): Fenstra-Logo und -Text statt KDE-Maskottchen
install -D -p -m 0644 plasma-welcome/intro-customization.desktop %{buildroot}%{_datadir}/plasma/plasma-welcome/intro-customization.desktop
# Farbschemata
install -d %{buildroot}%{_datadir}/color-schemes
install -p -m 0644 color-schemes/*.colors %{buildroot}%{_datadir}/color-schemes/
# systemweite Vorgaben (KConfig liest /etc/xdg vor den Fedora-Profilen)
install -d %{buildroot}%{_sysconfdir}/xdg
install -p -m 0644 xdg/kdeglobals xdg/kcminputrc xdg/kwinrc xdg/kscreenlockerrc xdg/ksplashrc xdg/krunnerrc %{buildroot}%{_sysconfdir}/xdg/
# Plasma-Designs
install -d %{buildroot}%{_datadir}/plasma/desktoptheme
cp -a desktoptheme-build/fenstra desktoptheme-build/fenstra-dark %{buildroot}%{_datadir}/plasma/desktoptheme/
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
%{_datadir}/plasma/desktoptheme/fenstra/
%{_datadir}/plasma/desktoptheme/fenstra-dark/
%{_datadir}/applications/fenstra-search.desktop
%{_datadir}/applications/fenstra-taskview.desktop
%config(noreplace) %{_sysconfdir}/fonts/conf.d/61-fenstra-ui.conf

%files -n fenstra-startmenu
%{_datadir}/plasma/plasmoids/org.fenstra.startmenu/

%files -n plymouth-theme-fenstra
%{_datadir}/plymouth/themes/fenstra/

%changelog
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
