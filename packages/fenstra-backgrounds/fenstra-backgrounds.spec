# Fenstra-Hintergrundbilder als Plasma-Wallpaper-Paket "Fenstra" (hell + dunkel).
# Ersetzt die Fedora-Hintergründe: stellt system-backgrounds-kde bereit und legt
# /usr/share/wallpapers/Default an (darauf zeigt /usr/share/wallpapers/Fedora aus
# kde-settings-plasma, das Anmelde- und Sperrbildschirm benutzen).
%global wpname Fenstra

Name:           fenstra-backgrounds
Version:        44.0
Release:        1%{?dist}
Summary:        Hintergrundbilder für Fenstra
License:        CC-BY-SA-4.0
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        fenstra-light.svg
Source1:        fenstra-dark.svg
Source2:        metadata.json
BuildArch:      noarch
BuildRequires:  librsvg2-tools
BuildRequires:  ImageMagick
Provides:       system-backgrounds-kde = %{version}-%{release}
Provides:       fenstra-backgrounds-kde = %{version}-%{release}
Conflicts:      desktop-backgrounds-kde

%description
Abstrakte Hintergrundbilder für Fenstra in einer hellen und einer dunklen
Variante, in den gängigen Auflösungen (16:9, 16:10, 4:3, 21:9, Hochformat).
Eigenes Werk des Fenstra-Projekts.

%prep
# keine Quellen zu entpacken

%build
# Auflösungen wie in den Fedora-Hintergrundpaketen. Das SVG ist 16:9 mit
# "slice", andere Seitenverhältnisse werden beschnitten, nicht verzerrt.
sizes="3840x2160 2560x1440 1920x1080 1366x768 1280x720 \
       2560x1600 1920x1200 1680x1050 1440x900 1280x800 \
       1600x1200 1400x1050 1280x1024 1024x768 \
       3440x1440 2960x1440 \
       1080x1920 1440x2960"
for variant in light dark; do
  mkdir -p images-$variant
  for s in $sizes; do
    w=${s%x*}; h=${s#*x}
    rsvg-convert -w "$w" -h "$h" -o "images-$variant/$s.png" "%{_sourcedir}/fenstra-$variant.svg"
    # JPEG spart gegenüber PNG viel Platz; die weichen Verläufe vertragen das gut.
    magick "images-$variant/$s.png" -quality 92 -strip "images-$variant/$s.jpg"
    rm -f "images-$variant/$s.png"
  done
done
rsvg-convert -w 640 -h 360 -o screenshot.png "%{_sourcedir}/fenstra-light.svg"

%install
d=%{buildroot}%{_datadir}/wallpapers/%{wpname}
install -d "$d/contents/images" "$d/contents/images_dark"
install -p -m 0644 images-light/*.jpg "$d/contents/images/"
install -p -m 0644 images-dark/*.jpg "$d/contents/images_dark/"
install -p -m 0644 screenshot.png "$d/contents/screenshot.png"
install -p -m 0644 %{SOURCE2} "$d/metadata.json"
# Quellen mitliefern (Lizenz: eigenes Werk, andere dürfen sie anpassen)
install -d %{buildroot}%{_datadir}/fenstra/backgrounds
install -p -m 0644 %{SOURCE0} %{SOURCE1} %{buildroot}%{_datadir}/fenstra/backgrounds/
# Standard-Hintergrund für Anmelde- und Sperrbildschirm (kde-settings: Fedora -> Default)
ln -s %{wpname} %{buildroot}%{_datadir}/wallpapers/Default

%files
%{_datadir}/wallpapers/%{wpname}/
%{_datadir}/wallpapers/Default
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/backgrounds/

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: helle und dunkle Variante, Plasma-Wallpaper-Paket
