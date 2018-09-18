<#
.SYNOPSIS

Get KeePass entry as PSCredential

.DESCRIPTION

Get KeePass entry as PSCredential.
Takes title from DynamicParameter and constructs PSCredential from stored username and password

.PARAMETER Title

Title of the KeePass entry (DynamicParameter)

.PARAMETER DatabasePath

Path to the KeePass database

.PARAMETER DatabasePassword

Password to the KeePass database

.INPUTS

None

.OUTPUTS

System.Management.Automation.PSCredential

.EXAMPLE

C:\PS> Enter-PSSession -ComputerName Server01 -Credential (Get-PSKeePassCredential -Title DomainAdmin)
Enters a PSSession to Server01 using the stored KeePass username and password under the 'DomainAdmin' title

.EXAMPLE

C:\PS> Get-PSKeePassCredential -Title User01 | Export-Clixml -Path $env:UserProfile\User01.xml
Gets credential for title User01 from the KeePass database and exports the PSCredential object to User01.xml

.LINK

New-PSKeePassConnection
#>
Function Get-PSKeePassCredential {
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
        $Username = $Entry.Strings.ReadSafe("UserName")
        $Password = $Entry.Strings.ReadSafe("Password")
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        Write-Verbose "Creating credential for $UserName"
        $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        Return $Credential
    }
    End {
        Write-Verbose "Closing database"
        $Database.Close()
    }
}