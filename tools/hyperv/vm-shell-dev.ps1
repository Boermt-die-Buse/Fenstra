# Entwicklungsstand der Fenstra-Shell (QML-Modul, Taskleisten-Plasmoids, KWin-Skripte) ohne
# RPM in die Test-VM bringen und plasmashell neu starten (tools/vm/fenstra-dev.sh).
#   vm-shell-dev.ps1                  alles (Modul + Plasmoids + KWin-Skripte)
#   vm-shell-dev.ps1 -Nur modul,taskbar,infobereich,kwin
#   vm-shell-dev.ps1 -Aufraeumen      Benutzerkopien entfernen (zurueck zum RPM-Stand)
# sudo-Passwort aus $env:FENSTRA_VM_PW (nie ins Repo schreiben).
param(
    [string[]]$Nur = @('modul', 'taskbar', 'infobereich', 'kwin'),
    [switch]$Aufraeumen,
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
$ip = Get-FenstraVmIp $name
$sshArgs = Get-FenstraSshArgs
$ws = Resolve-Path "$PSScriptRoot\..\.."
$ziel = '/tmp/fenstra-dev'

& scp @sshArgs -q "$ws\tools\vm\fenstra-dev.sh" "daniel@${ip}:/tmp/fenstra-dev.sh"
if ($Aufraeumen) {
    & ssh @sshArgs "daniel@$ip" "tr -d '\r' < /tmp/fenstra-dev.sh > /tmp/fd.sh; bash /tmp/fd.sh --aufraeumen"
    exit $LASTEXITCODE
}
$pw = $env:FENSTRA_VM_PW
if (-not $pw) { $pw = Read-Host -Prompt 'sudo-Passwort des Testbenutzers' }

& ssh @sshArgs "daniel@$ip" "rm -rf $ziel; mkdir -p $ziel/qml/org/fenstra $ziel/plasmoids $ziel/kwin" | Out-Null
if ($Nur -contains 'modul') {
    & scp @sshArgs -q -r "$ws\packages\fenstra-shell\src\qml\org\fenstra\shell" "daniel@${ip}:$ziel/qml/org/fenstra/"
}
foreach ($p in @('taskbar', 'infobereich')) {
    if ($Nur -contains $p) {
        & scp @sshArgs -q -r "$ws\packages\fenstra-theme\src\plasmoids\org.fenstra.$p" "daniel@${ip}:$ziel/plasmoids/"
    }
}
if ($Nur -contains 'kwin' -and (Test-Path "$ws\packages\fenstra-theme\src\kwin")) {
    Get-ChildItem "$ws\packages\fenstra-theme\src\kwin" -Directory | ForEach-Object {
        & scp @sshArgs -q -r $_.FullName "daniel@${ip}:$ziel/kwin/"
    }
}
$pw | & ssh @sshArgs "daniel@$ip" "tr -d '\r' < /tmp/fenstra-dev.sh > /tmp/fd.sh; bash /tmp/fd.sh $ziel"
exit $LASTEXITCODE
