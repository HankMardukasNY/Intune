$App1 = "Zoom.Zoom"
$App2 = "Microsoft.VisualStudio.2019.Enterprise"
$App3 = "DominikReichl.KeePass"
$App4 = "WiresharkFoundation.Wireshark"
$App5 = "VideoLAN.VLC"
$App6 = "Audacity.Audacity"
$App7 = "JetBrains.IntelliJIDEA.Community"
$App8 = "Notepad++.Notepad++"
$App9 = "BlenderFoundation.Blender"

#$App = "Microsoft.VCRedist.2015+.x86"
#$App = "Microsoft.VCRedist.2015+.x64"
#$App = "Microsoft.SQLServer2012NativeClient"
#$App = "Microsoft.VCRedist.2013.x86"
#$App = "Microsoft.VCRedist.2013.x64"


$Winget = Get-ChildItem -Path (Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath "WindowsApps") -ChildPath "Microsoft.DesktopAppInstaller*_x64*\winget.exe") | Select-Object -First 1
$Upgrade = &$winget upgrade --scope machine --accept-source-agreements | Out-String

if ($Upgrade.Contains($App1)) {
	Write-Host "Upgrade available for: $App1"
    &$winget upgrade --exact $App1 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App2)) {
	Write-Host "Upgrade available for: $App2"
    &$winget upgrade --exact $App2 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App3)) {
	Write-Host "Upgrade available for: $App3"
    &$winget upgrade --exact $App3 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App4)) {
	Write-Host "Upgrade available for: $App4"
    &$winget upgrade --exact $App4 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App5)) {
	Write-Host "Upgrade available for: $App5"
    &$winget upgrade --exact $App5 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App6)) {
	Write-Host "Upgrade available for: $App6"
    &$winget upgrade --exact $App6 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App7)) {
    $path = "C:\Program Files (x86)\JetBrains"
    $Uninstaller = Get-ChildItem -Path $path -Recurse -Filter "*Uninstall.exe*" | select -expand FullName
        foreach ($EXE in $Uninstaller){ 
            Start-Process -NoNewWindow -FilePath "$EXE" -ArgumentList "/S" -Wait
        }
    &$winget install --exact $App7 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
    }
if ($Upgrade.Contains($App8)) {
	Write-Host "Upgrade available for: $App8"
    &$winget upgrade --exact $App8 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App9)) {
	Write-Host "Upgrade available for: $App9"
    &$winget upgrade --exact $App9 --silent --force --scope machine --accept-package-agreements --accept-source-agreements
}

Write-Host "Upgrades Complete"
exit 0
