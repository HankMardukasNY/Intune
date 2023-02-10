$App1 = "Microsoft.VisualStudioCode"
$App2 = "Zoom.Zoom"
$App3 = "Microsoft.WindowsTerminal"

$Upgrade = winget upgrade --scope user --accept-source-agreements | Out-String

if ($Upgrade.Contains($App1)) {
	Write-Host "Upgrade available for: $App1"
    winget upgrade --exact $App1 --silent --force --scope user --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App2)) {
	Write-Host "Upgrade available for: $App2"
    winget upgrade --exact $App2 --silent --force --scope user --accept-package-agreements --accept-source-agreements
}
if ($Upgrade.Contains($App3)) {
	Write-Host "Upgrade available for: $App3"
    winget upgrade --exact $App3 --silent --force --scope user --accept-package-agreements --accept-source-agreements
}

Write-Host "Upgrades Complete"
exit 0