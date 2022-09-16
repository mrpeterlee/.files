@echo off

echo "Connect to Windows Client (10.1.1.111) with resolution of 1920x1080"
taskkill /f /im "mstsc.exe"
start "" mstsc D:\home\peter\.files\windows\bin\RDP-Winclient.rdp /w:1920 /h:1080

exit
