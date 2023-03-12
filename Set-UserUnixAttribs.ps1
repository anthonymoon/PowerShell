<#
    .SYNOPSIS
        This function will set the default Unix attributes on user objects in Active Directory.

    .DESCRIPTION
        This function will set the default Unix attributes on user objects in Active Directory.

    .EXAMPLE
        Set-UserUnixAttribs -User amoon
        Set-UserUnixAttribs -OU "OU=Users,DC=contoso,DC=com"

    .OUTPUTS
        This function will output the user objects that were modified.

    .NOTES
        CHANGE HISTORY:
            2023/01/03 - Initial Version
                Initial Version
    .link
        https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-aduser?view=windowsserver2022-ps
#>
Function Set-UserUnixAttribs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The OU to search for users in.",
            Position = 0)]
        [String]
        $OU,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The user to modify.",
            Position = 0)]
        [String]
        $UserArg
    )

    # Import the Active Directory module
    Try {
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    Catch {
        Write-Error "An error occurred while importing the ActiveDirectory module: $Error"
        Return
    }

    # We prefix UID/GID by 10 to avoid conflicts with system accounts
    $Prefix = 10

    # Create an array to hold the user information
    $UserObjs = @()

    # If the OU parameter is specified, get all users in the OU
    If ($OU) {
        Try {
            $UserObjs = Get-ADUser -Filter * -SearchBase $OU -ErrorAction Stop
        }
        Catch {
            Write-Error "An error occurred while searching for users in the OU: $Error"
            Return
        }
    }
    # If the Users parameter is specified, get all users in the array
    ElseIf ($UserArg) {
        Try {
            $UserObjs = Get-ADUser -Identity $UserArg -ErrorAction Stop
        }
        Catch {
            Write-Error "An error occurred while searching for the specified user: $Error"
            Return
        }
    }
    # If neither parameter is specified, exit the function
    Else {
        Write-Error "You must specify either the OU or Users parameter."
        Return
    }
    # Loop through each user and get their name and RID
    ForEach ($UnixUser in $UserObjs) {
        Write-Host "Processing:" $UnixUser.SamAccountName
        $SamAccountName = $UnixUser.SamAccountName
        $UID = $SamAccountName.ToLower()
        $SID = $UnixUser.SID.Value
        $RID = $SID.Substring($SID.LastIndexOf("-") + 1)
        $UIDNumber = "{0:D2}{1}" -f $Prefix, $RID
        Write-Host ""

        # Create "Replace" hash table
        $Properties = @{
            uid               = "$UID"
            uidNumber         = "$UIDNumber"
            gidNumber         = "10513"
            unixHomeDirectory = "/people/$UID"
            loginShell        = "/bin/zsh"
        }
        Try {
            # Replace properties on user
            Write-Host "Printing hash table properties.."
            Write-Host $Properties.Keys":"$Properties.Values
            Get-ADuser -Identity $UnixUser | Set-ADUser -Replace $Properties -ErrorAction Stop 
            Write-Host "Modified UNIX attributes for:" $UnixUser.SamAccountName 
        }
        Catch {
            Write-Error "An error occurred while modifying the UNIX attributes for "$SamAccountName" $Error"
        }
    }
}