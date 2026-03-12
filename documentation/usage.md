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
### Sepolia Deployment

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

## Minimalist Demo Actions
Use Foundry's `cast` tool (inside container) to interact with the deployment contract.
- **Check Total Suply:**
```bash
cast call 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc "totalSupply()(uint256)" --rpc-url $SEPOLIA_RPC_URL
```
- **Check Balance:**
```bash
cast call 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc "balanceOf(address)(uint256)" 0xd0Be4B40b5232852Af94F0d9B8D6d663ddDd590a --rpc-url $SEPOLIA_RPC_URL
```
- **Transfer Tokens (from deployer):**
```bash
cast send 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc "transfer(address,uint256)" 0xRecipientAddress 1000000000000000000000 --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL
```
- **Check Ownership:**
```bash
cast call 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc "owner()(address)" --rpc-url $SEPOLIA_RPC_URL
```
- **Renounce Ownership (demostrates privileges; irreversible):**
```bash
cast call 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc "owner()(address)" --rpc-url $SEPOLIA_RPC_URL
```
These actions demostrate the token's operation, security aspects, and compliance with project requirements.

### 🚀 Container Management

| Command | Description |
|---------|-------------|
| `make build` | Build the Docker image for the project |
| `make up` | Start the container in detached mode |
| `make shell` | Connect to the running container (bash) |
| `make down` | Stop and remove containers |
| `make logs` | Show container logs |

### 📦 Dependency Management

| Command | Description |
|---------|-------------|
| `make install-deps` | Install OpenZeppelin contracts |
| `make exec CMD="command"` | Execute a custom command in the container |

### 🔨 Development

| Command | Description |
|---------|-------------|
| `make build-contracts` | Compile smart contracts |
| `make test` | Run tests with verbose output |

### 🌐 Deployment and Verification

| Command | Description |
|---------|-------------|
| `make deploy-sepolia` | Deploy contract to Sepolia and update .env |
| `make get-address` | Get the last deployed contract address |
| `make status` | Show contract status from .env |
| `make verify ADDRESS=0x...` | Verify a specific contract on Etherscan |
| `make verify-last` | Automatically verify the last deployed contract |

### 🧹 Cleanup

| Command | Description |
|---------|-------------|
| `make clean` | Stop and remove containers |
| `make fclean` | Full cleanup (containers, images, and volumes) |
| `make re` | Rebuild from scratch (fclean + build + up) |

## Usage Guide









## Project Structure

```
Tokenizer/
├── Makefile                 # Project management commands
├── docker-compose.yml      # Docker configuration
├── Dockerfile              # Development container image
├── .env                     # Environment variables (not included in Git)
├── README.md               # This file
├── code/
│   ├── src/
│   │   └── Kicks42Token.sol # Main smart contract
│   └── tests/
│       └── Kicks42Token.t.sol # Contract tests
├── deployment/
│   └── script/
│       └── DeployKicks42Token.s.sol # Deployment script
└── broadcast/               # Deployment history (auto-generated)
```

## Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# Required for deployment
PRIVATE_KEY=your_ethereum_private_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key

# Auto-generated by deployment
CONTRACT_ADDRESS=deployed_contract_address
```

## Important Notes

- The `.env` file must be configured before deployment
- The project uses Sepolia testnet by default
- Contract addresses are automatically stored in `.env`
- Deployment logs are saved in the `broadcast/` directory
- All commands run inside Docker containers for consistency
- The Makefile provides a complete workflow from development to deployment

## Quick Start

```bash
# 1. Setup environment
make build && make up

# 2. Install dependencies
make install-deps

# 3. Build and test
make build-contracts && make test

# 4. Deploy to Sepolia (ensure .env is configured)
make deploy-sepolia

# 5. Verify on Etherscan
make verify-last
```

## Troubleshooting

- **Container issues**: Try `make re` to rebuild from scratch
- **Deployment failures**: Check your `.env` configuration
- **Test failures**: Use `make shell` to debug inside the container
- **Verification issues**: Ensure your Etherscan API key is valid

