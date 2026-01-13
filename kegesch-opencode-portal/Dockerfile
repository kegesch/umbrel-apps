# OpenCode Portal Dockerfile
# Multi-stage build for minimal final image size

FROM oven/bun:1.3-slim

WORKDIR /app

# Install OpenCode CLI and required system dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    unzip; \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*


RUN bun install -g opencode-ai
RUN bun install -g openportal

# Create directory for user projects
RUN mkdir -p /projects

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3065
ENV OPENCODE_PORT=4000
ENV HOSTNAME=0.0.0.0

# Expose ports for web UI and OpenCode server
EXPOSE 3065 4000

# Working directory for projects
WORKDIR /projects

# Start OpenCode Portal
# The CLI starts both the OpenCode server and the web UI
CMD ["openportal", "--hostname", "0.0.0.0", "--port", "3065", "--opencode-port", "4000", "--directory", "/projects"]
