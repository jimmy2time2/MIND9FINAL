/**
 * Solana Token Verification Tool
 * This script verifies that a token exists on the Solana blockchain
 * and retrieves its metadata
 */

import { Connection, PublicKey } from '@solana/web3.js';
import { TOKEN_PROGRAM_ID, getAccount, getAssociatedTokenAddress } from '@solana/spl-token';
import dotenv from 'dotenv';

// Read environment variables
dotenv.config();

const RPC_ENDPOINT = process.env.RPC_ENDPOINT || 'https://api.mainnet-beta.solana.com';
const CREATOR_WALLET_ADDRESS = process.env.CREATOR_WALLET_ADDRESS;

if (!CREATOR_WALLET_ADDRESS) {
  console.error('ERROR: Missing required environment variable CREATOR_WALLET_ADDRESS');
  process.exit(1);
}

// Create connection to Solana
const connection = new Connection(RPC_ENDPOINT, 'confirmed');

/**
 * Verify token existence and metadata on Solana
 * @param {string} mintAddress - The mint address to verify
 */
async function verifyToken(mintAddress) {
  try {
    console.log(`Verifying token with mint address: ${mintAddress}`);
    console.log(`Using RPC endpoint: ${RPC_ENDPOINT}`);
    
    // Verify the mint address is valid
    const mintPublicKey = new PublicKey(mintAddress);
    
    // Check if the token account exists on Solana
    console.log('Getting mint account info...');
    const mintAccountInfo = await connection.getAccountInfo(mintPublicKey);
    
    if (!mintAccountInfo) {
      console.error('❌ ERROR: Mint account not found on Solana!');
      return false;
    }
    
    console.log('✅ Mint account exists on Solana');
    console.log(`Account owner: ${mintAccountInfo.owner.toString()}`);
    console.log(`Account size: ${mintAccountInfo.data.length} bytes`);
    
    // Verify the mint account is owned by the SPL Token program
    if (!mintAccountInfo.owner.equals(TOKEN_PROGRAM_ID)) {
      console.error('❌ ERROR: Mint account is not owned by the SPL Token program!');
      return false;
    }
    
    console.log('✅ Mint account is a valid SPL token');
    
    // Get creator's token account for this mint
    const creatorPublicKey = new PublicKey(CREATOR_WALLET_ADDRESS);
    const creatorTokenAccount = await getAssociatedTokenAddress(
      mintPublicKey,
      creatorPublicKey
    );
    
    console.log(`Creator token account: ${creatorTokenAccount.toString()}`);
    
    // Get token holdings for creator
    try {
      const tokenAccount = await getAccount(connection, creatorTokenAccount);
      
      const amount = Number(tokenAccount.amount);
      console.log(`✅ Creator has ${amount} tokens`);
      
      return {
        verified: true,
        mintAddress,
        creatorBalance: amount,
        decimals: tokenAccount.decimals
      };
    } catch (err) {
      console.error(`❌ ERROR: Could not get creator token account: ${err.message}`);
      return {
        verified: false,
        error: err.message
      };
    }
  } catch (error) {
    console.error('Error verifying token:', error);
    return {
      verified: false,
      error: error.message
    };
  }
}

// If file is run directly (as a script)
if (import.meta.url === `file://${process.argv[1]}`) {
  const mintAddress = process.argv[2];
  
  if (!mintAddress) {
    console.error('Usage: node verify_token.js <mint_address>');
    process.exit(1);
  }
  
  verifyToken(mintAddress)
    .then(result => {
      if (result.verified) {
        console.log('✅ Token verified successfully!');
        console.log(JSON.stringify(result, null, 2));
        process.exit(0);
      } else {
        console.error('❌ Token verification failed!');
        console.error(result.error);
        process.exit(1);
      }
    })
    .catch(err => {
      console.error('Error running verification:', err);
      process.exit(1);
    });
}

// ES Module export
export { verifyToken };