$App1 = "Zoom.Zoom"
$App2 = "Microsoft.VisualStudio.2019.Enterprise"
$App3 = "DominikReichl.KeePass"
$App4 = "WiresharkFoundation.Wireshark"
$App5 = "VideoLAN.VLC"
$App6 = "Audacity.Audacity"

$Winget = Get-ChildItem -Path (Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath "WindowsApps") -ChildPath "Microsoft.DesktopAppInstaller*_x64*\winget.exe")

if ($(&$winget upgrade --accept-source-agreements) -like "* $App1 *") {
	Write-Host "Upgrade available for: $App1"
	exit 1 # upgrade available, remediation needed
}
elseif ($(&$winget upgrade --accept-source-agreements) -like "* $App2 *") {
	Write-Host "Upgrade available for: $App2"
	exit 1 # upgrade available, remediation needed
}
elseif ($(&$winget upgrade --accept-source-agreements) -like "* $App3 *") {
	Write-Host "Upgrade available for: $App3"
	exit 1 # upgrade available, remediation needed
}
elseif ($(&$winget upgrade --accept-source-agreements) -like "* $App4 *") {
	Write-Host "Upgrade available for: $App4"
	exit 1 # upgrade available, remediation needed
}
elseif ($(&$winget upgrade --accept-source-agreements) -like "* $App5 *") {
	Write-Host "Upgrade available for: $App5"
	exit 1 # upgrade available, remediation needed
}
elseif ($(&$winget upgrade --accept-source-agreements) -like "* $App6 *") {
	Write-Host "Upgrade available for: $App6"
	exit 1 # upgrade available, remediation needed
}
else {
	Write-Host "No Upgrade available"
	exit 0 # no upgrade, no action needed
}