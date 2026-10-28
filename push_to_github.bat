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

set DEFAULT_URL=https://github.com/rt566989-design/Sales-Data-Analysis-R-Project.git

echo Target Repository: %DEFAULT_URL%
echo.
set /p REPO_URL="Enter dabayein isi URL par upload karne ke liye (ya naya URL daalein): "

if "%REPO_URL%"=="" (
    set REPO_URL=%DEFAULT_URL%
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
    echo [NOTE] Agar push fail hua, to check karein ki aapne GitHub par
    echo "Sales-Data-Analysis-R-Project" repo create kar li hai:
    echo 👉 https://github.com/new?name=Sales-Data-Analysis-R-Project
)

pause
