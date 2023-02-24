$App1 = "Microsoft.VisualStudioCode"
$App2 = "Zoom.Zoom"
$App3 = "Microsoft.WindowsTerminal"

$Upgrade = winget upgrade --scope user --accept-source-agreements | Out-String

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
else {
	Write-Host "No Upgrade available"
	exit 0
}
