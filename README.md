My Environment
==============
Author:        Peter Lee (peter.lee@finclab.com)
last_update:   2021-11-13 20:51:45 UTC
description:   This repo holds a collection of configuration files for my preferred development environment in Linux / MacOS.

# Prerequisite

- fish
- Neovim
- Powerline

To install the prerequisites, one can execute the below after a fresh linux installation:

```bash
# NeoVim (install latest from source)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
# Neovim prerequisites for the Python modules:
sudo apt install python-dev python-pip python3-dev python3-pip

# Powerline
sudo apt install powerline
sudo pip3 install pynvim
```


The followings apply to a freshly-installed OS.

## Mac OS

### Clone this repo
```bash
git clone https://www.github.com/mrpeterlee/dotconfig.git ~/.config
```

### Install from App Store
Install the below apps from the App store:

- Owly
- 1password
- The Unarchiver
- BetterSnapTool

### Homebrew
Except the above few applications are either paid or direclty available from App store, most of the apps listed out in this list are freely available via homebrew. The below two lines shall install Homebrew, with the first line installs the Command Line Tools for Xcode, which is the prerequisite for Homebrew.

```bash
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Install other apps via Homebrew

```bash
brew cask install google-chrome dropbox iterm2 cheatsheet vlc visual-studio-code
```

There are more good choices per below:
```bash
brew cask install airmail
brew cask install alfred
brew cask install android-file-transfer
brew cask install asepsis
brew cask install appcleaner
brew cask install doubletwist
brew cask install google-drive
brew cask install google-hangouts
brew cask install flux
brew cask install latexian
brew cask install pdftk
brew cask install spectacle
brew cask install sublime-text
brew cask install superduper
brew cask install totalfinder
brew cask install transmission
brew cask install valentina-studio
brew cask install caffeine
brew install dos2unix
```

### Zsh
```bash
brew install zsh
ln -s ~/.files/unix/.zshenv ~/.zshenv
chsh -s /bin/zsh
```
Relaunch iTerm and see if zsh has loaded successfully.
```
echo $SHELL
echo $ZSH_VERSION
```
Note that you could follow *~/.zshenv* to see what files has been sournced in the zprezto start-up process.


The below script is used to setup this Git Repo the **1st** time. Please discard it.
```bash
cat <<EOT > ~/.files/unix/.zshenv
#!/bin/zsh
export ZDOTDIR=~/.files/unix
source "\${ZDOTDIR}/.zprofile"
EOT
touch ~/.files/unix/.zshrc # will put my fav aliases and functions here
ln -s ~/.files/unix/.zshenv ~/.zshenv
export ZDOTDIR=~/.files/unix
cat <<EOT >> ~/.files/unix/.zshrc
source "\${ZDOTDIR:-\$HOME}/.zprezto/init.zsh"
EOT
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

### Git & SSH
Then we can't live without git...
```
brew install git
git config --global user.name "Peter Lee""
git config --global user.email "mr.peter.lee@hotmail.com""
ssh-keygen -t rsa -b 4096 -C "mr.peter.lee@hotmail.com"
```

### Anaconda
Brew offers installation for Anaconda.
```
brew cask install anaconda
export PATH=/usr/local/anaconda3/bin:"$PATH"
```

### Vim
Install Vim from Homebrew and [Awesome_VIMRC](https://github.com/amix/vimrc)
```
brew install vim -—with-python3
ln -s ~/.files/unix/.vimrc ~/.vimrc
```

To configure the Awesome Vimrc **1st time** for this Git Repo (please discard this):
```
git clone --depth=1 https://github.com/amix/vimrc.git ~/.files/unix/vim_runtime
sh ~/.files/unix/vim_runtime/install_awesome_parameterized.sh /Users/peter/.files/unix/vim_runtime peter
```

### OS-specific configurations
Users & Groups
* Login Options -> Change fast switching user menu to Icon
* Set up Password, Apple ID, Picture, etc.
Trackpad
* Point & Click
    * Enable Tap to click with one finger
    * Change Secondary click to right corner
    * Uncheck three finger drag
* Scroll & Zoom
    * Uncheck all apart from Zoom in and out
Dock
* Visual settings
    * Change position to left and make the size of Icons small
* Other settings
    * Remove workspace auto-switching   $ defaults write com.apple.dock workspaces-auto-swoosh -bool NO
	       $ killall Dock
	Dock > Automatically hide and show the Dock
Finder
* Toolbar
    * Update to add path, new folder and delete
* Sidebar
    * Add home and code directory
    * Remove shared and tags
    * New finder window to open in the home directory
Menubar
* Remove the display and Bluetooth icons
* Change battery to show percentage symbols
Spotlight
* Uncheck fonts, images, files etc.
* Uncheck the keyboard shortcuts as we'll be replacing them with Alfred.
Accounts
* Add an iCloud account and sync Calendar, Find my mac, Contacts etc.
iterm2
* In iTerm > Preferences..., under the tab General, uncheck Confirm closing multiple sessions and Confirm "Quit iTerm2 (Cmd+Q)" command under the section Closing.
* In the tab Profiles, create a new one with the "+" icon, and rename it to your first name for example. Then, select Other Actions... > Set as Default. Finally, under the section Window, change the size to something better, like Columns: 125 and Rows: 35.
* Colors and Font Settings
** Set hotkey to open and close the terminal to command + control + i
** Go to profiles -> Default -> Terminal -> Check silence bell
** Download one of iTerm2 color schemes from here. And then set these to your default profile colors.
** Change the cursor text and cursor color to yellow make it more visible
** Change the font to 14pt Source Code Pro Lite. Source Code Pro can be downloaded from here.
** If you're using BASH instead of ZSH you could add export CLICOLOR=1 line to your ~/.bash_profile file for nice coloring of listings.


### Write to NTFS on OSX Yosemite and El Capitan

Install Homebrew and Homebrew Cask
* Instructions here!
Update Homebrew formulae:
$ brew update
Install osxfuse
* If you are on OSX 10.11 (El Capitan), install the (3.x.x) from https://github.com/osxfuse/osxfuse/releases. $ brew cask install osxfuse
Install ntfs-3g
$ brew install homebrew/fuse/ntfs-3g
If you are on OSX 10.11 (El Capitan), temporary disable System Integrity Protection.
* reboot and hold CMD+R to get in recovery mode
* Open the terminal and type
$ csrutil disable
* reboot normally
Create a symlink for mount_ntfs
$ sudo mv /sbin/mount_ntfs /sbin/mount_ntfs.original
$ sudo ln -s /usr/local/sbin/mount_ntfs /sbin/mount_ntfs
If you are on OSX 10.11 (El Capitan), re-enable System Integrity Protection.
* reboot and hold CMD+R to get in recovery mode
* Open the terminal and type
$ csrutil enable
* reboot normally


## Windows

1st Time Install
================

Anaconda: https://www.continuum.io/downloads
Emacs for Windows: https://sourceforge.net/projects/emacsbinw64/files/release/
Babun: http://babun.github.io/

Deployment
==========

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
````
