$App1 = "Zoom.Zoom"
$App2 = "Microsoft.VisualStudio.2019.Enterprise"
$App3 = "DominikReichl.KeePass"
$App4 = "WiresharkFoundation.Wireshark"
$App5 = "VideoLAN.VLC"
$App6 = "Audacity.Audacity"


try{
    # resolve and navigate to winget.exe
    $Winget = Get-ChildItem -Path (Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath "WindowsApps") -ChildPath "Microsoft.DesktopAppInstaller*_x64*\winget.exe")

    # upgrade command
    &$winget upgrade --exact $App1 --silent --force --accept-package-agreements --accept-source-agreements
    &$winget upgrade --exact $App2 --silent --force --accept-package-agreements --accept-source-agreements
    &$winget upgrade --exact $App3 --silent --force --accept-package-agreements --accept-source-agreements
    &$winget upgrade --exact $App4 --silent --force --accept-package-agreements --accept-source-agreements
    &$winget upgrade --exact $App5 --silent --force --accept-package-agreements --accept-source-agreements
    &$winget upgrade --exact $App6 --silent --force --accept-package-agreements --accept-source-agreements
    exit 0

}catch{
    Write-Error "Error while installing upgrades"
    exit 1
}