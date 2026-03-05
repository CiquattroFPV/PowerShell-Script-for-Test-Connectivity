<# 
NetTools-Interactive.ps1 (Presets + tracert Timeout 30s + DNS record type)
- Include/filter virtual adapters
- Adapter selection menu (default = first Up)
- Quick presets for TCP port tests
- Traceroute via tracert with 30s timeout + option to resolve hop names (slower) or not (faster -d)
- TCP test via Test-NetConnection (SourceAddress only if supported)
- DNS test via Resolve-DnsName with selectable record type + custom DNS server
- Loop: Enter repeat | A change adapter | Q quit
#>

function Read-NonEmpty {
    param([string]$Prompt, [string]$Default = $null)
    while ($true) {
        $msg = if ($null -ne $Default) { "$Prompt [$Default]" } else { $Prompt }
        $v = Read-Host $msg
        if ([string]::IsNullOrWhiteSpace($v)) {
            if ($null -ne $Default) { return $Default }
            continue
        }
        return $v.Trim()
    }
}

function Read-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    $def = if ($Default) { "Y" } else { "N" }
    while ($true) {
        $v = (Read-NonEmpty -Prompt $Prompt -Default $def).ToUpperInvariant()
        if ($v -in @("Y","YES","S","SI")) { return $true }
        if ($v -in @("N","NO")) { return $false }
        Write-Host "Inserisci Y/N." -ForegroundColor Yellow
    }
}

function Read-IntInRange {
    param([string]$Prompt, [int]$Default, [int]$Min = 1, [int]$Max = 65535)
    while ($true) {
        $raw = Read-NonEmpty -Prompt $Prompt -Default $Default
        $n = 0
        if ([int]::TryParse($raw, [ref]$n) -and $n -ge $Min -and $n -le $Max) { return $n }
        Write-Host "Valore non valido. Inserisci un numero tra $Min e $Max." -ForegroundColor Yellow
    }
}

function Get-AdapterList {
    param([bool]$IncludeVirtual)

    $all = Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" }

    if (-not $IncludeVirtual) {
        $all = $all | Where-Object {
            ($_.Virtual -eq $false) -and
            ($_.InterfaceDescription -notmatch "(?i)virtual|hyper-v|vmware|loopback|tunnel|tap|wintun|wireguard|fortinet|anyconnect|pangp|ndis|bluetooth|wi-?fi direct")
        }
    }

    $all | Sort-Object @{Expression={ $_.Status -ne "Up" }}, InterfaceAlias
}

