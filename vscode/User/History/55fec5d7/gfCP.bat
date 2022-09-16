echo "==================== Key Mapping Utilities ===================="
start /min D:\tool\dual-key-remap\dual-key-remap.exe
start /min D:\lab\bin\key_remap.exe

echo "==================== OpenVPN ===================="
start "" "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" --command connect bbg_client1.ovpn

echo "==================== Outlook ===================="
@start /min "" "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"

echo "==================== Teams ===================="
start /min C:\Users\Peter\AppData\Local\Microsoft\Teams\current\Teams.exe

echo "==================== Nginx ===================="
rem wt new-tab -p "Nginx" -d "%USERPROFILE%" cmd /k "d: && cd d:\tool\nginx && d:\tool\nginx\nginx.exe"
start d:\tool\nginx\nginx.exe 

echo "==================== CNBC Live TV ===================="
"C:\Program Files\Google\Chrome\Application\chrome_proxy.exe" --profile-directory=Default --app-id=nlmaamaoahjiilibgbafebhafkeccjac --app="https://tv.youtube.com/watch/vzhLFt62hhU?pwa=&vp=0gEEEgIwAQ%3D%3D"

echo "==================== BBG ===================="
start "" C:\blp\Wintrv\wintrv.exe

echo "==================== WinClient (GuoXin) ===================="
start "" c:\windows\system32\mstsc.exe /v:10.1.1.111 /w:1920 /h:1080