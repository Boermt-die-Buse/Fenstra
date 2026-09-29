# Schritt 1: Was ich gelesen habe, und was davon machbar ist

## Kurzfassung

Fenstra soll ein Fedora-44-Remix mit KDE Plasma (Wayland) werden, der wie Windows 11 aussieht und sich so bedient, im Hintergrund aber ein normales Fedora mit Btrfs bleibt. Gebaut wird per Kickstart und `livemedia-creator --no-virt` in deiner WSL-Fedora. Danach kommen nacheinander Branding, Taskleiste/Startmenü, Explorer-artiger Dateimanager mit Laufwerksbuchstaben, Wiederherstellungspunkte mit Snapper, Wine-Integration, eine eigene Einstellungen-App und der Fenstra Store, jeweils mit Messung von Bootzeit, RAM und Flüssigkeit.

Der Großteil ist machbar. Was nicht geht, ist eine 1:1-Kopie von Windows-Interna (Registry, Windows Update, Defender, Microsoft Store, Windows-Treibermodell). Diese Dinge werden funktional nachgebaut und als Nachbau gekennzeichnet, nicht verschwiegen. Die Tabelle unten sagt für jeden Bereich, was geht.

Zwei Einschränkungen dieser Sitzung: Ich arbeite in einer Cloud-Umgebung ohne Zugriff auf deine WSL. Der ISO-Build muss deshalb bei dir laufen (`build/build-iso.sh`); ich habe alles vorbereitet und geprüft, was sich ohne Fedora-Paketquellen prüfen lässt. Und die Fedora-Server (pagure.io, mirrors.fedoraproject.org, docs) waren aus meiner Umgebung nicht erreichbar, deshalb konnte ich Paket- und Gruppennamen nicht live gegen Fedora 44 abgleichen. Der erste Build zeigt, ob alles aufgeht; Fehler dort sind schnell behoben.

## Machbarkeit nach Bereichen

