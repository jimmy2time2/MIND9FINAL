#!/bin/bash
# Script to stop the Mind9 Twitter bot

echo "Stopping Mind9 Twitter Bot"
echo "-------------------------"

# Find PID of running Twitter bot process
PIDS=$(pgrep -f "python run_twitter_bot.py")

if [ -z "$PIDS" ]; then
  echo "No Twitter bot process found running."
  exit 0
fi

echo "Found Twitter bot processes with PIDs: $PIDS"

# Kill all matching processes
for PID in $PIDS; do
  echo "Stopping process $PID..."
  kill $PID
  
  # Check if process was stopped
  if ps -p $PID > /dev/null; then
    echo "Process $PID did not stop gracefully, forcing..."
    kill -9 $PID
  else
    echo "Process $PID stopped successfully."
  fi
done

echo "All Twitter bot processes have been stopped."
echo "To restart the bot: ./start_twitter_bot.sh"