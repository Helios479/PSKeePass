#Get public and private function definition files while excluding tests
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue | Where-Object Name -NotMatch "\.Tests\.ps1$")
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue | Where-Object Name -NotMatch "\.Tests\.ps1$")

#Dot source the files
Foreach($import in @($Public + $Private))
{
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
Try {
    . $PSScriptRoot\Config.ps1
}
Catch {
    New-PSKeePassConfig.ps1
}
#Test that KeePass is installed
IF (-not(Test-Path -Path $Script:Config.KeePassExe)){
    Throw "KeePass not found at $($Script:Config.KeePassExe); install KeePass or modify Config.ps1"
}