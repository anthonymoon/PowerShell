# Define the desired success and failure settings
$success = "disable"
$failure = "enable"

# Check the current settings for the "filtering platform connection" subcategory
$auditpol = & "C:\windows\system32\auditpol.exe" /get /subcategory:"filtering platform connection"

# Extract the success and failure settings from the output
$successSetting = $auditpol | Select-String "Success:" | ForEach-Object { $_.Line.Split(":")[1].Trim() }
$failureSetting = $auditpol | Select-String "Failure:" | ForEach-Object { $_.Line.Split(":")[1].Trim() }

# Compare the current and desired settings
if ($successSetting -eq $success -and $failureSetting -eq $failure) {
    Write-Output "Current settings already match the desired settings"
} else {
    # Modify the settings using the auditpol.exe command
    & "C:\windows\system32\auditpol.exe" /set /subcategory:"filtering platform connection" /success:$success /failure:$failure
    Write-Output "Settings updated"
}