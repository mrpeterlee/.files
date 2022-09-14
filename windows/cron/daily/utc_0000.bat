echo off
exit

echo "################################## China PreMarket (Local Time 8:00 AM) ##################################"
echo on
powershell.exe -ExecutionPolicy ByPass -NoExit -Command d:\\tool\\Anaconda3\\shell\\condabin\\conda-hook.ps1; conda activate d:\\tool\\Anaconda3; conda activate finclab; d:; cd D:\\lab; $env:PYTHONPATH = 'D:/lab/paper/finclab;D:/lab/paper/datalab;D:/lab/paper/labenv;D:/lab/paper/ts;D:/lab/paper/winclient'; python D:\lab\paper\winclient\winclient\guoxin\bin\pre_market.py; exit
