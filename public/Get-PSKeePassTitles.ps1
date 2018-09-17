Function Get-PSKeePassTitles {
    [cmdletbinding()]
    param(
        $DatabasePath = $Script:Config.KeePassDatabasePath,
        $DatabasePassword = (Import-Clixml $Script:Config.KeePassDatabasePasswordFile).GetNetworkCredential().Password
    )
    Try {
        $Titles = @()
        $Database = New-PSKeePassConnection -DatabasePath $DatabasePath -DatabasePassword $DatabasePassword
        $Database.RootGroup.GetObjects($true, $true) | %{$Titles += ($_.Strings.ReadSafe("Title"))}
        Return $Titles
    }
    Catch {
        Throw $_
    }
    Finally {
        $Database.Close()
    }
}