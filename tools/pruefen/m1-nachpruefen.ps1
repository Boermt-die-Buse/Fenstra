# Prüfliste M1: restliche Zustände (gedrückt, Listen-Popup, Werkzeugknopf, Plasma-Tooltip, Baumzeilen)
param([string]$Bilder = 'C:\Users\Daniel\Fenstra\ws\docs\bilder\m1')
$ErrorActionPreference = 'Continue'
$h = Join-Path $PSScriptRoot '..\hyperv'
$px = '/mnt/c/Users/Daniel/Fenstra/ws/tools/pruefen/pixel.py'
function wslpath([string]$p) { '/mnt/c' + ($p.Substring(2) -replace '\\', '/') }
function P([string]$bild) { $args2 = $args; wsl -d FedoraLinux-44 -u root -- python3 $px (wslpath $bild) @args2 }
function Foto([string]$name, [string]$region = '') {
    $f = Join-Path $Bilder "$name.png"
    if ($region) { & $h\vm-gastfoto.ps1 -Out $f -Region $region -Warten 0.4 | Out-Null } else { & $h\vm-gastfoto.ps1 -Out $f -Warten 0.4 | Out-Null }
    return $f
}
& $h\vm-ssh.ps1 'pkill -f stiltest.py; sleep 0.5; (setsid python3 ~/.local/bin/stiltest.py >/tmp/stiltest.log 2>&1 &); sleep 3; ~/.local/bin/fenster-setzen.sh "Fenstra Stiltest" 460 150'
& $h\vm-input.ps1 move 900 1000; Start-Sleep 1

$baum = Foto 'baum' '1195,230,250,140'
"== S18 Baumzeilen (Spalte x=60): Zeilenhöhe"
P $baum col 60 0 139 --tol 1

# D6: Schließen gedrückt halten, dann wegziehen und loslassen (kein Schließen)
& $h\vm-input.ps1 down 1437 166; Start-Sleep -Milliseconds 500
$gedr = Foto 'deko-schliessen-gedrueckt' '1400,148,62,36'
& $h\vm-input.ps1 move 1300 400; Start-Sleep -Milliseconds 200
& $h\vm-input.ps1 up
"== D6 Schließen gedrückt: Fläche (erwartet ≈ 90 % #C42B1C) und Glyphe"
P $gedr box 0 0 62 36

# S20: Werkzeugknopf Hover
& $h\vm-input.ps1 move 900 250; Start-Sleep -Milliseconds 700
$wk = Foto 'werkzeugknopf-hover' '870,226,60,48'
"== S20 Werkzeugknopf Hover"
P $wk box 0 0 60 48
& $h\vm-input.ps1 move 900 1000

# S7: Kombinationsfeld-Liste
& $h\vm-input.ps1 click 610 347; Start-Sleep -Milliseconds 900
$cb = Foto 'combo-liste' '470,280,300,200'
& $h\vm-input.ps1 key 27

# P3: Plasma-Tooltip über dem Firefox-Knopf
& $h\vm-input.ps1 move 1000 1058; Start-Sleep -Milliseconds 2500
$pt = Foto 'plasma-tooltip' '840,900,340,180'
& $h\vm-input.ps1 move 900 600
"Bilder: $Bilder"
