
#!/usr/bin/env node

/**
 * Dependency Verification Script
 * Checks if all required native dependencies are available
 */

const fs = require('fs');
const { execSync } = require('child_process');

console.log('====== Mind9 Dependency Verification ======');

// Check for libuuid.so.1
try {
  const ldconfig = execSync('ldconfig -p | grep libuuid.so.1').toString();
  console.log('✅ libuuid.so.1 is available:');
  console.log(ldconfig);
} catch (error) {
  console.error('❌ libuuid.so.1 is NOT available!');
  console.error('Try installing with: apt-get install -y libuuid1');
}

// Check canvas installation
try {
  require('canvas');
  console.log('✅ Canvas package loaded successfully');
} catch (error) {
  console.error('❌ Canvas package failed to load:');
  console.error(error.message);
  console.error('Try reinstalling with: npm rebuild canvas --update-binary');
}

console.log('\nSystem information:');
console.log(`Node.js: ${process.version}`);
console.log(`Platform: ${process.platform}`);
console.log(`Architecture: ${process.arch}`);
console.log('\nDone!');
