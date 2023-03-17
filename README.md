# Dot Files

Author: Peter Lee (peter.lee@astrocapital.net)
last_update: 2023-03-15 20:51:45 UTC
description: This repo holds a collection of configuration files for my preferred development environment (Windows/Mac OS/Linux)

# Installation Guide

    - Mac OS: Please see [Installation Guide](./mac/README.md)

## Linux

Assuming fresh Linux installation.

```bash
# Misc
sudo apt install powerline

# Conda

```

## Windows

# 1st Time Install

Anaconda: https://www.continuum.io/downloads
Emacs for Windows: https://sourceforge.net/projects/emacsbinw64/files/release/
Babun: http://babun.github.io/

# Deployment

### Get SourceCodePro front for powerline

Install it from:
git clone https://github.com/powerline/fonts.git

### Anaconda

The installation folder is "%USERPROFILE%\Apps\Anaconda"

To launch Anaconda Prompt, the following .bat script can be used:

```
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Scripts
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Lib
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\DLLs
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Lib\site-packages
set PATH=%PATH%;C:\Users\leepeteb\Home\Apps\Cygwin\bin"

set PYTHONPATH=%PYTHONPATH%;%PATH%

set HOME=C:\Users\leepeteb\Home
rem set USERPROFILE=C:\Users\leepeteb\Home

set http_proxy=http://x.com:8080
set https_proxy=https://x.com:8080

C:\Windows\System32\cmd.exe "/K" "C:\Users\leepeteb\Home\Apps\Anaconda\Scripts\activate.bat" "C:\Users\leepeteb\Home\Apps\Anaconda"
```

Then you could launch Jupyter notebook server from wherein.

To enable syntax checking, `flake8` package needs to be installed

#+begin_src sh
pip install flake8

#

### Cygwin

The default Cygwin installation looks geeky and lacks of a decent color scheme by default. Install Babun to a folder (you could later rename the folder and then run 'babun rebase' to update babun settings.)

Launch babun using the below .bat script will set the environment variables correctly:

```
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Scripts
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Lib
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\DLLs
set PATH=%PATH%;%USERPROFILE%\HOME\Apps\Anaconda\Lib\site-packages
set PATH=%PATH%;C:\Users\leepeteb\Home\Apps\Cygwin\bin"

set PYTHONPATH=%PYTHONPATH%;%PATH%

set HOME=C:\Users\leepeteb\Home

set http_proxy=http://x.com:8080
set https_proxy=https://x.com:8080

rem C:\Users\leepeteb\Home\Apps\Cygwin\bin\mintty.exe -i /Cygwin-Terminal.ico -
C:\Users\leepeteb\Home\Apps\Babun\cygwin.bat
```

When logged into Zsh Shell, run the below to get started:

```
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone https://gitlab.com/xxpeterxx/myfiles .myfiles
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
install apt-cyg /bin

cat > ~/.netrc << EOL
machine gitlab.com
    login xxpeterxx
    password xxx
EOL
```

### Matlab

The matlabShell is only available for 32-bit version of Matlab in Windows, making 2015b the last version usable. To launch matlabshell, simply place ~/.myfiles/Apps/MatlabShell/matlabShell_R2015B_32.exe into the /bin/win32 folder inside the Matlab 2015 installation folder.

### Emacs

1. Download windows Emacs from
   http://emacsbinw64.sourceforge.net/
   and extract to folder E:\Dropbox\Apps\Emacs

2. Install Spacemacs
   git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

3. Run Emacs to install plugins
   Launch Emacs from the below .bat:

```
set PATH=%PATH%;E:\Dropbox\Apps\Cygwin\bin
set PATH=%PATH%;E:\Dropbox\Apps\Anaconda
set PATH=%PATH%;E:\Dropbox\Apps\Anaconda\Scripts
set PATH=%PATH%;E:\Dropbox\Apps\Anaconda\Lib
set PATH=%PATH%;E:\Dropbox\Apps\Anaconda\Lib\site-packages
set PATH=%PATH%;E:\Dropbox\Apps\Anaconda\DLLs
set PYTHONPATH=%PATH%
set HOME=D:\Profile\Home
echo %HOME%
bin\runemacs.exe
```
