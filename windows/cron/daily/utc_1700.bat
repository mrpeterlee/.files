echo off
exit

echo "################################## UTC 17:00 ##################################"
echo on
echo "################################## Export CS Transaction & Portfolio Data ##################################"
powershell.exe -ExecutionPolicy ByPass -NoExit -Command d:\\tool\\Anaconda3\\shell\\condabin\\conda-hook.ps1; conda activate d:\\tool\\Anaconda3; conda activate finclab; d:; cd D:\\lab; $env:PYTHONPATH = 'D:/lab/paper/finclab;D:/lab/paper/datalab;D:/lab/paper/labenv;D:/lab/paper/ts;D:/lab/paper/winclient'; python -c 'from finclab.io.api.cs.export_data import export_portfolio; export_portfolio()'; exit
powershell.exe -ExecutionPolicy ByPass -NoExit -Command d:\\tool\\Anaconda3\\shell\\condabin\\conda-hook.ps1; conda activate d:\\tool\\Anaconda3; conda activate finclab; d:; cd D:\\lab; $env:PYTHONPATH = 'D:/lab/paper/finclab;D:/lab/paper/datalab;D:/lab/paper/labenv;D:/lab/paper/ts;D:/lab/paper/winclient'; python -c 'from finclab.io.api.cs.export_data import export_transaction; export_transaction()'; exit
exit
