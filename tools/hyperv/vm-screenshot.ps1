# Bildschirmfoto einer Hyper-V-VM als PNG (ohne vmconnect, ueber die Hyper-V-WMI-Schnittstelle).
#   vm-screenshot.ps1 [-Out datei.png] [-VM Name] [-W 960 -H 540]
# Gibt den Dateinamen aus. Nur zur Orientierung (RGB565, verkleinert; Hyper-V lehnt Groessen
# ueber etwa 1600x1200 ab, z. B. 1920x1080 mit ReturnValue 32775). Das Seitenverhaeltnis sollte
# dem Gast entsprechen (seit 2026-10-05 1920x1080 -> 960x540). Pixelgenaue Bilder aus der
# laufenden Sitzung: vm-gastfoto.ps1. Vor der Anmeldung (Bootscreen, Anmeldebildschirm,
# Installer) bleibt dieses Skript der einzige Weg.
param(
    [string]$Out = (Join-Path $env:TEMP 'fenstra-vm.png'),
    [string]$VM,
    [int]$W = 960,
    [int]$H = 540
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$name = Resolve-FenstraVm $VM
# nicht $vm nennen: PowerShell unterscheidet keine Gross-/Kleinschreibung, der [string]-Parameter
# $VM wuerde das CIM-Objekt in Text umwandeln
$vmCim = Get-FenstraVmCim $name
$vsms = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_VirtualSystemManagementService
$sett = Get-CimAssociatedInstance -InputObject $vmCim -ResultClassName Msvm_VirtualSystemSettingData |
        Where-Object VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized'
$r = Invoke-CimMethod -InputObject $vsms -MethodName GetVirtualSystemThumbnailImage `
     -Arguments @{ TargetSystem = $sett; WidthPixels = [uint16]$W; HeightPixels = [uint16]$H }
$bytes = [byte[]]$r.ImageData
if ($r.ReturnValue -ne 0 -or -not $bytes) { throw "Bildschirmfoto fehlgeschlagen (ReturnValue $($r.ReturnValue))" }
# Hyper-V liefert RGB565, gelegentlich mit einigen Bytes mehr als W*H*2
if ($bytes.Length -lt $W * $H * 2) { throw "Unerwartete Puffergroesse $($bytes.Length) fuer ${W}x${H}" }
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format16bppRgb565)
$d = $bmp.LockBits((New-Object System.Drawing.Rectangle 0, 0, $W, $H), 'WriteOnly', $bmp.PixelFormat)
for ($y = 0; $y -lt $H; $y++) {
    # zeilenweise kopieren: Stride der Bitmap kann von W*2 abweichen
    [System.Runtime.InteropServices.Marshal]::Copy($bytes, $y * $W * 2, [IntPtr]($d.Scan0.ToInt64() + $y * $d.Stride), $W * 2)
}
$bmp.UnlockBits($d)
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$Out
