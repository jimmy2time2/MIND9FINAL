
#!/bin/bash

echo "=========================================="
echo "   Mind9 Production Startup"
echo "=========================================="

# Ensure Node.js is available
echo "Setting up Node.js environment..."

# Try multiple approaches to find Node.js
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "Node.js not found in PATH, trying to locate it..."
  
  # Try to source Nix profile if it exists
  if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    echo "Sourced Nix profile"
  fi
  
  # Find and add Node.js to PATH
  NODEJS_PATH=$(find /nix/store -maxdepth 1 -name "*nodejs*" -type d | sort -r | head -n1)
  if [ -n "$NODEJS_PATH" ]; then
    export PATH="$NODEJS_PATH/bin:$PATH"
    echo "Added Node.js from $NODEJS_PATH to PATH"
  fi
fi

# Final verification
if command -v node &> /dev/null && command -v npm &> /dev/null; then
  echo "✅ Node.js $(node -v) and npm $(npm -v) are available"
else
  echo "⚠️ Node.js or npm still not found. Deployment may fail."
  exit 1
fi

# Set environment variables
export HOST=0.0.0.0
export PORT=5000

# Check if we need to build (in case of production environment)
if [ "$NODE_ENV" = "production" ] && [ ! -d "dist" -o ! -f "dist/index.js" ]; then
  echo "Production build needed. Building application..."
  npm ci && npm run build
fi

# Start the application in production mode
echo "Starting Mind9 application on port $PORT..."
NODE_ENV=production node dist/index.js
