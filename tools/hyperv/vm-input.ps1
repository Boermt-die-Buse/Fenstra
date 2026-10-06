# Maus- und Tastatureingaben an eine Hyper-V-VM senden (Hyper-V-WMI, ohne vmconnect).
#
#   vm-input.ps1 click X Y [right]    Mausklick an Gastpixel X/Y (links, oder rechts)
#   vm-input.ps1 dclick X Y           Doppelklick
#   vm-input.ps1 move X Y             Maus bewegen
#   vm-input.ps1 down X Y / up        linke Taste an X/Y drücken und halten / loslassen
#                                     (gedrückte Zustände prüfen; vor "up" wegbewegen = kein Klick)
#   vm-input.ps1 text "ls -la | less" Text tippen, fuer DEUTSCHE Tastaturbelegung im Gast
#   vm-input.ps1 key 13               eine Taste (virtueller Tastencode, s. u.)
#   vm-input.ps1 combo 17 18 84       Tasten gleichzeitig (hier Strg+Alt+T = Konsole)
#   ... -VM Fenstra-Test5             VM waehlen (sonst $env:FENSTRA_VM oder die einzige laufende Fenstra-VM)
#
# Haeufige Tastencodes: 8 Ruecktaste, 9 Tab, 13 Enter, 16 Shift, 17 Strg, 18 Alt, 27 Esc,
# 32 Leertaste, 37-40 Pfeile (links, oben, rechts, unten), 91 Windows-Taste, 115 F4.
#
# Erfahrungen (siehe tools/README.md):
#  - Mauskoordinaten sind Gastpixel. Waehrend ein vmconnect-Fenster offen ist und dort die
#    Maus bewegt wird, landen Klicks an falschen Stellen.
#  - Hyper-V uebersetzt Tastencodes in US-Scancodes. Der Gast hat DE-Belegung, deshalb
#    rechnet "text" jedes Zeichen auf die DE-Taste um (y/z vertauscht, Sonderzeichen,
#    AltGr = rechte Alt-Taste 0xA5, die <>|-Taste nur per Scancode 0x56).
#  - Die WMI-Methode TypeText kommt im Gast nicht an; deshalb Taste fuer Taste.
#  - Qt-Knoepfe reagieren auf die Leertaste, nicht immer auf Enter.
param(
    [Parameter(Mandatory, Position = 0)][ValidateSet('click', 'dclick', 'move', 'down', 'up', 'text', 'key', 'combo')][string]$Action,
    [Parameter(Position = 1)][string]$A,
    [Parameter(Position = 2)][string]$B,
    [Parameter(Position = 3)][string]$C,
    [Parameter(Position = 4)][string]$D,
    [string]$VM
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_vm.ps1"
$vmCim = Get-FenstraVmCim (Resolve-FenstraVm $VM)
$kbd = Get-CimAssociatedInstance -InputObject $vmCim -ResultClassName Msvm_Keyboard
$mouse = Get-CimAssociatedInstance -InputObject $vmCim -ResultClassName Msvm_SyntheticMouse

function MoveTo([int]$x, [int]$y) {
    Assert-WmiOk (Invoke-CimMethod -InputObject $mouse -MethodName SetAbsolutePosition -Arguments @{ horizontalPosition = $x; verticalPosition = $y }) 'SetAbsolutePosition'
}
function Click([int]$btn) {
    # Drücken, kurz halten, loslassen. Die WMI-Methode ClickButton liefert Drücken und Loslassen
    # mit identischem Zeitstempel; Firefox und KWin-Fenster verwerfen solche Klicks (Befund M3).
    Assert-WmiOk (Invoke-CimMethod -InputObject $mouse -MethodName SetButtonState -Arguments @{ ButtonIndex = [uint32]$btn; IsDown = $true }) 'SetButtonState'
    Start-Sleep -Milliseconds 90
    Assert-WmiOk (Invoke-CimMethod -InputObject $mouse -MethodName SetButtonState -Arguments @{ ButtonIndex = [uint32]$btn; IsDown = $false }) 'SetButtonState'
}
function KeyDown([int]$k) { Assert-WmiOk (Invoke-CimMethod -InputObject $kbd -MethodName PressKey -Arguments @{ keyCode = [uint32]$k }) 'PressKey' }
function KeyUp([int]$k) { Assert-WmiOk (Invoke-CimMethod -InputObject $kbd -MethodName ReleaseKey -Arguments @{ keyCode = [uint32]$k }) 'ReleaseKey' }
function KeyType([int]$k) { Assert-WmiOk (Invoke-CimMethod -InputObject $kbd -MethodName TypeKey -Arguments @{ keyCode = [uint32]$k }) 'TypeKey' }

# Zeichen -> (US-Tastencode, Modifikator) fuer deutsche Belegung im Gast.
# Modifikator: '' keiner, 's' Shift, 'g' AltGr (rechte Alt-Taste)
$deMap = @{
    ' ' = @(32, ''); '-' = @(0xBF, ''); '_' = @(0xBF, 's'); '.' = @(0xBE, ''); ':' = @(0xBE, 's'); ',' = @(0xBC, ''); ';' = @(0xBC, 's')
    '/' = @(0x37, 's'); '=' = @(0x30, 's'); '!' = @(0x31, 's'); '"' = @(0x32, 's'); '$' = @(0x34, 's'); '%' = @(0x35, 's'); '&' = @(0x36, 's')
    '(' = @(0x38, 's'); ')' = @(0x39, 's'); '?' = @(0xBD, 's'); '\' = @(0xBD, 'g'); '+' = @(0xDD, ''); '*' = @(0xDD, 's'); '~' = @(0xDD, 'g')
    '#' = @(0xDC, ''); "'" = @(0xDC, 's'); '<' = @(0xE2, ''); '>' = @(0xE2, 's'); '|' = @(0xE2, 'g'); '@' = @(0x51, 'g')
    '{' = @(0x37, 'g'); '[' = @(0x38, 'g'); ']' = @(0x39, 'g'); '}' = @(0x30, 'g'); '^' = @(0xC0, ''); '`' = @(0xBB, 's')
}

switch ($Action) {
    'move'   { MoveTo $A $B }
    'click'  { MoveTo $A $B; Start-Sleep -Milliseconds 150; Click ($(if ($C -eq 'right') { 2 } else { 1 })) }
    'dclick' { MoveTo $A $B; Start-Sleep -Milliseconds 150; Click 1; Start-Sleep -Milliseconds 80; Click 1 }
    'down'   { MoveTo $A $B; Start-Sleep -Milliseconds 150; Assert-WmiOk (Invoke-CimMethod -InputObject $mouse -MethodName SetButtonState -Arguments @{ ButtonIndex = [uint32]1; IsDown = $true }) 'SetButtonState' }
    'up'     { Assert-WmiOk (Invoke-CimMethod -InputObject $mouse -MethodName SetButtonState -Arguments @{ ButtonIndex = [uint32]1; IsDown = $false }) 'SetButtonState' }
    'key'    { KeyType $A }
    'combo'  {
        $keys = @($A, $B, $C, $D) | Where-Object { $_ }
        foreach ($k in $keys) { KeyDown $k }
        Start-Sleep -Milliseconds 100
        [array]::Reverse($keys)
        foreach ($k in $keys) { KeyUp $k }
    }
    'text'   {
        foreach ($ch in $A.ToCharArray()) {
            $s = [string]$ch
            if ($s -cmatch '[a-zA-Z]') {
                $u = $s.ToUpper(); if ($u -eq 'Y') { $u = 'Z' } elseif ($u -eq 'Z') { $u = 'Y' }
                $vk = [int][char]$u; $mod = $(if ($s -cmatch '[A-Z]') { 's' } else { '' })
            } elseif ($s -match '[0-9]') { $vk = [int][char]$s; $mod = '' }
            elseif ($deMap.ContainsKey($s)) { $vk = $deMap[$s][0]; $mod = $deMap[$s][1] }
            else { throw "Zeichen '$s' ist nicht abgebildet (Umlaute/Unicode werden nicht unterstuetzt)" }
            if ($mod -eq 's') { KeyDown 16 } elseif ($mod -eq 'g') { KeyDown 0xA5 }
            if ($vk -eq 0xE2) {
                # ISO-Zusatztaste <>| hat keinen US-Tastencode: Scancode 0x56 (Druecken/Loslassen)
                Assert-WmiOk (Invoke-CimMethod -InputObject $kbd -MethodName TypeScancodes -Arguments @{ scanCodes = [byte[]](0x56, 0xD6) }) 'TypeScancodes'
            } else {
                KeyType $vk
            }
            if ($mod -eq 's') { KeyUp 16 } elseif ($mod -eq 'g') { KeyUp 0xA5 }
        }
    }
}
