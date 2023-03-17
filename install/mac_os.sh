# Build TradeStation Image
#
# id:            Peter Lee (peter.lee@finclab.com)
# last_update:   2022-04-02 03:37:11 UTC
# type:          lib
# sensitivity:   datalab@finclab.com
# platform:      any
# description:   DockerFile to build the TradeStation Image.


## 2 - Create the environment
exit


# -------------------- Python (Conda) -------------------- #

## 1 - Download MiniConda installer
mkdir -p /opt && \
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
bash /tmp/miniconda.sh -b -u -p /opt/conda && \
rm -rf /tmp/miniconda.sh

## 2 - Create the environment
opt/conda/bin/conda config --add channels conda-forge && \
/opt/conda/bin/conda config --set channel_priority strict && \
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
# RUN /opt/conda/bin/conda install -c conda-forge/label/cf202003 -y nodejs && \
/opt/conda/envs/paper/bin/jupyter labextension install jupyterlab-plotly && \
/opt/conda/envs/paper/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager plotlywidget && \
/opt/conda/envs/paper/bin/jupyter labextension install @axlair/jupyterlab_vim && \
/opt/conda/envs/paper/bin/jupyter labextension update --all

# blpapi - BBG api
/opt/conda/envs/paper/bin/python -m pip install --index-url=https://bcms.bloomberg.com/pip/simple blpapi \

exit


# -------------------- System Packages -------------------- #
# System prerequisites
RUN apt-get update &&
	apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Install required packages && upgrade
RUN add-apt-repository ppa:neovim-ppa/unstable &&
	apt-get update &&
	yes | apt-get install -y zsh fish fonts-powerline neovim openssh-server nano sudo gosu npm python3-pip ripgrep git apt-utils unzip gcc g++ make shellcheck codespell cowsay fortune lolcat trash-cli tmux tmuxinator locales &&
	yes | apt-get upgrade -y &&
	chsh --shell /bin/bash root

# NodeJS packages
# RUN curl -sL https://deb.nodesource.com/setup_17.x | /bin/bash - && \
RUN apt install -y nodejs

# Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null &&
	echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list &&
	apt update &&
	yes | apt install -y yarn

# Rustc
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

# Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null &&
	apt-get update &&
	apt-get install -y docker-ce docker-ce-cli containerd.io

# sc-im
# RUN apt-get install -y bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev pkg-config && \
#     git clone https://github.com/jmcnamara/libxlsxwriter.git /tmp/libxlsxwriter && \
#     cd /tmplibxlsxwriter/ && make && make install && \
#     ldconfig && \
#     git clone https://github.com/andmarti1424/sc-im.git /tmp/sc-im && \
#     cd /tmp/sc-im/src && make && make install

# -------------------- User Apps -------------------- #
# Starship
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# EXA
RUN EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+') &&
	curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip" &&
	unzip -q exa.zip bin/exa -d /usr/local &&
	rm -f exa.zip

# Prettier
RUN yarn add --dev --exact prettier

# tree-sitter
RUN npm install -y -g --save-dev tree-sitter-cli

# batcat
RUN /root/.cargo/bin/cargo install --locked bat

# -------------------- QuantConnect / Lean CLI -------------------- #
# Install Mono & Environment for QuantConnect/Lean
RUN yes | DEBIAN_FRONTEND=noninteractive apt install -y nuget dirmngr gnupg apt-transport-https ca-certificates &&
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&
	sh -c 'echo "deb https://download.mono-project.com/repo/ubuntu stable-jammy main" > /etc/apt/sources.list.d/mono-official-stable.list' &&
	apt update --allow-unauthenticated --allow-insecure-repositories --allow-releaseinfo-change | true &&
	yes | DEBIAN_FRONTEND=noninteractive apt install -y mono-complete

# Restore dependency for QuantConnect/Lean
# RUN nuget restore /lab/lean/QuantConnect.Lean.sln

# Deploy latest lean
# COPY ./docker/lean /lab/lean

## Install Python libraries
RUN /opt/conda/envs/paper/bin/python -m pip install --upgrade lean &&
	/opt/conda/envs/paper/bin/python -m pip install --upgrade quantconnect-stubs

# -------------------- System Settings -------------------- #
# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen &&
	locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# -------------------- Create User Account -------------------- #
# Change ROOT password
RUN echo "root:${ts_password}" | chpasswd

COPY docker/sudoers /etc/sudoers
RUN groupadd -r -g 10000 tradestation &&
	useradd -U -u ${ts_uid} -G tradestation -G sudo -s ${ts_shell} ${ts_user} -p "$(openssl passwd -1 ${ts_password})" &&
	echo "${ts_user} ALL=NOPASSWD:/bin/mkdir" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/bin/chown" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/bin/apt" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/sbin/useradd" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/sbin/deluser" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/sbin/chpasswd" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/sbin/service" >>/etc/sudoers &&
	echo "${ts_user} ALL=NOPASSWD:/usr/bin/docker" >>/etc/sudoers

# -------------------- Configure Docker -------------------- #
# Add user to docker group
RUN usermod -a -G docker ${ts_user}

# Start Docker
# Trust the internal corp docker registry
COPY docker/docker_config/daemon.json /etc/docker/daemon.json
COPY docker/docker_config/docker-pull.sh /usr/bin
RUN chmod +x /usr/bin/docker-pull.sh && docker-pull.sh && rm /usr/bin/docker-pull.sh

# -------------------- Configure Docker -------------------- #
# Update hostname
RUN echo "[${ts_user}]ts-paper" >/etc/hostname

# Set labenv to paper
COPY docker/labenv/labenv_paper.yml /lab/labenv.yml

# Set File Permissions (after the `user` account has been created)
RUN chmod -R 770 /lab &&
	chown -R ${ts_user}:tradestation /lab &&
	chown -R ${ts_user}:tradestation /var/log &&
	chmod -R 770 /opt/conda &&
	chown -R ${ts_user}:tradestation /opt/conda

# -------------------- Clean Up -------------------- #
RUN apt-get install -y cifs-utils rsync &&
	apt-get autoremove -y
RUN echo $(date) >/lab/tradestation_last_built

# -------------------- In-house Packages -------------------- #
# Pyfolio
COPY ./docker/pyfolio/pyfolio /lab/lib/pyfolio
COPY ./docker/finclab/finclab /lab/lib/finclab

# Configure Bash / Zsh environment
COPY ./docker/sh/bash/bashrc /root/.bashrc
COPY ./docker/sh/bash/bash_alias /root/.bash_alias
COPY ./docker/sh/zsh/zshrc /root/.zshrc

# Copy over the GE config file
COPY ./docker/finclab_great_expectations_config.yml /lab/lib/finclab/data/great_expectations/uncommitted/config_variables.yml

# -------------------- Switch User -> Kick off ths system -------------------- #
# Switch user
USER ${ts_user}
WORKDIR /lab

# -------------------- Entry Point -------------------- #
COPY ./docker/entrypoint.sh /tmp/entrypoint.sh
CMD ["/bin/bash", "/tmp/entrypoint.sh"]
