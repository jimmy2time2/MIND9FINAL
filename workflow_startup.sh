#!/bin/bash

# Specialized startup script for the Replit workflow
# This script is designed to be used as the main entry point for the workflow

echo "===================================================="
echo "     Mind9 Autonomous System Startup (Workflow)"
echo "===================================================="

# Create necessary directories
mkdir -p logs
mkdir -p .pids

# Check if services are already running and stop them
if pgrep -f "python.*twitter_bot.py" > /dev/null; then
    echo "Stopping existing Twitter bot..."
    ./stop_twitter_bot.sh
fi

# Kill any existing Python processes that might be running Mind9 components
pkill -f "python.*coin_promoter.py" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true
sleep 2

# Set up status flags
echo "true" > .flags/autostart_enabled
echo "true" > .flags/autonomous_enabled 
echo "true" > .flags/twitter_enabled
echo "true" > .flags/coin_promoter_enabled

# Start the Twitter bot
echo "Starting Twitter bot..."
./start_twitter_bot.sh
echo "Twitter bot started!"

# Start the Coin Promoter in the background
echo "Starting Coin Promoter..."
nohup python coin_promoter.py > logs/coin_promoter.log 2>&1 &
PROMOTER_PID=$!
echo $PROMOTER_PID > .pids/coin_promoter.pid
echo "Coin Promoter started with PID: $PROMOTER_PID"

# Start the Mind9 autonomous system in the background
echo "Starting Mind9 Core System..."
nohup python main.py > logs/mind9.log 2>&1 &
MIND9_PID=$!
echo $MIND9_PID > .pids/mind9.pid
echo "Mind9 Core started with PID: $MIND9_PID"

# Set timestamps
echo "$(date)" > .services_running
echo "$(date)" > .mind9_running
echo "$(date)" > .twitter_bot_running

# Start watchdog monitor
echo "Starting watchdog monitor..."
nohup bash -c "
while true; do
  # Check if Twitter bot is running
  if ! pgrep -f 'python.*twitter_bot.py' > /dev/null; then
    echo \"\$(date) - Twitter bot not running, restarting...\" >> logs/watchdog.log
    ./start_twitter_bot.sh
  fi
  
  # Check if Coin Promoter is running
  if ! pgrep -f 'python.*coin_promoter.py' > /dev/null; then
    echo \"\$(date) - Coin Promoter not running, restarting...\" >> logs/watchdog.log
    nohup python coin_promoter.py > logs/coin_promoter.log 2>&1 &
    echo \$! > .pids/coin_promoter.pid
  fi
  
  # Check if Mind9 Core is running
  if ! pgrep -f 'python.*main.py' > /dev/null; then
    echo \"\$(date) - Mind9 Core not running, restarting...\" >> logs/watchdog.log
    nohup python main.py > logs/mind9.log 2>&1 &
    echo \$! > .pids/mind9.pid
  fi
  
  # Update timestamp
  echo \"\$(date)\" > .last_watchdog_run
  
  # Sleep for 5 minutes before next check
  sleep 300
done" > logs/watchdog.log 2>&1 &
WATCHDOG_PID=$!
echo $WATCHDOG_PID > .pids/watchdog.pid
echo "Watchdog started with PID: $WATCHDOG_PID"

# Now start the Node.js server in the foreground
# This ensures that the Replit workflow stays active
echo "Starting web application server..."
echo "===================================================="
echo "The Mind9 autonomous system is now running!"
echo "All services will be kept alive by the watchdog"
echo "The watchdog will restart any service that stops"
echo "===================================================="

# Start the Node.js server in the foreground (this keeps the workflow running)
npm run dev