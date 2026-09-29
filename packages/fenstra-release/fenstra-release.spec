# Fenstra-Systemkennung. Ergänzt fedora-release (wird NICHT ersetzt):
#  - /usr/lib/os-release bekommt die Fenstra-Namen (ID bleibt "fedora")
#  - ein RPM-Dateitrigger wendet das nach jedem fedora-release-Update erneut an
#  - /etc/issue in Deutsch
# Warum kein eigenes fedora-release-identity-Paket: fedora-release-common verlangt
# "fedora-release-identity = <exakte Version-Release>". Ein Fremdpaket müsste bei
# jedem fedora-release-Update neu gebaut werden, sonst bricht das Update. Der
# Trigger-Weg übersteht Updates ohne Neubau.
Name:           fenstra-release
Version:        44.0
Release:        1%{?dist}
Summary:        Systemkennung für Fenstra (basiert auf Fedora Linux)
License:        MIT
URL:            https://github.com/Boermt-die-Buse/Fenstra
Source0:        os-release
Source1:        fenstra-apply-os-release
Source2:        issue
BuildArch:      noarch
Requires:       fedora-release-common
Requires:       fedora-release-kde-desktop
Requires(post): coreutils sed
Requires:       fenstra-logos

%description
Kennzeichnet das System als Fenstra: Name, Variante und Verweise in
/usr/lib/os-release sowie /etc/issue. Fenstra ist ein Fedora Remix; die
Kennung ID=fedora bleibt erhalten, damit Paketverwaltung und Installer wie
gewohnt arbeiten.

%prep
# keine Quellen zu entpacken

%build
# nichts zu bauen

%install
install -D -p -m 0644 %{SOURCE0} %{buildroot}%{_prefix}/lib/fenstra/os-release
install -D -p -m 0755 %{SOURCE1} %{buildroot}%{_libexecdir}/fenstra/apply-os-release
install -D -p -m 0644 %{SOURCE2} %{buildroot}%{_prefix}/lib/fenstra/issue

%post
%{_libexecdir}/fenstra/apply-os-release
# /etc/issue ist bei Fedora ein Symlink auf /usr/lib/issue (fedora-release-common).
# Wir ersetzen nur den Symlink durch unseren, keine Datei eines anderen Pakets.
if [ -L /etc/issue ]; then ln -sf ../usr/lib/fenstra/issue /etc/issue; fi

%transfiletriggerin -- /usr/lib/os-release
%{_libexecdir}/fenstra/apply-os-release

%files
%dir %{_prefix}/lib/fenstra
%{_prefix}/lib/fenstra/os-release
%{_prefix}/lib/fenstra/issue
%dir %{_libexecdir}/fenstra
%{_libexecdir}/fenstra/apply-os-release

%changelog
* Tue Sep 29 2026 Fenstra-Projekt - 44.0-1
- Erste Fassung: os-release per Dateitrigger, deutsches /etc/issue
