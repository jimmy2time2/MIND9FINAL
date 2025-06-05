#!/bin/bash
# Script to start the Mind9 Twitter bot

echo "Starting Mind9 Twitter Bot"
echo "------------------------------"
echo "Bot Configuration:"
echo "* Maximum 2 tweets per day"
echo "* 3-hour minimum between tweets"
echo "* Checks for new coins every 15 minutes"
echo "* Tweet schedule: 8:30am, 1:15pm, 5:45pm, 10:00pm"
echo "* New coins announced immediately"
echo "------------------------------"

# Ensure all required packages are installed
python -m pip install -q tweepy python-dotenv schedule psycopg2-binary openai

# Check if the bot should run in continuous mode
CONTINUOUS=true
if [ "$1" == "once" ]; then
  CONTINUOUS=false
  echo "Running in single-execution mode"
else
  echo "Running in continuous mode"
fi

# Launch Twitter bot with nohup to keep it running after terminal closes
if [ "$CONTINUOUS" == "true" ]; then
  echo "Starting bot in background with nohup"
  nohup python run_twitter_bot.py > twitter_bot_output.log 2>&1 &
  echo "Bot started with PID: $!"
  echo "Log output is redirected to twitter_bot_output.log"
else
  echo "Running bot in foreground (once mode)"
  python run_twitter_bot.py once
fi

# Display status after starting
echo ""
echo "Twitter bot started successfully"
echo "To check status: python twitter_status.py"
echo "To stop the bot: ./stop_twitter_bot.sh"