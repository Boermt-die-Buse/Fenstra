# Bildschirmfoto in voller Gastaufloesung (Spectacle in der laufenden Sitzung, per SSH) holen.
#   vm-gastfoto.ps1 -Out C:\pfad\bild.png [-Region 'X,Y,B,H'] [-Fenster] [-Warten 1]
# Im Gegensatz zu vm-screenshot.ps1 (Hyper-V-Vorschaubild, RGB565, max. 1600x1200)
# ist das Bild pixelgenau (RGBA, 1920x1080) und taugt fuer 1-px-Vergleiche.
# Voraussetzung in der VM: ~/.local/bin/fenstra-shot.sh (tools/vm/fenstra-shot.sh).
param(
    [Parameter(Mandatory)][string]$Out,
    [string]$Region,
    [switch]$Fenster,
    [double]$Warten = 0.3,
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
$ip = Get-FenstraVmIp $name
$sshArgs = Get-FenstraSshArgs
$remote = '/tmp/fenstra-gastfoto.png'
$opts = "--warten $Warten"
if ($Region) { $opts += " --region $Region" }
if ($Fenster) { $opts += ' --fenster' }
& ssh @sshArgs "daniel@$ip" "~/.local/bin/fenstra-shot.sh $remote $opts" | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Bildschirmfoto in der VM fehlgeschlagen ($LASTEXITCODE)" }
$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
& scp @sshArgs -q "daniel@${ip}:$remote" $Out
if ($LASTEXITCODE -ne 0) { throw "scp fehlgeschlagen ($LASTEXITCODE)" }
$Out
