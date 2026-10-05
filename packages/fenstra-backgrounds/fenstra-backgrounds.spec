# Fenstra-Hintergrundbilder als Plasma-Wallpaper-Paket "Fenstra" (hell + dunkel).
# Ersetzt die Fedora-Hintergründe: stellt system-backgrounds-kde bereit und legt
# /usr/share/wallpapers/Default an (darauf zeigt /usr/share/wallpapers/Fedora aus
# kde-settings-plasma, das Anmelde- und Sperrbildschirm benutzen).
%global wpname Fenstra

Name:           fenstra-backgrounds
Version:        44.0
Release:        2%{?dist}
Summary:        Hintergrundbilder für Fenstra
License:        CC-BY-SA-4.0
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        hintergrund.py
Source2:        metadata.json
BuildArch:      noarch
BuildRequires:  python3
BuildRequires:  librsvg2-tools
BuildRequires:  ImageMagick
Provides:       system-backgrounds-kde = %{version}-%{release}
Provides:       fenstra-backgrounds-kde = %{version}-%{release}
Conflicts:      desktop-backgrounds-kde

%description
Hintergrundbilder für Fenstra: eine Blüte aus durchscheinenden blauen Blättern
in einer hellen und einer dunklen Variante, in den gängigen Auflösungen (16:9,
16:10, 4:3, 21:9, Hochformat), dazu sechs Benutzerbilder. Eigenes Werk des
Fenstra-Projekts, beim Bauen aus Python-Code erzeugt.

%prep
# keine Quellen zu entpacken

%build
python3 %{SOURCE0} --out . --benutzerbilder benutzerbilder
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
    rsvg-convert -w "$w" -h "$h" -o "images-$variant/$s.png" "fenstra-$variant.svg"
    # JPEG spart gegenüber PNG viel Platz; die weichen Verläufe vertragen das gut.
    magick "images-$variant/$s.png" -quality 92 -strip "images-$variant/$s.jpg"
    rm -f "images-$variant/$s.png"
  done
done
rsvg-convert -w 640 -h 360 -o screenshot.png fenstra-light.svg
# Benutzerbilder (Auswahl in den Systemeinstellungen, Seite Benutzer)
for f in benutzerbilder/fenstra-*.svg; do
  rsvg-convert -w 512 -h 512 -o "${f%.svg}.png" "$f"
done

%install
d=%{buildroot}%{_datadir}/wallpapers/%{wpname}
install -d "$d/contents/images" "$d/contents/images_dark"
install -p -m 0644 images-light/*.jpg "$d/contents/images/"
install -p -m 0644 images-dark/*.jpg "$d/contents/images_dark/"
install -p -m 0644 screenshot.png "$d/contents/screenshot.png"
install -p -m 0644 %{SOURCE2} "$d/metadata.json"
# Quellen mitliefern (Lizenz: eigenes Werk, andere dürfen sie anpassen)
install -d %{buildroot}%{_datadir}/fenstra/backgrounds
install -p -m 0644 fenstra-light.svg fenstra-dark.svg %{buildroot}%{_datadir}/fenstra/backgrounds/
install -p -m 0755 %{SOURCE0} %{buildroot}%{_datadir}/fenstra/backgrounds/
# Benutzerbilder mit deutschen Namen (der Dateiname erscheint als Titel)
a=%{buildroot}%{_datadir}/plasma/avatars
install -d "$a"
for n in person:Person bluete:Blüte berge:Berge welle:Welle blatt:Blatt planet:Planet; do
  install -p -m 0644 "benutzerbilder/fenstra-${n%%:*}.png" "$a/Fenstra ${n#*:}.png"
done
# Standard-Hintergrund für Anmelde- und Sperrbildschirm (kde-settings: Fedora -> Default)
ln -s %{wpname} %{buildroot}%{_datadir}/wallpapers/Default

%files
%{_datadir}/wallpapers/%{wpname}/
%{_datadir}/wallpapers/Default
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/backgrounds/
%{_datadir}/plasma/avatars/Fenstra*.png

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-2
- M2: neues Motiv "Blüte" (hell/dunkel) aus hintergrund.py, sechs eigene Benutzerbilder

* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: helle und dunkle Variante, Plasma-Wallpaper-Paket
