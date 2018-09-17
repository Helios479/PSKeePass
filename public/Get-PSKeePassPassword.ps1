<#
.SYNOPSIS

Get password from KeePass database

.DESCRIPTION

Get password from KeePass database. Will set the password in the clipboard unless "-Show" is specified, in which case it will type the password as plain text in the console.

.PARAMETER Title

Title of the KeePass entry for the desired password

.PARAMETER Show

Switch for typing the password in plain text to the console rather than setting the clipboard

.PARAMETER DatabasePath

Path to the KeePass database

.PARAMETER DatabasePassword

Password to the KeePass database

.INPUTS

None

.OUTPUTS

System.String

.EXAMPLE

C:\PS> Get-PSKeePassPassword -Title 'GitHub'
Set the password for the 'GitHub' entry to the clipboard

.EXAMPLE

C:\PS> Get-PSKeePassPassword -Title 'GitHub' -Show
Type the password for the 'GitHub' entry to the console

.EXAMPLE

C:\PS> Get-PSKeePassPassword -Title 'GitHub' -DatabasePath "$env:UserProfile\WorkPasswords.kdbx" -DatabasePassword 'password'
Set the password for the 'GitHub' entry from the KeePass database "WorkPasswords.kdbx" using the database password 'password'

.LINK

Get-PSKeePassTitles
#>
Function Get-PSKeePassPassword {
    [cmdletbinding()]
    param(
        $DatabasePath = $Script:Config.KeePassDatabasePath,
        $DatabasePassword = (Import-Clixml $Script:Config.KeePassDatabasePasswordFile).GetNetworkCredential().Password,
        [Switch]$Show
    )
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Title'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Get-PSKeePassTitles
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }
    Begin {
        $Title = $PSBoundParameters[$ParameterName]
        Write-Verbose "Loading database at $DatabasePath"
        $Database = New-PSKeePassConnection -DatabasePath $DatabasePath -DatabasePassword $DatabasePassword
    }
    Process{
        Write-Verbose "Getting entry for $Title"
        $Entry = $Database.RootGroup.GetObjects($true, $true) | Where-Object -FilterScript {$_.Strings.ReadSafe("Title") -eq $Title}
        $Password = $Entry.Strings.ReadSafe("Password")
        If ($Show) {
            Write-Verbose "-Show specified; return password as plain text"
            Return $Password
        }
        Else {
            Write-Verbose "Setting password to clipboard"
            $Password | Set-Clipboard
        }
    }
    End{
        Write-Verbose "Closing database"
        $Database.Close()
    }
}