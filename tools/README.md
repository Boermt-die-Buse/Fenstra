# Werkzeuge für den VM-Test

Hilfsmittel, mit denen Fenstra-Builds in Hyper-V installiert, ferngesteuert und geprüft
werden, ohne dass jemand an der VM sitzt. Entstanden beim Test der Builds #2–#5
(Oktober 2026).

| Ordner | Läuft auf | Inhalt |
|---|---|---|
| `hyperv/` | Windows-PC, PowerShell **als Administrator** | VM anlegen, Bildschirmfoto, Maus/Tastatur, IP, SSH einrichten |
| `vm/` | in der Test-VM (als Testbenutzer, z. B. über SSH) | Plasmoid einspielen, Testsitzung vorbereiten |

## Auf den Windows-PC holen

Das Repo liegt in WSL unter `/root/Fenstra`; Windows hat darauf keinen Lesezugriff. Die
Windows-Werkzeuge deshalb in einen Arbeitsordner kopieren (nach jeder Änderung erneut):

```
wsl -d FedoraLinux-44 -u root -- cp -r /root/Fenstra/tools/hyperv /mnt/c/Users/Daniel/Fenstra/tools/
```

Aufruf dann aus `C:\Users\Daniel\Fenstra\tools\hyperv\`. Die Skripte sind reines ASCII,
damit Windows PowerShell 5 sie ohne BOM richtig liest.

## Ablauf eines VM-Tests

1. ISO bauen (`build/build-iso.sh`) und nach Windows kopieren:
   `wsl -d FedoraLinux-44 -u root -- cp /var/lib/fenstra-build/out/<stempel>/*.iso /mnt/c/Users/Daniel/Fenstra/`
   und die Prüfsumme vergleichen (`Get-FileHash`).
2. VM anlegen und starten: `.\neue-vm.ps1 -Name Fenstra-TestN -Iso <pfad> -Start`
3. Live-System abwarten (GRUB wartet 60 s), Installer per Klick/Tasten bedienen
   (`vm-input.ps1`, Kontrolle mit `vm-screenshot.ps1`).
4. Nach „Erfolgreich installiert“: `.\vm-von-platte-starten.ps1`
5. Plasma Setup durchklicken, Benutzer anlegen, anmelden.
6. `.\vm-ssh-einrichten.ps1 -Passwort <pw>` → gibt die IP aus. Danach
   `ssh -i ~\.ssh\fenstra-vm -o UserKnownHostsFile=~\.ssh\known_hosts_<vm> daniel@<IP>`.
7. Messung: Neustart, anmelden, 2 min Leerlauf, `fenstra-baseline ~/baseline.txt` in der
   Konsole (nicht über SSH, sonst fehlt die Sitzungsart), Datei per `scp` holen, nach
   `messungen/` legen.

Mehrere laufende Fenstra-VMs: `-VM <Name>` angeben oder `$env:FENSTRA_VM = 'Fenstra-TestN'`.
Mit genau einer laufenden Fenstra-VM wird sie automatisch gewählt.

## hyperv/

| Skript | Zweck |
|---|---|
| `neue-vm.ps1` | VM mit Fenstra-Standardausstattung anlegen (Gen 2, 8 GB, 4 CPUs, 60 GB, Secure Boot MS-UEFI-CA) |
| `vm-screenshot.ps1` | Bildschirmfoto als PNG (Standard `%TEMP%\fenstra-vm.png`) |
| `vm-input.ps1` | `click X Y [right]`, `dclick`, `move`, `text "…"`, `key <code>`, `combo <codes>` |
| `vm-bootshots.ps1` | Bildserie alle 0,4 s (Bootscreen erwischen) |
| `vm-ip.ps1` | aktuelle IPv4 der VM |
| `vm-von-platte-starten.ps1` | herunterfahren, ISO auswerfen, von Platte starten |
| `vm-ssh-einrichten.ps1` | Schlüssel hinterlegen und sshd einschalten (über Tastatureingaben in der Konsole) |

Tastencodes: 8 Rücktaste, 9 Tab, 13 Enter, 27 Esc, 32 Leertaste, 37–40 Pfeile, 91 Windows-Taste;
Kombination Strg+Alt+T = `combo 17 18 84`, Alt+F4 = `combo 18 115`.

## vm/

| Skript | Zweck |
|---|---|
| `plasmoid-deploy.sh <dir> [--layout]` | Plasmoid für den Benutzer installieren, plasmashell neu laden, QML-Fehler zeigen; `--layout` baut die Taskleiste aus dem Design neu auf (frische Applets) |
| `testsitzung.sh` | automatisches Sperren und Bildschirm-Aus für den Testbenutzer abschalten |

Hinbringen: `scp -r tools/vm <plasmoid-ordner> daniel@<IP>:/tmp/` (von Windows aus mit
denselben `-i`/`-o`-Optionen wie bei ssh).

## Erfahrungen (Stolpersteine)

- **Maus:** Koordinaten sind Gastpixel (1024×768). Ist ein vmconnect-Fenster offen und wird
  dort die Maus bewegt, landen Klicks falsch → vmconnect-Fenster nicht anfassen.
- **Tastatur:** Hyper-V sendet US-Scancodes, der Gast hat DE-Belegung. `vm-input.ps1 text`
  rechnet um (y/z, Sonderzeichen, AltGr = rechte Alt-Taste, `<>|` nur per Scancode 0x56).
  Umlaute werden nicht unterstützt. Die WMI-Methode `TypeText` kommt im Gast nicht an.
- **Qt-Knöpfe** lösen mit der Leertaste aus, nicht immer mit Enter; Tab-Fokus kann auf
  „Neu starten“ landen – vor dem Bestätigen ein Bildschirmfoto machen.
- **Bildschirmfotos** zeigen den Zustand ohne Zeiger-Animation; der Bootscreen ist nur mit
  kurzen Abständen (≤ 0,4 s) zu sehen.
- **Kein Grafikchip in Hyper-V** (llvmpipe): Unschärfe-Effekte und Bildrate sind dort nicht
  aussagekräftig.
- **IP** wechselt nach jedem Neustart → `vm-ip.ps1`.
- **plasmashell** nach QML-Änderungen neu starten; nach mehreren schnellen Neustarts
  `systemctl --user reset-failed plasma-plasmashell.service` (macht `plasmoid-deploy.sh`).
- **Sperrbildschirm** nach einigen Minuten Leerlauf → `testsitzung.sh`.
- Das **Passwort** des Testbenutzers gehört nicht ins Repo.
