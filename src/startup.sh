#!/usr/bin/env bash
set -euo pipefail
trap 'echo "$0: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR

# ABOUTME: Startup script for opencode-docker container
# ABOUTME: Loads env vars, checks for credentials, starts opencode with permissions bypass

# Unset the host OPENCODE_CONFIG_DIR environment variable if it was passed in
# OpenCode should use the default ~/.config/opencode which is where we mount the config volume
unset OPENCODE_CONFIG_DIR || true

# Load environment variables from .env if it exists
if [ -f /app/.env ]; then
    echo "Loading environment from baked-in .env file"
    set -a
    source /app/.env 2>/dev/null || true
    set +a
    # Unset again after sourcing in case it's in the .env file
    unset OPENCODE_CONFIG_DIR || true
else
    echo "WARNING: No .env file found in image."
fi

# Configure OpenCode to use OpenRouter if API key is provided
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo "✓ OpenRouter API key found - configuring as model provider"
    export OPENCODE_API_BASE="https://openrouter.ai/api/v1"
    export OPENCODE_API_KEY="$OPENROUTER_API_KEY"
    
    # Set default model
    export OPENCODE_MODEL="${OPENROUTER_MODEL:-minimax/minimax-m2.1}"
    echo "  Using model: $OPENCODE_MODEL"
    
    # Ensure config.json exists with correct settings
    CONFIG_FILE="$HOME/.config/opencode/config.json"
    echo "  Creating config.json with minimax, nightowl theme, and permissions"
    
    # Build MCP configuration if Context7 API key is provided
    MCP_CONFIG=""
    if [ -n "${CONTEXT7_API_KEY:-}" ]; then
        echo "  ✓ Context7 API key found - configuring remote MCP server"
        MCP_CONFIG=',
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "'$CONTEXT7_API_KEY'"
      }
    }
  }'
    fi
    
    cat > "$CONFIG_FILE" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "minimax/minimax-m2.1",
  "theme": "nightowl",
  "permission": {
    "*": "allow",
    "bash": {
      "*": "allow",
      "sudo *": "allow",
      "apt *": "allow",
      "npm install -g *": "allow",
      "pip install *": "allow"
    },
    "edit": "allow",
    "read": "allow",
    "external_directory": {
      "/home/opencode-user/.config/**": "allow",
      "/home/opencode-user/.local/**": "allow",
      "/usr/local/**": "allow"
    }
  }$MCP_CONFIG
}
EOF
fi

# Check for existing authentication
if [ -f "$HOME/.config/opencode/config.json" ] || [ -f "$HOME/.opencode.json" ]; then
    echo "Found existing OpenCode authentication"
else
    echo "No existing authentication found - you will need to log in"
    echo "Your login will be saved for future sessions"
fi

# Ensure package.json exists in the config directory
if [ ! -f "$HOME/.config/opencode/package.json" ]; then
    echo "Initializing OpenCode config directory..."
    cat > "$HOME/.config/opencode/package.json" << 'EOF'
{
  "name": "opencode-config",
  "version": "1.0.0",
  "description": "OpenCode configuration directory",
  "private": true
}
EOF
    echo "Created package.json at $HOME/.config/opencode/package.json"
else
    echo "Found existing package.json"
fi

# Debug: Check what's in the config directory
echo "Config directory contents:"
ls -la "$HOME/.config/opencode/" 2>&1 || echo "Cannot list config directory"

# Debug: Check for any OpenCode environment variables that might be set wrong
echo "Environment check:"
env | grep -i opencode || echo "No OPENCODE environment variables set"
env | grep -i config || echo "No CONFIG environment variables set"

# Unset any OPENCODE_CONFIG_DIR that might be pointing to the host path
unset OPENCODE_CONFIG_DIR

# Start OpenCode with permissions bypass
echo "Starting OpenCode..."
echo "Working directory: $(pwd)"
echo ""

# Build the opencode command with explicit model flag
OPENCODE_CMD="opencode"

# Always use minimax model if OpenRouter is configured
if [ -n "${OPENCODE_MODEL:-}" ]; then
    echo "Explicitly setting model to: $OPENCODE_MODEL"
    OPENCODE_CMD="$OPENCODE_CMD --model $OPENCODE_MODEL"
fi

# Run opencode with all arguments passed to the container
exec $OPENCODE_CMD "$@"
