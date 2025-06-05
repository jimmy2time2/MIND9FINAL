#!/bin/bash

# Simple Deployment Script for Mind9 on Replit
# This script prepares your Mind9 platform for deployment

echo "=================================================="
echo "  Mind9 Simple Deployment Setup"
echo "=================================================="

# Create .replit file with proper deployment configuration
cat > .replit << EOL
run = "bash always_on.sh"
modules = ["nodejs-20", "python-3.11"]

[nix]
channel = "stable-24_05"

# Add system dependencies required by packages like Canvas
[nix.deps]
deps = [
  "libuuid",
  "cairo",
  "pango",
  "libpng",
  "libjpeg",
  "giflib",
  "librsvg",
  "pkg-config"
]

[env]
HOST = "0.0.0.0"
PORT = "5000"

[deployment]
run = ["bash", "-c", "npm run dev"]
build = ["bash", "-c", "npm install && npm run build"]
deploymentTarget = "gce"

[[ports]]
localPort = 5000
externalPort = 80
name = "Mind9 App"
protocol = "http"
EOL

# Create build.sh file that Replit will use during deployment
cat > build.sh << EOL
#!/bin/bash
# Set NPM config for Canvas
export npm_config_canvas_binary_host_mirror=https://github.com/Automattic/node-canvas/releases/download/
export CXXFLAGS="--std=c++14"

# Install system dependencies required by Canvas
echo "Installing system dependencies for Canvas..."
apt-get update
apt-get install -y libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev librsvg2-dev build-essential

# Ensure packages are installed
echo "Installing npm packages..."
npm install --build-from-source

# Rebuild canvas specifically
echo "Rebuilding canvas..."
npm rebuild canvas --update-binary

# Build the application
echo "Building application..."
npm run build

# Make scripts executable
chmod +x *.sh

# Notify build complete
echo "Build completed successfully!"
EOL
chmod +x build.sh

echo ""
echo "Deployment configuration created!"
echo ""
echo "To deploy your Mind9 platform:"
echo "1. Click on 'Deployments' in the Replit sidebar"
echo "2. Click 'Deploy' button"
echo ""
echo "To keep Mind9 running 24/7 on your Reserved VM:"
echo "1. Open a terminal in Replit"
echo "2. Run: ./always_on.sh"
echo "3. Keep the terminal open, but you can close your browser"
echo ""
echo "=================================================="