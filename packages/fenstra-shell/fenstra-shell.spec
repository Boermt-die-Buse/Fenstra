# Fenstra-Shell: gemeinsames QML-Modul org.fenstra.shell für Taskleiste, Startmenü und
# Flyouts (WinUI-Farben, Schaltflächen, Schalter, Regler, Suchfeld, Listeneinträge,
# Flyout-Fenster mit 12 px Abstand). Reines QML; liegt im QML-Verzeichnis von Qt 6 und ist
# deshalb architekturabhängig abgelegt (kein noarch).
%global debug_package %{nil}

Name:           fenstra-shell
Version:        44.0
Release:        1%{?dist}
Summary:        Gemeinsame Bedienelemente der Fenstra-Shell im Stil von Windows 11
License:        GPL-2.0-or-later
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        fenstra-shell-src.tar.gz

BuildRequires:  qt6-qtbase-devel
# Plasma-Dialoge, Kirigami-Symbole und -Farben
Requires:       libplasma
Requires:       kf6-kirigami
Requires:       qt6-qtdeclarative%{?_isa}

%description
QML-Modul org.fenstra.shell mit den WinUI-Farbwerten von Windows 11 und den
Bedienelementen, die Startmenü, Suche, Schnelleinstellungen, Benachrichtigungen
und Widgets gemeinsam nutzen.

%prep
%setup -q -n src

%build

%install
install -d %{buildroot}%{_qt6_qmldir}/org/fenstra/shell
install -p -m 0644 qml/org/fenstra/shell/* %{buildroot}%{_qt6_qmldir}/org/fenstra/shell/

%files
%dir %{_qt6_qmldir}/org/fenstra
%{_qt6_qmldir}/org/fenstra/shell/

%changelog
* Tue Oct 06 2026 Fenstra-Projekt - 44.0-1
- Neu (M4): Farben, WinText, WinKnopf, WinSchalter, WinRegler, WinSuchfeld,
  WinListenEintrag, WinTrenner, WinFlyout, FlyoutAnker, FlyoutFuss
