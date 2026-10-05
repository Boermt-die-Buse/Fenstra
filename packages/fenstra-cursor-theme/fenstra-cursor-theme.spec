# Fenstra-Mauszeiger: eigene Formen im Stil von Windows 11, beim Bauen aus Code erzeugt
# (src/zeiger.py -> SVG -> PNG mit rsvg-convert -> Xcursor mit xcursorgen).
Name:           fenstra-cursor-theme
Version:        44.0
Release:        1%{?dist}
Summary:        Mauszeiger für Fenstra (eigene Zeiger im Stil von Windows 11)
# Formen: CC-BY-SA-4.0; Generator: MIT
License:        CC-BY-SA-4.0 AND MIT
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source1:        zeiger.py
BuildArch:      noarch
BuildRequires:  python3
BuildRequires:  librsvg2-tools
BuildRequires:  xcursorgen

%description
Mauszeiger-Thema im Stil von Windows 11: weißer Pfeil mit schwarzem Rand, schwarze
Doppelpfeile, Hand für Verknüpfungen und ein animierter blauer Beschäftigt-Ring.
Alle Formen sind eigene Werke und werden beim Bauen aus Python-Code erzeugt
(Nenngrößen 24 bis 96).

%prep
%setup -q -c -T
cp -p %{SOURCE1} .

%build
python3 zeiger.py --out fenstra-cursors

%install
install -d %{buildroot}%{_datadir}/icons
cp -a fenstra-cursors %{buildroot}%{_datadir}/icons/fenstra-cursors
install -d %{buildroot}%{_datadir}/fenstra/cursor-theme
install -p -m 0755 zeiger.py %{buildroot}%{_datadir}/fenstra/cursor-theme/

%files
%{_datadir}/icons/fenstra-cursors/
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/cursor-theme/

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung (M2): 25 Formen, 112 Verweisnamen, Beschäftigt-Ring mit 24 Bildern (~1 s)
