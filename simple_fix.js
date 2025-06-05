/**
 * Simple database query to check if tokens are being saved properly
 */

import { db } from './server/db.ts';
import { coins } from './shared/schema.ts';

async function checkTokensInDatabase() {
  console.log('Checking tokens in database...');
  
  try {
    const allCoins = await db.select().from(coins);
    console.log(`Found ${allCoins.length} coins in database:`);
    
    for (const coin of allCoins) {
      console.log(`- ${coin.name} (${coin.symbol}) - Mint: ${coin.mint_address}`);
    }
    
    console.log('\nIf you see your tokens listed above, the issue is fixed!');
    console.log('The tokens will now be visible on the website.');
  } catch (error) {
    console.error('Error querying database:', error);
  }
}

checkTokensInDatabase().catch(console.error);