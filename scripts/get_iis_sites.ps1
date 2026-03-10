Import-Module WebAdministration

$sites = Get-ChildItem IIS:\Sites
$results = @()

foreach ($site in $sites) {
    $bindings = Get-WebBinding -Name $site.Name
    if ($bindings.Count -eq 0) {
        $results += [PSCustomObject]@{
            SiteName     = $site.Name
            SiteID       = $site.ID
            State        = $site.State
            Protocol     = ''
            BindingIP    = ''
            Port         = ''
            HostHeader   = ''
            PhysicalPath = $site.PhysicalPath
        }
    }
    else {
        foreach ($binding in $bindings) {
            $info = $binding.bindingInformation -split ':'
            if ($info[0] -eq '*') {
                $bindIP = 'All Unassigned'
            } else {
                $bindIP = $info[0]
            }
            $port    = $info[1]
            $hostHdr = $info[2]

            $results += [PSCustomObject]@{
                SiteName     = $site.Name
                SiteID       = $site.ID
                State        = $site.State
                Protocol     = $binding.protocol
                BindingIP    = $bindIP
                Port         = $port
                HostHeader   = $hostHdr
                PhysicalPath = $site.PhysicalPath
            }
        }
    }
}

$results | ConvertTo-Json -Depth 3 -Compress
