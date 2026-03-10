$hostname = $env:COMPUTERNAME
$ips = (Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -ExpandProperty IPAddress) -join ';'

$result = @{
    Hostname = $hostname
    IPs      = $ips
}

$result | ConvertTo-Json -Compress
