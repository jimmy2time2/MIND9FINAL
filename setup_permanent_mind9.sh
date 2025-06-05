#!/bin/bash

# Mind9 Permanent Installation Script
# This script sets up Mind9 to run permanently with multiple layers of resilience

echo "=================================================="
echo "  Mind9 Permanent Installation"
echo "=================================================="
echo ""
echo "This script will set up Mind9 with multiple layers of persistence:"
echo "1. PM2 process management"
echo "2. Systemd service"
echo "3. Cron job monitoring"
echo "4. Autostart at boot"
echo ""
echo "Continuing with automatic setup..."

# Make all scripts executable
echo "Making scripts executable..."
chmod +x *.sh

# Install PM2 globally if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2 globally..."
    npm install -g pm2
fi

# Install required Python packages
echo "Installing required Python packages..."
pip install schedule openai psycopg2-binary tweepy python-dotenv

# Set up PM2 for autostart
echo "Setting up PM2 for autostart..."
pm2 startup

# Stop any existing processes
echo "Stopping any existing processes..."
./stop_twitter_bot.sh 2>/dev/null || true
pkill -f "python.*twitter_bot.py" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true
pkill -f "python.*coin_promoter.py" 2>/dev/null || true
pm2 delete all 2>/dev/null || true
sleep 2

# Start all services using PM2
echo "Starting all services with PM2..."
pm2 start ecosystem.config.cjs

# Save the PM2 process list
echo "Saving PM2 process list..."
pm2 save

# Set up cron job for the health monitor
echo "Setting up cron job for health monitoring..."
(crontab -l 2>/dev/null | grep -v "health_monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * cd $(pwd) && ./health_monitor.sh >> monitor.log 2>&1") | crontab -

# Set up cron job to run at reboot
echo "Setting up autostart at system boot..."
(crontab -l 2>/dev/null | grep -v "mind9_autostart.sh") | crontab -
(crontab -l 2>/dev/null; echo "@reboot cd $(pwd) && ./mind9_autostart.sh >> autostart.log 2>&1") | crontab -

echo ""
echo "Mind9 has been set up for permanent operation!"
echo ""
echo "Current running processes:"
pm2 list
echo ""
echo "To check on your services anytime:"
echo "  - PM2 status: pm2 status"
echo "  - View logs: pm2 logs"
echo "  - Restart everything: pm2 restart all"
echo ""
echo "Your services will now continue running even after the terminal is closed"
echo "and will automatically restart if they crash or if the system reboots."
echo ""
echo "To promote all your coins on Twitter:"
echo "  python -c 'from coin_promoter import CoinPromoter; CoinPromoter().promote_all_coins(True)'"
echo ""
echo "=================================================="