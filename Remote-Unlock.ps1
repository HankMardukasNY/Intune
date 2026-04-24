$LegalNoticeTitle = ""
$LegalNoticeMessage = ""
$CredentialProviders = ""

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

#Restart sign-in screen
Stop-Process -Name LogonUI