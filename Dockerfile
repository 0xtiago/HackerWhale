FROM ubuntu:24.04

# Hostname
RUN echo "HackerWhale" > /etc/hostname


#Default package set
ENV DEFAULT_PACKAGE_SET="apt update && apt install -y \
    apt-transport-https \
    zsh \
    git \
    curl \
    file \
    wget \
    lsb-release \
    snapd \
    python3 \
    python3-pip \
    python-is-python3 \
    golang \
    vim \
    tmux"

# Expansion script argument
ARG EXPANSION_SCRIPT_URL
ARG EXPANSION_SCRIPT_LOCAL
ENV EXPANSION_SCRIPT_URL=${EXPANSION_SCRIPT_URL}
ENV EXPANSION_SCRIPT_LOCAL=${EXPANSION_SCRIPT_LOCAL}

# Copy the local script into the container, if provided
COPY ${EXPANSION_SCRIPT_LOCAL} /tmp/expansion_script.sh

RUN if [ ! -z "$EXPANSION_SCRIPT_URL" ]; then \
    eval ${DEFAULT_PACKAGE_SET} && \
    curl -sSL $EXPANSION_SCRIPT_URL | bash; \
    # curl -sSL $EXPANSION_SCRIPT_URL -o /tmp/expansion_script.sh && \
    # chmod +x /tmp/expansion_script.sh && \
    # /tmp/expansion_script.sh; \
    elif [ -f /tmp/expansion_script.sh ]; then \
    eval ${DEFAULT_PACKAGE_SET} && \
    chmod +x /tmp/expansion_script.sh && \
    /tmp/expansion_script.sh; \
    else \
    echo "No expansion script provided, executing default configuration."; \
    eval ${DEFAULT_PACKAGE_SET} && \
    echo "Default configuration completed."; \
    fi

# Instalando o ohmyzsh e configurando o zsh como bash padrão
# https://ohmyz.sh/#install
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    chsh -s /bin/zsh

# Configuração para o zsh history
RUN echo 'HISTFILE=/workdir/.zsh_history_docker' >> /root/.zshrc && \
    echo 'HISTSIZE=1000' >> /root/.zshrc && \
    echo 'SAVEHIST=1000' >> /root/.zshrc && \
    echo 'setopt inc_append_history' >> /root/.zshrc && \
    echo 'setopt share_history' >> /root/.zshrc && \
    echo 'export PATH=$PATH:/root/go/bin' >> /root/.zshrc

RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="refined"/' /root/.zshrc

# Instalando o ohmytmux
RUN git clone https://github.com/gpakosz/.tmux.git ~/.tmux && \
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf && \
    cp ~/.tmux/.tmux.conf.local ~/


#Limpeza de cache para diminuir a imagem
RUN rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    go clean -cache && \
    go clean -testcache && \
    go clean -fuzzcache && \
    go clean -modcache && \
    pip cache purge

WORKDIR /workdir

# Para manter o container em execução após saídas
CMD ["tail", "-f", "/dev/null"]

# docker build --build-arg EXPANSION_SCRIPT_LOCAL=expansion_script.sh -t hackerwhale .
# docker build --build-arg EXPANSION_SCRIPT_URL=https://github.com/0xtiago/expansion_script.sh -t hackerwhale .

