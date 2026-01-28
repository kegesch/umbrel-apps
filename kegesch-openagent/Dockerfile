FROM debian:bookworm-slim AS openagent-base

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        git \
        jq \
        unzip \
        openssh-client \
        systemd-container \
        debootstrap \
        xvfb \
        i3 \
        x11-utils \
        x11-xserver-utils \
        xdotool \
        scrot \
        imagemagick \
        tesseract-ocr \
        at-spi2-core \
        fonts-liberation \
        fonts-dejavu-core \
        fonts-noto \
        chromium; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bun.sh/install | bash \
    && install -m 0755 /root/.bun/bin/bun /usr/local/bin/bun \
    && install -m 0755 /root/.bun/bin/bunx /usr/local/bin/bunx

RUN curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
      | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" \
      > /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update && apt-get install -y --no-install-recommends caddy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code@latest || echo "Claude Code CLI install failed"

RUN curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path \
    && install -m 0755 /root/.opencode/bin/opencode /usr/local/bin/opencode || echo "OpenCode CLI install failed"

RUN npm install -g @anthropic-ai/amp@latest || echo "Amp CLI install failed"

RUN mkdir -p /root/.config/i3 /root/.openagent /root/.claude /root/work/screenshots

RUN curl -fsSL https://raw.githubusercontent.com/Th0rgal/openagent/v0.4.0/docker/i3config -o /root/.config/i3/config || true

RUN curl -fsSL https://raw.githubusercontent.com/Th0rgal/openagent/v0.4.0/docker/Caddyfile -o /etc/caddy/Caddyfile || echo 'Caddyfile download failed'

RUN curl -fsSL https://raw.githubusercontent.com/Th0rgal/openagent/v0.4.0/docker/entrypoint.sh -o /entrypoint.sh \
    && chmod +x /entrypoint.sh || echo 'Entrypoint download failed'

RUN curl -fsSL https://github.com/Th0rgal/openagent/releases/download/v0.4.0/openagent-linux-x86_64.tar.gz -o /tmp/openagent.tar.gz \
    && tar -xzf /tmp/openagent.tar.gz -C /usr/local/bin/ open_agent desktop-mcp workspace-mcp \
    && chmod +x /usr/local/bin/open_agent /usr/local/bin/desktop-mcp /usr/local/bin/workspace-mcp \
    && rm /tmp/openagent.tar.gz || echo 'Binary download failed'

RUN curl -fsSL https://github.com/Th0rgal/openagent/releases/download/v0.4.0/dashboard-standalone.tar.gz -o /tmp/dashboard.tar.gz \
    && mkdir -p /opt/dashboard \
    && tar -xzf /tmp/dashboard.tar.gz -C /opt/dashboard \
    && rm /tmp/dashboard.tar.gz || echo 'Dashboard download failed'

ENV HOST=127.0.0.1 \
    PORT=3000 \
    WORKING_DIR=/root \
    DEV_MODE=true \
    DESKTOP_ENABLED=true \
    DESKTOP_RESOLUTION=1920x1080 \
    GIT_TERMINAL_PROMPT=0

EXPOSE 3000

VOLUME ["/root/.openagent", "/root/.claude"]

ENTRYPOINT ["/entrypoint.sh"]
