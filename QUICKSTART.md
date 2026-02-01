# Quick Start Guide

This repository has been restructured to work like [claude-docker](https://github.com/VishalJ99/claude-docker) - a simple, local-only OpenCode development environment.

## What Changed

### Removed
- ❌ SSH server and remote access
- ❌ Tailscale VPN networking
- ❌ Complex tooling (mise, starship, etc.)
- ❌ Multi-user setup

### Added
- ✅ Simple shell script launcher (`opencode-docker`)
- ✅ One-command installation
- ✅ Local-only execution
- ✅ Automatic permission matching (host UID/GID)
- ✅ Persistent config directory (`~/.opencode-docker/config`)

## Installation

```bash
# 1. Copy sample.env to .env and add your OpenRouter API key
cp sample.env .env
nano .env  # Add OPENROUTER_API_KEY

# 2. Run the install script
./src/install.sh

# 3. Reload your shell
source ~/.bashrc  # or ~/.zshrc
```

## Usage

```bash
# Navigate to any project
cd ~/my-project

# Start OpenCode
opencode-docker
```

That's it! OpenCode will run in a Docker container with access to your current directory.

## Advanced Usage

```bash
# Rebuild the Docker image
opencode-docker --rebuild

# Use GPU
opencode-docker --gpus all

# Set memory limit
opencode-docker --memory 8g

# Combine options
opencode-docker --rebuild --no-cache --gpus all
```

## File Structure

```
opencode-docker/
├── src/
│   ├── install.sh           # One-time setup script
│   ├── opencode-docker.sh   # Main launcher
│   └── startup.sh           # Container entrypoint
├── Dockerfile               # Simplified container definition
├── docker-compose.yml       # Optional: use with docker-compose
├── sample.env              # Example environment variables
└── README.md               # Full documentation

After installation:
~/.opencode-docker/
└── config/                 # Persistent OpenCode configuration
```

## Environment Variables

Edit `.env` to configure:

- `OPENROUTER_API_KEY` - Your OpenRouter API key (recommended)
- `OPENROUTER_MODEL` - Model to use (optional, defaults to minimax/minimax-m2.1)
- `OPENCODE_API_KEY` - Direct OpenCode API key (alternative to OpenRouter)
- `DOCKER_MEMORY_LIMIT` - Default memory limit (optional)
- `DOCKER_GPU_ACCESS` - Default GPU access (optional)
- `SYSTEM_PACKAGES` - Additional apt packages (optional)

## Differences from Original

This fork is designed for **local development only**. If you need remote access via SSH/Tailscale, use the [original version](https://github.com/rpfilomeno/opencode-docker).

### Key Differences

| Feature | This Fork | Original |
|---------|-----------|----------|
| Setup | `./src/install.sh` | `docker-compose up` |
| Launch | `opencode-docker` | SSH to container |
| Access | Local only | Remote via Tailscale |
| Base Image | Node.js slim | Ubuntu + many tools |
| Complexity | Minimal | Full development environment |
