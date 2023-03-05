#Add ids of updates to run
$Allowlist = @(
'Zoom.Zoom',
'Microsoft.VisualStudio.2019.Enterprise',
'DominikReichl.KeePass',
'WiresharkFoundation.Wireshark',
'VideoLAN.VLC',
'Audacity.Audacity',
'Notepad++.Notepad++',
'BlenderFoundation.Blender',
'Razer Synapse',
'Nvidia.GeForceExperience',
'Microsoft.VisualStudioCode',
'Zoom.Zoom',
'Microsoft.WindowsTerminal'
)

#Add ids of updates to skip
$Blocklist = @(
'Microsoft.Teams',
'Microsoft.Office',
'Microsoft.VCRedist.2015+.x86',
'Microsoft.VCRedist.2015+.x64',
'Microsoft.SQLServer2012NativeClient',
'Microsoft.VCRedist.2013.x86',
'Microsoft.VCRedist.2013.x64'
)

# object to be used basically for view only
class Software {
  [string]$Name
  [string]$Id
  [string]$Version
  [string]$AvailableVersion
}

# get the available upgrades
$Winget = Get-ChildItem -Path (Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath "WindowsApps") -ChildPath "Microsoft.DesktopAppInstaller*_x64*\winget.exe") | Select-Object -First 1
$upgradeResult = &$winget upgrade --scope machine --accept-source-agreements

# run through the list and get the app data
$upgrades = @()
$idStart = -1
$isStartList = 0
$upgradeResult | ForEach-Object -Process {

  if ($isStartList -lt 1 -and -not $_.StartsWith("Name") -or $_.StartsWith("---") -or $_.StartsWith("The following packages have an upgrade"))
  {
    return
  }

  if ($_.StartsWith("Name"))
  {
    $idStart = $_.toLower().IndexOf("id")
    $isStartList = 1
    return
  }

  if ($_.Length -lt $idStart)
  {
    return
  }

  $Software = [Software]::new()
  $Software.Name = $_.Substring(0, $idStart-1)
  $info = $_.Substring($idStart) -split '\s+'
  $Software.Id = $info[0]
  $Software.Version = $info[1]
  $Software.AvailableVersion = $info[2]

  $upgrades += $Software
}

# view the list
$upgrades | Format-Table

# run through the WinGet list, compare with the Allow/Block lists and execute the upgrade
$upgrades | ForEach-Object -Process {

  if ($Allowlist -contains $_.Id){
    Write-Host "Upgrade available for $($_.Id)"
    $PendingUpdates += "$($_.id) "
  }
  elseif ($Blocklist -contains $_.Id) {
   Write-Host "Skipped upgrade for $($_.id)"
   return
  }
  else{
   Write-Host "Skipped upgrade for $($_.id)"
   $SkippedUpdates += "$($_.id) "
   return
  }
}
if($PendingUpdates){
Write-Host "Upgrades pending for $PendingUpdates"
exit 1
}
else{
Write-Host "No upgrades needed"
exit 0
}