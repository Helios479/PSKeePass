Function New-PSKeePassConfig {
    [cmdletbinding()]
    param(
        [parameter()]$ConfigPath = "$((Get-Item $PSScriptRoot).Parent.FullName)\Config.xml",
        [parameter()][Switch]$Force
    )
    # Check for existing Config.ps1
    If ((Test-Path -Path $ConfigPath) -and (-not ($Force))){
        Throw "Config.ps1 already exists at $ConfigPath; rerun with -Force to overwrite"
    }
    # Find KeePass Exe
    $KeePassExe = (Get-ChildItem -Path "C:\Program Files*" -Filter "KeePass.exe" -Recurse).FullName
    If ($KeePassExe.Count -ne 1) {
        $KeePassExe = $KeePassExe[0]
    }

    # Find XmlSerializers.dll
    $XmlSerializersDll = (Get-ChildItem -Path "C:\Program Files*" -Filter "KeePass.XmlSerializers.dll" -Recurse).FullName
    If ($XmlSerializersDll.Count -ne 1) {
        $XmlSerializersDll = $XmlSerializersDll[0]
    }

    # Find KeePass Database
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.FileName = "*.kdbx"
    $OpenFileDialog.Title = "Select KeePass Database File"
    $OpenFileDialog.ShowDialog() | Out-Null
    $KeePassDatabasePath = $OpenFileDialog.FileName

    # Get Database Password
    $PasswordObject = Get-Credential -Message "Enter the password for the KeePass Database"
    $DbName = (Get-Item -Path $KeePassDatabasePath).BaseName
    $KeePassDatabasePasswordFile = "$env:UserProfile\$DbName.xml"
    $PasswordObject | Export-Clixml -Path $KeePassDatabasePasswordFile

    # Build Config object
    $ConfigObj = [PSCustomObject]@{
        'KeePassExe' = "$KeePassExe"
        'XmlSerializersDll' = $XmlSerializersDll
        'KeePassDatabasePath' = $KeePassDatabasePath
        'KeePassDatabasePasswordFile' = $KeePassDatabasePasswordFile
    }
    
    # Export Config
    $ConfigObj | Export-Clixml -Path $ConfigPath
}