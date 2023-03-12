param (
    [string]$ConnectionSpecificSuffix
)

# Set Cloudflare DNS forwarders (blocks malware and adult content)
Get-NetAdapter | ForEach-Object { Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses ("1.1.1.3","1.0.0.3") }

# Set FQDN
Get-NetAdapter | ForEach-Object { Set-DnsClient -InterfaceAlias $_.Name -ConnectionSpecificSuffix $ConnectionSpecificSuffix -RegisterThisConnectionsAddress $true -UseSuffixWhenRegistering $true }

# Disable File & Printer Sharing
Get-NetAdapter | ForEach-Object { Disable-NetAdapterBinding -InterfaceAlias $_.Name -DisplayName "File and Printer Sharing for Microsoft Networks" }

# Register the DNS record with the DHCP server
Register-DnsClient