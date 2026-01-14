FROM oven/bun:1.3-slim

WORKDIR /app

# Install system packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    openssh-server \
    git \
    curl \
    wget \
    htop \
    tmux \
    vim \
    nano \
    sudo \
    ca-certificates \
    rsync \
    unzip; \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install OpenCode CLI
RUN bun install -g opencode-ai

# Create SSH directory and generate host keys on first run
RUN mkdir -p /var/run/sshd \
    /etc/ssh/keys \
    /home/dev/.ssh \
    /workspace

# Create dev user with sudo access
RUN set -eux; \
    useradd -m -s /bin/bash dev || true; \
    usermod -aG sudo dev; \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev; \
    chmod 440 /etc/sudoers.d/dev; \
    echo "export PATH=\"/root/.bun/bin:/usr/local/bin:/usr/local/bun-node-fallback-bin:\$PATH\"" >> /home/dev/.bashrc; \
    echo "export OPENCODE_BIN_PATH=/root/.bun/install/global/node_modules/opencode-linux-x64/bin/opencode" >> /home/dev/.bashrc; \
    echo "alias opencode='opencode-ai'" >> /home/dev/.bashrc; \
    chown -R dev:dev /home/dev; \
    chown -R dev:dev /workspace; \
    chmod 700 /home/dev/.ssh; \
    # Make opencode binaries accessible to dev user
    chmod -R +rx /root/.bun/install/global

# Configure SSH server for both password and key auth
RUN set -eux; \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config; \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config; \
    echo "Port 2222" >> /etc/ssh/sshd_config; \
    echo "AllowUsers dev" >> /etc/ssh/sshd_config; \
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config; \
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config; \
    echo "X11Forwarding no" >> /etc/ssh/sshd_config

# Set environment variables
ENV PATH="/root/.bun/bin:/usr/local/bin:${PATH}"
ENV HOME="/home/dev"

# Copy opencode to accessible location for all users
RUN mkdir -p /opt/opencode && \
    cp -r /root/.bun/install/global/node_modules/opencode-* /opt/opencode/ && \
    chmod -R +rx /opt/opencode

# Create wrapper scripts that use copied binaries
RUN printf '#!/bin/bash\nexport PATH="/root/.bun/bin:/usr/local/bin:/usr/local/bun-node-fallback-bin:$PATH"\nexport OPENCODE_BIN_PATH=/opt/opencode/opencode-linux-x64/bin/opencode\nexec /opt/opencode/opencode-ai/bin/opencode "$@"\n' > /usr/local/bin/opencode-wrapper && \
    chmod +x /usr/local/bin/opencode-wrapper && \
    ln -sf /usr/local/bin/opencode-wrapper /usr/local/bin/opencode && \
    ln -sf /usr/local/bin/opencode-wrapper /usr/local/bin/opencode-ai

# Set ownership and permissions
RUN chown -R dev:dev /workspace

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Verify OpenCode is accessible\n\
if ! command -v opencode-ai &> /dev/null; then\n\
    echo "WARNING: opencode-ai not found in PATH"\n\
    echo "PATH: $PATH"\n\
fi\n\
\n\
# Generate SSH host keys if they do not exist\n\
if [ ! -f /etc/ssh/keys/ssh_host_rsa_key ]; then\n\
    ssh-keygen -A\n\
    cp /etc/ssh/ssh_host_* /etc/ssh/keys/ 2>/dev/null || true\n\
fi\n\
\n\
# Set dev user password if DEV_PASSWORD is set\n\
if [ -n "$DEV_PASSWORD" ]; then\n\
    echo "dev:$DEV_PASSWORD" | chpasswd\n\
else\n\
    echo "dev:devuser" | chpasswd\n\
fi\n\
\n\
# Create empty authorized_keys if it does not exist\n\
mkdir -p /home/dev/.ssh\n\
if [ ! -f /home/dev/.ssh/authorized_keys ]; then\n\
    touch /home/dev/.ssh/authorized_keys\n\
    chown dev:dev /home/dev/.ssh/authorized_keys\n\
    chmod 600 /home/dev/.ssh/authorized_keys\n\
fi\n\
chown -R dev:dev /home/dev/.ssh\n\
\n\
echo "SSH Development Environment starting..."\n\
echo "OpenCode CLI: $(command -v opencode-ai || echo \"not found\")"\n\
echo "Listening on port 2222"\n\
\n\
# Start SSH server\n\
exec /usr/sbin/sshd -D -e "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Expose SSH port
EXPOSE 2222

# Set working directory for dev user
WORKDIR /workspace

# Start SSH server
ENTRYPOINT ["/entrypoint.sh"]
