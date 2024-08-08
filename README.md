# DN420 🚀🌈

DN420 is a novel ERC20-ERC1155 dual standard chimera token 🦄, inspired by the innovative ERC404 standard! It combines the best of both worlds, offering fungible and non-fungible token functionality in a single smart contract. 🎭✨
Whenever a user's ERC20 balance is updated, the corresponding ERC1155 balance is updated as well and vice versa.

## Project Overview 📁

```
DN420/
├── src/
│   ├── DN420.sol         # Main contract implementing DN420 functionality
│   ├── ERC20.sol         # ERC20 implementation
│   ├── ERC1155.sol       # ERC1155 implementation
│   └── lib/
│       └── LibBitmap.sol # Bitmap library for efficient token ownership tracking
├── test/                 # Test files (to be implemented)
└── README.md             # You are here! 👋
```

## Use Cases 🌟

1. **Fractionalized NFTs** 🖼️💎: Create divisible ownership of unique assets
2. **Gamification** 🎮: Implement in-game currencies with collectible items
3. **Loyalty Programs** 🏆: Offer both points and exclusive rewards
4. **DeFi** 💰: Enable new types of collateralized lending and yield farming
5. **Digital Art** 🎨: Create limited edition artworks with tradable fractions

## Building and Testing 🛠️

This project uses Foundry for building and testing. Follow these steps to get started:

1. Install Foundry 🔧
   ```
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository 📥
   ```
   git clone git@github.com:us3r-network/dn420.git
   cd DN420
   ```

3. Install dependencies 📦
   ```
   forge install
   ```

4. Build the project 🏗️
   ```
   forge build
   ```

5. Run tests 🧪
   ```
   forge test
   ```

6. Deploy (when ready) 🚀
   ```
   forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/DN420.sol:DN420
   ```

Happy coding! 🎉👨‍💻👩‍💻