# Fenstra-Klangschema: alle Ereignisklänge synthetisiert (src/klaenge.py, numpy),
# beim Bauen erzeugt und mit oggenc als Ogg Vorbis abgelegt.
Name:           fenstra-sound-theme
Version:        44.0
Release:        1%{?dist}
Summary:        Klangschema für Fenstra (synthetisierte Klänge im Stil von Windows 11)
# Klänge: CC-BY-SA-4.0; Generator: MIT
License:        CC-BY-SA-4.0 AND MIT
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source1:        klaenge.py
BuildArch:      noarch
BuildRequires:  python3
BuildRequires:  python3-numpy
BuildRequires:  vorbis-tools

%description
Ereignisklänge im Stil von Windows 11 (Anmelden, Benachrichtigung, Hinweis, Fehler,
Gerät an/ab, Papierkorb, Lautstärke, Akku, Wecker u. a.) nach der freedesktop-
Benennung. Alle Klänge werden beim Bauen aus Python-Code synthetisiert; Abmelden
bleibt wie unter Windows 11 still.

%prep
%setup -q -c -T
cp -p %{SOURCE1} .

%build
python3 klaenge.py --out fenstra

%install
install -d %{buildroot}%{_datadir}/sounds
cp -a fenstra %{buildroot}%{_datadir}/sounds/fenstra
install -d %{buildroot}%{_datadir}/fenstra/sound-theme
install -p -m 0755 klaenge.py %{buildroot}%{_datadir}/fenstra/sound-theme/

%files
%{_datadir}/sounds/fenstra/
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/sound-theme/

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung (M2): 58 Ereignisnamen, synthetisiert, Spitze -1,5 dBFS, einheitliche Lautheit
