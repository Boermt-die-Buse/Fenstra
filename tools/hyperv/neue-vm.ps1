# Test-VM fuer ein Fenstra-ISO anlegen (Hyper-V, als Administrator).
#   neue-vm.ps1 -Name Fenstra-Test6 -Iso C:\Users\Daniel\Fenstra\Fenstra-44-x86_64-<stempel>.iso [-Start]
# Ausstattung wie in CLAUDE.md: Generation 2, 8192 MB fest, 4 CPUs, 60 GB (dynamisch wachsend),
# Secure Boot mit Vorlage "Microsoft UEFI-Zertifizierungsstelle", Netz "Default Switch",
# Start vom ISO. Bricht ab, wenn es die VM schon gibt (veraendert dann nichts).
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Iso,
    [string]$Dir = (Join-Path $env:USERPROFILE 'Fenstra\vm'),
    [switch]$Start
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Iso)) { throw "ISO nicht gefunden: $Iso" }
if (Get-VM -Name $Name -ErrorAction SilentlyContinue) { throw "VM '$Name' existiert bereits." }
New-Item -ItemType Directory -Force $Dir | Out-Null

New-VM -Name $Name -Generation 2 -MemoryStartupBytes 8GB -Path $Dir `
       -NewVHDPath (Join-Path $Dir "$Name.vhdx") -NewVHDSizeBytes 60GB -SwitchName 'Default Switch' | Out-Null
Set-VMMemory    -VMName $Name -DynamicMemoryEnabled $false
Set-VMProcessor -VMName $Name -Count 4
Set-VMFirmware  -VMName $Name -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
Set-VM          -VMName $Name -CheckpointType Standard -AutomaticCheckpointsEnabled $false

$dvd = Add-VMDvdDrive -VMName $Name -Path $Iso -Passthru
Set-VMFirmware -VMName $Name -FirstBootDevice $dvd

if ($Start) { Start-VM -Name $Name }
Get-VM -Name $Name | Format-List Name, Generation, MemoryStartup, ProcessorCount, State
