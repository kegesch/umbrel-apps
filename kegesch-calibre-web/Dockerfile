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

### Stage 1: install Calibre using official installer ###
FROM ubuntu:22.04 AS calibre-installer

ARG MOD_VERSION
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tooling and libraries required for the installer script
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl wget python3 xz-utils xdg-utils \
    libgl1 libglx-mesa0 libxdamage1 libegl1 libxkbcommon0 libnss3 \
    libopengl0 libxcomposite1 libxkbfile1 libxrandr2 libxtst6 \
    libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 \
    libfreetype6 libfontconfig1 libdbus-1-3 && \
    rm -rf /var/lib/apt/lists/*

# Use the official Calibre installer script which handles all path setup automatically
RUN set -eux; \
    if [ -z "${MOD_VERSION:-}" ]; then \
    wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin; \
    else \
    CALIBRE_VER="${MOD_VERSION#v}"; \
    wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin version=${CALIBRE_VER}; \
    fi; \
    calibre --version > /calibre_version || true

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

# Copy the installed Calibre from the installer stage.
# The official installer puts everything in /opt/calibre and sets up paths correctly.
RUN rm -rf /opt/calibre /opt/lib
COPY --from=calibre-installer /opt/calibre /opt/calibre
COPY --from=calibre-installer /calibre_version /etc/calibre/RELEASE

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

# Configure library paths for Calibre shared libraries
# The installer sets up /opt/calibre with all libraries
RUN set -eux; \
    echo "/opt/calibre" > /etc/ld.so.conf.d/calibre.conf; \
    ldconfig

# Set LD_LIBRARY_PATH for runtime
ENV LD_LIBRARY_PATH="/opt/calibre"

# Test that Calibre binaries work
RUN set -eux; \
    /opt/calibre/ebook-convert --version

# Keep runtime DOCKER_MODS env available for compatibility
ENV DOCKER_MODS_RUNTIME=${DOCKER_MODS}
EXPOSE 8083
