#This script removes default Windows 10 appx programs

$Apps = @(

"*Microsoft.GetHelp*"
"*Microsoft.Getstarted*"
"*Microsoft.WindowsMaps*"
"*Microsoft.MicrosoftSolitaireCollection*"
"*Microsoft.SkypeApp*"
"*king.com.CandyCrushSodaSaga*"
"*disney*"
"*hiddencity*"
"*empires*"
"*dolby*"
"*microsoft.windowscommunicationsapps*"
"*Microsoft.BingNews*"
"*linkedin*"
"*ConnectivityStore*"
"*HP Client Security Manager*"
"*HP Connection Manager*"
"*HP Sure Click*"
"*HP Notifications*"
"*Microsoft.OneConnect*"
"*Microsoft.MixedReality.Portal*"
"*Microsoft.BingWeather*"
"*Twitter*"
"*Office.Sway*"
"*bingsports*"
"*Microsoft.WindowsFeedbackHub*"
"*Facebook*"
"*Microsoft.Asphalt8Airborne*"
"*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
"*Microsoft.3dbuilder*"
"*XboxOneSmartGlass*"
"*Microsoft.XboxApp*"
"*Microsoft3DViewer*"
"*Microsoft.Messaging*"
"*Microsoft.YourPhone*"
"*Microsoft.GamingApp*"
"*Kortext.Kortext*"
"*VictoryVR.VictoryVR*"
"*Microsoft.GamingApp*"
)

foreach ($App in $Apps) {

Get-AppxPackage -AllUsers -Name $App| Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Write-Output "Uninstalling $App"

}
