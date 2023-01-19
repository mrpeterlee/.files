@echo off

taskkill /f /im "mstsc.exe"

timeout 1

set ip="10.1.1.81"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient %ip%

set ip="10.1.1.82"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient %ip%

set ip="10.1.1.83"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient %ip%

set ip="10.1.1.84"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient %ip%

exit

:ConnectToWindowsClient

    set ip="%~1"
    ping -n 1 %ip% | find "TTL"
    if not errorlevel 1 set result=SUCCESS
    if errorlevel 1 set result=FAIL

    if "%result%" == "SUCCESS" (
        start "" mstsc /v:%ip% /w:1920 /h:1080 /span
    )

exit /b
