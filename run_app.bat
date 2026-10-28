@echo off
chcp 65001 >nul
title Sales Data Analysis - R Shiny Dashboard
color 0B
cd /d "%~dp0"

echo ======================================================================
echo    Starting Sales Data Analysis R Project (Frontend + Backend)
echo ======================================================================
echo.

set RSCRIPT_BIN=""

where Rscript >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set RSCRIPT_BIN="Rscript"
    goto :FOUND
)

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

:FOUND
if %RSCRIPT_BIN%=="" (
    echo [ERROR] R installation nahi mila.
    pause
    exit /b 1
)

start "" cmd /c "timeout /t 2 /nobreak >nul & start http://127.0.0.1:7860"
%RSCRIPT_BIN% run_app.R

pause
