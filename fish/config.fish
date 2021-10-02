#!/usr/bin/env fish

if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end

# Load Fish Plugins
fundle plugin 'danhper/fish-theme-afowler'
fundle plugin 'franciscolourenco/done'
fundle plugin 'junegunn/fzf'

fundle init

# Init Starship
starship init fish | source

# Init Conda
eval /opt/conda/bin/conda "shell.fish" "hook" $argv | source

#if [ (hostname) = finclab-us1 ]
#    conda activate finclab
#end 
#
#if [ (hostname) = TradeStation-Peter ]
#    conda activate finclab
#end 

# Disable greeting
set fish_greeting

############################## My Settings #############################
fish_vi_key_bindings  # vi-mode
set -gx PROJECT_PATHS ~/lab/paper ~/project
bind \cf forward-char

############################## PATHS #############################
set -x PATH $PATH /usr/bin
set -x PATH $PATH /snap/bin
set -x PATH $PATH /bin
set -x PATH $PATH /opt/conda/bin
set -x PATH $PATH /lab/lib/finclab/sh/bash
set -x PATH $PATH /lab/lib/finclab/sh/zsh
set -x PATH $PATH /lab/lib/finclab/sh/fish
set -x PATH $PATH /home/peter/.local/bin
set -x PATH $PATH /home/peter/.files/bin
set -x PATH $PATH /Users/peter/.files/bin
set -x PATH $PATH /Users/peter/lab/lib/finclab/sh/bash
set -x PATH $PATH /Users/peter/lab/lib/finclab/sh/zsh
set -x PATH $PATH /Users/peter/lab/lib/finclab/sh/fish

############################## Abbr #############################
# gitpush to main
abbr -a qr 'quantrocket'
abbr -a gpm 'set -lx _git_msg (read) && cd (git rev-parse --show-toplevel) && git submodule foreach \'git stash; git checkout main; git pull origin main\' && pytest && nb_rm_output && git add . && git commit -m $_git_msg && git push origin main && set -e _git_msg && cd -'
# switch to prod folder && git merge && git push
abbr -a gpp 'set -lx _current_folder (pwd) && cd (git rev-parse --show-toplevel) && git merge -s ours prod && cd (string replace /lab/paper /lab/prod $_current_folder) && git submodule foreach \'git stash; git checkout prod; git pull origin prod\' && git merge main && git push origin prod && cd $_current_folder && set -e _current_folder'
abbr -a paper 'set -lx _current_folder (pwd) && set _current_folder (string replace /lab/prod /lab/paper $_current_folder) && cd $_current_folder && set -e _current_folder'
abbr -a prod 'set -lx _current_folder (pwd) && set _current_folder (string replace /lab/paper /lab/prod $_current_folder) && cd $_current_folder && set -e _current_folder'
abbr -a ssh_ts 'ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval 60" -p 50000 peter@10.1.1.100'
abbr -a pjo pj open

############################## ALIAS #############################
alias lzd='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /home/peter/.config/lazydocker:/.config/jesseduffield/lazydocker lazyteam/lazydocker'
alias pip2=pip
alias pip2=pip
alias pip=pip3
alias vim=nvim
alias vpn='sudo /usr/local/Cellar/openvpn/2.5.2/sbin/openvpn --config ~/.ssh/peter.ovpn'
alias sshp='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval 60" -p 55555 -L 1969:10.1.1.100:1969 -L 10000:10.1.1.100:10000 -L 50000:10.1.1.100:50000 peter@vpn.finclab.com'
alias ssha='autossh -M 0 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval 10" -p 55555 -L 1969:10.1.1.100:1969 -L 10000:10.1.1.100:10000 -L 50000:10.1.1.100:50000 -L 55000:10.1.1.100:55000 peter@vpn.finclab.com'
alias update_prezto='cd $ZPREZTODIR;git pull;git submodule update --init --recursive'
if type -q exa
    alias ls='exa --group-directories-first'
    alias ll='exa -lhg --group-directories-first'
    alias la='exa -lahg --group-directories-first'
end
if type -q batcat
    alias cat='batcat'
