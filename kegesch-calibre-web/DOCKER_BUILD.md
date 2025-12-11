# Docker Build & Deployment Guide

This document explains how to build and deploy the kegesch-calibre-web Docker image using GitHub Actions.

## Overview

The project uses a GitHub Actions workflow to automatically build multi-architecture Docker images and push them to GitHub Container Registry (ghcr.io). This eliminates the need to build images locally and ensures consistency across deployments.

## Quick Start

### 1. Configure Your Repository

First, ensure your GitHub repository has the correct permissions:

1. Go to your repository **Settings** → **Actions** → **General**
2. Under "Workflow permissions", select **Read and write permissions**
3. Check **Allow GitHub Actions to create and approve pull requests**
4. Click **Save**

### 2. Push Code to Trigger Build

The workflow automatically runs when you push changes to the `kegesch-calibre-web/` directory:

```bash
git add .
git commit -m "Update calibre-web configuration"
git push origin main
```

### 3. Monitor the Build

1. Go to the **Actions** tab in your GitHub repository
2. Click on the latest workflow run
3. Watch the build progress in real-time
4. Once complete, the image will be available at `ghcr.io/YOUR_USERNAME/YOUR_REPO/kegesch-calibre-web`

### 4. Use the Image

Update your `docker-compose.yml` to reference the built image:

```yaml
services:
  server:
    image: ghcr.io/YOUR_USERNAME/YOUR_REPO/kegesch-calibre-web:latest
    # ... rest of configuration
```

Replace `YOUR_USERNAME/YOUR_REPO` with your actual GitHub username and repository name.

## Image Tags

The workflow creates multiple tags for each build:

- `latest` - The most recent build from the main/master branch
- `0.6.25` - The calibre-web version number
- `main-abc1234` - Branch name + git commit SHA (for tracking specific builds)
- `feature-branch` - Branch name for feature branches

Example usage with specific tags:

```yaml
# Use latest stable
image: ghcr.io/username/repo/kegesch-calibre-web:latest

# Use specific version
image: ghcr.io/username/repo/kegesch-calibre-web:0.6.25

# Use specific commit
image: ghcr.io/username/repo/kegesch-calibre-web:main-abc1234
```

## Manual Workflow Execution

You can manually trigger a build with custom parameters:

1. Go to **Actions** → **Build and Push Calibre-Web Docker Image**
2. Click **Run workflow**
3. Select the branch to build from
4. (Optional) Enter a specific Calibre version like `v8.16.2`
5. Click **Run workflow**

This is useful for:
- Testing changes before merging
- Building with a specific Calibre version
- Rebuilding without code changes

## Multi-Architecture Support

The workflow builds images for both:
- **linux/amd64** - Intel/AMD 64-bit processors
- **linux/arm64** - ARM 64-bit processors (Apple Silicon, Raspberry Pi 4, etc.)

Docker automatically pulls the correct architecture for your system.

## Using Private Images

If your repository is private, you'll need to authenticate before pulling images:

