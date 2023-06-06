taskkill /IM sysprep.exe /F
start /wait powershell.exe -Executionpolicy Bypass -File "%~dp0Upload-Autopilot-User.ps1"
%WINDIR%\system32\sysprep\sysprep.exe /reboot /oobe