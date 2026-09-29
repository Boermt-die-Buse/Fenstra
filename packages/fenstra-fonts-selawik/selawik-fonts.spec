# Selawik (Microsoft, SIL Open Font License 1.1): metrisch zu Segoe UI kompatible
# freie Schrift. Nicht in Fedora paketiert, deshalb hier.
# Quelle: https://github.com/microsoft/Selawik (Verzeichnis fonts/, Datei LICENSE.txt).
# Der Tarball wird beim Bauen von GitHub geladen (build/build-packages.sh) und seine
# Prüfsumme in packages/sources.sha256 festgehalten (erster Download = Referenz).
%global fontlicense    OFL-1.1
%global fontlicenses   LICENSE*
%global fontdocs       README.md
%global fontfamily     Selawik
%global fontsummary    Selawik, freier metrischer Ersatz für Segoe UI
# Die TTFs werden beim Entpacken aus dem Archiv nach fonts/ gesammelt (Layout des Repos egal)
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

%fontpkg

%prep
%autosetup -n Selawik-master
# TTFs unabhängig vom Verzeichnis-Layout des Repos einsammeln
mkdir -p fonts
find . -path ./fonts -prune -o -type f -iname '*.ttf' -print0 | xargs -0 -r -I{} mv {} fonts/
ls fonts/*.ttf >/dev/null 2>&1 || { echo "Keine TTF-Dateien im Selawik-Archiv gefunden:"; find . -type f | head -50; exit 1; }
ls LICENSE* >/dev/null 2>&1 || { echo "Keine LICENSE-Datei im Archiv"; exit 1; }
[ -e README.md ] || echo "Selawik: https://github.com/microsoft/Selawik" > README.md

%build
%fontbuild

%install
%fontinstall

%fontfiles

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 1.01-1
- Erste Paketierung für Fenstra, fontconfig-Alias für Segoe UI
