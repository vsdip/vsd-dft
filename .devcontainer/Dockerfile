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
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# System dependencies for OSS CAD Suite, Fault, Swift, Pyverilog, Quaigh, noVNC
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git make cmake ninja-build \
    build-essential g++ clang lld \
    autoconf automake libtool m4 gperf \
    bison flex gawk pkg-config \
    curl ca-certificates wget unzip xz-utils file \
    gpg gnupg gnupg2 bash \
    libcurl4-openssl-dev libz3-dev lldb python3-lldb-14 \
    python3 python3-pip python3-venv python3-dev \
    tcl tcl-dev tk tk-dev \
    zlib1g-dev libffi-dev libfl-dev libssl-dev \
    libreadline-dev libncurses-dev libedit-dev \
    libsqlite3-dev uuid-dev \
    graphviz xdot \
    xfce4 xfce4-terminal \
    x11vnc xvfb novnc websockify supervisor dbus-x11 \
    vim nano less \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Install OSS CAD Suite precompiled package
# Provides: yosys, abc, iverilog, vvp, gtkwave, nextpnr, openFPGALoader, etc.
# -----------------------------------------------------------------------------
RUN mkdir -p /opt \
    && cd /opt \
    && wget -q https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-05-13/oss-cad-suite-linux-x64-20260513.tgz \
    && tar -xzf oss-cad-suite-linux-x64-20260513.tgz \
    && rm -f oss-cad-suite-linux-x64-20260513.tgz

ENV OSS_CAD_SUITE=/opt/oss-cad-suite
ENV PATH="/opt/oss-cad-suite/bin:${PATH}"

# -----------------------------------------------------------------------------
# Install Rust + Quaigh
# -----------------------------------------------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --profile minimal

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install quaigh

# -----------------------------------------------------------------------------
# Install Swift using Swiftly
# Swiftly may complain about python3-lldb-13 but Swift installs correctly.
# Therefore, allow swiftly install to return non-zero, then strictly verify Swift.
# -----------------------------------------------------------------------------
SHELL ["/bin/bash", "-c"]

RUN cd /tmp \
    && curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz \
    && tar zxf swiftly-$(uname -m).tar.gz \
    && ./swiftly init --quiet-shell-followup --skip-install --assume-yes \
    && source /root/.local/share/swiftly/env.sh \
    && (/root/.local/share/swiftly/bin/swiftly install 6.3.1 || true) \
    && /root/.local/share/swiftly/bin/swiftly use 6.3.1 \
    && source /root/.local/share/swiftly/env.sh \
    && hash -r \
    && swift --version

ENV SWIFTLY_HOME_DIR=/root/.local/share/swiftly
ENV PATH="/root/.local/share/swiftly/bin:/root/.local/share/swiftly/toolchains/6.3.1/usr/bin:/opt/oss-cad-suite/bin:/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/root/.local/share/swiftly/toolchains/6.3.1/usr/lib/swift/linux:${LD_LIBRARY_PATH}"

# -----------------------------------------------------------------------------
# Python virtual environment + Pyverilog
# -----------------------------------------------------------------------------
RUN python3 -m venv /opt/fault_env \
    && /opt/fault_env/bin/pip install --upgrade pip \
    && /opt/fault_env/bin/pip install pyverilog

ENV PATH="/opt/fault_env/bin:${PATH}"

# -----------------------------------------------------------------------------
# Build Fault from source
# This follows the exact working manual flow:
# clone as root into /opt, chown to vscode, remove .swift-version, build, install.
# -----------------------------------------------------------------------------
RUN source /root/.local/share/swiftly/env.sh \
    && swift --version \
    && rm -rf /opt/Fault \
    && cd /opt \
    && git clone https://github.com/AUCOHL/Fault.git \
    && chown -R ${USERNAME}:${USERNAME} /opt/Fault \
    && cd /opt/Fault \
    && rm -f .swift-version \
    && swift build -c release \
    && cp .build/release/fault /usr/local/bin/fault \
    && chmod +x /usr/local/bin/fault \
    && which fault \
    && fault --help | head -n 20

SHELL ["/bin/sh", "-c"]

# -----------------------------------------------------------------------------
# Make tools available to vscode user
# -----------------------------------------------------------------------------
RUN cp -r /root/.cargo /home/${USERNAME}/.cargo \
    && cp -r /root/.local /home/${USERNAME}/.local \
    && cp -r /opt/fault_env /home/${USERNAME}/fault_env \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.cargo /home/${USERNAME}/.local /home/${USERNAME}/fault_env

RUN echo 'source /home/vscode/fault_env/bin/activate' >> /home/${USERNAME}/.bashrc \
    && echo 'source /home/vscode/.local/share/swiftly/env.sh' >> /home/${USERNAME}/.bashrc \
    && echo 'export SWIFTLY_HOME_DIR=/home/vscode/.local/share/swiftly' >> /home/${USERNAME}/.bashrc \
    && echo 'export OSS_CAD_SUITE=/opt/oss-cad-suite' >> /home/${USERNAME}/.bashrc \
    && echo 'export PATH=/home/vscode/fault_env/bin:/home/vscode/.cargo/bin:/home/vscode/.local/share/swiftly/bin:/home/vscode/.local/share/swiftly/toolchains/6.3.1/usr/bin:/opt/oss-cad-suite/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /home/${USERNAME}/.bashrc \
    && echo 'export LD_LIBRARY_PATH=/home/vscode/.local/share/swiftly/toolchains/6.3.1/usr/lib/swift/linux:${LD_LIBRARY_PATH:-}' >> /home/${USERNAME}/.bashrc \
    && echo 'export DISPLAY=:1' >> /home/${USERNAME}/.bashrc
    
# -----------------------------------------------------------------------------
# Final strict sanity check
# Do not hide Fault failures.
# -----------------------------------------------------------------------------
RUN /bin/bash -c "source /root/.local/share/swiftly/env.sh && swift --version" \
    && yosys -V \
    && iverilog -V | head -n 1 \
    && vvp -V | head -n 1 \
    && quaigh --help | head -n 3 \
    && which fault \
    && fault --help | head -n 20

# -----------------------------------------------------------------------------
# noVNC desktop setup
# -----------------------------------------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/vnc.conf

EXPOSE 6080

CMD ["/usr/bin/supervisord", "-n"]
