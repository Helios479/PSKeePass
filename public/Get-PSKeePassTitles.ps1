<#
.SYNOPSIS

Get all titles in KeePass database

.DESCRIPTION

Get all titles in KeePass database

.PARAMETER DatabasePath

Path to KeePass database

.PARAMETER DatabasePassword

Password to KeePass database

.INPUTS

None

.OUTPUTS

System.String

.EXAMPLE

C:\PS> Get-PSKeePassTitles

Get all titles from KeePass database set up on Config.xml

.EXAMPLE

C:\PS> Get-PSKeePassTitles -DatabasePath "$env:UserProfile\WorkPasswords.kdbx" -DatabasePassword 'password'

Get all titles in KeePass database "WorkPasswords.kdbx" using password 'password'

.LINK

Get-PSKeePassPassword
#>
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