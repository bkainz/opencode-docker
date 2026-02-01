#!/usr/bin/env bash
set -euo pipefail
trap 'echo "$0: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR

# ABOUTME: Installation script for opencode-docker
# ABOUTME: Creates opencode-docker/config directory at home, sets up .env,
# ABOUTME: adds opencode-docker alias to shell rc file

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Installing OpenCode Docker..."
echo ""

# Create persistence directory
mkdir -p "$HOME/.opencode-docker/config"
echo "✓ Created config directory at ~/.opencode-docker/config"

# Copy example env file if doesn't exist
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    if [ -f "$PROJECT_ROOT/sample.env" ]; then
        cp "$PROJECT_ROOT/sample.env" "$PROJECT_ROOT/.env"
        echo "✓ Created .env file from sample.env"
        echo "⚠️  Please edit $PROJECT_ROOT/.env with your OpenCode tokens!"
    else
        echo "⚠️  No sample.env found, creating basic .env"
        cat > "$PROJECT_ROOT/.env" << 'EOF'
# OpenCode Docker Configuration

# OpenCode API tokens (required)
OPENCODE_API_KEY=your_opencode_api_key_here

# Optional: Docker resource limits
# DOCKER_MEMORY_LIMIT=8g
# DOCKER_GPU_ACCESS=all

# Optional: Additional system packages to install
# SYSTEM_PACKAGES="vim curl htop"
EOF
        echo "✓ Created basic .env file"
        echo "⚠️  Please edit $PROJECT_ROOT/.env with your OpenCode tokens!"
    fi
else
    echo "✓ .env file already exists"
fi

# Detect shell and add alias
SHELL_RC=""
if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "${BASH_VERSION:-}" ] || [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    # Default to bashrc
    SHELL_RC="$HOME/.bashrc"
fi

# Add alias to shell rc file
ALIAS_LINE="alias opencode-docker='$PROJECT_ROOT/src/opencode-docker.sh'"

if ! grep -q "alias opencode-docker=" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# OpenCode Docker alias" >> "$SHELL_RC"
    echo "$ALIAS_LINE" >> "$SHELL_RC"
    echo "✓ Added 'opencode-docker' alias to $SHELL_RC"
else
    echo "✓ OpenCode-docker alias already exists in $SHELL_RC"
fi

# Make scripts executable
chmod +x "$PROJECT_ROOT/src/opencode-docker.sh"
chmod +x "$PROJECT_ROOT/src/startup.sh"
echo "✓ Made scripts executable"

# Check for GPU support
echo ""
echo "Checking GPU support..."

# Check if running with admin privileges
if [ "$EUID" -eq 0 ]; then
    echo "✓ Running with admin privileges"
    
    # Check if NVIDIA drivers are installed
    if command -v nvidia-smi &> /dev/null; then
        echo "✓ NVIDIA drivers detected"
        
        # Check if Docker has GPU support
        if docker info 2>/dev/null | grep -q nvidia; then
            echo "✓ Docker GPU support already installed"
        else
            echo "⚠️  Docker GPU support not found"
            echo "Installing NVIDIA Container Toolkit..."
            
            # Install without sudo (we're already root)
            distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
            curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
                gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
            curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
            apt-get update -qq
            apt-get install -y -qq nvidia-container-toolkit
            nvidia-ctk runtime configure --runtime=docker > /dev/null
            systemctl restart docker
            echo "✓ NVIDIA Container Toolkit installed"
        fi
    else
        echo "ℹ️  No NVIDIA GPU detected - skipping GPU support"
    fi
else
    echo "ℹ️  Not running as root - skipping GPU installation"
    echo "   To install GPU support, run: sudo $0"
    
    # Still check status for informational purposes
    if command -v nvidia-smi &> /dev/null; then
        if docker info 2>/dev/null | grep -q nvidia; then
            echo "   ✓ GPU support appears to be already installed"
        else
            echo "   ⚠️  GPU detected but Docker GPU support not installed"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete! 🎉"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Edit $PROJECT_ROOT/.env with your OpenCode API tokens"
echo "2. Run 'source $SHELL_RC' or start a new terminal"
echo "3. Navigate to any project and run 'opencode-docker' to start"
echo ""
