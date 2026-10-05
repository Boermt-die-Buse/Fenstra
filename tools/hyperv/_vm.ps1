# Gemeinsame Hilfsfunktionen der Fenstra-Hyper-V-Werkzeuge (wird per Dot-Sourcing geladen).
# Alle Werkzeuge brauchen Administratorrechte (Hyper-V-WMI).

# VM bestimmen: -VM / $env:FENSTRA_VM, sonst die einzige laufende VM, deren Name mit "Fenstra" beginnt.
function Resolve-FenstraVm([string]$Name) {
    if ($Name) { return $Name }
    if ($env:FENSTRA_VM) { return $env:FENSTRA_VM }
    $running = @(Get-VM -ErrorAction Stop | Where-Object { $_.Name -like 'Fenstra*' -and $_.State -eq 'Running' })
    if ($running.Count -eq 1) { return $running[0].Name }
    $names = ($running | ForEach-Object Name) -join ', '
    if (-not $names) { $names = '(keine)' }
    throw "VM nicht eindeutig. Laufende Fenstra-VMs: $names. Bitte -VM <Name> angeben oder `$env:FENSTRA_VM setzen."
}

function Get-FenstraVmCim([string]$Name) {
    $vm = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem -Filter "ElementName='$Name'"
    if (-not $vm) { throw "VM '$Name' nicht gefunden" }
    return $vm
}

function Assert-WmiOk($Result, [string]$What) {
    if ($Result.ReturnValue -ne 0) { throw "$What fehlgeschlagen (ReturnValue $($Result.ReturnValue))" }
}
