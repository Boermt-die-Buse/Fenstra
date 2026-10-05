# Prüfliste M1 (docs/checkliste-stil.md): Zustände im Stiltest herstellen, Bildschirmfotos
# speichern (docs/bilder/m1) und Pixelwerte ausgeben. Voraussetzung: Stiltest läuft bei
# (460,150) (tools/vm/fenster-setzen.sh), helles Farbschema.
param([string]$Bilder = 'C:\Users\Daniel\Fenstra\ws\docs\bilder\m1')
$ErrorActionPreference = 'Continue'
$h = Join-Path $PSScriptRoot '..\hyperv'
$px = '/mnt/c/Users/Daniel/Fenstra/ws/tools/pruefen/pixel.py'
New-Item -ItemType Directory -Force $Bilder | Out-Null
function wslpath([string]$p) { '/mnt/c' + ($p.Substring(2) -replace '\\', '/') }
function P([string]$bild) { $args2 = $args; wsl -d FedoraLinux-44 -u root -- python3 $px (wslpath $bild) @args2 }
function Foto([string]$name, [string]$region = '') {
    $f = Join-Path $Bilder "$name.png"
    if ($region) { & $h\vm-gastfoto.ps1 -Out $f -Region $region -Warten 0.4 | Out-Null } else { & $h\vm-gastfoto.ps1 -Out $f -Warten 0.4 | Out-Null }
    return $f
}

& $h\vm-input.ps1 move 900 1000; Start-Sleep 1
$ruhe = Foto 'stiltest-hell'
"== S1 Schaltfläche (Spalte x=500): erwartet Höhe 32, Fläche #FBFBFB, Rand oben #E5E5E5"
P $ruhe col 500 230 272
"== S3 Standardschaltfläche x=640: erwartet #0067C0"
P $ruhe at 640 250
"== S4 Eingabefeld (x=600): Unterkante 1 px kräftig"
P $ruhe col 600 278 320
"== S8 Kontrollkästchen leer (Zeile y=394): 20 px, Rand"
P $ruhe row 394 480 520
"== S9 Optionsfeld an (Zeile y=394, x 696..724): Akzentring, Punkt 12"
P $ruhe row 394 696 726
"== S10 Schieberegler (Spalte durch Daumen und Spur)"
P $ruhe col 588 490 525
P $ruhe col 520 500 512
"== S11 Fortschritt (Spalte x=520 und x=700)"
P $ruhe col 520 538 552
P $ruhe col 700 538 552
"== S17 Liste: Auswahl Dokumente (Zeile y=297)"
P $ruhe row 297 958 1000
"== F1 Fenster/Ansicht"
P $ruhe at 900 700
P $ruhe at 1100 760

# Hover-Zustände
& $h\vm-input.ps1 move 543 250; Start-Sleep -Milliseconds 600
$hov = Foto 'knopf-hover' '470,220,420,60'
"== S2 Schaltfläche Hover (erwartet ≈ #F6F6F6)"
P $hov at 20 30
& $h\vm-input.ps1 move 900 196; Start-Sleep -Milliseconds 300
& $h\vm-input.ps1 move 900 1000; Start-Sleep -Milliseconds 300

# Fokus über Tastatur (Tab) auf die erste Schaltfläche, dann ins Eingabefeld
& $h\vm-input.ps1 click 600 299; Start-Sleep -Milliseconds 300
$fokus = Foto 'feld-fokus' '470,270,470,60'
"== S5 Eingabefeld mit Fokus: Fläche #FFFFFF, Unterkante 2 px Akzent"
P $fokus col 130 10 46
& $h\vm-input.ps1 combo 16 9; Start-Sleep -Milliseconds 300
& $h\vm-input.ps1 combo 16 9; Start-Sleep -Milliseconds 300
$fring = Foto 'fokusrahmen' '470,220,420,60'
"== S22 Fokusrahmen (Tastatur): außen 2 px dunkel, innen 1 px hell"
P $fring row 30 0 60

# Menü
& $h\vm-input.ps1 click 486 197; Start-Sleep -Milliseconds 700
& $h\vm-input.ps1 move 560 280; Start-Sleep -Milliseconds 600
$menu = Foto 'menue-hell' '455,180,440,440'
& $h\vm-input.ps1 key 27; Start-Sleep -Milliseconds 300
"== S14 Menü: Spalte x=200 im Ausschnitt (Rand, Einträge)"
P $menu col 200 0 120

# Tooltip über der Schaltfläche (Stiltest setzt Tooltips)
& $h\vm-input.ps1 move 543 250; Start-Sleep -Milliseconds 2500
$tip = Foto 'tooltip-hell' '470,220,420,120'
& $h\vm-input.ps1 move 900 1000

# Dekoration: Hover Minimieren/Schließen
& $h\vm-input.ps1 move 1345 166; Start-Sleep -Milliseconds 600
Foto 'deko-hover-min' '1280,145,190,45' | Out-Null
& $h\vm-input.ps1 move 1437 166; Start-Sleep -Milliseconds 1800
Foto 'deko-hover-schliessen' '1280,145,190,80' | Out-Null
& $h\vm-input.ps1 move 900 1000
"Bilder: $Bilder"
