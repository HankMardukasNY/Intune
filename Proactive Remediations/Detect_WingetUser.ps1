#Add IDs of updates to run
$Allowlist = @(
'7zip.7zip',
'Audacity.Audacity',
'Bitwarden.Bitwarden',
'BlenderFoundation.Blender',
'Cisco.CiscoWebexMeetings',
'Cisco.WebexTeams',
'Dell.CommandUpdate.Universal',
'Dell.DisplayManager',
'DominikReichl.KeePass',
'EpicGames.EpicGamesLauncher',
'Inkscape.Inkscape',
'JAMSoftware.TreeSize.Free',
'JetBrains.IntelliJIDEA.Community',
'Logitech.CameraSettings',
'Logitech.GHUB',
'Logitech.LGS',
'Logitech.LogiTune',
'Logitech.Options',
'Logitech.Sync',
'Logitech.UnifyingSoftware',
'Microsoft.PowerShell',
'Microsoft.VisualStudio.2019.Enterprise',
'Microsoft.VisualStudioCode',
'Microsoft.WindowsTerminal',
'mRemoteNG.mRemoteNG',
'Notepad++.Notepad++',
'Nvidia.GeForceExperience',
'NZXT.CAM',
'Paessler.PRTGDesktop',
'PuTTY.PuTTY',
'SanfordLP.DYMOConnect',
'SonicPi.SonicPi',
'TexasInstruments.TI-SmartView.TI-84Plus',
'Valve.Steam',
'VideoLAN.VLC',
'WiresharkFoundation.Wireshark',
'Zoom.Zoom'
)

Function Get-WingetPath
 {
    param( 
    ) 
    if(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
 {
    $resolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    $wingetPath = $ResolveWingetPath[-1].Path
    $winget= Join-Path -Path $wingetPath -ChildPath "winget.exe"
 }
    else
        {
            $wingetPath = Get-Command winget.exe -ErrorAction SilentlyContinue
            $winget = $wingetPath.Source
    } return $winget
 }

$winget = Get-WingetPath

# Get all available upgrades
$Upgrade = &$winget upgrade --scope user --accept-source-agreements | Out-String

# Run through the WinGet list, compare with the Allow list
foreach($App in $Allowlist){

  if ($Upgrade.Contains($App)){
    Write-Host "Upgrade available for $App"
    $PendingUpgrades += "$App "
  }
}

if($PendingUpgrades){
Write-Host "Pending $PendingUpgrades"
exit 1
}
else{
Write-Host "No upgrades needed"
exit 0
}