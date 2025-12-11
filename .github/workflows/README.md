# GitHub Workflows

## Build and Push Calibre-Web Docker Image

This workflow builds the `kegesch-calibre-web` Docker image and pushes it to the GitHub Container Registry (ghcr.io).

### Workflow Triggers

The workflow runs automatically on:

1. **Push to main/master branch** - When changes are made to:
   - `kegesch-calibre-web/**` directory
   - `.github/workflows/build-calibre-web.yml` file

2. **Pull Requests** - When PRs modify:
   - `kegesch-calibre-web/**` directory
   - `.github/workflows/build-calibre-web.yml` file
   - Note: Images are built but NOT pushed on PRs (for testing purposes)

3. **Manual Trigger** - Via GitHub Actions UI with optional parameters:
   - `calibre_version`: Specify a Calibre version tag (e.g., `v8.16.2`), or leave empty to use the latest release

### What It Does

1. **Multi-Architecture Build**: Builds Docker images for both `linux/amd64` and `linux/arm64` platforms
2. **Version Tagging**: Tags images with:
   - `latest` (on main/master branch)
   - `0.6.25` (calibre-web version)
   - Git SHA (e.g., `main-abc1234`)
   - Branch name (e.g., `feature-branch`)
3. **Push to Registry**: Pushes images to `ghcr.io/YOUR_USERNAME/YOUR_REPO/kegesch-calibre-web`
4. **Build Caching**: Uses GitHub Actions cache to speed up subsequent builds

### Setup Requirements

#### 1. Enable GitHub Container Registry

The workflow uses `GITHUB_TOKEN` which is automatically available. No additional secrets needed!

#### 2. Set Repository Permissions

Ensure your repository has the correct permissions:

1. Go to **Settings** → **Actions** → **General**
2. Under "Workflow permissions", select:
   - ✅ **Read and write permissions**
3. Save changes

#### 3. Update docker-compose.yml

Replace the image reference with your repository:

```yaml
services:
  server:
    image: ghcr.io/YOUR_USERNAME/YOUR_REPO/kegesch-calibre-web:latest
```

Or use an environment variable:

```yaml
services:
  server:
    image: ghcr.io/${GITHUB_REPOSITORY}/kegesch-calibre-web:latest
```

### Using the Built Image

#### Option 1: Public Image (Recommended)

1. Make your GitHub package public:
   - Go to your repository → **Packages**
   - Click on `kegesch-calibre-web`
   - **Package settings** → **Change visibility** → **Public**

2. Use in docker-compose:
```yaml
services:
  server:
    image: ghcr.io/username/repo/kegesch-calibre-web:latest
```

#### Option 2: Private Image (Requires Authentication)

1. Create a Personal Access Token (PAT):
   - Go to **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
   - Generate new token with `read:packages` scope
   - Save the token securely

2. Login to GitHub Container Registry:
```bash
echo YOUR_PAT | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

3. Pull the image:
```bash
docker pull ghcr.io/username/repo/kegesch-calibre-web:latest
```

### Manual Workflow Trigger

To manually trigger the workflow:

1. Go to **Actions** tab in your repository
2. Select **Build and Push Calibre-Web Docker Image**
3. Click **Run workflow**
4. (Optional) Specify a Calibre version, or leave empty for latest
5. Click **Run workflow** button

### Customizing the Workflow

#### Change Image Tags

Edit `.github/workflows/build-calibre-web.yml` in the `Extract metadata` step:

```yaml
tags: |
  type=raw,value=latest,enable={{is_default_branch}}
  type=raw,value=0.6.25
  type=raw,value=my-custom-tag
  type=semver,pattern={{version}}
  type=sha,prefix={{branch}}-
```

#### Change Platforms

Modify the `platforms` in the `Build and push Docker image` step:

```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

#### Add Build Arguments

Add more build arguments:

```yaml
build-args: |
  MOD_VERSION=${{ inputs.calibre_version || '' }}
  MY_ARG=value
```

### Troubleshooting

#### Permission Denied Errors

- Ensure workflow permissions are set to "Read and write"
- Check that `GITHUB_TOKEN` has `packages: write` permission

#### Image Not Found

- Verify the image was pushed successfully in Actions logs
- Check package visibility (public vs private)
- Ensure you're logged in if using private packages

#### Build Failures

- Check the Actions logs for detailed error messages
- Verify Dockerfile syntax
- Ensure base images are accessible

### Additional Resources

- [GitHub Container Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)