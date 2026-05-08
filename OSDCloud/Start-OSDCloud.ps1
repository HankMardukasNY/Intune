#Start-OSDCloud -Firmware -Restart -ZTI -OSName 'Windows 11 25H2 x64' -OSLanguage en-us -OSEdition Pro -OSActivation Retail

#Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$OSName = 'Windows 11 25H2 x64'
$OSEdition = 'Pro'
$OSActivation = 'Retail'
$OSLanguage = 'en-us'

#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$true
    MSCatalogFirmware = [bool]$true
    MSCatalogDiskDrivers = [bool]$true
    MSCatalogNetDrivers = [bool]$true
    MSCatalogScsiDrivers = [bool]$true
    RecoveryPartition = [bool]$true
    OEMActivation = [bool]$true
    WindowsUpdate = [bool]$true
    WindowsUpdateDrivers = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$false
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB = [bool]$true
    CheckSHA1 = [bool]$true
    ZTI = [bool]$true
    updateDiskDrivers = [bool]$true
    updateFirmware = [bool]$true
    updateNetworkDrivers = [bool]$true
    updateSCSIDrivers = [bool]$true
    SyncMSUpCatDriverUSB = [bool]$true
    OSNames = @('Windows 11 25H2 x64', 'Windows 11 24H2 x64')
    OSVersionNames = @('Windows 11')
    BrandName = 'Valley Stream Central High School District'
}

#Launch OSDCloud
Write-Host "Starting OSDCloud" -ForegroundColor Green
write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"

Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage