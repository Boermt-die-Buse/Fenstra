# IPv4-Adresse einer laufenden VM ausgeben (aus den Hyper-V-Gastdiensten, hypervkvpd).
#   vm-ip.ps1 [-VM Name]
# Die Adresse aus dem "Default Switch" wechselt nach jedem Neustart der VM oder des PCs.
param([string]$VM)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
$ip = (Get-VMNetworkAdapter -VMName $name).IPAddresses | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
if (-not $ip) { throw "Keine IPv4-Adresse fuer '$name' (VM noch nicht hochgefahren?)" }
$ip