### Generate a Personal Access Token (PAT)

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token** → **Generate new token (classic)**
3. Give it a name like "Docker Registry Access"
4. Select scope: `read:packages`
5. Click **Generate token**
6. **Save the token immediately** (you won't see it again!)

### Login to GitHub Container Registry

```bash
echo YOUR_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### Pull the Image

```bash
docker pull ghcr.io/username/repo/kegesch-calibre-web:latest
```

## Making Images Public

To allow anyone to pull your images without authentication:

1. Go to your repository's main page
2. Click **Packages** (right sidebar)
3. Click on `kegesch-calibre-web`
4. Click **Package settings** (right sidebar)
5. Scroll to **Danger Zone** → **Change visibility**
6. Select **Public**
7. Type the package name to confirm
8. Click **I understand, change package visibility**

Now anyone can pull your image:

```bash
docker pull ghcr.io/username/repo/kegesch-calibre-web:latest
```

## Environment Variables

Update your `docker-compose.yml` to use environment variables for flexibility:

```yaml
services:
  server:
    image: ${CALIBRE_WEB_IMAGE:-ghcr.io/username/repo/kegesch-calibre-web:latest}
    # ... rest of configuration
```

Then create a `.env` file:

```bash
CALIBRE_WEB_IMAGE=ghcr.io/username/repo/kegesch-calibre-web:latest
```

Or override at runtime:

```bash
CALIBRE_WEB_IMAGE=ghcr.io/username/repo/kegesch-calibre-web:0.6.25 docker-compose up -d
```

## Workflow Triggers

The build workflow triggers on:

### Automatic Triggers

- **Push to main/master**: When code in `kegesch-calibre-web/` changes
- **Pull Requests**: Builds but doesn't push (for testing)

### Manual Triggers

- **workflow_dispatch**: Via GitHub Actions UI with optional Calibre version

### Paths Filter

Only triggers when these paths change:
- `kegesch-calibre-web/**`
- `.github/workflows/build-calibre-web.yml`

This prevents unnecessary builds when other parts of the repository change.

## Build Caching

The workflow uses GitHub Actions cache to speed up builds:

- **cache-from**: Reuses layers from previous builds
- **cache-to**: Saves layers for future builds

This significantly reduces build time, especially for unchanged layers.

## Customizing Calibre Version

### Via Workflow Input

Manually trigger the workflow and specify a Calibre version:

1. Go to **Actions** → **Build and Push Calibre-Web Docker Image**
2. Click **Run workflow**
3. Enter `v8.16.2` (or desired version) in the calibre_version field
4. Click **Run workflow**

### Via Dockerfile ARG

Edit the Dockerfile and set a default:

```dockerfile
ARG MOD_VERSION=v8.16.2
```

Or update the workflow file to set a default:

```yaml
build-args: |
  MOD_VERSION=${{ inputs.calibre_version || 'v8.16.2' }}
```

## Troubleshooting

### Build Fails with "Permission Denied"

**Problem**: Workflow can't push to GitHub Container Registry

**Solution**:
1. Check workflow permissions in Settings → Actions → General
2. Ensure "Read and write permissions" is selected
3. Re-run the workflow

### Image Pull Fails with "Not Found"

**Problem**: Can't pull the image

**Solutions**:
- Verify the image name is correct: `ghcr.io/username/repo/kegesch-calibre-web:latest`
- Check if the package is private (requires authentication)
- Ensure the workflow completed successfully
- Wait a few minutes for registry propagation

### Build Times Out

**Problem**: Build takes too long and times out

**Solutions**:
- GitHub Actions has a 6-hour timeout per job
- Multi-arch builds can be slow on first run
- Subsequent builds use caching and are much faster
- Consider building architectures separately if needed

### Wrong Architecture Pulled

**Problem**: Docker pulls the wrong architecture

**Solution**:
- Docker should auto-select the correct architecture
- Manually specify: `docker pull --platform linux/amd64 ghcr.io/...`
- Check your Docker daemon configuration

### Old Image Version

**Problem**: Docker compose uses old image version

**Solution**:
```bash
# Pull latest image
docker-compose pull

# Recreate containers
docker-compose up -d --force-recreate
```

## Local Development

For local testing without pushing to the registry:

```bash
# Build locally
cd kegesch-calibre-web
docker build -t kegesch-calibre-web:test .

# Test the image
docker run -p 8083:8083 kegesch-calibre-web:test

# Use in docker-compose
docker-compose -f docker-compose.local.yml up
```

## Security Best Practices

1. **Use specific tags in production**: Avoid `latest` tag for stability
2. **Rotate PATs regularly**: Update tokens every 90 days
3. **Limit PAT scope**: Only grant `read:packages` permission
4. **Use secrets**: Never commit tokens to the repository
5. **Public packages**: Only make public if intended for public use

## Additional Resources

- [Dockerfile Reference](./Dockerfile)
- [Docker Compose File](./docker-compose.yml)
- [GitHub Actions Workflow](../.github/workflows/build-calibre-web.yml)
- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)