try {

$cmdPath = "${env:ProgramFiles(x86)}\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
$cmdArgList = @(
	"--action=install"
)

$CheckUpdates = & $cmdPath $cmdArgList 2>&1 | Out-String

    if($LASTEXITCODE -eq 0){
    Write-Host "Adobe Apps Updated"
    exit 0
    }
    if($LASTEXITCODE -eq 1){
    Write-Host "Generic error"
    exit 1
    }
    if($LASTEXITCODE -eq 2){
    Write-Host "One or more updates could not be installed"
    exit 1
    }
}
catch {

    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}