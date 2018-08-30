Function New-PSKeePassConfig {
    [cmdletbinding()]
    param(
        [parameter()]$ConfigPath = "$((Get-Item $PSScriptRoot).Parent.FullName)Config.ps1",
        [parameter()][Switch]$Force
    )
    If ((Test-Path -Path $ConfigPath) -and (-not ($Force))){
        Throw "Config.ps1 already exists at $ConfigPath; rerun with -Force to overwrite"
    }
}