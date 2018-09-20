<#
.SYNOPSIS

Get KeePass entry

.DESCRIPTION

Get KeePass entry.
Returns all data from KeePass entry as object

.PARAMETER Title

Title of the KeePass entry (DynamicParameter)

.PARAMETER DatabasePath

Path to the KeePass database

.PARAMETER DatabasePassword

Password to the KeePass database

.INPUTS

None

.OUTPUTS

KeePassLib.PwEntry

.EXAMPLE

C:\PS> $Entry = Get-PSKeePassEntry -Title 'GitHub'
Populate $Entry variable with data from 'GitHub' entry from the KeePass database

.LINK

New-KeePassConnection
#>
Function Get-PSKeePassEntry {
    [cmdletbinding()]
    param(
        $DatabasePath = $Script:Config.KeePassDatabasePath,
        $DatabasePassword = (Import-Clixml $Script:Config.KeePassDatabasePasswordFile).GetNetworkCredential().Password
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
    Process {
        Write-Verbose "Getting entry for $Title"
        $Entry = $Database.RootGroup.GetObjects($true, $true) | Where-Object -FilterScript {$_.Strings.ReadSafe("Title") -eq $Title}
        Return $Entry
    }
    End {
        Write-Verbose "Closing database"
        $Database.Close()
    }
}