| Bereich | Geht 1:1? | Was Fenstra stattdessen macht |
|---|---|---|
| Aussehen (zentrierte Taskleiste, Startmenü, Schnelleinstellungen, Benachrichtigungscenter, abgerundete Fenster, Animationen) | weitgehend | Plasma-Panel zentriert, eigenes Startmenü-Applet (Kickoff-Fork oder eigenes QML), eigenes Plasma-Theme, KWin-Regeln für Rundungen und Schatten |
| Mica/Blur | nur angenähert | KWin-Blur mit Transparenz und Farbüberlagerung. Echtes Mica (aus dem Wallpaper berechnetes Material) gibt es in KWin nicht; die Optik ist nah, der Mechanismus anders |
| Snap-Layouts | Nachbau | KWin-Kacheln plus KWin-Skript für das Layout-Popup beim Überfahren der Maximieren-Schaltfläche |
| Widgets-Bereich | Nachbau | Plasma-Widgets in einem ausklappbaren Panel |
| Schriften | nein (Segoe UI ist proprietär) | Selawik (OFL, von Microsoft als freier Segoe-Ersatz veröffentlicht), Cascadia Code (OFL) im Terminal, Noto als Fallback |
| Icons | nein (Windows-Icons proprietär) | Fluent UI System Icons (MIT), eigenes Fenstra-Icon-Theme |
| Registry | nein | Entfällt bewusst (Entscheidung vom 29.09.2026). Es gibt keine Registry; Einstellungen liegen in KDE-Konfigdateien (kconfig) und systemd. Kein Registrierungs-Editor, kein Nachbau |
| Windows Update | Nachbau | Fedora-Paketupdates und Flatpak-Updates hinter einer Oberfläche „Updates“. Vor jedem Update ein Wiederherstellungspunkt (Snapper). Es sind Fedora-Updates, keine Microsoft-Updates |
| Defender | nein | Fedora hat keinen Virenscanner. Standard-Schutz: SELinux (enforcing), Firewall firewalld (aktiv), signierte Pakete, Secure Boot, Flatpak-Sandbox, Firmware-Updates über fwupd. Fenstra zeigt das in einem Panel „Sicherheit“ ehrlich an. Einzig sinnvoller Scanner-Einsatz: ClamAV-Prüfung von .exe-Dateien vor dem Start über Wine, weil Wine Windows-Schadsoftware ausführen kann. Kein „Echtzeitschutz“-Versprechen |
| Microsoft Store | Nachbau | Fenstra Store mit kuratiertem Katalog (Flatpak, AppImage, RPM, .exe über Wine, Web-Apps) |
| Windows-Programme | teilweise | Wine/Proton mit Doppelklick auf .exe. Läuft: viele klassische Programme und Spiele. Läuft nicht oder eingeschränkt: Anti-Cheat-Spiele, Office 365 Desktop (Web-Version stattdessen), Adobe Creative Cloud, Programme mit Kernel-Treibern. Der Nutzer bekommt das vor der Installation gesagt |
| Treibermodell | nein | Treiber sind Kernel-Module (Mesa für AMD/Intel, NVIDIA aus RPM Fusion). Windows-Treiber (.inf/.sys) laufen nie. Secure Boot: Fedora-Kernel ist signiert; das NVIDIA-Modul braucht einmalig eine eigene Signatur (MOK-Enrollment mit Passwort beim Neustart) oder Secure Boot aus |
| Laufwerksbuchstaben | Darstellung | Im Dateimanager werden Einhängepunkte als C:, D: usw. angezeigt. Intern bleibt der Linux-Verzeichnisbaum |
| Ordnernamen (Dokumente, Bilder, Downloads, Desktop) | ja | Deutsche XDG-Benutzerordner; „Desktop“ statt „Schreibtisch“ wird gesetzt |
| Btrfs mit @ und @home | teilweise | Der grafische Installer (Anaconda) legt Btrfs mit Subvolumes an, nennt sie aber fest `root` und `home`. Die Namen sind nicht einstellbar. Funktional gleichwertig; für `@`/`@home` gibt es die Vorlage `kickstart/vorlage-autoinstall-btrfs.ks` (unbeaufsichtigte Installation) |
| Wiederherstellungspunkte | Nachbau | Snapper-Snapshots vor Updates, wöchentlich, manuell. Zurücksetzen nur des Systems, /home bleibt. Boot aus Snapshot über grub-btrfs (nicht in Fedora enthalten, wird als eigenes Paket gebaut) |
| Bootzeit < 15 s, RAM < 1,5 GB, 60 fps | realistisch, mit Messung | Fedora KDE liegt auf SSD-Hardware meist bei 8–15 s und 1,0–1,4 GB im Leerlauf. 60 fps sind auf echter Hardware normal; in VMs ohne GPU-Durchreichung (Hyper-V) ist Flüssigkeit nicht messbar |
| Secure Boot | ja | Fedora-Standardkernel mit shim, von Microsofts UEFI-CA signiert. Keine Drittanbieter-Kernel |

## Basis und Build-Weg

**Fedora 44 + KDE Plasma 6.6, Wayland-Sitzung** (F44 hat die X11-Sitzung im KDE-Spin bereits abgeschafft). Build über Kickstart und `livemedia-creator --no-virt`, so wie Fedora seine eigenen Spins baut.

Was in WSL anders ist als auf einem echten Fedora-Rechner, und wie das Kickstart damit umgeht:

