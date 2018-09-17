Function Get-PSKeePassTitles {
    [cmdletbinding()]
    param(
        $DatabasePath = $Script:Config.KeePassDatabasePath,
        $DatabasePassword = (Import-Clixml $Script:Config.KeePassDatabasePasswordFile).GetNetworkCredential().Password
    )
    Begin {
        $Database = New-PSKeePassConnection -DatabasePath $DatabasePath -DatabasePassword $DatabasePassword
    }
    Process {
        Try {
            $Titles = @()
            $Database.RootGroup.GetObjects($true, $true) | %{$Titles += ($_.Strings.ReadSafe("Title"))}
            Return $Titles
        }
        Catch {
            Throw $_
        }
    }
    End {
        $Database.Close()
    }
}