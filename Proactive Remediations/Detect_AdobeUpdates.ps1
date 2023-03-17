try {

$cmdPath = "${env:ProgramFiles(x86)}\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
$cmdArgList = @(
	"--action=list"
)

if (Test-Path -Path $cmdPath){
        Write-Host "Adobe RUM Found"
        $CheckUpdates = & $cmdPath $cmdArgList 2>&1 | Out-String
            if ($CheckUpdates -match 'No new applicable Updates'){   
                Write-Host "No updates needed"
                exit 0
                }
            else {
                Write-Host "Updates available"
                exit 1
            }
}
else {
    Write-Host "RUM Not Installed"
    exit 0
    }   
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}