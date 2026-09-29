# Fenstra-Logos: ersetzt fedora-logos (Provides: system-logos).
# Enthält: Logo als Icon (hicolor), Startmenü-Symbol (start-here), Systeminfo-Logo,
# Anaconda-Grafiken (klassische GTK-Oberfläche), Plymouth-Wasserzeichen für die
# Fedora-Themes spinner/bgrt, Favicon. Alle Grafiken werden beim Bauen aus SVG
# gerendert (librsvg).
Name:           fenstra-logos
Version:        44.0
Release:        1%{?dist}
Summary:        Logos und Markengrafiken für Fenstra
License:        CC-BY-SA-4.0
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        fenstra-logo.svg
Source1:        fenstra-logo-white.svg
Source2:        fenstra-logo-dark.svg
Source3:        fenstra-wordmark.svg
Source4:        anaconda-sidebar-bg.svg
Source5:        anaconda-topbar-bg.svg
Source6:        fenstra.css
BuildArch:      noarch
BuildRequires:  librsvg2-tools
BuildRequires:  ImageMagick
Provides:       system-logos = %{version}-%{release}
Provides:       redhat-logos = %{version}-%{release}
Conflicts:      fedora-logos
Conflicts:      generic-logos
# Verzeichnisse gehören anderen Paketen, wir liefern nur Dateien hinein
Requires:       hicolor-icon-theme

%description
Eigene Logos und Markengrafiken des Fenstra-Projekts. Keine Microsoft- oder
Fedora-Marken. Das Logo zeigt ein geöffnetes Fenster.

%prep
# keine Quellen zu entpacken

%build
render() { rsvg-convert -w "$2" -h "$3" -o "$4" "$1"; }
mkdir -p out
# Icon-Größen (hicolor)
for s in 16 22 24 32 36 48 64 96 128 256 512; do
  render %{SOURCE0} $s $s out/fenstra-logo-icon-$s.png
done
# Systeminfo (kinfocenter, kcm-about-distrorc: LogoPath), weiß auf transparent
render %{SOURCE1} 256 256 out/system-logo-white.png
render %{SOURCE0} 256 256 out/fenstra-logo.png
render %{SOURCE0} 64 64 out/fenstra-logo-small.png
render %{SOURCE2} 256 256 out/fenstra-logo-dark.png
# Plymouth-Wasserzeichen für spinner/bgrt (fedora-logos liefert dort watermark.png)
render %{SOURCE1} 160 160 out/watermark.png
# Anaconda (klassische GTK-Oberfläche)
render %{SOURCE3} 640 160 out/wordmark-640.png
magick out/wordmark-640.png -resize 180x -background none -gravity center -extent 200x60 out/sidebar-logo.png
render %{SOURCE4} 200 800 out/sidebar-bg.png
render %{SOURCE5} 1200 100 out/topbar-bg.png
rsvg-convert -a -w 240 -h 240 -o out/splash-logo.png %{SOURCE0}
magick -size 640x480 xc:'#0B3D7A' out/splash-logo.png -gravity center -composite out/splash.png
cp out/splash.png out/syslinux-splash.png
# Favicon und Bootloader-Logos
magick out/fenstra-logo-icon-16.png out/fenstra-logo-icon-32.png out/fenstra-logo-icon-48.png out/fenstra-logo.ico
cp out/fenstra-logo-icon-128.png out/bootlogo_128.png
cp out/fenstra-logo-icon-256.png out/bootlogo_256.png

%install
# hicolor-Icons: Logo und Startmenü-Symbol ("start-here" wird vom Startmenü benutzt)
for s in 16 22 24 32 36 48 64 96 128 256 512; do
  install -D -p -m 0644 out/fenstra-logo-icon-$s.png %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/apps/fenstra-logo-icon.png
  install -D -p -m 0644 out/fenstra-logo-icon-$s.png %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/apps/start-here.png
  install -D -p -m 0644 out/fenstra-logo-icon-$s.png %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/places/start-here.png
done
install -D -p -m 0644 %{SOURCE0} %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/fenstra-logo-icon.svg
install -D -p -m 0644 %{SOURCE0} %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/start-here.svg
install -D -p -m 0644 %{SOURCE0} %{buildroot}%{_datadir}/icons/hicolor/scalable/places/start-here.svg
install -D -p -m 0644 out/fenstra-logo-icon-256.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/anaconda.png
# pixmaps (Systeminfo, Anmeldung, Altlasten-Pfade, die Programme abfragen)
install -d %{buildroot}%{_datadir}/pixmaps/bootloader
install -p -m 0644 out/system-logo-white.png out/fenstra-logo.png out/fenstra-logo-small.png out/fenstra-logo-dark.png out/fenstra-logo.ico %{buildroot}%{_datadir}/pixmaps/
install -p -m 0644 %{SOURCE0} %{buildroot}%{_datadir}/pixmaps/fenstra-logo.svg
install -p -m 0644 %{SOURCE1} %{buildroot}%{_datadir}/pixmaps/fenstra-logo-white.svg
install -p -m 0644 %{SOURCE3} %{buildroot}%{_datadir}/pixmaps/fenstra-wordmark.svg
install -p -m 0644 out/bootlogo_128.png out/bootlogo_256.png %{buildroot}%{_datadir}/pixmaps/bootloader/
# Anaconda (GTK): Seitenleiste, Kopfzeile, Bootsplash; CSS für die Variante "fenstra"
install -d %{buildroot}%{_datadir}/anaconda/pixmaps %{buildroot}%{_datadir}/anaconda/boot
install -p -m 0644 out/sidebar-logo.png out/sidebar-bg.png out/topbar-bg.png %{buildroot}%{_datadir}/anaconda/pixmaps/
install -p -m 0644 %{SOURCE6} %{buildroot}%{_datadir}/anaconda/pixmaps/fenstra.css
install -p -m 0644 %{SOURCE6} %{buildroot}%{_datadir}/anaconda/pixmaps/fedora.css
install -p -m 0644 out/splash.png out/syslinux-splash.png %{buildroot}%{_datadir}/anaconda/boot/
# Plymouth: Wasserzeichen für die Fedora-Themes spinner und bgrt
install -D -p -m 0644 out/watermark.png %{buildroot}%{_datadir}/plymouth/themes/spinner/watermark.png
# Favicon (fedora-logos hat /etc/favicon.png)
install -D -p -m 0644 out/fenstra-logo-icon-16.png %{buildroot}%{_sysconfdir}/favicon.png

%files
%config(noreplace) %{_sysconfdir}/favicon.png
%{_datadir}/icons/hicolor/*/apps/*
%{_datadir}/icons/hicolor/*/places/*
%{_datadir}/pixmaps/*
%{_datadir}/anaconda/pixmaps/
%{_datadir}/anaconda/boot/
%dir %{_datadir}/plymouth
%dir %{_datadir}/plymouth/themes
%dir %{_datadir}/plymouth/themes/spinner
%{_datadir}/plymouth/themes/spinner/watermark.png

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: Logo, Startmenü-Symbol, Anaconda- und Plymouth-Grafiken
