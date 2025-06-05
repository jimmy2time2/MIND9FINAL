#!/bin/bash
# Start script for Mind9 autonomous system

# Ensure script has execute permission
if [ ! -x "$0" ]; then
    echo "Making script executable..."
    chmod +x "$0"
fi

# Ensure Python dependencies are installed
check_dependencies() {
    echo "Checking Python dependencies..."
    missing=0
    
    # List of required packages
    packages=(
        "python-dotenv"
        "openai"
        "tweepy"
        "pillow"
        "numpy"
        "schedule"
        "requests"
        "base58"
        "solana"
    )
    
    for package in "${packages[@]}"; do
        if ! pip list | grep -q "$package"; then
            echo "Missing package: $package"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        echo "Installing missing packages..."
        pip install python-dotenv openai tweepy pillow numpy schedule requests base58 solana
    else
        echo "All dependencies are installed."
    fi
}

# Check for .env file
check_env_file() {
    if [ ! -f ".env" ]; then
        echo "Error: .env file not found."
        echo "Please create a .env file with your API keys and settings."
        echo "You can use .env.example as a template."
        exit 1
    fi
}

# Clean up test coins when deploying to production
cleanup_test_coins() {
    echo "Checking and removing test coins before startup..."
    if [ "$NODE_ENV" == "production" ] || [ "$1" == "--force-cleanup" ]; then
        echo "Running in production mode, executing test coin cleanup"
        python cleanup_test_coins.py
    else
        echo "Not in production mode, skipping test coin cleanup"
    fi
}

# Function to keep Mind9 running forever with automatic restart on crash
start_mind9() {
    echo "Starting Mind9 autonomous system with continuous operation..."
    echo "The system will automatically restart if it crashes."
    
    # Create a marker file to indicate Mind9 is running
    touch .mind9_running
    
    # Run in a continuous loop with automatic restart
    while [ -f .mind9_running ]; do
        echo "============================================"
        echo "[$(date)] STARTING MIND9 AUTONOMOUS SYSTEM"
        echo "============================================"
        
        # Run main.py, capturing logs to file
        python main.py >> mind9_continuous.log 2>&1
        
        # If we get here, the process crashed or exited
        EXIT_CODE=$?
        
        echo "[$(date)] Mind9 process exited with code $EXIT_CODE. Restarting in 60 seconds..."
        
        # Sleep before restarting to prevent rapid restart loops
        sleep 60
    done
}

# Function to start Mind9 Twitter bot with automatic restart
start_twitter_bot() {
    echo "Starting Twitter bot with continuous operation..."
    echo "The Twitter bot will automatically restart if it crashes."
    
    # Create a marker file to indicate Twitter bot is running
    touch .twitter_bot_running
    
    # Start in background with nohup
    nohup bash -c '
        while [ -f .twitter_bot_running ]; do
            echo "============================================"
            echo "[$(date)] STARTING TWITTER BOT"
            echo "============================================"
            
            # Run the Twitter bot, capturing logs to file
            python twitter_bot.py >> twitter_bot_continuous.log 2>&1
            
            # If we get here, the process crashed or exited
            EXIT_CODE=$?
            
            echo "[$(date)] Twitter bot exited with code $EXIT_CODE. Restarting in 60 seconds..."
            
            # Sleep before restarting to prevent rapid restart loops
            sleep 60
        done
    ' &
    
    echo "Twitter bot started in background with automatic restart"
}

# Function to stop all Mind9 processes gracefully
stop_mind9() {
    echo "Gracefully stopping Mind9 processes..."
    
    # Remove the marker files to stop the continuous loops
    if [ -f .mind9_running ]; then
        rm .mind9_running
        echo "Mind9 main system will stop after current cycle"
    fi
    
    if [ -f .twitter_bot_running ]; then
        rm .twitter_bot_running
        echo "Twitter bot will stop after current cycle"
    fi
    
    # Find and kill any running Python processes related to Mind9
    MIND9_PIDS=$(ps aux | grep 'python.*[m]ain.py\|python.*[t]witter_bot.py' | awk '{print $2}')
    
    if [ -n "$MIND9_PIDS" ]; then
        echo "Sending graceful termination signal to Mind9 processes..."
        for pid in $MIND9_PIDS; do
            kill -TERM $pid 2>/dev/null || true
            echo "Sent TERM signal to PID $pid"
        done
    else
        echo "No running Mind9 processes found"
    fi
    
    echo "Mind9 shutdown initiated"
}

# Main execution
echo "========================================"
echo "       Mind9 Autonomous System"
echo "========================================"
echo "An AI-driven token creation and Twitter engagement system"
echo ""

# Process command line arguments
if [ "$1" == "stop" ]; then
    stop_mind9
    exit 0
fi

# Normal startup process
check_dependencies
check_env_file
cleanup_test_coins $1

# Start Twitter bot first in background
start_twitter_bot

# Then start Mind9 main system in foreground
start_mind9