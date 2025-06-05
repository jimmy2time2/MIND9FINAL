#!/bin/bash

# Start all Mind9 services properly
# This script ensures all services will run persistently and restart on failures

echo "==========================================="
echo "     Mind9 System Startup"
echo "==========================================="

# First stop any existing services
echo "Stopping any existing services..."
./stop_twitter_bot.sh 2>/dev/null || true
pkill -f "python.*run_twitter_bot.py" 2>/dev/null || true
pkill -f "python.*twitter_bot.py" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true
pkill -f "python.*coin_promoter.py" 2>/dev/null || true
sleep 2

# Start the Twitter bot properly
echo "Starting Twitter bot..."
./restart_twitter_bot.sh

# Start the coin promoter service
echo "Starting Coin Promoter service..."
./start_coin_promoter.sh

# Start the main autonomous system
echo "Starting Mind9 autonomous system..."
nohup python main.py > mind9_autonomous.log 2>&1 &
MIND9_PID=$!
echo "Mind9 autonomous system started with PID: $MIND9_PID"

# Start web application
echo "Starting web application..."
npm run dev > webapp.log 2>&1 &
WEBAPP_PID=$!
echo "Web application started with PID: $WEBAPP_PID"

# Set up a simple monitoring script to run every 5 minutes
echo "Setting up monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * cd $(pwd) && ./health_monitor.sh >> monitor.log 2>&1") | crontab -

# Create PID directory if it doesn't exist
mkdir -p .pids

# Save PIDs for monitoring
echo $MIND9_PID > .pids/mind9.pid
echo $WEBAPP_PID > .pids/webapp.pid

# Set a flag to indicate services are running
touch .services_running

echo ""
echo "All services started successfully!"
echo "To check Twitter bot status: ./check_twitter_bot.sh"
echo "To view logs:"
echo "  - Twitter bot: tail -f twitter_bot_output.log"
echo "  - Coin promoter: tail -f coin_promoter.log"
echo "  - Mind9 system: tail -f mind9_autonomous.log"
echo "  - Web app: tail -f webapp.log"
echo ""
echo "Note: The Twitter API has rate limits, so don't worry if"
echo "      you see rate limit errors - the bot will automatically"
echo "      wait and retry when limits reset."
echo ""
echo "ALL SERVICES WILL CONTINUE RUNNING AFTER TERMINAL CLOSES"