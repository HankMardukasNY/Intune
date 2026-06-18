#!ps
#MaxLength=100000
#timeout=10000000

<#
Intune Proactive Remediation -- Detection Script

Installs HPIA, runs in List mode, determines compliance via exit code.
Exits 0 (compliant) if no updates found.
Exits 1 (non-compliant) to trigger remediation.
#>

# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------
$BIOSPwdData       = 'REPLACEME'

# Softpaqs excluded from compliance checks (wildcard name patterns)
$ExcludedSoftpaqs = @(
    '*Wacom*'
    # '*Realtek Audio*'
    # '*Intel Wireless*'
)
$HPIAStagingFolder = "$env:ProgramData\HP\HPIAUpdateService"
$HPIAStagingLogs   = "$HPIAStagingFolder\LogFiles"
$HPIAStagingReports= "$HPIAStagingFolder\Reports"
$HPIAStagingProgram= "$env:ProgramFiles\HPIA"

try {
    [void][System.IO.Directory]::CreateDirectory($HPIAStagingFolder)
    [void][System.IO.Directory]::CreateDirectory($HPIAStagingLogs)
    [void][System.IO.Directory]::CreateDirectory($HPIAStagingReports)
    [void][System.IO.Directory]::CreateDirectory($HPIAStagingProgram)
}
catch { throw }

# ---------------------------------------------------------
# Manufacturer check
# ---------------------------------------------------------
$manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
if ($manufacturer -notlike '*HP*' -and $manufacturer -notlike '*Hewlett*') {
    Write-Output 'Not an HP device. Skipping.'
    exit 0
}

#region Functions

Function Install-HPIA {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        $HPIAInstallPath = "$env:ProgramFiles\HP\HPIA\bin"
        )
    $script:TempWorkFolder = "$env:windir\Temp\HPIA"
    $ProgressPreference = 'SilentlyContinue'
    $HPIACABUrl = "https://hpia.hpcloud.hp.com/HPIAMsg.cab"

    try {
        [void][System.IO.Directory]::CreateDirectory($HPIAInstallPath)
        [void][System.IO.Directory]::CreateDirectory($TempWorkFolder)
    }
    catch { throw }

    $OutFile = "$TempWorkFolder\HPIAMsg.cab"
    Invoke-WebRequest -Uri $HPIACABUrl -UseBasicParsing -OutFile $OutFile
    if (Test-Path "$env:windir\System32\expand.exe") {
        try { Start-Process cmd.exe -ArgumentList "/c C:\Windows\System32\expand.exe -F:* $OutFile $TempWorkFolder\HPIAMsg.xml" -Wait }
        catch { Write-Output "Could not expand CAB." }
    }
    if (Test-Path -Path "$TempWorkFolder\HPIAMsg.xml") {
        [XML]$HPIAXML = Get-Content -Path "$TempWorkFolder\HPIAMsg.xml"
        $HPIADownloadURL = $HPIAXML.ImagePal.HPIALatest.SoftpaqURL
        $HPIAVersion     = $HPIAXML.ImagePal.HPIALatest.Version
        $HPIAFileName    = $HPIADownloadURL.Split('/')[-1]
    }
    else {
        $HPIAWebUrl = "https://ftp.hp.com/pub/caps-softpaq/cmit/HPIA.html"
        try { $HTML = Invoke-WebRequest -Uri $HPIAWebUrl -ErrorAction Stop }
        catch { Write-Output "Failed to download the HPIA web page. $($_.Exception.Message)"; throw }
        $HPIADownloadURL = ($HTML.Links | Where-Object { $_.href -match "hp-hpia-" }).href
        $HPIAFileName    = $HPIADownloadURL.Split('/')[-1]
        $HPIAVersion     = ($HPIAFileName.Split("-") | Select-Object -Last 1).Replace(".exe","")
    }

    Write-Output "Latest HPIA version: $HPIAVersion ($HPIAFileName)"

    $HPIAIsCurrent = $false
    If (Test-Path "$HPIAInstallPath\HPImageAssistant.exe") {
        $HPIAExtractedVersion = (Get-Item "$HPIAInstallPath\HPImageAssistant.exe").VersionInfo.FileVersion
        if ($HPIAExtractedVersion -match $HPIAVersion) {
            Write-Output "HPIA $HPIAVersion already installed. Skipping download."
            $HPIAIsCurrent = $true
        }
        else {
            Write-Output "Installed version ($HPIAExtractedVersion) differs from latest ($HPIAVersion). Updating."
        }
    }

    if ($HPIAIsCurrent -eq $false) {
        Write-Output "Downloading HPIA..."
        if (!(Test-Path -Path "$TempWorkFolder\$HPIAFileName")) {
            try {
                $ExistingBitsJob = Get-BitsTransfer -Name "$HPIAFileName" -AllUsers -ErrorAction SilentlyContinue
                If ($ExistingBitsJob) { Remove-BitsTransfer -BitsJob $ExistingBitsJob }
                $BitsJob = Start-BitsTransfer -Source $HPIADownloadURL -Destination "$TempWorkFolder\$HPIAFileName" -Asynchronous -DisplayName "$HPIAFileName" -Description "HPIA download" -RetryInterval 60 -ErrorAction Stop
                do {
                    Start-Sleep -Seconds 5
                    $Progress = [Math]::Round((100 * ($BitsJob.BytesTransferred / $BitsJob.BytesTotal)), 2)
                    Write-Output "Downloaded $Progress%"
                } until ($BitsJob.JobState -in ("Transferred","Error"))
                If ($BitsJob.JobState -eq "Error") { Write-Output "BITS transfer failed: $($BitsJob.ErrorDescription)"; throw }
                Complete-BitsTransfer -BitsJob $BitsJob
                Write-Output "BITS transfer complete."
            }
            catch { Write-Output "Failed to start BITS transfer: $($_.Exception.Message)"; throw }
        }
        else { Write-Output "$HPIAFileName already downloaded. Skipping." }

        Write-Output "Extracting HPIA..."
        try {
            Start-Process -FilePath "$TempWorkFolder\$HPIAFileName" -WorkingDirectory $HPIAInstallPath -ArgumentList "/s /f .\ /e" -NoNewWindow -PassThru -Wait -ErrorAction Stop | Out-Null
            Start-Sleep -Seconds 5
            If (Test-Path "$HPIAInstallPath\HPImageAssistant.exe") { Write-Output "Extraction complete." }
            Else { Write-Output "HPImageAssistant.exe not found after extraction."; throw }
        }
        catch { Write-Output "Failed to extract HPIA: $($_.Exception.Message)"; throw }
    }
}

