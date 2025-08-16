#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Generate deterministic container name based on project path
CONTAINER_HASH="$(printf "%s" "$ROOT_DIR" | md5sum | head -c12)"
CLAUDE_CONTAINER_NAME="claude-code-dev-$CONTAINER_HASH"

echo "==============================================="
echo "Setting up Claude Code Docker environment..."
echo "==============================================="
echo "[0/4] Preparing container $CLAUDE_CONTAINER_NAME..."

# Step 1: Build the Docker image
echo "[1/4] Building Docker image..."
docker-compose -f "$SCRIPT_DIR/docker-compose.yml" build

# Ensure .claude.json exists
if [ ! -f "$ROOT_DIR/.claude.json" ]; then
  echo '{}' > "$ROOT_DIR/.claude.json"
fi

# Step 2: Start the container in detached mode
echo "[2/4] Starting container in detached mode..."
CLAUDE_CONTAINER_NAME="$CLAUDE_CONTAINER_NAME" docker-compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

# Step 3: Wait for firewall initialization
echo "[3/4] Waiting for firewall to initialize..."
until docker exec "$CLAUDE_CONTAINER_NAME" bash -c "test -f /tmp/firewall.ready" >/dev/null 2>&1; do
  sleep 1
done

# Step 4: Enter the container
cat <<MSG
[4/4] Setup complete! Entering container...

IMPORTANT: Run 'claude-code auth' to set up your API key
Your repository root is available at /workspace

===============================================
Quick commands inside the container:
  claude-code auth          - Set up API key
  claude-code --help        - Show help
  cd /workspace            - Go to repository root
  exit                     - Leave container
===============================================
MSG

docker exec -it "$CLAUDE_CONTAINER_NAME" bash

echo
cat <<MSG
===============================================
You've exited the Claude Code container.
The container is still running in the background.

To re-enter: docker exec -it $CLAUDE_CONTAINER_NAME bash
To stop: docker stop $CLAUDE_CONTAINER_NAME
===============================================
MSG
