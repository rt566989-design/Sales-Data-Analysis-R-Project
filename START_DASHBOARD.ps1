# ==============================================================================
# Script: START_DASHBOARD.ps1
# Purpose: PowerShell 1-Click Launcher for Sales Data Analysis Dashboard
# ==============================================================================

Set-Location -Path $PSScriptRoot

$rscript = ""
if (Get-Command Rscript -ErrorAction SilentlyContinue) {
    $rscript = "Rscript"
} elseif (Test-Path "C:\Program Files\R\R-4.6.1\bin\Rscript.exe") {
    $rscript = "C:\Program Files\R\R-4.6.1\bin\Rscript.exe"
} else {
    $rDirs = Get-ChildItem "C:\Program Files\R" -Directory -Filter "R-*" -ErrorAction SilentlyContinue
    if ($rDirs.Count -gt 0) {
        $rscript = Join-Path $rDirs[0].FullName "bin\Rscript.exe"
    }
}

if (-not $rscript) {
    Write-Host "Error: R not found on system!" -ForegroundColor Red
    Pause
    Exit
}

Write-Host "Starting Sales Data Analysis Web Dashboard..." -ForegroundColor Cyan
Start-Process "http://127.0.0.1:7860"
& $rscript run_app.R

