# AGENTS.md

This file provides guidance for AI coding agents working in this repository.

## Project Overview

This is an **Umbrel Community App Store** repository that provides custom applications for the Umbrel home server ecosystem.

### Repository Structure

```
umbrel-apps/
├── .github/workflows/          # CI/CD pipelines
├── <app>                       # Umbrel App
└──umbrel-app-store.yml        # App store configuration
```

## CI/CD Pipeline

The GitHub Actions workflow to build custom dockerfiles (if necessary) automatically:
- Builds multi-architecture images (linux/amd64, linux/arm64)
- Pushes to GitHub Container Registry (ghcr.io)
- Tags images with: `latest`, `<version>`, `{branch}-{sha}`

## Code Style Guidelines

### File Naming

- Use `kebab-case` for all files: `docker-compose.yml`, `umbrel-app.yml`
- App directories follow pattern: `{store-id}-{app-name}` (e.g., `kegesch-calibre-web`)

### YAML Formatting

- Quote version strings: `version: "3.7"`, `version: "0.6.25"`
- Use `>-` folded block style for multi-line descriptions
- Boolean strings should be quoted in environment variables: `"true"`, `"false"`
- Indent with 2 spaces

```yaml
# Good
version: "3.7"
environment:
  PROXY_AUTH_ADD: "false"
description: >-
  Multi-line description
  continues here.

# Bad
version: 3.7
environment:
  PROXY_AUTH_ADD: false
```

### Dockerfile Conventions

- Use multi-stage builds to minimize final image size
- Stage names should be descriptive and use `kebab-case`: `calibre-installer`
- Use `set -eux` for shell strict mode in RUN commands
- Add `|| true` for optional commands that may fail gracefully
- Variables use `UPPER_CASE` naming
- Include comments explaining complex build stages

```dockerfile
# Good
RUN set -eux; \
    command_that_must_succeed; \
    optional_command || true

# Bad
RUN command
```

### Container Naming

- Format: `{app-id}_{service}_{instance}` (e.g., `kegesch-calibre-web_server_1`)

### Environment Variables

- Use `UPPER_CASE` with underscores
- Standard variables: `PUID`, `PGID`, `APP_DATA_DIR`
- Document non-obvious variables in comments

## Umbrel App Manifest (umbrel-app.yml)

Required fields:
- `manifestVersion`: Always `1`
- `id`: Must start with app store ID (`kegesch-`)
- `name`: Human-readable app name
- `version`: Semantic version string (quoted)
- `port`: External port for Umbrel
- `category`: One of: `files`, `media`, `networking`, `developer`, etc.

Optional but recommended:
- `defaultUsername` / `defaultPassword`: Initial credentials
- `releaseNotes`: Changelog in `>-` block format
- `dependencies`: Array of dependent app IDs


## Important Files Reference

| File | Purpose |
|------|---------|
| `umbrel-app-store.yml` | Defines store ID and name |
| `*/umbrel-app.yml` | App manifest for Umbrel UI |
| `*/docker-compose.yml` | Service definitions |
| `*/Dockerfile` | Container build instructions |
| `.github/workflows/*.yml` | CI/CD pipelines |

## Security Considerations

- Use specific image tags in production (avoid `latest`)
- Never commit secrets or tokens
- Default credentials should be documented for user awareness
- PAT tokens for private registries: limit scope to `read:packages`

## Adding a New App

1. Create directory: `kegesch-{app-name}/`
2. Add `umbrel-app.yml` with app metadata
3. Add `docker-compose.yml` with service definitions
4. Optionally add `Dockerfile` if custom image needed
5. Add CI workflow if building custom images

## Official Documentation of custom community app stores for umbrel: 
https://github.com/getumbrel/umbrel-community-app-store

## Example Community App Store (look here if documentation is not enough)
https://github.com/dennysubke/dennys-umbrel-app-store
