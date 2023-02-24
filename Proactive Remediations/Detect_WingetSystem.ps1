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
	exit 1
}
elseif ($Upgrade.Contains($App2)) {
	Write-Host "Upgrade available for: $App2"
	exit 1
}
elseif ($Upgrade.Contains($App3)) {
	Write-Host "Upgrade available for: $App3"
	exit 1
}
elseif ($Upgrade.Contains($App4)) {
	Write-Host "Upgrade available for: $App4"
	exit 1
}
elseif ($Upgrade.Contains($App5)) {
	Write-Host "Upgrade available for: $App5"
	exit 1
}
elseif ($Upgrade.Contains($App6)) {
	Write-Host "Upgrade available for: $App6"
	exit 1
}
elseif ($Upgrade.Contains($App7)) {
	Write-Host "Upgrade available for: $App7"
	exit 1
}
elseif ($Upgrade.Contains($App8)) {
	Write-Host "Upgrade available for: $App8"
	exit 1
}
elseif ($Upgrade.Contains($App9)) {
	Write-Host "Upgrade available for: $App9"
	exit 1
}

else {
	Write-Host "No Upgrade available"
	exit 0
}
