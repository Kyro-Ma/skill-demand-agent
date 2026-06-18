$ErrorActionPreference = "Continue"

$WorkspaceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$LogDir = Join-Path $WorkspaceRoot "logs"
$LogPath = Join-Path $LogDir "clawhub-hourly-loop.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, "Global\SkillDemandClawHubHourlyLoop", [ref]$createdNew)
if (-not $createdNew) {
    Add-Content -LiteralPath $LogPath -Encoding UTF8 -Value "$(Get-Date -Format o) another ClawHub hourly loop is already running; exiting."
    exit 0
}

try {
    Add-Content -LiteralPath $LogPath -Encoding UTF8 -Value "$(Get-Date -Format o) ClawHub hourly loop started."
    while ($true) {
        $taskOutput = & (Join-Path $PSScriptRoot "run_clawhub_hourly_task.ps1") 2>&1
        $taskOutput | Tee-Object -FilePath $LogPath -Append
        Start-Sleep -Seconds 3600
    }
} finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
