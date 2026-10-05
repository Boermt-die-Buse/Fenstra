# Entwicklungs-Schleife: einen CMake-Build aus WSL direkt in die Test-VM installieren (ohne RPM).
#   vm-dev.ps1 -Build /var/lib/fenstra-build/cmake-style [-Nach 'qdbus-qt6 org.kde.KWin /KWin reconfigure']
# Ablauf: in WSL "cmake --build" + "cmake --install" nach DESTDIR, als tar.gz in die VM,
# dort mit sudo nach / entpacken, danach optional einen Befehl in der Sitzung ausfuehren.
# Nur fuer die Test-VM! Das Paket (RPM) bleibt der saubere Weg; vm-rpm.ps1 ueberschreibt
# diese Dateien wieder. Passwort aus $env:FENSTRA_VM_PW oder Abfrage.
#   -KWin   danach kwin_wayland neu starten: KWin laedt Dekorations-/Effekt-Plugins nur beim
#           Start (ein neues .so auf der Platte wirkt sonst nicht). Die Sitzung bleibt,
#           offene Programme werden dabei beendet (kein Wayland-Reconnect).
param(
    [Parameter(Mandatory)][string]$Build,
    [string]$Nach,
    [switch]$KWin,
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
$ip = Get-FenstraVmIp $name
$sshArgs = Get-FenstraSshArgs
$pw = $env:FENSTRA_VM_PW
if (-not $pw) { $pw = Read-Host -Prompt 'sudo-Passwort des Testbenutzers' }

$tarWin = Join-Path $env:TEMP 'fenstra-dev-stage.tar.gz'
$tarWsl = '/mnt/c/Users/' + $env:USERNAME + '/AppData/Local/Temp/fenstra-dev-stage.tar.gz'
$script = @"
set -e
cmake --build '$Build' 2>&1 | grep -E 'error|FAILED' && exit 1
rm -rf /tmp/fenstra-stage
DESTDIR=/tmp/fenstra-stage cmake --install '$Build' > /tmp/fenstra-stage.log
tar -C /tmp/fenstra-stage -czf '$tarWsl' .
find /tmp/fenstra-stage -type f -printf '  /%P\n'
"@
$script -replace "`r", '' | wsl -d FedoraLinux-44 -u root -- bash -s
if ($LASTEXITCODE -ne 0) { throw "Build/Install in WSL fehlgeschlagen" }
& scp @sshArgs -q $tarWin "daniel@${ip}:/tmp/fenstra-dev-stage.tar.gz"
$pw | & ssh @sshArgs "daniel@$ip" "sudo -S -p '' tar -C / --no-same-owner -xzf /tmp/fenstra-dev-stage.tar.gz && echo 'in der VM installiert'"
if ($KWin) {
    & "$PSScriptRoot\vm-ssh.ps1" -VM $name 'kill -9 $(pgrep -x kwin_wayland) 2>/dev/null; for i in $(seq 1 30); do sleep 0.5; pgrep -x plasmashell >/dev/null && pgrep -x kwin_wayland >/dev/null && break; done; sleep 3; echo "KWin neu gestartet"'
}
if ($Nach) { & "$PSScriptRoot\vm-ssh.ps1" -VM $name $Nach }