1. **Kein SELinux im WSL-Kernel.** Anaconda kann die Dateien im Image nicht mit Sicherheitslabels versehen. Ein Image ohne Labels startet mit `enforcing` nicht sauber. Deshalb steht im Kickstart `selinux --permissive`. Das installierte System labelt sich beim ersten Start neu (`/.autorelabel`, ein automatischer Neustart) und schaltet dann auf `enforcing`. Sobald ein Build auf einem echten Fedora (VM) läuft, wird das wieder `enforcing`.
2. **Host- und Zielversion müssen gleich sein.** Deine WSL ist Fedora 44, das Ziel ist Fedora 44. Passt.
3. **Loop-Geräte und ext4-Image.** `--no-virt --make-iso` installiert in eine ext4-Datei, die per Loop eingehängt wird. Du hast Loop-Unterstützung bestätigt; `build/prepare-wsl.sh` testet es trotzdem.
4. **Bootloader im ISO.** lorax baut das ISO seit einigen Versionen mit GRUB2 für BIOS und UEFI (kein isolinux mehr). Dafür müssen `grub2-pc-modules`, `grub2-efi-x64-cdboot` und `shim-x64` im Image sein; das Kickstart listet sie ausdrücklich.
5. **Pflichtzeilen für `--no-virt`.** lorax verlangt eine `url`-Zeile als Installationsmethode, aktiviertes Netzwerk und genau eine `part /`-Zeile. Alles enthalten.

Falls der Build in WSL nicht bis zum ISO durchläuft, sind die Alternativen (in dieser Reihenfolge): Fedora-44-VM mit denselben Skripten (dann auch SELinux-Labels und `enforcing`), `mock`-Chroot auf der VM, oder ein Wechsel auf Kiwi bzw. OSBuild. Ein Wechsel auf bootc/Kinoite-Images wäre ein größerer Kurswechsel (siehe EU OS).

## EU OS als Grundlage?

**Was es ist:** Ein Proof of Concept (kein Produkt, kein EU-Projekt) für einen Fedora-basierten KDE-Desktop für den öffentlichen Sektor. Technisch ein Fedora-Kinoite/bootc-Image (unveränderliches Basissystem, Updates als Container-Images, atomares Zurückrollen), mit Schichten für Organisationen, Richtlinien und Flottenverwaltung. Aktiv (FOSDEM 2026, Online-Sprints, Matrix-Kanal).

**Dafür spricht:** gleiche Basis (Fedora + KDE), sehr zuverlässige Updates mit automatischem Rückfall (das ist näher an „Windows Update, das nie kaputtgeht“ als ein normales Paketsystem), sauberer Containerfile-Build, gute Dokumentation.

**Dagegen spricht für Fenstra:** Das unveränderliche bootc-Modell passt schlecht zu deinen Anforderungen: RPMs und Wine-Programme aus dem Store zu installieren bedeutet dort „Layering“ mit Neustart, Snapper-Wiederherstellungspunkte haben in diesem Modell keinen Platz (bootc rollt Deployments zurück, nicht /etc- und /var-Zustände nach Wahl), und der Fokus von EU OS liegt auf Absperren und Verwalten von Behördenrechnern, nicht auf einem Windows-artigen Heimdesktop. Es ist außerdem noch PoC-Stand.

**Empfehlung:** Nicht als Grundlage. Ideen übernehmen: Build als reproduzierbare Pipeline, KDE-Vorgaben zentral verwalten. Falls Fenstra später ein „Updates gehen nie kaputt“-Modell braucht, ist bootc der Weg dahin, aber als bewusster zweiter Schritt, nicht als Start.

## Namensprüfung „Fenstra“

Das habe ich gefunden (Web-Recherche; die Markenregister EUIPO/TMview, DPMAregister und Swissreg waren aus meiner Umgebung nicht erreichbar, siehe unten):

