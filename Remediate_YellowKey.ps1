<#
.SYNOPSIS
    Remediates CVE-2026-45585 - YellowKey - Windows BitLocker Security Feature Bypass Vulnerability.

.DESCRIPTION
    This script:
      1. Mounts the WinRE image
      2. Loads the WinRE system registry hive
      3. Removes autofstx.exe from the BootExecute registry value
      4. Unloads the registry hive
      5. Unmounts and commits the WinRE image
      6. Re-enables WinRE to reestablish BitLocker trust

.NOTES
    Must be run from an elevated (Administrator) PowerShell session.
    Reference: https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-45585
#>

#region --- Elevation Check ---

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator. Exiting."
    exit 1
}

#endregion

#region --- Variables ---

$MountPath   = "C:\mount"
$HiveName    = "WinREHive"
$HivePath    = "$MountPath\Windows\System32\config\SYSTEM"
$RegKey      = "HKLM\$HiveName\ControlSet001\Control\Session Manager"
$RegKeyPS    = "HKLM:\$HiveName\ControlSet001\Control\Session Manager"
$ValueName   = "BootExecute"
$BadEntry    = "autofstx.exe"

#endregion

#region --- Helper Functions ---

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "[ STEP ] $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "  [  OK  ] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [ FAIL ] $Message" -ForegroundColor Red
}

function Invoke-Command-Safe {
    param(
        [string]$Description,
        [scriptblock]$Command
    )
    Write-Host "         Running: $Description"
    try {
        & $Command
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            throw "Exit code: $LASTEXITCODE"
        }
    }
    catch {
        Write-Fail "$Description failed: $_"
        throw
    }
}

#endregion

#region --- Main Remediation ---

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "  CVE-2026-45585 YellowKey Remediation   " -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

try {

    # Step 1: Create mount directory and mount WinRE
    Write-Step "Step 1: Mounting WinRE image to $MountPath"

    if (-not (Test-Path $MountPath)) {
        New-Item -ItemType Directory -Path $MountPath -Force | Out-Null
        Write-OK "Created mount directory: $MountPath"
    }
    else {
        Write-OK "Mount directory already exists: $MountPath"
    }

    Invoke-Command-Safe "reagentc /mountre" {
        reagentc /mountre /path $MountPath
    }
    Write-OK "WinRE image mounted successfully."


    # Step 2: Load the WinRE system registry hive
    Write-Step "Step 2: Loading WinRE registry hive as HKLM\$HiveName"

    if (-not (Test-Path $HivePath)) {
        throw "Registry hive not found at expected path: $HivePath"
    }

    Invoke-Command-Safe "reg load HKLM\$HiveName" {
        reg load "HKLM\$HiveName" $HivePath
    }
    Write-OK "Registry hive loaded successfully."


    # Step 3: Remove autofstx.exe from BootExecute
    Write-Step "Step 3: Removing '$BadEntry' from BootExecute"

    $currentValue = (Get-ItemProperty -Path $RegKeyPS -Name $ValueName -ErrorAction Stop).$ValueName

    Write-Host "         Current BootExecute entries:"
    $currentValue | ForEach-Object { Write-Host "           - $_" }

    $cleaned = $currentValue | Where-Object { $_.Trim() -ne $BadEntry.Trim() }

    if ($currentValue.Count -eq $cleaned.Count) {
        Write-Host "  [ INFO ] '$BadEntry' was not found in BootExecute. No changes needed." -ForegroundColor Yellow
    }
    else {
        Set-ItemProperty -Path $RegKeyPS -Name $ValueName -Value $cleaned -Type MultiString
        Write-OK "Removed '$BadEntry' from BootExecute."
    }

    Write-Host "         Updated BootExecute entries:"
    $cleaned | ForEach-Object { Write-Host "           - $_" }


    # Step 4: Unload the registry hive
    Write-Step "Step 4: Unloading registry hive"

    # Force garbage collection to release any open handles before unloading
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Invoke-Command-Safe "reg unload HKLM\$HiveName" {
        reg unload "HKLM\$HiveName"
    }
    Write-OK "Registry hive unloaded successfully."


    # Step 5: Unmount and commit the WinRE image
    Write-Step "Step 5: Unmounting and committing WinRE image"

    Invoke-Command-Safe "reagentc /unmountre /commit" {
        reagentc /unmountre /path $MountPath /commit
    }
    Write-OK "WinRE image unmounted and committed."


    # Step 6: Reestablish BitLocker trust for WinRE
    Write-Step "Step 6: Reestablishing BitLocker trust (disable then enable WinRE)"

    Invoke-Command-Safe "reagentc /disable" {
        reagentc /disable
    }
    Write-OK "WinRE disabled."

    Invoke-Command-Safe "reagentc /enable" {
        reagentc /enable
    }
    Write-OK "WinRE re-enabled. BitLocker trust reestablished."


    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "  Remediation completed successfully.     " -ForegroundColor Green
    Write-Host "  CVE-2026-45585 has been remediated.     " -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""

}
catch {

    Write-Host ""
    Write-Fail "Remediation encountered an error: $_"
    Write-Host ""
    Write-Host "  Attempting cleanup..." -ForegroundColor Yellow

    # Attempt to unload hive if it is still loaded
    $hiveLoaded = Get-ChildItem HKLM: -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq $HiveName }
    if ($hiveLoaded) {
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
        reg unload "HKLM\$HiveName" 2>$null
        Write-Host "  Hive unloaded during cleanup." -ForegroundColor Yellow
    }

    # Attempt to unmount WinRE without committing to leave it unchanged
    if (Test-Path $MountPath) {
        reagentc /unmountre /path $MountPath /discard 2>$null
        Write-Host "  WinRE image unmounted (changes discarded) during cleanup." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  Review the error above and re-run the script." -ForegroundColor Red
    exit 1

}
#endregion