# ExportAllDNSZones.ps1
# get list of all zones from Get-DnsServerZone
$zones = Get-DnsServerZone

foreach ($zone in $zones) {
    Export-DnsServerZone -Name $zone.Name FileName "C:\${zone.Name}.dns"
}