end
alias fd=fdfind
alias lsp='ls -C --color=always | less -R'
alias lsd='ls -ldg */'
alias lsf='ls -lhpg | grep -v "/"'
alias unbz='tar -jxvf'
alias ungz='tar -zxvf'
alias cmc='./configure && make && sudo checkinstall'
alias cleanswap='sudo swapoff -a && sudo swapon -a'

# Hardware
alias ram='free -h'
alias dush='du -sh'
alias dushs='du -sh * | sort -r -h'
alias disk='df -h .'

# X11
alias xres='xrdb ~/.Xresources'

# Zsh
alias viz='vim ~/.zshrc'
alias soz='source ~/.zshrc'

# Vim
alias vir='vim $HOME/.vimrc'
alias vimgd='vim `git diff --name-only`'
alias svim='sudoedit'
alias vil='vim $HOME/.SpaceVim/autoload/myspacevim.vim'
alias vis='vim $HOME/.SpaceVim.d/init.toml'

# Vifm
alias vif='vim ~/.config/vifm/vifmrc'

# Docker
## Show all docker name and port
alias ddc="docker ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}' | sed 's#^/##';"

# Trash-cli tool
# sudo apt install trash-cli
#alias rm='echo "rm is disabled, use tr or trash or /bin/rm instead."'
alias tr='trash'
alias trl='trash-list'
alias tre='trash-empty'
alias trun='trash `git ls-files . --exclude-standard --others`' # mv git untracked 

# Apt
alias aptedit='sudo apt edit-sources'
alias aptdep='apt-cache depends'
alias aptpol='apt-cache policy'
alias aptsea='apt-cache search'
alias aptsho='apt-cache show'
alias aptver='apt-cache madison'
alias aptbin='apt-get download'
alias aptsrc='apt-get source'
alias aptins='sudo apt-get install'
alias aptsid='sudo apt-get -t sid install'
alias aptrem='sudo apt-get remove'
alias aptaut='sudo apt-get autoremove'
alias aptupg='sudo apt-get update && sudo apt-get upgrade'

# Surfraw
alias srd='surfraw duckduckgo'
alias srg='surfraw github'
alias srl='surfraw slinuxdoc'
alias srm='surfraw mdn'
alias srs='surfraw stack'
alias srw='surfraw wikipedia'
alias srwca='surfraw wikipedia -l=CA'
alias srwes='surfraw wikipedia -l=ES'
alias sry='surfraw youtube'

# Faster git alias
alias gg='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gdn='git diff --name-only'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit --amend -m'
alias gl='git log'
alias gls='git log --stat'
alias ga='git add'
alias gk='git checkout'
alias gb='git branch'
alias gt='git tag'
alias gver='git_version'
alias gm='git merge'
alias grebm='git rebase master'       # Update a branch with the master
alias guntr='git rm --cached'         # Untrack file
alias gunst='git reset HEAD'          # Unstage file
alias gunco='git reset --soft HEAD~1' # Undo last commit
alias gpuom='git push origin master'
alias gpush='git push'
alias gpull='git pull'

# Dev
alias cdd='cd $HOME/project/; ls -ld */'

# Translate-shell
# apt install translate-shell
alias enes='trans en:es -brief'
alias esen='trans es:en -brief'
alias enzh='trans es:zh -brief'
alias zhen='trans zh:en -brief'
alias enfr='trans en:fr -brief'
alias fren='trans fr:en -brief'
alias enjp='trans en:ja -brief'
alias jpen='trans ja:en -brief'

# Time
alias cal1='ncal -M1b'
alias cal3='ncal -M3b'
alias caly='ncal -Myb'
alias diso='date -I | sed "s/-//g"'
alias dutc='date -u'

# Network
alias ipr='ip route'
alias wanip='curl -s icanhazip.com'

# Misc
alias news='newsbeuter'
alias www='w3m'
alias mux='tmuxinator'

# ssh copy back to local
# https://stackoverflow.com/questions/1152362/how-to-send-data-to-local-clipboard-from-a-remote-ssh-session
alias cb='ssh -p 2222 127.0.0.1 pbcopy'



