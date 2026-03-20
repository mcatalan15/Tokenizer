# Kicks42Token Usage Guide

## How It Works

Kicks42Token is a standard ERC-20 token deployed on the Ethereum Sepolia testnet. It represents loyalty points in a sneaker reselling community:
- **Purpose:** Reward users for community activites (trades, listings, referrals).
- **Redemption:** Points can be used for perks like priority drops or fee discounts.
- **Supply:** Fixed 10,000,000 tokens with 18 decimals. All tokens are minted to the deployer upon creation for controlled distribution (e.g., airdrops to community members).
- **Functions:** Standard ERC-20 (totalSupply, balanceOf, transfer, approve, transferFrom) + Ownable (owner, renounceOwnershipPublic).
- **Security Notes:**
    - Ownership: Deployer initially owns the contract and can renounce ownership for decentralization.
    - Privileges: No minting or burning after deployment to prevent inflation or destruction.
    - Vulnerabilities: Inherited from OpenZeppelin (audited); no reentrancy risks in basic use. Always use testnet; audit for production.
    - Deployment: Contract is immutable post-deploy.

## Requitements
- Foundry installed (or use the Docker container in this repo).
- Sepolia test ETH (from faucets like Alchemy or Chainlink).
- Environment variables in `.env` (see `deployment/.env.example`): PRIVATE_KEY, SEPOLIA_RPC_URL, ETHERSCAN_API_KEY.

## Project Structure

```bash
Tokenizer/
├── bonus/
│   ├── script/
│   │   └── DeployWithMultisig.s.sol    # Bonus deployment (Token + Multisig)
│   └── src/
│       └── Multisig.sol                # 2-of-3 Multisig contract
├── code/
│   ├── src/
│   │   └── Kicks42Token.sol            # Main ERC-20 token
│   └── tests/
│       └── Kicks42Token.t.sol          # Unit tests
├── deployment/
│   └── script/
│       └── DeployKicks42Token.s.sol    # Mandatory deployment script
├── documentation/
│   ├── usage.md
│   └── whitepaper.md
├── Makefile                            # Project management commands
├── docker-compose.yml                  # Docker configuration
├── Dockerfile                          # Development container image
├── foundry.toml                        # Foundry config file
└── README.md
```

## Setup & Development

### Initial Setup

1. **Clone and navigate to project:**
    ```bash
    cd ~/Tokenizer
    ```

2. **Configure environment variables:**
    ```bash
    # Create .env file
    PRIVATE_KEY=your_private_key_here
    SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_infura_key
    ETHERSCAN_API_KEY=your_etherscan_api_key
    ```

3. **Build and start environment:**
    ```bash
    make build
    make up
    ```

### Development Workflow

1. **Install dependencies:**
    ```bash
    make install-deps
    ```

2. **Develop and compile contracts:**
    ```bash
    make build-contracts
    ```

3. **Run tests:**
    ```bash
    make test
    ```

4. **Connect to container for development:**
    ```bash
    make shell
    ```
### Mandatory Deployment

1. **Deploy contract:**
    ```bash
    make deploy-sepolia
    ```
    This command:
    - Deploys the contract to Sepolia
    - Automatically updates the `.env` file with the contract address
    - Shows the Etherscan link

2. **Check contract status:**
    ```bash
    make status
    ```

3. **Verify on Etherscan:**
    ```bash
    # Verify the last deployed contract
    make verify-last

    # Or verify a specific contract
    make verify ADDRESS=0x435767284620b56ae037d8a9c4a9cccb882bd7aa
    ```

### Bonus: Multisignature System (2-of-3)

After running `make deploy-bonus`, the token ownership is transferred to the Multisig contract. No single person can perform privileged actions anymore.

#### Demo Commands (Multisig)

```bash
# 1. Submit a transaction (example: renounce ownership)
cast send $MULTISIG_ADDRESS "submitTransaction(address,uint256,bytes)" \
  $CONTRACT_ADDRESS 0 "0x715018a6" \
  --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL

# 2. Second owner confirms (repeat with another private key)
cast send $MULTISIG_ADDRESS "confirmTransaction(uint256)" <TX_ID> \
  --private-key $PRIVATE_KEY2 --rpc-url $SEPOLIA_RPC_URL
```

Once 2 owners confirm, the transaction executes automatically.

### Utility Commands

- **View logs in real-time:**
    ```bash
    make logs
    ```

- **Get contract address:**
    ```bash
    make get-address
    ```

- **Execute custom command:**
    ```bash
    make exec CMD="forge --version"
    ```

### Cleanup and Maintenance

- **Basic cleanup:**
    ```bash
    make clean
    ```

- **Full cleanup:**
    ```bash
    make fclean
    ```

- **Rebuild from scratch: fclean + build + up**
    ```bash
    make re
    ```

## Mandatory Demo Actions (No needed if using Make)
Use Foundry's `cast` tool (inside container) to interact with the deployment contract.
- **Check Total Suply:**
    ```bash
    cast call $CONTRACT_ADDRESS "totalSupply()(uint256)" --rpc-url $SEPOLIA_RPC_URL
    ```
- **Check Balance:**
    ```bash
    cast call $CONTRACT_ADDRESS "balanceOf(address)(uint256)" 0xd0Be4B40b5232852Af94F0d9B8D6d663ddDd590a --rpc-url $SEPOLIA_RPC_URL
    ```
- **Transfer Tokens (from deployer):**
    ```bash
    cast send $CONTRACT_ADDRESS "transfer(address,uint256)" 0xRecipientAddress 1000000000000000000000 --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL
    ```
- **Check Ownership:**
    ```bash
    cast call $CONTRACT_ADDRESS "owner()(address)" --rpc-url $SEPOLIA_RPC_URL
    ```
- **Renounce Ownership (demostrates privileges; irreversible):**
    ```bash
    cast call $CONTRACT_ADDRESS "owner()(address)" --rpc-url $SEPOLIA_RPC_URL
    ```
