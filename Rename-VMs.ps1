#Connect-VIServer MyvCenterSRV
# Specify if your virtual machine names include the FQDN
$IncludeFQDN = $True
$excludeNAME = "localhost|TEMP|test"

Get-VMHost -Name grid-a.monw.mpc.local |Get-VM -Name "{$NAME}" | Where { $_.PowerState -eq "PoweredOn" } | Foreach {
  If ($_.Guest.Hostname) {
    If ($IncludeFQDN) {
      $Name = $_.Guest.Hostname
    } Else {
      $Name = (([string]$_.Guest.HostName).Split("."))[0]
    }
    If ($_.Name -ne $Name -and $Name -notmatch $excludeNAME) {
      Write "VM name '$($_.Name)' is not the same as the hostname $Name"
      Set-VM $_.Name -Name $Name -confirm:$false
    }
  }
  Else {
    Write "Unable to read hostname for $($_.Name) - No VMTools ?"
  }
}