| Treffer | Was | Relevanz für ein Betriebssystem |
|---|---|---|
| Fenstra AG, Aarburg (Schweiz) | Fensterbau/Innenausbau seit 1988; laut Moneyhouse 2 Schweizer Marken im IGE-Register | Andere Branche (Bau, Klassen 6/19/37 zu erwarten, nicht 9/42). Geringes Risiko, aber existierende Marke mit identischem Wort |
| Fenstra (Ålesund, Norwegen) | PVC-Fenster, fenstra.no, Facebook-Seite | Andere Branche, geringes Risiko |
| FENSTRA LTD (England) | gegründet Juli 2026, Handelsvertretung/Engineering | Frisch, Branche unklar |
| „Fenstra“ auf LinkedIn | Firmenseite | unklar |
| Fenestra (US-Softwarefirma: Buchung/Abrechnung), fenestra.app (KI-Rendering), WerWolv/Fenestra (ImGui-UI-Framework, GPLv2) | Software mit fast gleichem Namen | Verwechslungsgefahr im Softwarebereich ist der eigentliche Punkt. Ein Markenamt könnte „Fenstra“ und „Fenestra“ für Software als ähnlich einstufen |
| Linux-Distribution oder OS namens Fenstra | keine gefunden | frei |
| fenstra.de | steht zum Verkauf (Domain-Parking) | kaufbar, Preis unbekannt |
| fenstra.com / .org / .io / .app / .dev | konnte ich nicht prüfen (kein Zugriff aus meiner Umgebung) | bitte selbst nachsehen |

**Einschätzung:** Für deine private Testumgebung ist der Name unproblematisch. Für eine Veröffentlichung gilt: keine Kollision mit einem Betriebssystem, aber „Fenstra“ ist als Firmenname mehrfach vergeben (Fensterbau) und „Fenestra“ existiert im Softwarebereich. Wenn du später veröffentlichen willst, vorher selbst prüfen: TMview (tmdn.org) und DPMAregister nach „Fenstra“ und „Fenestra“ in den Klassen 9 und 42, plus Domain-Verfügbarkeit. Ich kann dir bei Bedarf Alternativnamen mit demselben Wortspiel vorschlagen. Bis dahin bleibt Fenstra der Arbeitsname.

Quellen: [Companies House: FENSTRA LTD](https://find-and-update.company-information.service.gov.uk/company/17345424), [Moneyhouse: Fenstra AG](https://www.moneyhouse.ch/en/company/fenstra-ag-4005920231), [LinkedIn: Fenstra](https://www.linkedin.com/company/fenstra), [Facebook: fenstra.no](https://www.facebook.com/fenstra.no/), [fenstra.de (zum Verkauf)](http://fenstra.de/), [Crunchbase: Fenestra](https://www.crunchbase.com/organization/fenestra), [fenestra.app](https://www.fenestra.app/termsandconditions), [GitHub: WerWolv/Fenestra](https://github.com/WerWolv/Fenestra), [EU OS](https://eu-os.eu/), [EU OS PoC](https://eu-os.eu/poc/), [EU OS FAQ](https://eu-os.eu/faq/), [The Register über EU OS](https://www.theregister.com/software/2025/03/25/eu-os-aims-to-free-the-european-public-sector-desktop/654372), [Fedora Remix](https://fedoraproject.org/wiki/Remix), [generic-logos](https://packages.fedoraproject.org/pkgs/generic-logos/generic-logos/), [Fedora 44 KDE](https://fedoraproject.org/kde/download/), [Fedora 44 Beta: livesys-scripts](https://www.gamingonlinux.com/2026/03/fedora-44-beta-is-out-with-kde-improvements-better-live-media-and-more/), [Snapper + grub-btrfs auf Fedora 44](https://github.com/SysGuides/sysguides-snapper-fedora), [livemedia-creator-Dokumentation](https://github.com/weldr/lorax/blob/master/docs/livemedia-creator.rst).

## Fedora-Remix-Regeln (für Branding relevant)

Ein Fedora Remix darf die Fedora-Marken nicht als eigene verwenden. Konkret: `fedora-logos`, `fedora-release` und `fedora-release-notes` werden durch eigene Pakete ersetzt (`fenstra-logos`, `fenstra-release`; Fedora liefert als Vorlage `generic-logos` und `generic-release`). „Fedora Remix“ darf als Hinweis benutzt werden, „Fedora“ nicht als Teil des Produktnamens. Build #1 setzt die sichtbaren Namen nur als Platzhalter in `/usr/lib/os-release`; das richtige Paket kommt im Baustein Branding.
