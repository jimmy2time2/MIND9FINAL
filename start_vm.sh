#!/bin/bash

# Start Mind9 with PM2 (if installed) or use the regular scripts
if command -v pm2 &> /dev/null; then
    echo "Starting Mind9 using PM2..."
    # Start all services defined in ecosystem.config.js
    pm2 start ecosystem.config.js
else
    echo "PM2 not found, using traditional startup scripts..."
    # Run the traditional startup scripts
    chmod +x start_mind9.sh
    chmod +x start_twitter_bot.sh
    
    # Start the main Node.js application
    ./start_mind9.sh
    
    # Start the Twitter bot
    ./start_twitter_bot.sh
fi

echo "Mind9 has been started!"
echo "Website should be accessible at: http://localhost:5000"
echo "To view logs:"
echo "  - Main application: tail -f mind9_continuous.log"
echo "  - Twitter bot: tail -f twitter_bot_continuous.log"