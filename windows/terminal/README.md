README - Windows Terminal
=========================

Add the below script to Windows Log-on:
```cmd
echo ---------------------------------- Attempt to Update .files ----------------------------------
if exist "d:\home\peter\.files" (
  d: && cd d:\home\peter\.files && git checkout HEAD -- && git pull
)

echo ---------------------------------- Deploy Settings for Terminal ----------------------------------
copy /Y d:\home\peter\.files\windows\terminal\settings.json %USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json


```


**[Deprecated] Use symlink to sync the settings**
Do **NOT** use the below methodology as terminal is locking the `settings.json`
and making editing such file impossible when terminal is running.
```cmd
mklink /J "C:\Users\peter\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" "D:\home\peter\.files\windows\terminal\LocalState"
```
