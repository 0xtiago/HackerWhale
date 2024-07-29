FROM ubuntu:latest

RUN apt update && apt install -y \
    zsh \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    python-is-python3 \
    golang \
    vim \
    tmux

# Hostname
RUN echo "HackerWhale" > /etc/hostname

# Expansion script argument
ARG EXPANSION_SCRIPT_URL
ARG EXPANSION_SCRIPT_LOCAL
ENV EXPANSION_SCRIPT_URL=${EXPANSION_SCRIPT_URL}
ENV EXPANSION_SCRIPT_LOCAL=${EXPANSION_SCRIPT_LOCAL}

COPY ${EXPANSION_SCRIPT_LOCAL} /tmp/expansion_script.sh

RUN if [ ! -z "$EXPANSION_SCRIPT_URL" ]; then \
    curl -sSL $EXPANSION_SCRIPT_URL -o /tmp/expansion_script.sh && \
    chmod +x /tmp/expansion_script.sh && \
    /tmp/expansion_script.sh; \
    elif [ -f /tmp/expansion_script.sh ]; then \
    chmod +x /tmp/expansion_script.sh && \
    /tmp/expansion_script.sh; \
    else \
    echo "No expansion script provided, executing default configuration."; \
    # Add the default configuration you want to execute here
    apt-get update && apt-get install -y nodejs npm; \
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
    echo 'setopt share_history' >> /root/.zshrc

RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="refined"/' /root/.zshrc

# Instalando o ohmytmux
RUN git clone https://github.com/gpakosz/.tmux.git ~/.tmux && \
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf && \
    cp ~/.tmux/.tmux.conf.local ~/


#Limpeza de cache para diminuir a imagem
#RUN rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

# Para manter o container em execução após saídas
CMD ["tail", "-f", "/dev/null"]

# docker build --build-arg EXPANSION_SCRIPT_LOCAL=expansion_script.sh -t hackerwhale .
# docker build --build-arg EXPANSION_SCRIPT_URL=https://github.com/0xtiago/expansion_script.sh -t hackerwhale .

