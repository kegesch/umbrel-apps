# OpenCode Portal Dockerfile
# Multi-stage build for minimal final image size

# Stage 1: Build the application
FROM oven/bun:1.3 AS builder

WORKDIR /app

# Install git for cloning the repository
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the portal repository
RUN git clone --depth 1 --branch main https://github.com/hosenur/portal.git .

# Install dependencies
RUN bun install --frozen-lockfile || bun install

# Build the application
RUN bun run build

# Stage 2: Runtime image
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
    # Install OpenCode CLI
    curl -fsSL https://opencode.ai/install | bash || true; \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Add opencode to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Copy built application from builder stage
COPY --from=builder /app /app

# Install production dependencies only
RUN bun install --production --frozen-lockfile || bun install --production || true

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
CMD ["bunx", "openportal", "--hostname", "0.0.0.0", "--port", "3065", "--opencode-port", "4000", "--directory", "/projects"]
