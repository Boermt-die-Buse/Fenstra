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

# IPv4 der VM, zwischengespeichert in %TEMP%\fenstra-vm-ip-<Name>.txt (-Refresh: neu ermitteln).
function Get-FenstraVmIp([string]$Name, [switch]$Refresh) {
    $cache = Join-Path $env:TEMP "fenstra-vm-ip-$Name.txt"
    if (-not $Refresh -and (Test-Path $cache)) {
        $ip = (Get-Content $cache -TotalCount 1).Trim()
        if ($ip) { return $ip }
    }
    $ip = (Get-VMNetworkAdapter -VMName $Name).IPAddresses | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
    if (-not $ip) { throw "Keine IPv4-Adresse fuer '$Name' (VM noch nicht hochgefahren?)" }
    Set-Content -Path $cache -Value $ip
    return $ip
}

# Gemeinsame ssh/scp-Optionen (Schluessel und eigene known_hosts der Test-VMs).
function Get-FenstraSshArgs {
    $key = Join-Path $HOME '.ssh\fenstra-vm'
    $kh = Join-Path $HOME '.ssh\known_hosts_fenstra'
    return @('-i', $key, '-o', "UserKnownHostsFile=$kh", '-o', 'StrictHostKeyChecking=accept-new',
             '-o', 'ConnectTimeout=10', '-o', 'BatchMode=yes')
}

function Assert-WmiOk($Result, [string]$What) {
    if ($Result.ReturnValue -ne 0) { throw "$What fehlgeschlagen (ReturnValue $($Result.ReturnValue))" }
}
