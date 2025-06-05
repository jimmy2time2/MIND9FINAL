#!/usr/bin/env python3
"""
Twitter Status Monitor for Mind9
Checks the status of the Twitter bot and provides monitoring information
"""

import os
import json
import logging
from datetime import datetime, timedelta

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("twitter_status")

class TwitterMonitor:
    def __init__(self):
        """Initialize the Twitter status monitor"""
        self.state_file = "twitter_bot_state.json"
        self.history_file = "tweet_history.json"
        self.error_log = "twitter_bot_error.log"
        
    def load_bot_state(self):
        """Load the Twitter bot state from file"""
        try:
            if os.path.exists(self.state_file):
                with open(self.state_file, 'r') as f:
                    return json.load(f)
            return None
        except Exception as e:
            logger.error(f"Error loading Twitter bot state: {e}")
            return None
    
    def load_tweet_history(self):
        """Load the tweet history from file"""
        try:
            if os.path.exists(self.history_file):
                with open(self.history_file, 'r') as f:
                    return json.load(f)
            return []
        except Exception as e:
            logger.error(f"Error loading tweet history: {e}")
            return []
    
    def get_recent_errors(self, max_lines=20):
        """Get recent errors from the error log file"""
        try:
            if os.path.exists(self.error_log):
                with open(self.error_log, 'r') as f:
                    # Get the last 'max_lines' lines from the file
                    lines = f.readlines()
                    return lines[-max_lines:] if len(lines) > max_lines else lines
            return []
        except Exception as e:
            logger.error(f"Error reading error log: {e}")
            return []
    
    def check_bot_status(self):
        """Check the status of the Twitter bot"""
        state = self.load_bot_state()
        
        if not state:
            return {
                "status": "unknown",
                "message": "No Twitter bot state found. The bot may not be running.",
                "last_update": None
            }
        
        # Check when the last tweet was made
        last_tweet_time = state.get("last_tweet_time")
        
        if not last_tweet_time:
            return {
                "status": "warning",
                "message": "Twitter bot is running but no tweets have been made yet.",
                "last_update": state.get("last_update")
            }
        
        # Calculate time since last tweet
        last_tweet = datetime.fromisoformat(last_tweet_time)
        time_since_last_tweet = datetime.now() - last_tweet
        
        # Determine status based on time since last tweet
        if time_since_last_tweet > timedelta(hours=48):
            status = "critical"
            message = f"No tweets in the last {time_since_last_tweet.days} days and {time_since_last_tweet.seconds // 3600} hours."
        elif time_since_last_tweet > timedelta(hours=24):
            status = "warning"
            message = f"No tweets in the last {time_since_last_tweet.seconds // 3600} hours."
        else:
            status = "healthy"
            message = f"Last tweet was {time_since_last_tweet.seconds // 3600} hours and {(time_since_last_tweet.seconds % 3600) // 60} minutes ago."
        
        # Add more details to the status
        return {
            "status": status,
            "message": message,
            "last_tweet_time": last_tweet_time,
            "daily_tweet_count": state.get("daily_tweet_count", 0),
            "total_tweets": state.get("total_tweets", 0),
            "announced_coins": len(state.get("announced_coins", [])),
            "last_update": state.get("last_update"),
            "recent_tweet_history": state.get("tweet_history", []),
            "alerts": state.get("alerts", []),
            "errors": state.get("errors", [])
        }
    
    def print_status_report(self):
        """Print a status report for the Twitter bot"""
        status = self.check_bot_status()
        history = self.load_tweet_history()
        recent_errors = self.get_recent_errors()
        
        print("\n" + "=" * 50)
        print(" MIND9 TWITTER BOT STATUS REPORT ")
        print("=" * 50)
        
        # Print status overview
        print(f"\nStatus: {status['status'].upper()}")
        print(f"Message: {status['message']}")
        
        # Print tweet statistics
        print("\nTWEET STATISTICS:")
        print(f"- Total tweets: {status.get('total_tweets', 'Unknown')}")
        print(f"- Daily tweet count: {status.get('daily_tweet_count', 'Unknown')}")
        print(f"- Announced coins: {status.get('announced_coins', 'Unknown')}")
        
        # Print recent tweets
        print("\nRECENT TWEETS:")
        if history:
            for i, tweet in enumerate(history[:5]):
                print(f"- {i+1}. [{tweet.get('timestamp', 'Unknown date')}] {tweet.get('text', '')}")
        else:
            print("No tweet history found.")
        
        # Print recent errors
        print("\nRECENT ERRORS:")
        if recent_errors:
            for error in recent_errors:
                if "ERROR" in error:
                    print(f"- {error.strip()}")
        else:
            print("No recent errors found.")
        
        # Print alerts
        print("\nALERTS:")
        if status.get('alerts'):
            for alert in status['alerts']:
                print(f"- [{alert.get('timestamp', 'Unknown')}] {alert.get('type', 'Unknown')}: {alert.get('details', '')}")
        else:
            print("No alerts found.")
        
        print("\n" + "=" * 50)
    
    def get_status_json(self):
        """Get the Twitter bot status as JSON for API integration"""
        status = self.check_bot_status()
        history = self.load_tweet_history()
        recent_errors = self.get_recent_errors()
        
        # Format errors for JSON
        formatted_errors = []
        for error in recent_errors:
            if "ERROR" in error:
                formatted_errors.append(error.strip())
        
        # Return JSON-ready object
        return {
            "status": status['status'],
            "message": status['message'],
            "last_tweet_time": status.get('last_tweet_time'),
            "stats": {
                "total_tweets": status.get('total_tweets', 0),
                "daily_tweet_count": status.get('daily_tweet_count', 0),
                "announced_coins": status.get('announced_coins', 0)
            },
            "recent_tweets": history[:5] if history else [],
            "recent_errors": formatted_errors,
            "alerts": status.get('alerts', []),
            "timestamp": datetime.now().isoformat()
        }

# For direct testing
if __name__ == "__main__":
    monitor = TwitterMonitor()
    monitor.print_status_report()