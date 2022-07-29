try {

$cmdPath = "${env:ProgramFiles(x86)}\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
 
    if (Test-Path -Path $cmdPath){
        Write-Host "Adobe RUM Found"
        exit 1
    }
    else
   {
        Write-Host "Not Found"
        exit 0
    }   
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}