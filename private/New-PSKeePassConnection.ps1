Function New-PSKeePassConnection {
    [cmdletbinding()]
    param(
        $DatabasePath,
        $DatabasePassword
    )
    $KeePassDb = New-Object KeePassLib.PwDatabase
    $DbKey = New-Object KeePassLib.Keys.CompositeKey
    $DbKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($DatabasePassword)))
    $IOConnectionInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $IOCOnnectionInfo.Path = "$DatabasePath"
    $KeePassDb.Open($IOCOnnectionInfo,$DbKey,(New-Object KeePassLib.Interfaces.NullStatusLogger))
    Return $KeePassDb
}