#!/usr/bin/env bash
set -euo pipefail
trap 'echo "$0: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR

# ABOUTME: Startup script for opencode-docker container
# ABOUTME: Loads env vars, checks for credentials, starts opencode with permissions bypass

# Load environment variables from .env if it exists
if [ -f /app/.env ]; then
    echo "Loading environment from baked-in .env file"
    set -a
    source /app/.env 2>/dev/null || true
    set +a
else
    echo "WARNING: No .env file found in image."
fi

# Configure OpenCode to use OpenRouter if API key is provided
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo "✓ OpenRouter API key found - configuring as model provider"
    export OPENCODE_API_BASE="https://openrouter.ai/api/v1"
    export OPENCODE_API_KEY="$OPENROUTER_API_KEY"
    
    # Set default model if not specified
    if [ -z "${OPENCODE_MODEL:-}" ]; then
        export OPENCODE_MODEL="${OPENROUTER_MODEL:-minimax/minimax-m2.1}"
        echo "  Using model: $OPENCODE_MODEL"
    fi
fi

# Check for existing authentication
if [ -f "$HOME/.config/opencode/config.json" ] || [ -f "$HOME/.opencode.json" ]; then
    echo "Found existing OpenCode authentication"
else
    echo "No existing authentication found - you will need to log in"
    echo "Your login will be saved for future sessions"
fi

# Start OpenCode with permissions bypass
echo "Starting OpenCode..."
echo "Working directory: $(pwd)"
echo ""

# Run opencode with all arguments passed to the container
# The --dangerously-skip-permissions equivalent for opencode
exec opencode "$@"