Function Run-HPIA {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("Analyze","DownloadSoftPaqs")]
        $Operation = "Analyze",
        [Parameter(Mandatory=$false)]
        [ValidateSet("All","BIOS","Drivers","Software","Firmware","Accessories","BIOS,Drivers,Firmware")]
        $Category = "BIOS,Drivers,Firmware",
        [Parameter(Mandatory=$false)]
        [ValidateSet("All","Critical","Recommended","Routine")]
        $Selection = "All",
        [Parameter(Mandatory=$false)]
        [ValidateSet("List","Download","Extract","Install","UpdateCVA")]
        $Action = "List",
        [Parameter(Mandatory=$false)]
        $LogFolder = "$env:systemdrive\ProgramData\HP\Logs",
        [Parameter(Mandatory=$false)]
        $ReportsFolder = "$env:systemdrive\ProgramData\HP\HPIA",
        [Parameter(Mandatory=$false)]
        $HPIAInstallPath = "$env:ProgramFiles\HP\HPIA\bin",
        [Parameter(Mandatory=$false)]
        $ReferenceFile,
        [Parameter(Mandatory=$false)]
        $BIOSPwdData
        )

    $DateTime = Get-Date -Format "yyyyMMdd-HHmmss"
    $script:CurrentReportsFolder = "$ReportsFolder\$DateTime"
    $script:TempWorkFolder = "$env:temp\HPIA"
    try {
        [void][System.IO.Directory]::CreateDirectory($LogFolder)
        [void][System.IO.Directory]::CreateDirectory($TempWorkFolder)
        [void][System.IO.Directory]::CreateDirectory($script:CurrentReportsFolder)
        [void][System.IO.Directory]::CreateDirectory($HPIAInstallPath)
    }
    catch { throw }

    Install-HPIA -HPIAInstallPath $HPIAInstallPath

    $HPIAArgs = "/Operation:$Operation /Category:$Category /Selection:$Selection /Action:$Action /Silent /Debug /IgnoreGenericOsError /ReportFolder:$script:CurrentReportsFolder"
    if ($BIOSPwdData)   { $HPIAArgs += " /BIOSPwdData:$BIOSPwdData" }
    if ($ReferenceFile) { $HPIAArgs += " /ReferenceFile:$ReferenceFile" }

    Write-Output "Running HPIA with args: $HPIAArgs"

    try {
        $Process = Start-Process -FilePath "$HPIAInstallPath\HPImageAssistant.exe" -WorkingDirectory $TempWorkFolder -ArgumentList $HPIAArgs -NoNewWindow -PassThru -Wait -ErrorAction Stop

        switch ($Process.ExitCode) {
            0    { Write-Output "Exit 0 -- Updates available." }
            256  { Write-Output "Exit 256 -- No recommendations found." }
            257  { Write-Output "Exit 257 -- No recommendations selected." }
            3010 { Write-Output "Exit 3010 -- Complete. Reboot required."; $script:RebootRequired = $true }
            3020 { Write-Output "Exit 3020 -- One or more installs failed." }
            4096 { Write-Output "Exit 4096 -- Platform not supported." }
            default { Write-Output "Exit $($Process.ExitCode)." }
        }

        return $Process.ExitCode
    }
    catch {
        Write-Output "Failed to run HPImageAssistant.exe: $($_.Exception.Message)"
        throw
    }
}

