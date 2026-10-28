@echo off
chcp 65001 >nul
title GitHub Upload - Sales Data Analysis
color 0A
cls
cd /d "%~dp0"

echo ==============================================================================
echo                 🚀 GITHUB REPOSITORY UPLOAD WIZARD
echo ==============================================================================
echo.

set /p REPO_URL="Aapki GitHub Repository ka URL enter karein (e.g., https://github.com/username/repo.git): "

if "%REPO_URL%"=="" (
    color 0C
    echo [ERROR] Repository URL khali nahi ho sakta!
    pause
    exit /b 1
)

echo.
echo [1/3] Adding remote origin...
git remote remove origin >nul 2>nul
git remote add origin %REPO_URL%

echo [2/3] Setting branch to main...
git branch -M main

echo [3/3] Pushing files to GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==============================================================================
    echo  ✅ Mubarak ho! Project successfully GitHub par upload ho chuka hai!
    echo ==============================================================================
) else (
    color 0C
    echo.
    echo [ERROR] Push fail ho gaya. Kripya check karein ki repository exist karti hai
    echo aur aapka GitHub login/credentials sahi hain.
)

pause

