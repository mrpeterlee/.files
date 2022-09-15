echo "==================== Windows Terminal ===================="
wt -p "Wsl-Ubuntu" ; new-tab -p "Windows Powershell" -d D:\lab ; split-pane -p "Windows Powershell"
rem wt new-tab -p "Nginx" -d "%USERPROFILE%" cmd /k "d: && cd d:\tool\nginx && d:\tool\nginx\nginx.exe"