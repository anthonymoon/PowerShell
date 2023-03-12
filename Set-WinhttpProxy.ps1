Function Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg
    )
    
    Add-Content C:\SetWinhttpProxyLog.txt $msg
}

$country = Get-WinHomeLocation | foreach { $_.HomeLocation }
$port  = ":9400"
$date = Get-Date

switch($country){
   "United States" {
   $zproxy1 = "den3.sme.zscaler.net" 
   $zproxy2 = "ams2-2.sme.zscaler.net"}

   "Canada" {
   $zproxy1 = "den3.sme.zscaler.net" 
   $zproxy2 = "ams2-2.sme.zscaler.net"}

   "France" {
   $zproxy1 = "ams2-2.sme.zscaler.net" 
   $zproxy2 = "den3.sme.zscaler.net"}

   "Europe" {
   $zproxy1 = "ams2-2.sme.zscaler.net" 
   $zproxy2 = "den3.sme.zscaler.net"}

   "United Kingdom" {
   $zproxy1 = "ams2-2.sme.zscaler.net" 
   $zproxy2 = "den3.sme.zscaler.net"}

   "India" {
   $zproxy1 = "del1.sme.zscaler.net" 
   $zproxy2 = "tpe2.sme.zscaler.net"}

   "Australia" {
   $zproxy1 = "tpe2.sme.zscaler.net" 
   $zproxy2 = "del1.sme.zscaler.net"}

   default {
   $zproxy1 = "den3.sme.zscaler.net" 
   $zproxy2 = "ams2-2.sme.zscaler.net"
  }
}

if ( Test-Connection $zproxy1 -count 1 -Quiet )
{
     $zproxy = $zproxy1
     Log "Using proxy: $($zproxy)"
}
elseif ( Test-Connection $zproxy2 -count 1 -Quiet )
{
    $zproxy = $zproxy2
    Log "Using proxy: $($zproxy)"    
}
else
{
    Log "** $zproxy1 & $zproxy2 are not reachable **"
    exit
}

$exclusionList="<local>;127.0.0.1"
$netshOutput = & netsh winhttp set proxy $zproxy$port $exclusionList 
$logOutput = @"
`n
Running at: $date
`n
** dump variables **
netshproxy: $zproxy$port
exclusion list: $exclusionList
first proxy: $zproxy1, second proxy: $zproxy2
country: $country
`n
** cmd output **
$netshOutput
"@
Log "$logOutput"