param(
    [string]$CsvPath
)

# Import the CSV file and loop through each row
Import-Csv $CsvPath | ForEach-Object {

    # Extract the IP address, hostname, DNS server name, and zone name from the current row
    $ipAddress = $_.IPAddress
    $hostname = $_.Hostname
    $dnsServerName = $_.DnsServerName
    $zoneName = $_.ZoneName

    # Construct the reverse lookup zone name for the current IP address
    $reverseZoneName = ($ipAddress.Split('.')[3,2,1,0] -join '.') + ".in-addr.arpa"

    # Construct the PTR record name for the current IP address
    $ptrRecordName = $ipAddress.Split('.')[3,2,1,0] -join '.'

    # Construct the fully qualified domain name (FQDN) for the PTR record
    $ptrFqdn = "$ptrRecordName.$reverseZoneName"

    # Construct the target FQDN for the PTR record
    $targetFqdn = "$hostname.$zoneName"

    # Add the PTR record to the DNS server
    Add-DnsServerResourceRecordPtr -Name $ptrRecordName -ZoneName $reverseZoneName -PtrDomainName $targetFqdn -IPv4Address $ipAddress -ComputerName $dnsServerName
}
