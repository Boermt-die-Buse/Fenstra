# Frisch gebaute Fenstra-RPMs in die Test-VM einspielen (dnf install der neuesten Version).
#   vm-rpm.ps1 fenstra-release fenstra-style          Pakete nach Name
#   vm-rpm.ps1 fenstra-theme -Reinstall                gleiche Version erneut installieren
# Quelle: lokale Paketquelle in WSL (/var/lib/fenstra-build/repo, erzeugt von
# build/build-packages.sh). Das sudo-Passwort des Testbenutzers wird abgefragt oder aus
# $env:FENSTRA_VM_PW gelesen (nie ins Repo schreiben).
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)][string[]]$Pakete,
    [switch]$Reinstall,
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
$ip = Get-FenstraVmIp $name
$sshArgs = Get-FenstraSshArgs
$pw = $env:FENSTRA_VM_PW
if (-not $pw) { $pw = Read-Host -Prompt 'sudo-Passwort des Testbenutzers' }

$repo = '\\wsl.localhost\FedoraLinux-44\var\lib\fenstra-build\repo'
$dateien = @()
foreach ($p in $Pakete) {
    # neueste Datei "<name>-<version>-<release>.<arch>.rpm" (ohne Unterpakete mit laengerem Namen)
    $f = Get-ChildItem $repo -Filter "$p-*.rpm" |
         Where-Object { $_.Name -match ("^" + [regex]::Escape($p) + "-\d") } |
         Sort-Object LastWriteTime | Select-Object -Last 1
    if (-not $f) { throw "Kein RPM fuer '$p' in $repo" }
    $dateien += $f.FullName
}
$ziel = '/tmp/fenstra-rpms'
& ssh @sshArgs "daniel@$ip" "rm -rf $ziel; mkdir -p $ziel" | Out-Null
& scp @sshArgs -q @dateien "daniel@${ip}:$ziel/"
if ($LASTEXITCODE -ne 0) { throw "scp fehlgeschlagen" }
$cmd = if ($Reinstall) { 'reinstall' } else { 'install' }
$pw | & ssh @sshArgs "daniel@$ip" "sudo -S -p '' dnf -y -q $cmd $ziel/*.rpm 2>&1 | tail -5; rpm -q $($Pakete -join ' ')"
