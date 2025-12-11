# Multi-stage Dockerfile
#
# Stage "calibre-downloader" downloads and extracts Calibre into /opt/calibre.
# It is split into multiple RUN steps to improve layer cacheability.
#
# Build args:
# - MOD_VERSION (optional): a Calibre tag like "v8.16.2". If omitted, the latest
#   release tag will be resolved during the build.
#
# Final image is based on linuxserver/calibre-web and only receives the extracted
# Calibre runtime files from the downloader stage (keeps final image smaller).

### Stage 1: download & extract Calibre ###
FROM ubuntu:22.04 AS calibre-downloader

ARG MOD_VERSION
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tooling required for resolving releases and extracting txz
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl jq xz-utils tar && \
    rm -rf /var/lib/apt/lists/*

# Resolve Calibre release tag (if MOD_VERSION not provided) and write marker files
RUN set -eux; \
    if [ -z "${MOD_VERSION:-}" ]; then \
    MOD_VERSION="$(curl -fsSL 'https://api.github.com/repos/kovidgoyal/calibre/releases/latest' | jq -r '.tag_name')"; \
    fi; \
    CALIBRE_VER="${MOD_VERSION#v}"; \
    echo "${MOD_VERSION}" > /calibre_version; \
    echo "${CALIBRE_VER}" > /calibre_ver; \
    echo "Resolved Calibre version: ${MOD_VERSION} -> ${CALIBRE_VER}"

# Download the appropriate Calibre txz for the build architecture and extract it.
# Keep download + extract as a single layer so changes to the download (or version)
# only affect this layer.
RUN set -eux; \
    ARCH="$(uname -m)"; \
    MOD_VERSION="$(cat /calibre_version)"; \
    CALIBRE_VER="$(cat /calibre_ver)"; \
    CALIBRE_TXZ="/tmp/calibre.txz"; \
    if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then \
    URL_GH="https://github.com/kovidgoyal/calibre/releases/download/${MOD_VERSION}/calibre-${CALIBRE_VER}-x86_64.txz"; \
    URL_ALT="https://download.calibre-ebook.com/${CALIBRE_VER}/calibre-${CALIBRE_VER}-x86_64.txz"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
    URL_GH="https://github.com/kovidgoyal/calibre/releases/download/${MOD_VERSION}/calibre-${CALIBRE_VER}-arm64.txz"; \
    URL_ALT="https://download.calibre-ebook.com/${CALIBRE_VER}/calibre-${CALIBRE_VER}-arm64.txz"; \
    else \
    echo "Unsupported architecture: $ARCH"; \
    exit 0; \
    fi; \
    if ! curl -fsSL -o "$CALIBRE_TXZ" "$URL_GH"; then \
    curl -fsSL -o "$CALIBRE_TXZ" "$URL_ALT"; \
    fi; \
    if [ ! -s "$CALIBRE_TXZ" ]; then \
    echo "Calibre archive missing or empty, aborting"; \
    rm -f "$CALIBRE_TXZ" || true; \
    exit 1; \
    fi; \
    mkdir -p /opt/calibre; \
    tar -xJf "$CALIBRE_TXZ" -C /opt/calibre --strip-components=1; \
    rm -f "$CALIBRE_TXZ"; \
    echo "Calibre extracted to /opt/calibre"

### Stage 2: final image ###
FROM linuxserver/calibre-web:0.6.25@sha256:ab176faac42ad33f5fa898f7c975fa590f4507b35afaf6c4cc3e9acf4ba860fa

# Keep runtime compatibility with linuxserver mods
ARG MOD_VERSION
ARG DOCKER_MODS
ENV DOCKER_MODS=${DOCKER_MODS}

# Install runtime libraries Calibre depends on. Kept in its own RUN for caching.
RUN set -eux; \
    if [ -x /usr/bin/apt ]; then \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
    libgl1 libglx-mesa0 libxdamage1 libegl1 libxkbcommon0 libnss3 \
    libopengl0 libxcomposite1 libxkbfile1 libxrandr2 libxtst6 ca-certificates || true; \
    rm -rf /var/lib/apt/lists/*; \
    else \
    echo "apt not found in base image; skipping runtime libs installation."; \
    fi

# Copy only the extracted Calibre runtime and the version marker from the downloader stage.
COPY --from=calibre-downloader /opt/calibre /opt/calibre
COPY --from=calibre-downloader /calibre_version /etc/calibre/RELEASE

# Ensure /etc/calibre exists and create symlink(s) for the calibre executable.
RUN set -eux; \
    mkdir -p /etc/calibre; \
    if [ ! -f /etc/calibre/RELEASE ]; then \
    echo "${MOD_VERSION:-unknown}" > /etc/calibre/RELEASE; \
    fi; \
    if [ -x /opt/calibre/calibre ]; then \
    ln -sf /opt/calibre/calibre /usr/local/bin/calibre || true; \
    elif [ -x /opt/calibre/bin/calibre ]; then \
    ln -sf /opt/calibre/bin/calibre /usr/local/bin/calibre || true; \
    else \
    echo "Warning: no calibre binary found in /opt/calibre"; \
    fi

# Keep runtime DOCKER_MODS env available for compatibility
ENV DOCKER_MODS_RUNTIME=${DOCKER_MODS}
EXPOSE 8083
