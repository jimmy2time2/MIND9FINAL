#!/bin/bash

# Start the coin promoter service
echo "Starting Mind9 Coin Promoter..."
nohup python coin_promoter.py > coin_promoter.log 2>&1 &
PROMOTER_PID=$!
echo "Coin Promoter started with PID: $PROMOTER_PID"

# Create a PID file for monitoring
echo $PROMOTER_PID > .coin_promoter_pid

echo "Coin Promoter is now running in the background"
echo "Check logs with: tail -f coin_promoter.log"