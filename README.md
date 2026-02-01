# OpenCode Docker

Containerized drop-in replacement for OpenCode - run in an isolated Docker environment with complete workspace access. Simple one-command setup for local development.

---

## Prerequisites

**Required:**
- ✅ Docker installation
- ✅ OpenRouter API key (or OpenCode API key)

**Everything else is optional** - the container runs fine without any additional setup.

---

## Quick Start

```bash
# 1. Clone and enter directory
git clone https://github.com/bkainz/opencode-docker.git
cd opencode-docker

# 2. Setup environment
cp sample.env .env
nano .env  # Add your OPENROUTER_API_KEY

# 3. Install
./src/install.sh

# 4. Run from any project
cd ~/your-project
opencode-docker
```

**That's it!** OpenCode runs in an isolated Docker container with access to your project directory.

---

## Command Line Reference

### Basic Usage
```bash
opencode-docker                       # Start OpenCode in current directory
opencode-docker --podman              # Use podman instead of docker
opencode-docker --rebuild             # Force rebuild Docker image
opencode-docker --rebuild --no-cache  # Rebuild without using cache
opencode-docker --memory 8g           # Set container memory limit
opencode-docker --gpus all            # Enable GPU access (requires nvidia-docker)
```

### Available Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--podman` | Use podman instead of docker | `opencode-docker --podman` |
| `--rebuild` | Force rebuild of the Docker image | `opencode-docker --rebuild` |
| `--no-cache` | When rebuilding, don't use Docker cache | `opencode-docker --rebuild --no-cache` |
| `--memory` | Set container memory limit | `opencode-docker --memory 8g` |
| `--gpus` | Enable GPU access | `opencode-docker --gpus all` |

### Environment Variable Defaults

Set defaults in your `.env` file:
```bash
DOCKER_MEMORY_LIMIT=8g          # Default memory limit
DOCKER_GPU_ACCESS=all           # Default GPU access
```

### Examples
```bash
# Standard usage
cd ~/my-project
opencode-docker

# Use GPU for ML tasks
opencode-docker --gpus all

# Rebuild after updating .env file
opencode-docker --rebuild
```

---

## Optional Configuration

All configuration below is optional. The container works out-of-the-box without any of these settings.

### Environment Variables (.env file)

#### OpenRouter API Key (Recommended)
Use OpenRouter for access to multiple AI models including MiniMax, Claude, GPT-4, and more:
```bash
OPENROUTER_API_KEY=your_openrouter_api_key_here
# Optional: Specify model (defaults to minimax/minimax-m2.1)
OPENROUTER_MODEL=minimax/minimax-m2.1
```

Get your API key from [openrouter.ai](https://openrouter.ai)

**Available Models:**
- `minimax/minimax-m2.1` (default - cost-effective)
- `anthropic/claude-3.5-sonnet`
- `anthropic/claude-3-opus`
- `openai/gpt-4-turbo`
- `openai/gpt-4`
- See full list at [openrouter.ai/models](https://openrouter.ai/models)

#### Alternative: Direct OpenCode API Key
```bash
OPENCODE_API_KEY=your_opencode_api_key_here
```

Get your API key from [opencode.ai](https://opencode.ai)

#### System Packages
Additional apt packages beyond the Dockerfile defaults:
```bash
SYSTEM_PACKAGES="neovim tmux htop"
```

**Note:** Adding system packages requires rebuilding the image with `opencode-docker --rebuild`.

### Git Configuration

Git configuration (global username and email) is automatically loaded from your host system during Docker build. Commits appear as you.

---

## Features

### Core Capabilities
- ✅ Complete AI coding agent setup - OpenCode in isolated Docker container
- ✅ Persistent conversation history and sessions - Resume previous work with `/session`
- ✅ Auto-approved permissions - No interruptions, fully autonomous operation
- ✅ Simple one-command setup - Zero friction plug-and-play integration
- ✅ GPU support for ML/AI tasks (with nvidia-docker)
- ✅ Ralph Wiggum autonomous loop included - Self-correcting agentic workflows
- ✅ Fully customizable - Modify files at `~/.opencode-docker` for custom behavior

### Model Configuration
- ✅ Default: MiniMax M2.1 via OpenRouter (cost-effective, powerful)
- ✅ Theme: Night Owl (customizable in config)
- ✅ Model persists across sessions

### Security
- ✅ Runs in isolated container - no access to host system beyond project directory
- ✅ User permissions matched to host UID/GID - files created with correct ownership
- ✅ No SSH or network exposure - completely local setup

---

## Advanced Features

### Session Management

OpenCode persists your conversation history across container restarts:

```bash
# Start OpenCode
opencode-docker

# Inside OpenCode:
/session          # List all previous sessions
# Select a session to resume where you left off
```

Sessions are stored in `~/.opencode-docker/config/local/share/opencode/storage/`

### Ralph Wiggum Autonomous Loop

The container includes [Ralph Wiggum](https://github.com/Th0rgal/open-ralph-wiggum) for autonomous agentic workflows:

```bash
# Enter the container
docker exec -it opencode-docker-yourproject-$$ bash

# Run autonomous loop until task complete
ralph "Build a REST API with CRUD operations and tests. \
  Run tests after changes. Output <promise>COMPLETE</promise> when all tests pass." \
  --max-iterations 20

# Use Tasks Mode for complex projects
ralph "Build a full-stack web application" --tasks --max-iterations 50
```

Ralph automatically retries tasks, seeing previous work and self-correcting until completion.

---

## Directory Structure

After installation:
```
~/.opencode-docker/
  └── config/          # Persistent OpenCode configuration

Your Project/
  ├── your files...
  └── (OpenCode works here)
```

The container mounts:
- **Current directory** → `/workspace` (read/write)
- **`~/.opencode-docker/config`** → OpenCode config directory (read/write)

---

## GPU Support

To use GPU acceleration:

1. Install NVIDIA Docker runtime (one-time setup):
```bash
sudo ./src/install.sh  # Automatically installs GPU support if NVIDIA GPU detected
```

2. Run with GPU access:
```bash
opencode-docker --gpus all
```

Or set as default in `.env`:
```bash
DOCKER_GPU_ACCESS=all
```

---

## Troubleshooting

### Permission Issues
The container automatically matches your host UID/GID. If you see permission errors:
```bash
# Rebuild with your current UID/GID
opencode-docker --rebuild
```

### OpenCode Not Found
If opencode command fails:
```bash
# Rebuild the image
opencode-docker --rebuild --no-cache
```

### GPU Not Working
1. Verify NVIDIA drivers: `nvidia-smi`
2. Check Docker GPU support: `docker info | grep -i nvidia`
3. Install GPU support: `sudo ./src/install.sh`

---

## Differences from Original Fork

This fork simplifies the original [rpfilomeno/opencode-docker](https://github.com/rpfilomeno/opencode-docker) by:

- ❌ Removed SSH server and Tailscale networking (local-only setup)
- ❌ Removed complex tool installations (minimal base image)
- ✅ Added simple shell script launcher (like [claude-docker](https://github.com/VishalJ99/claude-docker))
- ✅ Simplified to single-command installation and usage
- ✅ Focus on local development workflow

---

## Created By

- **Repository**: https://github.com/bkainz/opencode-docker
- **Original Fork**: https://github.com/rpfilomeno/opencode-docker
- **Inspired By**: https://github.com/VishalJ99/claude-docker

---

## License

This project is open source. See the [LICENSE](LICENSE) file for details.

