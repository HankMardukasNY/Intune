Write-Host "Closing Microsoft Teams & Edge"
Get-Process -Name Teams, msedge -ErrorAction SilentlyContinue | Stop-Process
Write-Host "Starting Questar Secure Browser"
Start-Process -NoNewWindow -FilePath "C:\Program Files (x86)\Questar Assessment Inc\QuestarStudent-NY\QuestarStudent-NY.exe" -WorkingDirectory "C:\Program Files (x86)\Questar Assessment Inc\QuestarStudent-NY\"