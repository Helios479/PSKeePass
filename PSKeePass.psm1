#Get public and private function definition files while excluding tests
$Public  = @( Get-ChildItem -Path $PSScriptRoot\public -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object Name -NotMatch "\.Tests\.ps1$")
$Private = @( Get-ChildItem -Path $PSScriptRoot\private -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object Name -NotMatch "\.Tests\.ps1$")

#Dot source the files
Foreach($import in @($Public + $Private)){
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

#Load Config
$ConfigFile = "$PSScriptRoot\Config.xml"
If (Test-Path $ConfigFile) {
    $Script:Config =  Import-Clixml $ConfigFile
}
Else {
    New-PSKeePassConfig
    $Script:Config = Import-Clixml $ConfigFile
}
#Test that KeePass is installed
IF (-not(Test-Path -Path $Script:Config.KeePassExe)){
    Throw "KeePass not found at $($Script:Config.KeePassExe); install KeePass or modify Config.ps1"
}
#Load .Net Binaries
[Reflection.Assembly]::LoadFile("$($Script:Config.KeePassExe)") | Out-Null
[Reflection.Assembly]::LoadFile("$($Script:Config.XmlSerializersDll)") | Out-Null