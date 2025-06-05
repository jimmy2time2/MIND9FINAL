#!/bin/bash

# Mind9 Replit-specific Startup for Autoscale deployments
# This script focuses only on the web server for deployment

echo "=========================================="
echo "     Mind9 Replit Startup"
echo "=========================================="

# Create necessary directory for logs (in writable location)
mkdir -p logs

# Set up Node.js environment more robustly
echo "Setting up Node.js environment..."

# Source Nix profile first
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Try multiple approaches to find Node.js
# 1. Try the standard Replit Node.js path
export PATH="/nix/store/$(ls -t /nix/store | grep -E 'nodejs-[0-9]+' | head -n1)/bin:$PATH"

# 2. Check if Node.js is available now
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "First attempt failed, trying alternative Node.js paths..."
  
  # Try a broader search
  NODE_PATH=$(find /nix/store -maxdepth 1 -name "*nodejs*" -type d | sort -r | head -n1)
  if [ -n "$NODE_PATH" ]; then
    export PATH="$NODE_PATH/bin:$PATH"
    echo "Found Node.js at: $NODE_PATH"
  fi
fi

# Final verification
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "ERROR: Node.js or npm not found in PATH after multiple attempts"
  echo "Available Node.js installations:"
  find /nix/store -maxdepth 1 -name "*nodejs*" -type d
  echo "Current PATH: $PATH"
  exit 1
else
  echo "Node.js version: $(node -v)"
  echo "npm version: $(npm -v)"
fi

# Kill any existing processes
pkill -f "npm run dev" || true

# Start the web application on 0.0.0.0:5000
echo "Starting web application..."
export HOST=0.0.0.0
export PORT=5000

# Install dependencies if needed
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.package-lock.json" ]; then
  echo "Installing dependencies..."
  npm ci || npm install
fi

# For production, we need to run the start command
echo "Running web server in production mode"
NODE_ENV=production node dist/index.js