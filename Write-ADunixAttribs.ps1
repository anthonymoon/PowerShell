Import-Module ActiveDirectory

# Get all users in the active directory
$users = Get-ADUser -Filter *

# Create a new array to hold the user information
$userInfo = @()
$prefix = 10

# Loop through each user and get their name and RID
foreach ($user in $users) {
    $samAccountName = $user.SamAccountName
    $uid = $user.SamAccountName.ToLower()
    $sid = $user.SID.Value
    $rid = $sid.Substring($sid.LastIndexOf("-") + 1)
    $uidNumber = "{0:D2}{1}" -f $prefix, $rid
    # Create "Add" hash table
    $add = @{
        "uid"           = $uid
        "uidNumber"     = $uidNumber
        "gidNumber"     = "10513"
        "homeDirectory" = "/people/$uid"
        "loginShell"    = "/bin/zsh"
    }
    # Add hash table to user
    Set-ADUser -Identity $samAccountName -Add $add
    write-host "Added $samAccountName to AD"
}

# Done!
write-host "Done!"
