#!/usr/bin/env python3
"""
Test script for admin coin creation
This script demonstrates the admin-controlled coin generation system
"""

import os
import sys
import logging
from coin_manager import CoinManager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("test_admin_coin")

def main():
    print("============================================")
    print("  Mind9 Admin Coin Creation Test Script")
    print("============================================")
    print("This script tests the admin-controlled coin creation system")
    
    # Create a coin manager instance
    manager = CoinManager()
    
    # Test creating a new coin
    print("\n1. Creating a test coin...")
    
    test_coin = manager.admin_create_coin(
        name="Admin Test Coin",
        symbol="ATCOIN",
        description="A test coin created using the admin-controlled system",
        mint_address="AdminTestMintAddress123456789012345678901234567",
        total_supply="1,000,000"
    )
    
    if test_coin:
        print(f"✅ Coin created successfully:")
        print(f"   ID: {test_coin['id']}")
        print(f"   Name: {test_coin['name']}")
        print(f"   Symbol: {test_coin['symbol']}")
        print(f"   Mint Address: {test_coin['mint_address']}")
        print(f"   Minted: {test_coin['minted']}")
        print(f"   User Mintable: {test_coin['user_mintable']}")
        
        # Store the coin ID for further testing
        coin_id = test_coin['id']
        
        # Test marking as user-mintable
        print("\n2. Making the coin available to users...")
        if manager.make_coin_mintable(coin_id):
            print(f"✅ Coin ID {coin_id} is now available to users")
        else:
            print(f"❌ Failed to make coin ID {coin_id} available to users")
        
        # List all minted coins
        print("\n3. Listing all minted coins:")
        minted_coins = manager.get_all_minted_coins()
        
        if minted_coins:
            print(f"Found {len(minted_coins)} minted coins:")
            for coin in minted_coins:
                print(f"- {coin['name']} ({coin['symbol']})")
                print(f"  Mint Address: {coin['mint_address']}")
                print(f"  User Mintable: {'Yes' if coin['user_mintable'] else 'No'}")
        else:
            print("No minted coins found")
            
    else:
        print("❌ Failed to create test coin")
    
    print("\nTest completed.")

if __name__ == "__main__":
    main()