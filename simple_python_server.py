"""
Simple Python HTTP Server for Mind9
This provides a basic HTTP server when Node.js is not available
"""

import http.server
import socketserver
import os
import json
from pathlib import Path
import sys

# Set the port where the server will run
PORT = int(os.environ.get('PORT', 5000))
HOST = os.environ.get('HOST', '0.0.0.0')

# Path to serve
STATIC_DIR = Path("./public").absolute()
GENERATED_IMAGES_DIR = Path("./generated_images").absolute()

# Create the handler with custom directories
class Mind9Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(STATIC_DIR), **kwargs)
    
    def do_GET(self):
        # Handle image paths
        if self.path.startswith('/img/coins/'):
            # Extract image filename from path
            filename = os.path.basename(self.path)
            image_path = GENERATED_IMAGES_DIR / filename
            
            # If the file exists, serve it
            if image_path.exists():
                self.send_response(200)
                if filename.endswith('.jpg') or filename.endswith('.jpeg'):
                    self.send_header('Content-type', 'image/jpeg')
                elif filename.endswith('.png'):
                    self.send_header('Content-type', 'image/png')
                else:
                    self.send_header('Content-type', 'application/octet-stream')
                self.end_headers()
                
                with open(image_path, 'rb') as file:
                    self.wfile.write(file.read())
                return
        
        # Handle API endpoint for coins
        elif self.path == '/api/coins':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            # Generate sample JSON response
            coins = [
                {
                    "id": 1,
                    "name": "Velocity", 
                    "symbol": "VELO", 
                    "description": "A high-speed transaction token",
                    "mint_address": "8Xe5N4KF8PPtBvY9JvPBxiMv4zkzQ4RmMetgNuJRDXzR",
                    "image_path": "/img/coins/velo-8a384b05.png",
                    "minted": True,
                    "user_mintable": True,
                    "total_supply": "1,000,000"
                }
            ]
            
            self.wfile.write(json.dumps(coins).encode())
            return
        
        # Default handler for other paths
        return super().do_GET()

# Create the server
with socketserver.TCPServer((HOST, PORT), Mind9Handler) as httpd:
    print(f"Mind9 Python Server running at http://{HOST}:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("Server stopped by user")
    finally:
        httpd.server_close()
        print("Server closed")