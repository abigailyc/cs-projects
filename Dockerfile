FROM ubuntu:24.04

RUN apt-get update

# RUN useradd -ms /bin/bash testuser
# RUN echo 'testuser' 'testpassword' | chpasswd
# USER testuser
# WORKDIR /home/testuser

RUN <<EOF
    apt install -y curl
    apt-get update && apt-get install -y git

    curl -sL https://deb.nodesource.com/setup_22.x -o /tmp/node_setup.sh
    bash /tmp/node_setup.sh
    apt install -y nodejs
EOF

RUN <<EOF
    DEBIAN_FRONTEND=noninteractive
    apt install -y default-jre-headless
    rm -fr /var/lib/apt/lists/*
EOF

RUN <<EOF
    add-apt-repository universe
    apt update
    apt install -y python3
    apt install -y python3-pygame
    rm -fr /var/lib/apt/lists/*

    apt-get install autoconf 
    apt-get install autotools-dev
    apt-get install automake
    apt-get install libtool
    apt-get install inotify-tools
    rm -fr /var/lib/apt/lists/*
EOF

RUN <<EOF
    npm install --global @vscode/vsce
    mkdir -p /opt/codespace/extensions
    cd /tmp
    git clone https://github.com/Lynbrook-High-School/lynbrook-cs
    cd lynbrook-cs
    npm install
    vsce package
    mv lynbrook-cs-*.vsix /opt/codespace/extensions
    npm uninstall --global vsce
EOF

RUN apt-get update && apt-get install -y \
    git \
    fswatch \
    inotify-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN curl -s https://raw.githubusercontent.com/gitwatch/gitwatch/master/gitwatch.sh -o /usr/local/bin/gitwatch.sh \ 
    && chmod +x /usr/local/bin/gitwatch.sh

RUN apt clean
