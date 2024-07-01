<#PSScriptInfo
<#
.SYNOPSIS
Installs the latest Windows 10 quality updates and drivers.
.DESCRIPTION
This script uses the PSWindowsUpdate module to install the latest cumulative update for Windows 10 and installs latest drivers.
.EXAMPLE
.\UpdateOS.ps1
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)] [Switch] $HardReboot = $false
)

Process
{

# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\Microsoft\UpdateOS"))
{
    Mkdir "$($env:ProgramData)\Microsoft\UpdateOS"
}
Set-Content -Path "$($env:ProgramData)\Microsoft\UpdateOS\UpdateOS.ps1.tag" -Value "Installed"

# Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\UpdateOS\UpdateOS.log"

# Load module from PowerShell Gallery
$null = Install-PackageProvider -Name NuGet -Force
$null = Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

# Install all available updates
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false | Out-Null
Get-WindowsUpdate -Install -UpdateType Driver -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue | Select Title, Result | Format-Table
Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -IgnoreReboot -MicrosoftUpdate -NotCategory 'FeaturePacks' -NotTitle 'Preview' -ErrorAction SilentlyContinue | Select Title, Result | Format-Table

Write-Host "Exiting with return code 3010 to indicate a soft reboot is needed."
Exit 3010
}
