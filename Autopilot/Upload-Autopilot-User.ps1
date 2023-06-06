#Prevent Sleep
$Key1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    If (!(Test-Path $Key1)) {
        New-Item -Path $Key1 -Force | Out-Null
    }
    Set-ItemProperty -Path $Key1 -Name "InactivityTimeoutSecs" -Type DWord -Value 10800

Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change monitor-timeout-ac 0

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Set-Location -Path "$env:ProgramFiles\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
.\Get-WindowsAutopilotInfo.ps1 -GroupTag "User-Driven-Azure" -Online -Assign

#Prevent Sleep
$Key1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    If (!(Test-Path $Key1)) {
        New-Item -Path $Key1 -Force | Out-Null
    }
    Set-ItemProperty -Path $Key1 -Name "InactivityTimeoutSecs" -Type DWord -Value 1800

Powercfg /Change monitor-timeout-dc 15
Powercfg /Change standby-timeout-dc 15
Powercfg /Change standby-timeout-ac 60
Powercfg /Change monitor-timeout-ac 15