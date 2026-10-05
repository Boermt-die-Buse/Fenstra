# Befehl per SSH in der Fenstra-Test-VM ausfuehren (Benutzer daniel).
#   vm-ssh.ps1 'kscreen-doctor -o'             einzelner Befehl
#   vm-ssh.ps1 -Script datei.sh                Skriptdatei (Windows-Pfad) in der VM ausfuehren
#   'echo hallo' | vm-ssh.ps1 -Stdin           Befehle von der Standardeingabe (Here-String)
#   ... -VM Fenstra-Test5 -User daniel
# Die IP wird ueber vm-ip.ps1 ermittelt und in %TEMP%\fenstra-vm-ip-<VM>.txt zwischengespeichert;
# schlaegt die Verbindung fehl, wird sie neu ermittelt. Die Sitzungsumgebung (DBUS, WAYLAND)
# setzt ~/.bashrc.d/fenstra-ssh-env.sh in der VM (tools/vm/fenstra-ssh-env.sh).
param(
    [Parameter(Position = 0)][string]$Command,
    [string]$Script,
    [switch]$Stdin,
    [string]$VM,
    [string]$User = 'daniel',
    [Parameter(ValueFromPipeline)][string[]]$InputLines
)
begin { $lines = New-Object System.Collections.Generic.List[string] }
process { if ($InputLines) { $lines.AddRange($InputLines) } }
end {
    $ErrorActionPreference = 'Stop'
    . "$PSScriptRoot\_vm.ps1"
    $name = Resolve-FenstraVm $VM
    $ip = Get-FenstraVmIp $name
    $sshArgs = Get-FenstraSshArgs
    if ($Script) {
        $text = (Get-Content -Raw $Script) -replace "`r`n", "`n"
    } elseif ($Stdin -or $lines.Count -gt 0) {
        $text = ($lines -join "`n") -replace "`r`n", "`n"
    } else {
        $text = $Command
    }
    # Skript ueber stdin an bash geben (keine Quoting-Probleme mit PowerShell)
    $text | & ssh @sshArgs "$User@$ip" "tr -d '\r' | bash -s"
    $code = $LASTEXITCODE
    if ($code -eq 255) {
        # Verbindung gescheitert: IP neu bestimmen und noch einmal
        $ip = Get-FenstraVmIp $name -Refresh
        $text | & ssh @sshArgs "$User@$ip" "tr -d '\r' | bash -s"
        $code = $LASTEXITCODE
    }
    exit $code
}
