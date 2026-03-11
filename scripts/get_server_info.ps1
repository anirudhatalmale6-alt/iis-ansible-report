$hostname = $env:COMPUTERNAME
$ipList = @(Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -ExpandProperty IPAddress)

$result = @{
    Hostname = $hostname
    IPs      = $ipList
}

$result | ConvertTo-Json -Compress
