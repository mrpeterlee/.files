echo off
exit


echo "################################## bob 3:10 pm buy CN Treasury Repo ##################################"

echo on
rem powershell.exe -ExecutionPolicy ByPass -NoExit -Command d:\\tool\\Anaconda3\\shell\\condabin\\conda-hook.ps1; conda activate d:\\tool\\Anaconda3; conda activate finclab; d:; cd D:\\lab; $env:PYTHONPATH = 'D:/lab/paper/finclab;D:/lab/paper/datalab;D:/lab/paper/labenv;D:/lab/paper/ts;D:/lab/paper/winclient'; python D:\lab\paper\winclient\winclient\guoxin\bin\buy_repo.py; exit
rem 3:10 PM
timeout 10
D:\lab\paper\winclient\autoit\guoxin_buy_repo.exe
timeout 300

rem 3:15 PM
timeout 20
D:\lab\paper\winclient\autoit\guoxin_buy_repo.exe
timeout 300

rem 3:20 PM
timeout 30
D:\lab\paper\winclient\autoit\guoxin_buy_repo.exe
timeout 300

rem 3:25 PM
timeout 32
D:\lab\paper\winclient\autoit\guoxin_buy_repo.exe
exit
