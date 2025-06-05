#!/usr/bin/env python3
"""
Running Script for Mind9 Core System
Provides continuous execution with auto-restart capability for Replit environment
"""

import os
import sys
import time
import subprocess
import logging
import signal
import traceback

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("logs/mind9_runner.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("mind9_runner")

# Status file
STATUS_FILE = ".mind9_running"

# Create status file to indicate the service is running
def create_status_file():
    with open(STATUS_FILE, 'w') as f:
        f.write(f"{time.time()}")

# Check if status file exists
def is_running():
    return os.path.exists(STATUS_FILE)
    
# Register signal handlers
def handle_exit(signum, frame):
    logger.info(f"Received signal {signum}, shutting down...")
    if os.path.exists(STATUS_FILE):
        os.remove(STATUS_FILE)
    sys.exit(0)

# Register handlers for common signals
signal.signal(signal.SIGINT, handle_exit)
signal.signal(signal.SIGTERM, handle_exit)

def run_with_restart():
    """Run Mind9 core system with automatic restart capability"""
    create_status_file()
    logger.info("Starting Mind9 core system runner in continuous mode")
    
    restart_count = 0
    max_restarts = 100  # Prevent infinite restart loops
    
    try:
        while is_running() and restart_count < max_restarts:
            logger.info(f"Starting Mind9 core system (restart count: {restart_count})")
            
            # Run the Mind9 module
            start_time = time.time()
            try:
                logger.info("Importing and running main Mind9 module")
                from main import Mind9
                mind9 = Mind9()
                mind9.run()
            except Exception as e:
                error_message = f"Mind9 core system crashed: {str(e)}"
                logger.error(error_message)
                logger.error(traceback.format_exc())
                
                # Check if we need to wait before restarting
                runtime = time.time() - start_time
                if runtime < 60:  # Less than 1 minute
                    logger.warning("Process crashed too quickly, waiting 60 seconds before restart")
                    time.sleep(60)
                
                restart_count += 1
                continue
    
    except Exception as e:
        logger.critical(f"Runner crashed: {str(e)}")
        logger.critical(traceback.format_exc())
    
    finally:
        if os.path.exists(STATUS_FILE):
            os.remove(STATUS_FILE)
        logger.info("Mind9 core system runner stopped")

if __name__ == "__main__":
    run_with_restart()