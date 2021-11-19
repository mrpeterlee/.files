#!/usr/bin/bash

# Makefile for Installation

# Author: Peter Lee (mr.peter.lee@hotmail.com)

module := dotfiles

# Please specify where this repo is
module_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Check the flavour of operating system
ifeq ($(OS),Windows_NT)
    os_type += windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        os_type += linux
    endif
    ifeq ($(UNAME_S),Darwin)
        os_type += osx
    endif
endif

install:
ifeq (${os_type},osx)
	$(MAKE) install_osx
endif
ifeq (${os_type},linux)
	$(MAKE) install_linux
endif


install_osx:
	# Installation script for mac os
	@mkdir -p $${HOME}/.config
	# Install zsh
	brew install zsh zsh-completions
	# Install prezto
	if [ ! -d "${HOME}/.zprezto" ]; then \
		echo "Clone official zprezto repo..."; \
		git clone --recursive https://github.com/sorin-ionescu/prezto.git "$${HOME}/.zprezto"; \
	fi
	@ln -sf ${module_path}/zsh/zlogin $${HOME}/.zlogin
	@ln -sf ${module_path}/zsh/zlogout $${HOME}/.zlogout
	@ln -sf ${module_path}/zsh/zpreztorc $${HOME}/.zpreztorc
	@ln -sf ${module_path}/zsh/zprofile $${HOME}/.zprofile
	@ln -sf ${module_path}/zsh/zshenv $${HOME}/.zshenv
	@ln -sf ${module_path}/zsh/zshrc $${HOME}/.zshrc
	# Install neovim
	@mkdir -p $${HOME}/.config/nvim
	# brew install --HEAD neovim
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	python3 -m pip install --upgrade pip --user
	python3 -m pip install --user neovim
	# Install tmux
	brew install tmux
	ln -sf ${module_path}/tmux/.tmux.conf $${HOME}/.tmux.conf

install_linux:
	# Installation script for mac os
	@mkdir -p $${HOME}/.config
	# Install prezto
	if [ ! -d "${HOME}/.zprezto" ]; then \
		echo "Clone official zprezto repo..."; \
		git clone --recursive https://github.com/sorin-ionescu/prezto.git "$${HOME}/.zprezto"; \
	fi
	@ln -sf ${module_path}/zsh/zlogin $${HOME}/.zlogin
	@ln -sf ${module_path}/zsh/zlogout $${HOME}/.zlogout
	@ln -sf ${module_path}/zsh/zpreztorc $${HOME}/.zpreztorc
	@ln -sf ${module_path}/zsh/zprofile $${HOME}/.zprofile
	@ln -sf ${module_path}/zsh/zshenv $${HOME}/.zshenv
	@ln -sf ${module_path}/zsh/zshrc $${HOME}/.zshrc
	# Install neovim
	@mkdir -p $${HOME}/.config/nvim
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	/usr/bin/python3 -m pip install --upgrade pip --user
	/usr/bin/python3 -m pip install --user neovim
	# Install tmux
	ln -sf ${module_path}/tmux/.tmux.conf $${HOME}/.tmux.conf
	# sym_link bash 
	ln -sf ${module_path}/bash/.bash_alias $${HOME}/.bash_alias
	ln -sf ${module_path}/bash/.bashrc $${HOME}/.bashrc
	# Install vifm
	@mkdir -p $${HOME}/.config/vifm
	ln -sf ${module_path}/vifm/vifmrc $${HOME}/.config/vifm/vifmrc
	# Install git config
	ln -sf ${module_path}/git/.gitconfig $${HOME}/.gitconfig

install_neovim:
	ln -sf ${module_path}/nvim/init.vim $${HOME}/.config/nvim/init.vim
	ln -sf ${module_path}/nvim/init.vim $${HOME}/.vimrc

install_spacevim:
	curl -sLf https://spacevim.org/install.sh | bash
	mkdir -p $${HOME}/.SpaceVim/autoload
	rm -f $${HOME}/.SpaceVim/autoload/myspacevim.vim
	ln -sf ${module_path}/spacevim/myspacevim.vim $${HOME}/.SpaceVim/autoload/myspacevim.vim
	rm -f $${HOME}/.SpaceVim.d/init.toml
	ln -sf ${module_path}/spacevim/init.toml $${HOME}/.SpaceVim.d/init.toml
	ln -sf ${module_path}/spacevim/coc-settings.json $${HOME}/.config/nvim/coc-settings.json
	ln -sf ${module_path}/spacevim/.pylintrc $${HOME}/.pylintrc
	npm install -g neovim
	# COC auto completion
	# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  # echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	# sudo apt install yarn
	#
	# Python Layer
	conda install -y -n finclab -c conda-forge yapf flake8 autoflake isort coverage black
	python -m pip install doq  # (pydocstring)
	conda install -y -n finclab ipython
	pip2 install --user pynvim
	pip install --user notedown  # ipynb support
	# In Neovim run:
	#:CocInstall coc-python
	#:CocInstall coc-omnisharp
	# Install language server protocals: https://spacevim.org/layers/language-server-protocol/
	npm i -g bash-language-server
	npm install --global vscode-html-languageserver-bin
	# Support for MarkDown
	npm -g install remark
	npm -g install remark-cli
	npm -g install remark-stringify
	npm -g install remark-frontmatter
	npm -g install wcwidth
	sudo apt install -y ripgrep
	sudo apt install -y exuberant-ctags fzf

	

uninstall_spacevim:
	rm -rf ~/.config/nvim
	rm -rf ~/.vim
	rm -rf ~/.SpaceVim
	rm -rf ~/.SpaceVim.d
	rm -rf ~/.cache

