# ABOUTME: Docker image for OpenCode with full permissions
# ABOUTME: Provides autonomous OpenCode environment in isolated container

FROM node:20.18.1-slim

# Install system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    build-essential \
    sudo \
    gettext-base \
    # Additional useful tools
    vim \
    nano \
    htop \
    tmux \
    bash \
    fzf \
    ripgrep \
    fd-find \
    bat \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install additional system packages if specified
ARG SYSTEM_PACKAGES=""
RUN if [ -n "$SYSTEM_PACKAGES" ]; then \
    echo "Installing additional system packages: $SYSTEM_PACKAGES" && \
    apt-get update && \
    apt-get install -y $SYSTEM_PACKAGES && \
    rm -rf /var/lib/apt/lists/*; \
else \
    echo "No additional system packages specified"; \
fi

# Create a non-root user with matching host UID/GID
ARG USER_UID=1000
ARG USER_GID=1000
RUN if getent group $USER_GID > /dev/null 2>&1; then \
        GROUP_NAME=$(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd -g $USER_GID opencode-user && GROUP_NAME=opencode-user; \
    fi && \
    useradd -m -s /bin/bash -u $USER_UID -g $GROUP_NAME opencode-user && \
    echo "opencode-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create app directory
WORKDIR /app

# Install OpenCode CLI globally as root
RUN curl -fsSL https://opencode.ai/install | bash && \
    # Make opencode available system-wide
    ln -sf /root/.local/bin/opencode /usr/local/bin/opencode && \
    # Verify installation
    opencode --version || echo "OpenCode installed"

# Make sure opencode is in PATH
ENV PATH="/root/.local/bin:/usr/local/bin:${PATH}"

# Create directories for configuration
RUN mkdir -p /app/.opencode /home/opencode-user/.config/opencode

# Copy startup script
COPY src/startup.sh /app/
RUN chmod +x /app/startup.sh

# Copy .env file during build to bake credentials into the image
COPY .env /app/.env

# Copy OpenCode authentication files from host if they exist
# Note: Build will create empty file if doesn't exist
RUN touch /home/opencode-user/.opencode.json

# Configure git user during build using host git config passed as build args
ARG GIT_USER_NAME=""
ARG GIT_USER_EMAIL=""
RUN if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then \
        echo "Configuring git user from host: $GIT_USER_NAME <$GIT_USER_EMAIL>" && \
        git config --global user.name "$GIT_USER_NAME" && \
        git config --global user.email "$GIT_USER_EMAIL" && \
        echo "Git configuration complete"; \
    else \
        echo "Warning: No git user configured on host system"; \
    fi

# Set proper ownership for everything
RUN chown -R opencode-user:opencode-user /app /home/opencode-user

# Switch to non-root user
USER opencode-user

# Set HOME immediately after switching user
ENV HOME=/home/opencode-user

# Install OpenCode CLI for opencode-user
RUN curl -fsSL https://opencode.ai/install | bash

# Install Ralph Wiggum (autonomous agentic loop tool)
RUN npm install -g @th0rgal/ralph-wiggum

# Add opencode bin directory to PATH
ENV PATH="/home/opencode-user/.opencode/bin:$PATH"

# Set working directory to mounted volume
WORKDIR /workspace

# Environment variables will be passed from host
ENV NODE_ENV=production

# Start OpenCode
ENTRYPOINT ["/app/startup.sh"]
