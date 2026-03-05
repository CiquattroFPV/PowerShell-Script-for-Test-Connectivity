<# 
NetTools-Interactive.ps1
Interattivo:
- Selezione adapter (nome)
- Stampa MAC + IP
- Test-NetConnection verso destinazione:porta (usa -SourceAddress solo se disponibile)
- Resolve-DnsName verso server DNS specifico

Esecuzione:
powershell -ExecutionPolicy Bypass -File .\NetTools-Interactive.ps1
#>

function Read-NonEmpty {
    param(
        [Parameter(Mandatory=$true)][string]$Prompt,
        [string]$Default = $null
    )
    while ($true) {
        $msg = if ($Default) { "$Prompt [$Default]" } else { $Prompt }
        $val = Read-Host $msg
        if ([string]::IsNullOrWhiteSpace($val)) {
            if ($Default) { return $Default }
            continue
        }
        return $val.Trim()
    }
}

function Read-IntInRange {
    param(
        [Parameter(Mandatory=$true)][string]$Prompt,
        [int]$Default,
        [int]$Min = 1,
        [int]$Max = 65535
    )
    while ($true) {
        $raw = Read-NonEmpty -Prompt $Prompt -Default $Default
        $n = 0
        if ([int]::TryParse($raw, [ref]$n) -and $n -ge $Min -and $n -le $Max) {
            return $n
        }
        Write-Host "Valore non valido. Inserisci un numero tra $Min e $Max." -ForegroundColor Yellow
    }
}

Write-Host "`n=== NetTools Interactive (PowerShell) ===`n" -ForegroundColor Cyan

# Mostra adattatori
Write-Host "Adattatori disponibili:" -ForegroundColor Gray
Get-NetAdapter | Select-Object Name, InterfaceAlias, Status, MacAddress, LinkSpeed | Format-Table -AutoSize
Write-Host ""

# Input adapter
$adapter = Read-NonEmpty -Prompt "Nome scheda (InterfaceAlias o Name) da usare" -Default "Ethernet 3"

# Recupero adapter
$adapterObj = Get-NetAdapter -Name $adapter -ErrorAction SilentlyContinue
if (-not $adapterObj) {
    # Prova a cercare per InterfaceAlias/Name simile
    $match = Get-NetAdapter | Where-Object { $_.Name -eq $adapter -or $_.InterfaceAlias -eq $adapter } | Select-Object -First 1
    if ($match) { $adapterObj = $match }
}

if (-not $adapterObj) {
    Write-Host "Scheda '$adapter' non trovata. Controlla i nomi nella tabella sopra." -ForegroundColor Red
    exit 1
}

# IP (preferisci IPv4 non-APIPA; se non c'è, prendi il primo disponibile)
$ipObj = Get-NetIPAddress -InterfaceAlias $adapterObj.InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
         Where-Object { $_.IPAddress -and $_.IPAddress -notlike "169.254.*" } |
         Select-Object -First 1

if (-not $ipObj) {
    $ipObj = Get-NetIPAddress -InterfaceAlias $adapterObj.InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Select-Object -First 1
}

$info = [PSCustomObject]@{
    Adapter = $adapterObj.InterfaceAlias
    Name    = $adapterObj.Name
    MAC     = $adapterObj.MacAddress
    IP      = if ($ipObj) { $ipObj.IPAddress } else { $null }
}

Write-Host "`n--- Adapter info ---" -ForegroundColor Cyan
$info | Format-List

# Input Test-NetConnection
$dest = Read-NonEmpty -Prompt "`nDestinazione per Test-NetConnection (es: google.com o 1.1.1.1)" -Default "google.com"
$port = Read-IntInRange -Prompt "Porta" -Default 443 -Min 1 -Max 65535

# Esecuzione Test-NetConnection (compatibile: usa SourceAddress solo se disponibile)
Write-Host "`n--- Test-NetConnection ---" -ForegroundColor Cyan
$tncCmd = Get-Command Test-NetConnection -ErrorAction SilentlyContinue
if (-not $tncCmd) {
    Write-Host "Test-NetConnection non disponibile su questo sistema." -ForegroundColor Red
} else {
    $hasSource = $tncCmd.Parameters.ContainsKey("SourceAddress")
    try {
        if ($hasSource -and $info.IP) {
            $tnc = Test-NetConnection $dest -Port $port -SourceAddress $info.IP -InformationLevel Detailed
        } else {
            if (-not $hasSource) {
                Write-Host "Nota: parametro -SourceAddress NON supportato su questa versione. Uso routing normale." -ForegroundColor Yellow
            } elseif (-not $info.IP) {
                Write-Host "Nota: nessun IPv4 trovato per la scheda. Uso routing normale." -ForegroundColor Yellow
            }
            $tnc = Test-NetConnection $dest -Port $port -InformationLevel Detailed
        }

        $tnc | Select-Object ComputerName, RemoteAddress, RemotePort, InterfaceAlias, SourceAddress, PingSucceeded, TcpTestSucceeded |
               Format-List
    } catch {
        Write-Host "Errore Test-NetConnection: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Input Resolve-DnsName
$dnsName   = Read-NonEmpty -Prompt "`nNome da risolvere (es: maticmind.it)" -Default "maticmind.it"
$dnsType   = Read-NonEmpty -Prompt "Tipo record (A, AAAA, MX, TXT, CNAME, SRV, NS, SOA)" -Default "MX"
$dnsServer = Read-NonEmpty -Prompt "DNS server da usare (es: 1.1.1.1 o IP DNS interno)" -Default "1.1.1.1"

# Esecuzione Resolve-DnsName
Write-Host "`n--- Resolve-DnsName ---" -ForegroundColor Cyan
try {
    $dns = Resolve-DnsName $dnsName -Type $dnsType -Server $dnsServer -ErrorAction Stop
    $dns | Format-Table -AutoSize
} catch {
    Write-Host "Errore Resolve-DnsName: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nFine. Windows cooperativo: evento raro, segnatelo sul calendario.`n" -ForegroundColor DarkGray