FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# -----------------------------------------------------------------------------
# Create Codespaces-compatible vscode user
# -----------------------------------------------------------------------------
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# -----------------------------------------------------------------------------
# System dependencies for Fault, Yosys, Icarus, Pyverilog, Quaigh, GUI/noVNC
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git make cmake ninja-build \
    build-essential g++ clang lld \
    autoconf automake libtool m4 gperf \
    bison flex gawk pkg-config \
    curl ca-certificates wget unzip xz-utils file \
    gpg gnupg bash \
    libcurl4-openssl-dev libz3-dev python3-lldb-14 \
    python3 python3-pip python3-venv python3-dev \
    tcl tcl-dev tk tk-dev \
    zlib1g-dev libffi-dev libfl-dev libssl-dev \
    libreadline-dev libncurses-dev libedit-dev \
    libsqlite3-dev libxml2-dev uuid-dev \
    graphviz xdot \
    xfce4 xfce4-terminal \
    x11vnc xvfb novnc websockify supervisor dbus-x11 \
    vim nano less \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Install Rust + Quaigh
# -----------------------------------------------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --profile minimal

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install quaigh

# -----------------------------------------------------------------------------
# Install Swift using Swiftly
# -----------------------------------------------------------------------------
SHELL ["/bin/bash", "-c"]

RUN cd /tmp \
    && curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz \
    && tar zxf swiftly-$(uname -m).tar.gz \
    && ./swiftly init --quiet-shell-followup --skip-install --assume-yes \
    && source /root/.local/share/swiftly/env.sh \
    && /root/.local/share/swiftly/bin/swiftly install 6.3.1 \
    && /root/.local/share/swiftly/bin/swiftly use 6.3.1

SHELL ["/bin/sh", "-c"]

ENV SWIFTLY_HOME_DIR=/root/.local/share/swiftly
ENV PATH="/root/.local/share/swiftly/bin:/root/.local/share/swiftly/toolchains/6.3.1/usr/bin:${PATH}"

# -----------------------------------------------------------------------------
# Python virtual environment + Pyverilog
# -----------------------------------------------------------------------------
RUN python3 -m venv /opt/fault_env \
    && /opt/fault_env/bin/pip install --upgrade pip \
    && /opt/fault_env/bin/pip install pyverilog

ENV PATH="/opt/fault_env/bin:${PATH}"

# -----------------------------------------------------------------------------
# Build Icarus Verilog from source
# -----------------------------------------------------------------------------
RUN git clone https://github.com/steveicarus/iverilog.git /opt/iverilog \
    && cd /opt/iverilog \
    && sh autoconf.sh \
    && ./configure \
    && make -j"$(nproc)" \
    && make install

# -----------------------------------------------------------------------------
# Build Yosys from source
# -----------------------------------------------------------------------------
RUN git clone --recurse-submodules https://github.com/YosysHQ/yosys.git /opt/yosys \
    && cd /opt/yosys \
    && make config-clang \
    && make -j"$(nproc)" \
    && make install

# -----------------------------------------------------------------------------
# Build Fault from source
# -----------------------------------------------------------------------------
RUN git clone https://github.com/AUCOHL/Fault.git /opt/Fault \
    && cd /opt/Fault \
    && swift --version | head -n 1 | awk '{print $3}' | cut -d'.' -f1,2 > .swift-version \
    && swift build -c release \
    && cp .build/release/fault /usr/local/bin/fault \
    && chmod +x /usr/local/bin/fault

# -----------------------------------------------------------------------------
# Make tools available to vscode user
# -----------------------------------------------------------------------------
RUN cp -r /root/.cargo /home/${USERNAME}/.cargo \
    && cp -r /root/.local /home/${USERNAME}/.local \
    && cp -r /opt/fault_env /home/${USERNAME}/fault_env \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.cargo /home/${USERNAME}/.local /home/${USERNAME}/fault_env

RUN echo 'source /home/vscode/fault_env/bin/activate' >> /home/${USERNAME}/.bashrc \
    && echo 'export PATH=/home/vscode/.cargo/bin:/home/vscode/.local/share/swiftly/bin:/home/vscode/.local/share/swiftly/toolchains/6.3.1/usr/bin:/usr/local/bin:$PATH' >> /home/${USERNAME}/.bashrc \
    && echo 'export DISPLAY=:1' >> /home/${USERNAME}/.bashrc

# -----------------------------------------------------------------------------
# noVNC desktop setup copied from vsd-rtl pattern
# -----------------------------------------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/vnc.conf

EXPOSE 6080

CMD ["/usr/bin/supervisord", "-n"]
