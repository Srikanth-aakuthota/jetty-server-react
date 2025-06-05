@echo off
setlocal enabledelayedexpansion

REM =============================================================================
REM == 1. CONFIGURATION VARIABLES ==============================================
REM =============================================================================

:: Jetty version to download
set JETTY_VERSION=11.0.15

:: React app folder name
set REACT_APP_DIR=my-hybrid-app

:: After building React, the output folder is "build"
set REACT_BUILD_DIR=%REACT_APP_DIR%\build

:: Where to install Jetty (jetty.home)
set HOME_DIR=jetty-server

:: Where to configure Jetty (jetty.base)
set BASE_DIR=jetty-base

:: The Jetty archive name downloaded from Maven Central
set JETTY_ARCHIVE=jetty-home-%JETTY_VERSION%.tar.gz

:: The download URL for the Jetty archive
set DOWNLOAD_URL=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/%JETTY_VERSION%/%JETTY_ARCHIVE%

REM =============================================================================
REM == 2. CREATE OR UPDATE REACT APP ===========================================
REM =============================================================================

echo.
echo ================================================
echo 1. Creating / Updating React App (%REACT_APP_DIR%)
echo ================================================
echo.

REM If the folder doesn't exist, run 'npx create-react-app'
if not exist "%REACT_APP_DIR%\" (
    echo -- React folder not found. Generating a new React app...
    npx create-react-app "%REACT_APP_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to create React app. Make sure Node.js and npx are installed.
        exit /b 1
    )
) else (
    echo -- React folder already exists. Skipping "npx create-react-app".
)

REM Navigate into the React app folder
cd "%REACT_APP_DIR%"

echo.
echo -- Installing / Updating dependencies...
npm install

echo.
echo -- Building React (production)...
npm run build
if errorlevel 1 (
    echo [ERROR] React build failed. Check the output above for details.
    exit /b 1
)

REM Return to project root
cd ..

REM =============================================================================
REM == 3. DOWNLOAD & EXTRACT JETTY =============================================
REM =============================================================================

echo.
echo ================================================
echo 2. Downloading & Extracting Jetty (%JETTY_VERSION%)
echo ================================================
echo.

REM Download Jetty if the archive doesn’t already exist
if not exist "%JETTY_ARCHIVE%" (
    echo -- Downloading %JETTY_ARCHIVE% ...
    curl -L -o "%JETTY_ARCHIVE%" "%DOWNLOAD_URL%"
    if errorlevel 1 (
        echo [ERROR] Failed to download Jetty. Check your internet connection.
        exit /b 1
    )
) else (
    echo -- Jetty archive already exists. Skipping download.
)

REM Delete any existing jetty-server folder (to avoid conflicts)
if exist "%HOME_DIR%\" (
    echo -- Removing existing %HOME_DIR% folder...
    rmdir /S /Q "%HOME_DIR%"
)

echo -- Extracting Jetty into "%HOME_DIR%"...
mkdir "%HOME_DIR%"
tar -xvzf "%JETTY_ARCHIVE%" -C "%HOME_DIR%" --strip-components=1
if errorlevel 1 (
    echo [ERROR] Failed to extract Jetty.
    exit /b 1
)

REM =============================================================================
REM == 4. CREATE AND CONFIGURE JETTY BASE ======================================
REM =============================================================================

echo.
echo ================================================
echo 3. Creating / Configuring Jetty Base (%BASE_DIR%)
echo ================================================
echo.

REM Remove any existing jetty-base (clean slate)
if exist "%BASE_DIR%\" (
    echo -- Removing existing %BASE_DIR% folder...
    rmdir /S /Q "%BASE_DIR%"
)

REM Create a fresh jetty-base folder
mkdir "%BASE_DIR%"

REM Inside jetty-base, invoke Jetty to add the "webapp" module
cd "%BASE_DIR%"
echo -- Adding "webapp" module to Jetty base...
java -jar ..\%HOME_DIR%\start.jar --add-module=webapp
if errorlevel 1 (
    echo [ERROR] Failed to add the webapp module. Make sure jetty-server/start.jar exists.
    exit /b 1
)

REM Create the start.ini with your specified content (including port 9090)
(
    echo # tell Jetty which modules to load:
    echo --module=server
    echo --module=http
    echo --module=deploy
    echo.
    echo # set the HTTP port you want Jetty to bind
    echo jetty.http.port=9090
) > start.ini

REM Ensure the webapps\ROOT folder structure exists
echo -- Ensuring webapps\ROOT exists...
if not exist "webapps\" mkdir "webapps"
if not exist "webapps\ROOT\" mkdir "webapps\ROOT"

REM Return to project root
cd ..

REM =============================================================================
REM == 5. COPY REACT BUILD INTO JETTY BASE =====================================
REM =============================================================================

echo.
echo ================================================
echo 4. Copying React build into Jetty Base (webapps\ROOT)
echo ================================================
echo.

REM Use Robocopy for a robust copy operation
robocopy "%REACT_BUILD_DIR%" "%BASE_DIR%\webapps\ROOT" /E /R:2 /W:5
if errorlevel 8 (
    echo [ERROR] Problems copying React build to Jetty base.
    exit /b 1
)

REM =============================================================================
REM == 6. START JETTY ===========================================================
REM =============================================================================

echo.
echo ================================================
echo 5. Starting Jetty Server (on port 9090)
echo ================================================
echo.

cd "%BASE_DIR%"
java -jar ..\%HOME_DIR%\start.jar
if errorlevel 1 (
    echo [ERROR] Jetty failed to start. Check the logs above for any errors.
    exit /b 1
)

echo.
echo ================================================
echo Jetty is up at http://localhost:9090/
echo React app should now be served from Jetty.
echo ================================================
echo.

pause
