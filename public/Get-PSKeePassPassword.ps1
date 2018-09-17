Function Get-PSKeePassPassword {
    [cmdletbinding()]
    param(
        $DatabasePath = $Script:Config.KeePassDatabasePath,
        $DatabasePassword = (Import-Clixml $Script:Config.KeePassDatabasePasswordFile).GetNetworkCredential().Password,
        $Title,
        [Switch]$Show
    )
    Begin {
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