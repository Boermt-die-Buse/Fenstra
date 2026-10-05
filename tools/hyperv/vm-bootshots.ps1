# Bildschirmfotos in kurzen Abstaenden, z. B. um den Bootscreen (Plymouth) zu erwischen.
#   vm-bootshots.ps1 [-Count 60] [-IntervalMs 400] [-OutDir ordner] [-VM Name]
# Erst den Neustart ausloesen, dann sofort starten. Bilder: boot-00.png, boot-01.png, ...
# Erfahrung: mit 1 s Abstand wurde der Fenstra-Bootscreen verpasst, mit 0,4 s nicht.
param(
    [int]$Count = 60,
    [int]$IntervalMs = 400,
    [string]$OutDir = (Join-Path $env:TEMP 'fenstra-boot'),
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
New-Item -ItemType Directory -Force $OutDir | Out-Null
for ($i = 0; $i -lt $Count; $i++) {
    # einzelne Fehlversuche (VM gerade im Neustart) ueberspringen
    try { & "$PSScriptRoot\vm-screenshot.ps1" -VM $name -Out (Join-Path $OutDir ('boot-{0:d2}.png' -f $i)) | Out-Null } catch { }
    Start-Sleep -Milliseconds $IntervalMs
}
$OutDir
