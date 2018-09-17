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
        $Database = New-PSKeePassConnection -DatabasePath $DatabasePath -DatabasePassword $DatabasePassword
    }
    Process{
        $Entry = $Database.RootGroup.GetObjects($true, $true) | Where-Object -FilterScript {$_.Strings.ReadSafe("Title") -eq $Title}
        $Password = $Entry.Strings.ReadSafe("Password")
        If ($Show) {
            Return $Password
        }
        Else {
            $Password | Set-Clipboard
        }
    }
    End{
        $Database.Close()
    }
}