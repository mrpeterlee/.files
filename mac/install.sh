# Install all dependencies from scratch
#
# id:            Peter Lee (peter.lee@finclab.com)
# last_update:   2022-04-02 03:37:11 UTC
# type:          lib
# sensitivity:   datalab@finclab.com
# platform:      any
# description:   DockerFile to build the TradeStation Image.

# -------------------- System Packages -------------------- #
# System packages are installed using brew
brew install neovim
brew install starship
brew install exa
brew install prettier
brew install bat
brew install zoxide
brew install --cask julia
brew install golang
brew install ripgrep git make shellcheck codespell cowsay fortune lolcat tmux tmuxinator tree-sitter openvpn
brew install --cask docker

# Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null &&
	apt-get update &&
	apt-get install -y docker-ce docker-ce-cli containerd.io

# -------------------- Rust -------------------- #
brew install rustup
rustup-init

# -------------------- Zsh -------------------- #
# zsh configs
mkdir -p "$HOME/.zprezto-contrib"
git clone --recursive https://github.com/agkozak/zsh-z.git $HOME/.zprezto-contrib/zsh-z
git clone --recursive https://github.com/olets/zsh-abbr.git $HOME/.zprezto-contrib/zsh-abbr

# -------------------- Python (Conda) -------------------- #
## 1 - Download MiniConda installer
mkdir -p /opt &&
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh &&
	bash /tmp/miniconda.sh -b -u -p /opt/conda &&
	rm -rf /tmp/miniconda.sh

## 2 - Create the environment
opt/conda/bin/conda config --add channels conda-forge &&
	/opt/conda/bin/conda config --set channel_priority strict &&
	/opt/conda/bin/conda create -y -c conda-forge --name paper python=3.9 pip --file /lab/paper/tradestation/docker/conda/requirements-conda-install.txt

conda activate paper

## Install Python libraries
/opt/conda/envs/paper/bin/python -m pip install -r /lab/paper/tradestation/docker/conda/conda/requirements.txt
/opt/conda/envs/paper/bin/python -m pip install exchange-calendars
/opt/conda/envs/paper/bin/python -m pip install pandas-market-calendars
/opt/conda/envs/paper/bin/python -m pip install country-converter
/opt/conda/envs/paper/bin/python -m pip install iexfinance
/opt/conda/envs/paper/bin/python -m pip install quantrocket-moonshot
/opt/conda/envs/paper/bin/python -m pip install kaleido

# #################### Trading / Data Science ####################
/opt/conda/envs/paper/bin/python -m pip install bta-lib
/opt/conda/envs/paper/bin/python -m pip install quantrocket-client
/opt/conda/envs/paper/bin/python -m pip install ta
/opt/conda/envs/paper/bin/python -m pip install trendln
/opt/conda/envs/paper/bin/python -m pip install pandas_ta
/opt/conda/envs/paper/bin/python -m pip install numpy_ext
# RUN /opt/conda/envs/paper/bin/python -m pip install quantrocket-moonchart

## 3 - Install Jupyter Lab Extensions
python -m pip install notebook jupyter_contrib_nbextensions
# Jupyter lab plugins - Vim Bindings
rm -rf $(jupyter --data-dir)/nbextensions
mkdir -p $(jupyter --data-dir)/nbextensions
git clone https://github.com/lambdalisue/jupyter-vim-binding $(jupyter --data-dir)/nbextensions/vim_binding
chmod -R go-w $(jupyter --data-dir)/nbextensions/vim_binding
jupyter nbextension enable vim_binding/vim_binding
jupyter labextension install jupyterlab-plotly
jupyter labextension install @jupyter-widgets/jupyterlab-manager plotlywidget
jupyter labextension install @axlair/jupyterlab_vim
jupyter labextension update --all

# blpapi - BBG api
/opt/conda/envs/paper/bin/python -m pip install --index-url=https://bcms.bloomberg.com/pip/simple blpapi

# -------------------- Tmuxinator -------------------- #
git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
ln -sf $HOME/.tmux/.tmux.conf $HOME/.tmux.conf
ln -sf $HOME/.files/tmux/.tmux.conf.local $HOME/.tmux.conf.local
ln -sf $HOME/.files/tmuxinator $HOME/.tmuxinator

# -------------------- QuantConnect / Lean CLI -------------------- #
brew install mono nuget

# Restore dependency for QuantConnect/Lean
nuget restore /lab/paper/lean/QuantConnect.Lean.sln

## Install Python libraries
/opt/conda/envs/paper/bin/python -m pip install --upgrade lean quantconnect-stubs