Function Get-HPIARecommendations {
    param([string]$ReportFolder)

    $reportJson = Get-ChildItem -Path $ReportFolder -Filter '*.json' -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $reportJson) { Write-Output 'No JSON report found.'; return @() }

    try { $json = Get-Content -Path $reportJson.FullName -ErrorAction Stop | ConvertFrom-Json }
    catch { Write-Output "Could not parse report JSON: $_"; return @() }

    if (-not $json.HPIA.Recommendations) { return @() }

    $results = [System.Collections.Generic.List[object]]::new()
    foreach ($rec in $json.HPIA.Recommendations) {
        $results.Add([PSCustomObject]@{
            SoftpaqName  = $rec.Name
            SoftpaqId    = $rec.SoftPaqID
            AvailableVer = $rec.RecommendationValue
            Comments     = $rec.Comments
            SSMCompliant = $rec.SSMCompliant
            DPBCompliant = $rec.DPBCompliant
            Severity     = $rec.Severity
        })
    }
    return $results
}

#endregion

# Disable IE First Run Wizard
$IEMainPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"
if (-not (Test-Path $IEMainPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "Main" -Force | Out-Null
}
if ((Get-ItemProperty -Path $IEMainPath -ErrorAction SilentlyContinue).DisableFirstRunCustomize -ne 1) {
    New-ItemProperty -Path $IEMainPath -Name "DisableFirstRunCustomize" -PropertyType DWORD -Value 1 -Force | Out-Null
}

# Run HPIA List
$exitCode = Run-HPIA -Operation Analyze -Category 'BIOS,Drivers,Firmware' -Selection All -Action List `
    -LogFolder $HPIAStagingLogs -ReportsFolder $HPIAStagingReports -HPIAInstallPath $HPIAStagingProgram `
    -BIOSPwdData $BIOSPwdData

# Parse JSON -- compliance is based on whether recommendations exist
$allRecs = @(Get-HPIARecommendations -ReportFolder $script:CurrentReportsFolder)

Write-Output ''
Write-Output "Recommendations ($($allRecs.Count) total):"
Write-Output ('-' * 60)
foreach ($rec in $allRecs) {
    Write-Output "  $($rec.SoftpaqName) ($($rec.SoftpaqId))"
    Write-Output "    Available : $($rec.AvailableVer)"
    Write-Output "    Severity  : $($rec.Severity)"
    Write-Output "    Comments  : $($rec.Comments)"
    Write-Output "    SSM       : $($rec.SSMCompliant)   DPB: $($rec.DPBCompliant)"
    Write-Output ''
}
Write-Output ('-' * 60)

$filteredRecs = $allRecs | Where-Object {
    $name = $_.SoftpaqName
    -not ($ExcludedSoftpaqs | Where-Object { $name -like $_ })
}

if ($filteredRecs.Count -gt 0 -and $filteredRecs.Count -lt $allRecs.Count) {
    $excludedNames = ($allRecs | Where-Object {
        $name = $_.SoftpaqName
        ($ExcludedSoftpaqs | Where-Object { $name -like $_ })
    } | ForEach-Object { $_.SoftpaqName }) -join ', '
    Write-Output "Excluded from compliance check: $excludedNames"
}

if ($filteredRecs.Count -eq 0) {
    Write-Output 'No recommendations found (after exclusions). Device is compliant.'
    exit 0
}

$pendingNames = $filteredRecs | ForEach-Object { $_.SoftpaqName }
Write-Output "Non-compliant. Updates pending ($($filteredRecs.Count)): $($pendingNames -join ', ')"
exit 1