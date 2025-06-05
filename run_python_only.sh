#!/bin/bash

# Mind9 Python-Only Startup Script
# This script runs only the Python components of Mind9 (Twitter bot, core system, and coin promoter)
# Use this when Node.js isn't working properly

echo "=================================================="
echo "  Mind9 Python-Only Mode"
echo "=================================================="
echo ""

# Create logs directory
mkdir -p logs

# Kill any existing processes
echo "Stopping any existing Mind9 services..."
pkill -f "python.*twitter_bot.py" 2>/dev/null || true
pkill -f "python.*run_mind9.py" 2>/dev/null || true
pkill -f "python.*run_coin_promoter.py" 2>/dev/null || true
sleep 2

# Find Python path
PYTHON_PATH=$(which python3.11 || which python3 || which python || echo "python3")
echo "Using Python path: $PYTHON_PATH"

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
echo ""
echo "=================================================="

# Keep the terminal active and monitor services
echo "Starting monitoring loop..."
while true; do
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
  
  # Log heartbeat
  echo "[$(date)] Mind9 Python services are running"
  sleep 60  # Check every minute
done