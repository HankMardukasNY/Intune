$LegalNoticeTitle = "Computer Locked"
$LegalNoticeMessage = "This computer has been locked. Please bring this laptop to the tech office."

$RegistryCredentialProviders = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers').PSChildName

$CredentialProviders = "{01A30791-40AE-4653-AB2E-FD210019AE88},{1b283861-754f-4022-ad47-a5eaaa618894},{1ee7337f-85ac-45e2-a23c-37c753209769},{2135f72a-90b5-4ed3-a7f1-8bb705ac276a},{25CBB996-92ED-457e-B28C-4774084BD562},{27FBDB57-B613-4AF2-9D7E-4FA7A66C21AD},{3dd6bec0-8193-4ffe-ae25-e08e39ea4063},{48B4E58D-2791-456C-9091-D524C6C706F2},{600e7adb-da3e-41a4-9225-3c0399e88c0c},{60b78e88-ead8-445c-9cfd-0b87f74ea6cd},{8841d728-1a76-4682-bb6f-a9ea53b4b3ba},{8AF662BF-65A0-4D0A-A540-A338A999D36F},{8FD7E19C-3BF7-489B-A72C-846AB3678C96},{94596c7e-3744-41ce-893e-bbf09122f76a},{BEC09223-B018-416D-A0AC-523971B639F5},{C5D7540A-CD51-453B-B22B-05305BA03F07},{C885AA15-1764-4293-B82A-0586ADD46B35},{cb82ea12-9f71-446d-89e1-8d0924e1256e},{D6886603-9D2F-4EB2-B667-1971041FA96B},{e74e57b0-6c6d-44d5-9cda-fb2df5ed7435},{F8A0B131-5F68-486c-8040-7E8FC3C85BB6},{F8A1793B-7873-4046-B2A7-1F318747F427}"

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegistryNames = @("LegalNoticeCaption","LegalNoticeText","ExcludedCredentialProviders")
$RegistryValues = @("$LegalNoticeTitle","$LegalNoticeMessage","$CredentialProviders")

$i = 0

#Set if registry values are not set
While ($i -lt $RegistryNames.Count) {
$Value = Get-ItemProperty -Path $RegistryPath -Name $RegistryNames[$i] -ErrorAction SilentlyContinue

if($Value.($RegistryNames[$i]) -ne $($RegistryValues[$i])){
Write-Output "$($RegistryNames[$i]) Not Set. Setting registry value for $($RegistryNames[$i])."
Set-ItemProperty -Path $RegistryPath -Name $($RegistryNames[$i]) -Value $($RegistryValues[$i])
}
else{
Write-Output "$($RegistryNames[$i]) Already Set."
}
$i++
}

#Force log off if user is signed in
If ((Get-CimInstance -ClassName Win32_ComputerSystem).Username -ne $null) {
Invoke-CimMethod -Query 'SELECT * FROM Win32_OperatingSystem' -MethodName 'Win32ShutdownTracker' -Arguments @{ Flags = 4; Comment = 'Computer Locked' }
} Else {
#Restart sign-in screen if user is not signed in
Stop-Process -Name LogonUI
}