# Fenstra-Symbolthema: alle Symbole eigene Werke, beim Bauen aus Code erzeugt
# (src/glyphs.py = einfarbige Strichsymbole, src/farbig.py = farbige Symbole,
# src/mapping.json = Zuordnung der KDE-/freedesktop-Namen). Keine fremden Symbolsätze,
# kein Rückfall auf Breeze (erbt nur von hicolor).
Name:           fenstra-icon-theme
Version:        44.0
Release:        5%{?dist}
Summary:        Symbolthema für Fenstra (eigene Symbole im Stil von Windows 11)
# Motive: CC-BY-SA-4.0; Generator: MIT
License:        CC-BY-SA-4.0 AND MIT
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source1:        generate.py
Source2:        glyphs.py
Source3:        farbig.py
Source4:        mapping.json
BuildArch:      noarch
BuildRequires:  python3
Requires:       hicolor-icon-theme
# Programmsymbole (Installer, Startknopf) verweisen auf das Logo aus fenstra-logos
Requires:       fenstra-logos

%description
Symbolthema im Stil von Windows 11: einfarbige Strichsymbole für Aktionen, Status und
Geräte (folgen dem Farbschema), gelbe Ordner mit Motiv, farbige Laufwerke, Dateitypen,
Hinweis- und Programmsymbole. Alle Motive sind eigene Werke und werden beim Bauen aus
Python-Code als SVG erzeugt.

%prep
%setup -q -c -T
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} %{SOURCE4} .

%build
python3 generate.py --out fenstra

%install
install -d %{buildroot}%{_datadir}/icons
cp -a fenstra %{buildroot}%{_datadir}/icons/fenstra
# Quellen des Generators mitliefern (Nachvollziehbarkeit)
install -d %{buildroot}%{_datadir}/fenstra/icon-theme
install -p -m 0644 glyphs.py farbig.py mapping.json %{buildroot}%{_datadir}/fenstra/icon-theme/
install -p -m 0755 generate.py %{buildroot}%{_datadir}/fenstra/icon-theme/

%transfiletriggerin -- %{_datadir}/icons/fenstra
gtk-update-icon-cache --force %{_datadir}/icons/fenstra &>/dev/null || :

%files
%{_datadir}/icons/fenstra/
%dir %{_datadir}/fenstra
%{_datadir}/fenstra/icon-theme/

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-5
- farbige Symbole mit weniger Rand (Ausschnitt 58/64): füllen ihr Feld wie Windows-Symbole,
  in der Taskleiste deutlich größer (Nutzerbefund „Skalierung falsch“); Store-Tasche größer

* Tue Oct 06 2026 Fenstra-Projekt - 44.0-4
- Kabelnetz als Bildschirm mit Stecker (wie der Windows-Infobereich), kein Netz als Globus
  mit Verbotszeichen; Helligkeit, Eingabemethoden, weitere Programm- und Dateinamen

* Tue Oct 06 2026 Fenstra-Projekt - 44.0-3
- Komplett eigene Symbole (M2): Strichsymbole aus glyphs.py, farbige Symbole aus farbig.py
- Fluent UI System Icons und Breeze-Rückfall entfernt (Inherits=hicolor)
- Bibliotheken mit eigenen 16-px-Motiven, Programmsymbole als Kacheln, Hinweise farbig

* Sun Oct 04 2026 Fenstra-Projekt - 44.0-2
- Arbeitsfläche (user-desktop) in Akzentblau statt schwarz, -symbolic bleibt einfarbig
- Installer-Symbol (org.fedoraproject.AnacondaInstaller, anaconda) = Fenstra-Logo

* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: Aktions-, Status-, Geräte- und Ordnersymbole aus Fluent, Rest Breeze
