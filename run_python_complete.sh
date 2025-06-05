#!/bin/bash

# Mind9 Complete Python Startup Script
# This script runs all Mind9 components using Python only

echo "=================================================="
echo "  Mind9 Python Complete Mode"
echo "=================================================="
echo ""

# Create logs directory
mkdir -p logs

# Kill any existing processes
echo "Stopping any existing Mind9 services..."
pkill -f "python.*twitter_bot.py" 2>/dev/null || true
pkill -f "python.*run_mind9.py" 2>/dev/null || true
pkill -f "python.*run_coin_promoter.py" 2>/dev/null || true
pkill -f "python.*simple_python_server.py" 2>/dev/null || true
sleep 2

# Find Python path
PYTHON_PATH=$(which python3.11 || which python3 || which python || echo "python3")
echo "Using Python path: $PYTHON_PATH"

# Start Python HTTP server
echo "Starting Python HTTP server..."
export PORT=5000
export HOST=0.0.0.0
nohup $PYTHON_PATH -u simple_python_server.py > logs/http_server.log 2>&1 &
HTTP_SERVER_PID=$!
echo "Python HTTP server started with PID: $HTTP_SERVER_PID"

# Start Twitter bot
echo "Starting Twitter bot..."
nohup $PYTHON_PATH -u run_twitter_bot.py > logs/twitter_bot.log 2>&1 &
TWITTER_BOT_PID=$!
echo "Twitter bot started with PID: $TWITTER_BOT_PID"

# Start Mind9 core
echo "Starting Mind9 core system..."
nohup $PYTHON_PATH -u run_mind9.py > logs/mind9.log 2>&1 &
MIND9_PID=$!
echo "Mind9 core started with PID: $MIND9_PID"

# Start coin promoter
echo "Starting Coin Promoter..."
nohup $PYTHON_PATH -u run_coin_promoter.py > logs/coin_promoter.log 2>&1 &
COIN_PROMOTER_PID=$!
echo "Coin Promoter started with PID: $COIN_PROMOTER_PID"

echo ""
echo "Mind9 Python services started successfully!"
echo "Web UI available at: http://localhost:5000"
echo ""
echo "=================================================="

# Create status files for other scripts to check
touch .mind9_running
touch .twitter_bot_running
touch .services_running

# Keep the terminal active and monitor services
echo "Starting monitoring loop..."
while true; do
  # Check Python HTTP server
  if ! ps -p $HTTP_SERVER_PID > /dev/null; then
    echo "[$(date)] Python HTTP server not running, restarting..."
    nohup $PYTHON_PATH -u simple_python_server.py > logs/http_server.log 2>&1 &
    HTTP_SERVER_PID=$!
    echo "Python HTTP server restarted with PID: $HTTP_SERVER_PID"
  fi

  # Check Twitter bot
  if ! ps -p $TWITTER_BOT_PID > /dev/null; then
    echo "[$(date)] Twitter bot not running, restarting..."
    nohup $PYTHON_PATH -u run_twitter_bot.py > logs/twitter_bot.log 2>&1 &
    TWITTER_BOT_PID=$!
    echo "Twitter bot restarted with PID: $TWITTER_BOT_PID"
  fi
  
  # Check Mind9 core
  if ! ps -p $MIND9_PID > /dev/null; then
    echo "[$(date)] Mind9 core not running, restarting..."
    nohup $PYTHON_PATH -u run_mind9.py > logs/mind9.log 2>&1 &
    MIND9_PID=$!
    echo "Mind9 core restarted with PID: $MIND9_PID"
  fi
  
  # Check coin promoter
  if ! ps -p $COIN_PROMOTER_PID > /dev/null; then
    echo "[$(date)] Coin Promoter not running, restarting..."
    nohup $PYTHON_PATH -u run_coin_promoter.py > logs/coin_promoter.log 2>&1 &
    COIN_PROMOTER_PID=$!
    echo "Coin Promoter restarted with PID: $COIN_PROMOTER_PID"
  fi
  
  # Log heartbeat and update status files
  echo "[$(date)] Mind9 is running in Python-only mode" 
  echo "$(date)" > .last_watchdog_run
  sleep 60  # Check every minute
done