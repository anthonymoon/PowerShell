$Logfile = "C:\SplitTunnel.log"
Start-Transcript $Logfile

Get-NetRoute -DestinationPrefix 10*,172*,192.168.192* -PolicyStore ActiveStore |Remove-NetRoute -Confirm:$false

do {
    Write-Host "Setting VPN interface metric to 9999..."; `
    Get-NetAdapter -ifDesc "PANGP Virtual Ethernet Adapter"| `
    Set-NetIPInterface -InterfaceMetric 9999 -ErrorAction SilentlyContinue `
    && Write-host "Done"
   } until ($? -eq "true" )

 do {
    Write-Host "Setting HOST interface metric to 1..."; `
    Get-NetAdapter -ifDesc "*Intel*Eth*"| `
    Set-NetIPInterface -InterfaceMetric 1 -ErrorAction SilentlyContinue `
    && Write-host "Done"
   } until ($? -eq "true" )

do {
    Write-Host "Setting HOST default gateway..."; `
    Get-NetAdapter -ifDesc "*Intel*Eth*"| `
    Set-NetRoute -NextHop 192.168.0.254 -DestinationPrefix 0.0.0.0/0 -Confirm:$false -ErrorAction SilentlyContinue `
    && Write-host "Done"
   } until ($? -eq "true" )


do {
   Write-Host "Setting VPN routes..."; `
   $VPN = Get-NetAdapter -ifDesc "PANGP Virtual Ethernet Adapter" |Get-NetIPAddress 
   '10.0.0.0/8','192.168.192.0/24','172.0.0.0/8','104.42.171.152/32' | `
   ForEach-Object { New-NetRoute -InterfaceIndex $VPN.ifIndex -NextHop $VPN.IPAddress -DestinationPrefix "$_" -Confirm:$false } `
   && Write-host "Done"
   } until ($? -eq "true" )
     
Stop-Transcript
Exit