rem wsl --export Ubuntu-Acap "D:\home\peter\vm\wsl\exported_ubuntu.tar"
rem wsl --import Ubuntu-Acap "D:\home\peter\vm\wsl" "D:\home\peter\vm\wsl\exported_ubuntu.tar"
rem wsl --setdefault Ubuntu-Acap

rem The current Microsoft recommended way of setting the username in an instance is to create a /etc/wsl.conf in the instance with the following setting:
rem [user]
rem default=username




echo "Checkout https://askubuntu.com/questions/1429369/how-to-transfer-ubuntu-on-wsl-from-one-laptop-to-another"
wsl --import Ubuntu-Acap D:\home\peter\vm\wsl D:\home\peter\vm\wsl\exported_ubuntu.tar --version 2

wsl --set-default Ubuntu-Acap
wsl ~ 


echo "Default username should be peter"
echo "If `apt update` failed, run the below line"
echo "wsl --ser-version Ubuntu-Acap 1"