# Fenstra-Symbolthema: Fluent UI System Icons (Microsoft, MIT) als KDE-Symbolthema,
# erbt von Breeze. Erzeugt beim Bauen aus dem npm-Paket @fluentui/svg-icons
# (nur SVGs, ~13 MB) mit src/generate-icons.py und der Zuordnung src/mapping.json.
%global fluent_version 1.1.343

Name:           fenstra-icon-theme
Version:        44.0
Release:        1%{?dist}
Summary:        Symbolthema für Fenstra (Fluent UI System Icons)
# Fluent-Symbole: MIT; Ordnersymbol und Generator: CC-BY-SA-4.0 bzw. MIT
License:        MIT AND CC-BY-SA-4.0
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        https://registry.npmjs.org/@fluentui/svg-icons/-/svg-icons-%{fluent_version}.tgz
Source1:        generate-icons.py
Source2:        mapping.json
Source3:        folder-base.svg
Source4:        LICENSE.fluent-ui-system-icons
BuildArch:      noarch
BuildRequires:  python3
Requires:       breeze-icon-theme
Requires:       hicolor-icon-theme

%description
Symbolthema im Stil von Windows 11 auf Basis der frei lizenzierten Fluent UI
System Icons. Aktions-, Status-, Geräte- und Ordnersymbole stammen aus Fluent,
alle übrigen Symbole (Programme, Dateitypen) aus Breeze.

%prep
%setup -q -c -n fluent
# npm-Tarball entpackt nach fluent/package/{icons,package.json,...}; Lizenztext (MIT) liegt als Source4 bei
grep -q '"license": "MIT"' package/package.json
cp -p %{SOURCE4} LICENSE

%build
mkdir -p src
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} src/
python3 src/generate-icons.py --fluent package/icons --src src --out fenstra

%install
install -d %{buildroot}%{_datadir}/icons
cp -a fenstra %{buildroot}%{_datadir}/icons/fenstra
# Quellen des Generators mitliefern (Nachvollziehbarkeit)
install -d %{buildroot}%{_datadir}/fenstra/icon-theme
install -p -m 0644 %{SOURCE2} %{SOURCE3} %{buildroot}%{_datadir}/fenstra/icon-theme/
install -p -m 0755 %{SOURCE1} %{buildroot}%{_datadir}/fenstra/icon-theme/

%files
%license LICENSE
%{_datadir}/icons/fenstra/
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/icon-theme/

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: Aktions-, Status-, Geräte- und Ordnersymbole aus Fluent, Rest Breeze
