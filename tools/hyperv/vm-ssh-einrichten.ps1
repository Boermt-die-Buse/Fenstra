# SSH-Zugang vom Windows-PC in eine installierte, angemeldete Fenstra-VM einrichten.
#   vm-ssh-einrichten.ps1 -Passwort <Passwort des Testbenutzers> [-VM Name] [-Schluessel ~\.ssh\fenstra-vm.pub]
# Voraussetzung: Benutzer ist am Desktop angemeldet, kein Fenster im Vordergrund, das Tasten abfaengt.
# Ablauf: Konsole oeffnen (Strg+Alt+T), oeffentlichen Schluessel in ~/.ssh/authorized_keys,
# sshd aktivieren (sudo fragt nach dem Passwort), danach IP ausgeben.
# Danach: ssh -i ~\.ssh\fenstra-vm -o UserKnownHostsFile=~\.ssh\known_hosts_<vm> daniel@<IP>
# Das Passwort steht nur in diesem Aufruf, nie im Repo.
param(
    [Parameter(Mandatory)][string]$Passwort,
    [string]$VM,
    [string]$Schluessel = (Join-Path $env:USERPROFILE '.ssh\fenstra-vm.pub')
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
if (-not (Test-Path $Schluessel)) {
    throw "Schluessel fehlt: $Schluessel. Erzeugen mit: ssh-keygen -t ed25519 -N '' -C fenstra-vm -f $($Schluessel -replace '\.pub$','')"
}
$pub = (Get-Content $Schluessel -Raw).Trim()
$in = "$PSScriptRoot\vm-input.ps1"

& $in combo 17 18 84 -VM $name; Start-Sleep 3
& $in text "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pub' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && sudo systemctl enable --now sshd; clear" -VM $name
& $in key 13 -VM $name; Start-Sleep 2
& $in text $Passwort -VM $name
& $in key 13 -VM $name; Start-Sleep 4
& "$PSScriptRoot\vm-ip.ps1" -VM $name
