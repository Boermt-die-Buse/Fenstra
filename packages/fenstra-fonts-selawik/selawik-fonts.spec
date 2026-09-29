# Selawik (Microsoft, SIL Open Font License 1.1): metrisch zu Segoe UI kompatible
# freie Schrift. Nicht in Fedora paketiert, deshalb hier.
# Quelle: https://github.com/microsoft/Selawik. Das Archiv enthält nur die
# UFO-Quellen ("Source files/UFO/Selawik-*.ufo"); die TTFs werden beim Bauen mit
# fontmake erzeugt (so macht es Fedora bei Schriften, die als Quelle vorliegen).
# Der Tarball wird von build/build-packages.sh geladen und gegen
# packages/sources.sha256 geprüft.
%global fontlicense    OFL-1.1
%global fontlicenses   LICENSE*
%global fontdocs       README.md
%global fontfamily     Selawik
%global fontsummary    Selawik, freier metrischer Ersatz für Segoe UI
# fontmake legt die erzeugten TTFs unter fonts/ ab
%global fonts          fonts/*.ttf
%global fontconfs      %{SOURCE10}
%global fontdescription %{expand:
Selawik ist eine von Microsoft unter der SIL Open Font License veröffentlichte
Schrift mit denselben Metriken wie Segoe UI. Fenstra verwendet sie als
Oberflächenschrift; Anfragen nach "Segoe UI" werden per fontconfig auf Selawik
umgeleitet.}

# Achtung: RPM expandiert Makros auch in Kommentaren, deshalb hier keine Makronamen.
# Name (selawik-fonts), Summary, License, BuildArch und BuildRequires erzeugt das
# Font-Makro unten aus fontfamily/fontsummary/fontlicense; sie dürfen hier nicht stehen.
Version:        1.01
Release:        1%{?dist}
URL:            https://github.com/microsoft/Selawik
Source0:        https://github.com/microsoft/Selawik/archive/refs/heads/master.tar.gz#/Selawik-master.tar.gz
Source10:       60-selawik.conf
Provides:       fenstra-fonts-selawik = %{version}-%{release}
BuildRequires:  fontmake

%fontpkg

%prep
%autosetup -n Selawik-master
ls LICENSE* >/dev/null 2>&1 || { echo "Keine LICENSE-Datei im Archiv:"; ls; exit 1; }
[ -e README.md ] || echo "Selawik: https://github.com/microsoft/Selawik" > README.md

%build
# TTFs aus den UFO-Quellen erzeugen (Regular, Bold, Light, Semibold, Semilight)
mkdir -p fonts
n=0
while IFS= read -r ufo; do
  echo "fontmake: $ufo"
  fontmake -u "$ufo" -o ttf --output-dir fonts
  n=$((n + 1))
done < <(find . -type d -name '*.ufo' | sort)
[ "$n" -gt 0 ] || { echo "Keine UFO-Quellen im Archiv gefunden:"; find . -maxdepth 3 | head -40; exit 1; }
ls -l fonts/
%fontbuild

%install
%fontinstall

%fontfiles

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 1.01-1
- Erste Paketierung für Fenstra, fontconfig-Alias für Segoe UI
