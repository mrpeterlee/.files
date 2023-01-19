@echo off
cls

taskkill /f /im "mstsc.exe"


set ip="10.1.1.81"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient

set ip="10.1.1.82"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient

set ip="10.1.1.83"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient

set ip="10.1.1.84"
echo Connect to Windows Client (%ip%) with resolution of 1920x1080
call :ConnectToWindowsClient

exit

:ConnectToWindowsClient
    ping -n 1 %ip% | find "TTL"
    if not errorlevel 1 set result=SUCCESS
    if errorlevel 1 set result=FAIL
    cls

    if "%result%" == "SUCCESS" (
        start "" mstsc /v:10.1.1.81 /w:1920 /h:1080 /span
    )

exit /b
