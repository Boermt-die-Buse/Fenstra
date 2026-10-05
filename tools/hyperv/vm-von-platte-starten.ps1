# Nach der Installation: VM sauber herunterfahren, ISO auswerfen, von der Festplatte starten.
#   vm-von-platte-starten.ps1 [-VM Name]
# Hinweis: Get-VMDvdDrive zeigt direkt danach manchmal noch den alten ISO-Pfad an;
# massgeblich ist die Bootreihenfolge (erster Eintrag muss die Festplatte sein).
param([string]$VM)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
Stop-VM -Name $name                      # sauberes Herunterfahren ueber die Gastdienste
Set-VMDvdDrive -VMName $name -Path $null
Set-VMFirmware -VMName $name -FirstBootDevice (Get-VMHardDiskDrive -VMName $name)
# erster Eintrag: "EFI SCSI Device" (Platte) oder "Fedora" (shim auf der Platte) sind beide richtig
$first = (Get-VMFirmware -VMName $name).BootOrder[0]
Start-VM -Name $name
"$name startet, erster Booteintrag: $($first.BootType) / $($first.Description)"
