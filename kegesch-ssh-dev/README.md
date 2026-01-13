# SSH Development Environment for Umbrel

A fully-featured development environment accessible via SSH from any device. Perfect for coding on-the-go with OpenCode AI assistant, managing git repositories, and performing development tasks from your phone using Terminus or any SSH client.

## Features

- Full SSH server access (port 2222)
- Pre-installed OpenCode AI coding agent
- Git and version control tools
- Development utilities: vim, nano, tmux, htop, curl, wget
- Both password and SSH key authentication supported
- Persistent workspace and home directory
- Non-root dev user with sudo access

## Quick Start

1. Install the app on your Umbrel
2. Default credentials:
   - Username: `dev`
   - Password: `devuser` (change this immediately!)
3. Connect from your phone using Terminus:
   - Host: `umbrel.local`
   - Port: `2222`
   - Username: `dev`
   - Password: `devuser`

## Connecting from Phone via Terminus

### Setup Terminus

1. Download Terminus from your app store
2. Open Terminus and tap the "+" button to add a new connection
3. Configure:
   - **Name**: Umbrel Dev
   - **Host**: `umbrel.local` (or your Umbrel's IP address)
   - **Port**: `2222`
   - **Username**: `dev`
   - **Password**: `devuser` (or use SSH key)
4. Tap "Connect"

### Using SSH Keys with Terminus

1. Generate an SSH key on your phone (Terminus supports key management):
   - Open Terminus settings
   - Navigate to "Keys"
   - Tap "Generate New Key"
   - Copy the public key

2. Add the key to the container:
   ```bash
   # SSH into the container with password first
   ssh -p 2222 dev@umbrel.local

   # Add your public key to authorized_keys
   echo "your-public-key-content" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. Configure Terminus to use the key:
   - Edit your connection
   - Switch authentication to "Key"
   - Select your generated key

## Changing Default Password

### Option 1: Inside the Container

```bash
ssh -p 2222 dev@umbrel.local
passwd
```

### Option 2: Using Environment Variable

Edit `${APP_DATA_DIR}/../docker-compose.yml`:

```yaml
environment:
  - DEV_PASSWORD=your-new-password
```

Then restart the app:

```bash
sudo ~/umbrel/scripts/app restart kegesch-ssh-dev
```

## Usage Examples

### OpenCode AI Assistant

```bash
# Start OpenCode in the workspace
cd ~/workspace
opencode-ai

# Or use the alias
opencode

# Get help
opencode-ai help

# Start a chat session
opencode-ai chat "create a python script for data analysis"
```

### Using tmux for Persistent Sessions

```bash
# Create a new session
tmux new -s dev

# Detach from session: Ctrl+B, then D

# List sessions
tmux ls

# Reattach to session
tmux attach -t dev
```

### Git Workflow

```bash
# Clone a repository
cd ~/workspace
git clone https://github.com/user/repo.git

# Make changes
cd repo
vim file.py

# Commit changes
git add .
git commit -m "Add new feature"
git push
```

### File Editing

```bash
# Using vim
vim myfile.py

# Using nano
nano myfile.sh

# View files with htop
htop
```

## Directory Structure

- `/workspace` - Your main development directory (persistent)
- `/home/dev` - User home directory with dotfiles (persistent)
- `/etc/ssh/keys` - SSH host keys (persistent)

## SSH Key Management

### Adding Multiple SSH Keys

```bash
# SSH into the container
ssh -p 2222 dev@umbrel.local

# Edit authorized_keys
nano ~/.ssh/authorized_keys

# Add each public key on a new line

# Save and set permissions
chmod 600 ~/.ssh/authorized_keys
```

### Listing Added Keys

```bash
cat ~/.ssh/authorized_keys
```

## Troubleshooting

### Cannot Connect

1. Check if the app is running:
   ```bash
   sudo ~/umbrel/scripts/app status kegesch-ssh-dev
   ```

2. Check SSH port is accessible:
   ```bash
   telnet umbrel.local 2222
   ```

3. Check Umbrel logs:
   ```bash
   sudo ~/umbrel/scripts/app logs kegesch-ssh-dev
   ```

### Password Authentication Not Working

1. Verify password is correct
2. Try resetting the password inside the container
3. Check SSH logs for authentication failures

### SSH Key Authentication Failing

1. Verify public key is in `~/.ssh/authorized_keys`
2. Check file permissions:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Ensure private key is configured correctly in Terminus

## Security Best Practices

1. **Change the default password** immediately after first login
2. **Use SSH keys** instead of passwords when possible
3. **Limit SSH access** by IP address if needed
4. **Keep OpenCode API keys** secure - use environment variables
5. **Regularly update** the app to get security patches

## OpenCode Configuration

OpenCode requires an AI provider API key to function. Set up your API key:

### Create Environment File

```bash
# SSH into the container
ssh -p 2222 dev@umbrel.local

# Create .env file in your workspace
cd ~/workspace
nano .env
```

Add your API key:

```bash
ANTHROPIC_API_KEY=your-anthropic-key-here
```

### Use OpenCode

```bash
# Load environment and start OpenCode
source .env
opencode-ai
```

### Verify OpenCode is Available

```bash
# Check if opencode is in PATH
which opencode-ai

# Or check version
opencode-ai --version
```

## Persistent Storage

The following directories are persisted across container restarts:

- `${APP_DATA_DIR}/workspace` → `/workspace` (projects and code)
- `${APP_DATA_DIR}/home` → `/home/dev` (user home directory)
- `${APP_DATA_DIR}/ssh_keys` → `/etc/ssh/keys` (SSH host keys)

Your work will be preserved even if you restart the app.

## Additional Resources

- [OpenCode Documentation](https://opencode.ai)
- [Umbrel Documentation](https://umbrel.com)
- [Terminus App](https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client)

## Support

For issues and questions:
- GitHub Issues: https://github.com/kegesch/umbrel-apps/issues
- OpenCode Portal: https://openportal.space

## License

This app is provided as-is for Umbrel community use.
