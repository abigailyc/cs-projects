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

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install xvfb x11vnc openbox \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV WINDOW_MANAGER="openbox"

# Change the default number of virtual desktops from 4 to 1 (footgun)
RUN sed -ri "s/<number>4<\/number>/<number>1<\/number>/" /etc/xdg/openbox/rc.xml

# Install novnc
# RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
#     && git clone --depth 1 https://github.com/novnc/websockify /opt/novnc/utils/websockify
RUN mkdir -p /opt/novnc \
    && curl -sSL https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz -o /tmp/novnc-install.tar.gz \
    && tar -zxf /tmp/novnc-install.tar.gz --strip-components=1 -C /opt/novnc \
    && rm -f /tmp/novnc-install.tar.gz \
    && mkdir -p /opt/novnc/utils/websockify \
    && curl -sSL https://github.com/novnc/websockify/archive/v0.11.0.tar.gz -o /tmp/websockify-install.tar.gz \
    && tar -zxf /tmp/websockify-install.tar.gz --strip-components=1 -C /opt/novnc/utils/websockify \
    && rm -f /tmp/websockify-install.tar.gz \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends python3-minimal python3-numpy \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*
COPY novnc-index.html /opt/novnc/index.html

# Add VNC startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

# This is a bit of a hack. At the moment we have no means of starting background
# tasks from a Dockerfile. This workaround checks, on each bashrc eval, if the X
# server is running on screen 0, and if not starts Xvfb, x11vnc and novnc.
RUN echo "export DISPLAY=:0" >> ~/.bashrc \
    && echo "[ ! -e /tmp/.X0-lock ] && (/usr/bin/start-vnc-session.sh &> /tmp/display-\${DISPLAY}.log)" >> ~/.bashrc


RUN apt clean
