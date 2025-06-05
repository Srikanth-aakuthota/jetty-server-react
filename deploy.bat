@echo OFF
set currPath=%~dp0%
set adbExe=D:\Android\platform-tools\adb.exe
set apkPath=%currPath%app\build\outputs\apk\debug\app-debug.apk
if "kill" == "%1" (
    @echo Killing ...

    %adbExe% shell am force-stop com.example.myserviceapp
    goto end
)

if "restart" == "%1" (
    @echo Restarting App...

    %adbExe% shell am force-stop com.example.myserviceapp
    %adbExe% logcat -c
    %adbExe% shell am start -n com.example.myserviceapp/.MainActivity
    goto end
)


if "install" == "%1" (
    @echo Installing App...
    if not exist "%apkPath%" (
        echo APK not found at %apkPath%
        goto end
    )
    if not exist "%adbExe%" (
        echo adb.exe not found at %adbExe%
        goto end
    )
    call "%adbExe%" install -r -t "%apkPath%"
    goto end
)

if "set-owner" == "%1" (
    @echo Setting App as the admin app...

    %adbExe% shell dpm set-device-owner com.example.myserviceapp/.NeoDeviceAdminReceiver
    goto end
)

if "is" == "%1" (
    @echo Installing and starting App...

    call %adbExe% install -r -t "%apkPath%"
    %adbExe% shell am force-stop com.example.myserviceapp
    %adbExe% logcat -c
    %adbExe% shell am start -n com.example.myserviceapp/.MainActivity
    goto end
)
if "remove-owner" == "%1" (
    @echo Removing App Admin...
    call %adbExe% shell dpm remove-active-admin com.example.myserviceapp/.RiddleDeviceAdminReceiver
    goto end
)

if "sc" == "%1" (
    @echo Taking screenshot...
    set file_name=screenshot_%RANDOM%
    %adbExe% shell screencap -p /sdcard/%file_name%.png
    %adbExe% pull /sdcard/%file_name%.png
    %adbExe% shell rm /sdcard/%file_name%.png
    goto end
)

:end