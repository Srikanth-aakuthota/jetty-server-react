@echo off
setlocal enabledelayedexpansion

REM =============================================================================
REM == 1. CONFIGURATION VARIABLES ==============================================
REM =============================================================================

:: Git repository URL
set GIT_REPO_URL=https://github.com/Srikanth-aakuthota/jetty-server-react.git

:: Branch name
set BRANCH_NAME=master

REM =============================================================================
REM == 2. UPLOAD PROJECT TO GIT ================================================
REM =============================================================================

echo.
echo ================================================
echo Uploading project to Git repository
echo ================================================
echo.

REM Initialize Git if not already initialized
if not exist ".git\" (
    echo -- Initializing Git repository...
    git init
)

REM Add all files to the staging area
echo -- Adding files to Git...
git add .

REM Commit the changes
echo -- Committing changes...
git commit -m "Initial commit"

REM Set the remote repository URL
echo -- Setting remote repository URL...
git remote add origin %GIT_REPO_URL%

REM Push the changes to the remote repository
echo -- Pushing changes to remote repository...
git push -u origin %BRANCH_NAME%
if errorlevel 1 (
    echo [ERROR] Failed to push changes to Git repository. Check your credentials and repository URL.
    exit /b 1
)

echo.
echo ================================================
echo Project successfully uploaded to %GIT_REPO_URL%
echo ================================================
echo.

pause