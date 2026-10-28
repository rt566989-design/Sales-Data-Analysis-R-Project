@echo off
chcp 65001 >nul
title SalesPulse Analytics - Sales Data Analysis Dashboard
color 0B
cls

REM Navigate to the folder where this batch file is located
cd /d "%~dp0"

echo ==============================================================================
echo        📊 SALES DATA ANALYSIS - FULL-STACK R SHINY DASHBOARD
echo ==============================================================================
echo.
echo [1/3] R environment verify ho raha hai...

set RSCRIPT_BIN=""

REM 1. Check if Rscript is in PATH
where Rscript >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set RSCRIPT_BIN="Rscript"
    goto :FOUND
)

REM 2. Check standard 64-bit Program Files R installations
if exist "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" (
    set RSCRIPT_BIN="C:\Program Files\R\R-4.6.1\bin\Rscript.exe"
    goto :FOUND
)

for /d %%D in ("C:\Program Files\R\R-*") do (
    if exist "%%D\bin\Rscript.exe" (
        set RSCRIPT_BIN="%%D\bin\Rscript.exe"
        goto :FOUND
    )
)

REM 3. Check Local AppData Programs
for /d %%D in ("%LOCALAPPDATA%\Programs\R\R-*") do (
    if exist "%%D\bin\Rscript.exe" (
        set RSCRIPT_BIN="%%D\bin\Rscript.exe"
        goto :FOUND
    )
)

:FOUND
if %RSCRIPT_BIN%=="" (
    color 0C
    echo [ERROR] R installation nahi mila!
    echo Kripya R install karein: https://cran.r-project.org/
    echo.
    pause
    exit /b 1
)

echo [2/3] R found: %RSCRIPT_BIN%
echo [3/3] Dashboard server start ho raha hai...
echo.
echo ==============================================================================
echo  👉 Web Browser me link open ho jayega: http://127.0.0.1:7860
echo  👉 Dashboard ko band karne ke liye is window ko close karein ya Ctrl+C dabayein
echo ==============================================================================
echo.

REM Delay 2 seconds and launch default browser in background
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://127.0.0.1:7860"

REM Run the R Shiny Application
%RSCRIPT_BIN% run_app.R

pause

