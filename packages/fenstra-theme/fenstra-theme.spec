# Fenstra-Theme: globales Plasma-Design (hell/dunkel), Farbschemata, systemweite
# KDE-Vorgaben (Schriften, Symbole, Fensterknöpfe, Sperrbildschirm), Plymouth-
# Bootscreen und fontconfig-Regeln. Bindet Hintergrund, Symbole und Schriften ein.
Name:           fenstra-theme
Version:        44.0
Release:        1%{?dist}
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
Requires:       fenstra-backgrounds
Requires:       fenstra-icon-theme
Requires:       fenstra-logos
Requires:       selawik-fonts
Requires:       cascadia-code-fonts

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

%prep
%setup -q -n src

%build
# Plymouth: Ladering-Bilder und Dialoggrafiken rendern
python3 plymouth/make-frames.py plymouth/frames
for f in plymouth/frames/*.svg; do
  rsvg-convert -o "${f%.svg}.png" "$f"
done
rsvg-convert -w 128 -h 128 -o plymouth/frames/watermark.png look-and-feel/org.fenstra.desktop/contents/splash/images/fenstra-logo-white.svg

%install
# Globale Designs (Look-and-Feel)
install -d %{buildroot}%{_datadir}/plasma/look-and-feel
cp -a look-and-feel/org.fenstra.desktop %{buildroot}%{_datadir}/plasma/look-and-feel/
cp -a look-and-feel/org.fenstra.desktop.dark %{buildroot}%{_datadir}/plasma/look-and-feel/
# dunkle Variante nutzt denselben Startbildschirm
ln -s ../../org.fenstra.desktop/contents/splash %{buildroot}%{_datadir}/plasma/look-and-feel/org.fenstra.desktop.dark/contents/splash
# Farbschemata
install -d %{buildroot}%{_datadir}/color-schemes
install -p -m 0644 color-schemes/*.colors %{buildroot}%{_datadir}/color-schemes/
# systemweite Vorgaben (KConfig liest /etc/xdg vor den Fedora-Profilen)
install -d %{buildroot}%{_sysconfdir}/xdg
install -p -m 0644 xdg/kdeglobals xdg/kcminputrc xdg/kwinrc xdg/kscreenlockerrc xdg/ksplashrc %{buildroot}%{_sysconfdir}/xdg/
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
%config(noreplace) %{_sysconfdir}/xdg/kdeglobals
%config(noreplace) %{_sysconfdir}/xdg/kcminputrc
%config(noreplace) %{_sysconfdir}/xdg/kwinrc
%config(noreplace) %{_sysconfdir}/xdg/kscreenlockerrc
%config(noreplace) %{_sysconfdir}/xdg/ksplashrc
%config(noreplace) %{_sysconfdir}/fonts/conf.d/61-fenstra-ui.conf

%files -n plymouth-theme-fenstra
%{_datadir}/plymouth/themes/fenstra/

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: Look-and-Feel hell/dunkel, Farbschemata, Vorgaben, Plymouth
