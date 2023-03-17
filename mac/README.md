# Mac OS Installation Guide

Author: Peter Lee (peter.lee@astrocapital.net)
last_update: 2023-03-15 20:51:45 UTC
description: This repo holds a collection of configuration files for my preferred development environment (Windows/Mac OS/Linux)

# Installation Guide

### Install from App Store

Install the below apps from the App store:

- Owly
- 1password
- The Unarchiver
- BetterSnapTool

## Create /lab folder

You need to create the file `/etc/synthetic.conf`, which should be owned by root and group wheel with permissions 0644.
The contents should look like this - the gap is a TAB not SPACES!
newfolder Users/foo/bar

```bash
    sudo touch /etc/synthetic.conf
    sudo vim /etc/synthetic.conf
    sudo chmod 644 /etc/synthetic.conf
```

### Clone this repo

```bash
git clone https://www.github.com/mrpeterlee/dotconfig.git ~/.config
```

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
brew install dos2unix
brew install lolcat
brew install fortune
brew install git
brew install exa
brew install neovim
brew install --cask iterm2
```

### Zsh

```bash
# Install zprezo
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
# Install starship
brew install starship

# Set up symlinks
ln -sf ~/.files/zsh/zshrc ~/.zshrc
ln -sf ~/.files/zsh/zpreztorc ~/.zpreztorc
ln -sf ~/.files/starship/starship.toml ~/.config/starship.toml

chsh -s /bin/zsh
```

# Iterm

ln -sf ~/.files/iterm/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

### Git

```
ln -sf ~/.files/git/.gitconfig ~/.gitconfig
```

### Miniconda

Install Miniconda to /opt/conda

### Neovim

Follow the instructions from `AstroNvim`

### OS-specific configurations

Users & Groups

- Login Options -> Change fast switching user menu to Icon
- Set up Password, Apple ID, Picture, etc.
  Trackpad
- Point & Click
  - Enable Tap to click with one finger
  - Change Secondary click to right corner
  - Uncheck three finger drag
- Scroll & Zoom \* Uncheck all apart from Zoom in and out
  Dock
- Visual settings
  - Change position to left and make the size of Icons small
- Other settings \* Remove workspace auto-switching  $ defaults write com.apple.dock workspaces-auto-swoosh -bool NO
  $ killall Dock
  Dock > Automatically hide and show the Dock
  Finder
- Toolbar
  - Update to add path, new folder and delete
- Sidebar
  _ Add home and code directory
  _ Remove shared and tags \* New finder window to open in the home directory
  Menubar
- Remove the display and Bluetooth icons
- Change battery to show percentage symbols
  Spotlight
- Uncheck fonts, images, files etc.
- Uncheck the keyboard shortcuts as we'll be replacing them with Alfred.
  Accounts
- Add an iCloud account and sync Calendar, Find my mac, Contacts etc.
  iterm2
- In iTerm > Preferences..., under the tab General, uncheck Confirm closing multiple sessions and Confirm "Quit iTerm2 (Cmd+Q)" command under the section Closing.
- In the tab Profiles, create a new one with the "+" icon, and rename it to your first name for example. Then, select Other Actions... > Set as Default. Finally, under the section Window, change the size to something better, like Columns: 125 and Rows: 35.
- Colors and Font Settings
  ** Set hotkey to open and close the terminal to command + control + i
  ** Go to profiles -> Default -> Terminal -> Check silence bell
  ** Download one of iTerm2 color schemes from here. And then set these to your default profile colors.
  ** Change the cursor text and cursor color to yellow make it more visible
  ** Change the font to 14pt Source Code Pro Lite. Source Code Pro can be downloaded from here.
  ** If you're using BASH instead of ZSH you could add export CLICOLOR=1 line to your ~/.bash_profile file for nice coloring of listings.

### Write to NTFS on OSX Yosemite and El Capitan

Install Homebrew and Homebrew Cask

- Instructions here!
  Update Homebrew formulae:
  $ brew update
  Install osxfuse
- If you are on OSX 10.11 (El Capitan), install the (3.x.x) from https://github.com/osxfuse/osxfuse/releases. $ brew cask install osxfuse
  Install ntfs-3g
  $ brew install homebrew/fuse/ntfs-3g
  If you are on OSX 10.11 (El Capitan), temporary disable System Integrity Protection.
- reboot and hold CMD+R to get in recovery mode
- Open the terminal and type
  $ csrutil disable
- reboot normally
  Create a symlink for mount_ntfs
  $ sudo mv /sbin/mount_ntfs /sbin/mount_ntfs.original
  $ sudo ln -s /usr/local/sbin/mount_ntfs /sbin/mount_ntfs
  If you are on OSX 10.11 (El Capitan), re-enable System Integrity Protection.
- reboot and hold CMD+R to get in recovery mode
- Open the terminal and type
  $ csrutil enable
- reboot normally