function Select-NetworkAdapter {
    param([bool]$IncludeVirtual)

    $adapters = @(Get-AdapterList -IncludeVirtual:$IncludeVirtual)
    if ($adapters.Count -eq 0) { throw "Nessun adattatore trovato (prova a includere quelli virtuali)." }

    $defaultIndex = 1
    for ($i=0; $i -lt $adapters.Count; $i++) {
        if ($adapters[$i].Status -eq "Up") { $defaultIndex = $i + 1; break }
    }

    Write-Host "`n=== Adapter Selection ===" -ForegroundColor Cyan
    for ($i=0; $i -lt $adapters.Count; $i++) {
        $idx = $i + 1
        $a = $adapters[$i]
        Write-Host ("[{0}] {1} | Alias: {2} | Status: {3} | MAC: {4} | Speed: {5}" -f `
            $idx, $a.Name, $a.InterfaceAlias, $a.Status, $a.MacAddress, $a.LinkSpeed)
    }

    $choice = Read-NonEmpty -Prompt "Seleziona adapter (numero) oppure Q per uscire" -Default "$defaultIndex"
    if ($choice.Trim().ToUpperInvariant() -eq "Q") { return $null }

    $n = 0
    if (-not [int]::TryParse($choice, [ref]$n)) { throw "Scelta non valida." }
    if ($n -lt 1 -or $n -gt $adapters.Count) { throw "Scelta fuori range (1-$($adapters.Count))." }

    return $adapters[$n - 1]
}

function Get-AdapterInfo {
    param($AdapterObj)

    $ipObj = Get-NetIPAddress -InterfaceAlias $AdapterObj.InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Where-Object { $_.IPAddress -and $_.IPAddress -notlike "169.254.*" } |
             Select-Object -First 1

    if (-not $ipObj) {
        $ipObj = Get-NetIPAddress -InterfaceAlias $AdapterObj.InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                 Select-Object -First 1
    }

    [PSCustomObject]@{
        Adapter = $AdapterObj.InterfaceAlias
        Name    = $AdapterObj.Name
        MAC     = $AdapterObj.MacAddress
        IP      = if ($ipObj) { $ipObj.IPAddress } else { $null }
        Status  = $AdapterObj.Status
        Speed   = $AdapterObj.LinkSpeed
    }
}

function Choose-Preset {
    Write-Host "`n=== Preset rapidi (TCP) ===" -ForegroundColor Cyan
    Write-Host "[1] HTTPS (443) + DNS A"
    Write-Host "[2] DNS (53) + DNS A"
    Write-Host "[3] LDAP (389) + DNS SRV _ldap._tcp.<domain>"
    Write-Host "[4] LDAPS (636) + DNS SRV _ldaps._tcp.<domain>"
    Write-Host "[5] RDP (3389) + DNS A"
    Write-Host "[6] SMTP (25) + DNS MX"
    Write-Host "[7] SMTP Submission (587) + DNS MX"
    Write-Host "[8] Custom (manuale)"

    $p = Read-IntInRange -Prompt "Seleziona preset" -Default 1 -Min 1 -Max 8

    $result = [ordered]@{
        TraceDest = "google.com"
        TcpDest   = "google.com"
        TcpPort   = 443
        DnsName   = "example.com"
        DnsType   = "A"
        DnsServer = "1.1.1.1"
    }

    switch ($p) {
        1 { $result.TraceDest="google.com"; $result.TcpDest="google.com"; $result.TcpPort=443;  $result.DnsName="example.com"; $result.DnsType="A" }
        2 { $result.TraceDest="1.1.1.1";    $result.TcpDest="1.1.1.1";    $result.TcpPort=53;   $result.DnsName="example.com"; $result.DnsType="A" }
        3 { $result.TraceDest="dc.example.com"; $result.TcpDest="dc.example.com"; $result.TcpPort=389; $result.DnsName="_ldap._tcp.example.com";  $result.DnsType="SRV" }
        4 { $result.TraceDest="dc.example.com"; $result.TcpDest="dc.example.com"; $result.TcpPort=636; $result.DnsName="_ldaps._tcp.example.com"; $result.DnsType="SRV" }
        5 { $result.TraceDest="server.example.com"; $result.TcpDest="server.example.com"; $result.TcpPort=3389; $result.DnsName="server.example.com"; $result.DnsType="A" }
        6 { $result.TraceDest="mail.example.com"; $result.TcpDest="mail.example.com"; $result.TcpPort=25;  $result.DnsName="example.com"; $result.DnsType="MX" }
        7 { $result.TraceDest="mail.example.com"; $result.TcpDest="mail.example.com"; $result.TcpPort=587; $result.DnsName="example.com"; $result.DnsType="MX" }
        8 { } # custom
    }

    return [PSCustomObject]$result
}

function Invoke-TracertWithTimeout {
    param(
        [Parameter(Mandatory=$true)][string]$Destination,
        [int]$TimeoutSeconds = 30,
        [bool]$ResolveHopNames = $false
    )

    # tracert: -d disables name resolution (faster)
    $args = if ($ResolveHopNames) { "$Destination" } else { "-d $Destination" }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "tracert"
    $psi.Arguments = $args
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    [void]$p.Start()

    if ($p.WaitForExit($TimeoutSeconds * 1000)) {
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $text = ($out + "`r`n" + $err).Trim()
        return @{ TimedOut = $false; Result = $text }
    } else {
        try { $p.Kill() } catch {}
        return @{ TimedOut = $true; Result = $null }
    }
}

function Read-DnsType {
    param([string]$Default = "A")

    $valid = @("A","AAAA","MX","TXT","CNAME","SRV","NS","SOA","PTR")
    while ($true) {
        $t = (Read-NonEmpty -Prompt "Tipo record DNS (A, AAAA, MX, TXT, CNAME, SRV, NS, SOA, PTR)" -Default $Default).ToUpperInvariant()
        if ($valid -contains $t) { return $t }
        Write-Host "Tipo non valido. Validi: $($valid -join ', ')" -ForegroundColor Yellow
    }
}

# ================= MAIN =================

Write-Host "`n=== NetTools Interactive (Comfort Edition) ===`n" -ForegroundColor Cyan

$includeVirtual = Read-YesNo -Prompt "Vuoi includere anche le schede virtuali? (Y=include, N=filtra)" -Default $false

$tncCmd = Get-Command Test-NetConnection -ErrorAction SilentlyContinue
$hasTnc = $null -ne $tncCmd
$hasSource = $false
if ($hasTnc) { $hasSource = $tncCmd.Parameters.ContainsKey("SourceAddress") }

$adapterObj = $null
$exitScript = $false

while (-not $exitScript) {

    if (-not $adapterObj) {
        try {
            $adapterObj = Select-NetworkAdapter -IncludeVirtual:$includeVirtual
            if (-not $adapterObj) { break }  # Q dal menu adapter
        } catch {
            Write-Host "Errore selezione adapter: $($_.Exception.Message)" -ForegroundColor Red
            $adapterObj = $null
            continue
        }
    }

    $info = Get-AdapterInfo -AdapterObj $adapterObj
    Write-Host "`n--- Adapter info ---" -ForegroundColor Cyan
    $info | Format-List

    # Preset
    $preset = Choose-Preset

    # --- Traceroute ---
    $traceDest = Read-NonEmpty -Prompt "Destinazione per TraceRoute" -Default $preset.TraceDest
    $resolveHopNames = Read-YesNo -Prompt "Traceroute: risolvere i nomi degli hop? (più lento)" -Default $false

    Write-Host "`n--- TraceRoute (tracert, timeout 30s) ---" -ForegroundColor Cyan
    try {
        $trWrap = Invoke-TracertWithTimeout -Destination $traceDest -TimeoutSeconds 30 -ResolveHopNames $resolveHopNames
        if ($trWrap.TimedOut) {
            Write-Host "Traceroute > 30s: interrotto, continuo lo script." -ForegroundColor Yellow
        } else {
            $trWrap.Result | Out-Host
        }
    } catch {
        Write-Host "Traceroute fallito: $($_.Exception.Message)" -ForegroundColor Red
    }

    # --- TCP test ---
    $dest = Read-NonEmpty -Prompt "Destinazione TCP (Invio = stessa del traceroute)" -Default $traceDest
    $port = Read-IntInRange -Prompt "Porta TCP" -Default $preset.TcpPort -Min 1 -Max 65535

    Write-Host "`n--- TCP Test (Test-NetConnection) ---" -ForegroundColor Cyan
    if (-not $hasTnc) {
        Write-Host "Test-NetConnection non disponibile su questo sistema." -ForegroundColor Red
    } else {
        try {
            if ($hasSource -and $info.IP) {
                $tnc = Test-NetConnection $dest -Port $port -SourceAddress $info.IP -InformationLevel Detailed
            } else {
                if (-not $hasSource) { Write-Host "Nota: -SourceAddress NON supportato. Uso routing normale." -ForegroundColor Yellow }
                elseif (-not $info.IP) { Write-Host "Nota: nessun IPv4 trovato. Uso routing normale." -ForegroundColor Yellow }
                $tnc = Test-NetConnection $dest -Port $port -InformationLevel Detailed
            }

            $tnc | Select-Object ComputerName, RemoteAddress, RemotePort, InterfaceAlias, SourceAddress, PingSucceeded, TcpTestSucceeded |
                   Format-List
        } catch {
            Write-Host "TCP test fallito: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # --- DNS test (record type selectable) ---
    $dnsName   = Read-NonEmpty -Prompt "`nNome da risolvere (DNS)" -Default $preset.DnsName
    $dnsType   = Read-DnsType -Default $preset.DnsType
    $dnsServer = Read-NonEmpty -Prompt "DNS server da usare" -Default $preset.DnsServer

    Write-Host "`n--- Resolve-DnsName ---" -ForegroundColor Cyan
    try {
        Resolve-DnsName $dnsName -Type $dnsType -Server $dnsServer -ErrorAction Stop | Format-Table -AutoSize
    } catch {
        Write-Host "DNS fallito: $($_.Exception.Message)" -ForegroundColor Red
    }

    # --- Next ---
    Write-Host ""
    $next = Read-Host "Invio = ripeti | A = cambia adapter | Q = esci"
    $nextU = ($next.Trim()).ToUpperInvariant()

    if ($nextU -eq "Q") { $exitScript = $true; break }
    if ($nextU -eq "A") { $adapterObj = $null; continue }

    continue
}

Write-Host "`nFine. Ora hai sia traceroute veloce che DNS record type. Hai vinto tu, per stavolta.`n" -ForegroundColor DarkGray
