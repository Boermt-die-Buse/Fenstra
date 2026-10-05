# Fenstra: Qt-Widget-Stil "Fenstra" (WinUI-Steuerelemente wie Windows 11) und KWin-
# Fensterdekoration "Fenstra" (Titelleiste 32 px, Knöpfe 46×32, Schließen rot, Ecken 8 px).
# Fork von KDE Breeze 6.7.5 (kstyle, kdecoration, libbreezecommon), umbenannt und umgebaut.
# Die Plugins hängen an der Qt-/KWin-Version, mit der sie gebaut wurden: nach
# Fedora-Updates von Qt/KWin neu bauen.
%global kwin_ver %(rpm -q --qf '%%{VERSION}' kwin-devel 2>/dev/null || echo 0)
%global qt_ver %(rpm -q --qf '%%{VERSION}' qt6-qtbase-devel 2>/dev/null || echo 0)

Name:           fenstra-style
Version:        44.0
Release:        2%{?dist}
Summary:        Widget-Stil und Fensterdekoration im Stil von Windows 11 für Fenstra
License:        GPL-2.0-or-later AND (GPL-2.0-only OR GPL-3.0-only)
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        fenstra-style-src.tar.gz

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-rpm-macros
BuildRequires:  cmake(Qt6Core)
BuildRequires:  cmake(Qt6DBus)
BuildRequires:  cmake(Qt6Quick)
BuildRequires:  cmake(Qt6Widgets)
BuildRequires:  cmake(Qt6Svg)
BuildRequires:  cmake(KF6ColorScheme)
BuildRequires:  cmake(KF6Config)
BuildRequires:  cmake(KF6CoreAddons)
BuildRequires:  cmake(KF6FrameworkIntegration)
BuildRequires:  cmake(KF6GuiAddons)
BuildRequires:  cmake(KF6I18n)
BuildRequires:  cmake(KF6IconThemes)
BuildRequires:  cmake(KF6KCMUtils)
BuildRequires:  cmake(KF6WindowSystem)
BuildRequires:  cmake(KDecoration3)
BuildRequires:  kwin-devel

# exakt die Versionen, gegen die gebaut wurde (Plugin-ABI)
Requires:       kwin-common >= %{kwin_ver}
Requires:       kwin-common < %{kwin_ver}.99
Requires:       qt6-qtbase%{?_isa} >= %{qt_ver}

%description
Der Qt-Stil "Fenstra" zeichnet Schaltflächen, Eingabefelder, Kontrollkästchen,
Optionsfelder, Schieberegler, Fortschrittsbalken, Bildlaufleisten, Menüs,
Tooltips, Listen und Register wie die WinUI-Steuerelemente von Windows 11.
Die Fensterdekoration "Fenstra" bildet die Titelleiste von Windows 11 nach.

%prep
%setup -q -n src

%build
%cmake_kf6 -DBUILD_TESTING=OFF
%cmake_build

%install
%cmake_install
# Einstellungsdialog des Breeze-Erbes nicht anbieten (Windows hat keinen)
rm -f %{buildroot}%{_bindir}/fenstra-settings6
rm -f %{buildroot}%{_datadir}/applications/fenstrastyleconfig.desktop
rm -f %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/fenstra-settings.svgz

%files
%license LICENSES/*
%{_qt6_plugindir}/styles/fenstra6.so
%{_qt6_plugindir}/kstyle_config/fenstrastyleconfig.so
%{_qt6_plugindir}/org.kde.kdecoration3/org.fenstra.decoration.so
%{_datadir}/kstyle/themes/fenstra.themerc

%changelog
* Mon Oct 05 2026 Fenstra-Projekt - 44.0-2
- Kombinationsfeld-Liste wie WinUI (graue Auswahl, Akzentbalken), Baumzeilen 32 px

* Mon Oct 05 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung (Meilenstein M1): WinUI-Stil und Windows-11-Fensterdekoration
