// Simple node server to start the Mind9 application
// This ensures Node.js is properly detected during deployment

const { exec } = require('child_process');
const path = require('path');

console.log('Starting Mind9 platform...');

// Set correct working directory
process.chdir(path.dirname(__filename));

// Start the Mind9 application
const startCommand = 'bash start_replit_services.sh';
const child = exec(startCommand);

child.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

child.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

child.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});

// Keep the process running
process.on('SIGINT', function() {
  console.log('Received SIGINT - keeping server running');
});

// Log to confirm the server is running
console.log('Mind9 platform initialized');