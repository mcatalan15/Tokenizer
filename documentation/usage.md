# Kicks42Token Usage Guide

## 📚 Documentation Navigation

**New to the project?**
- Start here: [Theory Explanation](theory_explanation.md) – Learn what ERC-20 and Multisig are
- Then read: [Code Explanation](../code_explanation.md) – Understand how the code works

**Just want to deploy?**
- Follow this guide!

---

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
    make deploy-mandatory
    ```
    This command:
    - Deploys the Kicks42Token to Sepolia testnet
    - Automatically updates the `.env` file with `CONTRACT_ADDRESS`
    - Shows the contract address in console

2. **Check contract status:**
    ```bash
    make status
    ```
    Shows all saved contract addresses in `.env`

3. **Transfer tokens (optional):**
    ```bash
    make transfer-mandatory
    ```
    Transfer 500 K42T from deployer to `WALLET_RECEIVER` (set this in `.env` first)

4. **Verify on Etherscan:**
    ```bash
    # Verify the mandatory contract
    make verify-mandatory

    # Or verify a specific contract by address
    make verify ADDRESS=0x435767284620b56ae037d8a9c4a9cccb882bd7aa PATH=code/src/Kicks42Token.sol NAME=Kicks42Token
    ```

### Bonus: Multisignature System (2/2)

After running `make deploy-bonus`, the token ownership is transferred to the Multisig contract. No single person can perform privileged actions anymore.

**Not familiar with Multisig?** → [Read Theory Explanation](theory_explanation.md#part-2-what-is-a-multisig-multisignature-wallet)

#### Setup

1. **Deploy Token + Multisig:**
    ```bash
    make deploy-bonus
    ```
    This command:
    - Deploys 2/2 Multisig contract
    - Deploys Kicks42Token
    - Transfers token ownership to Multisig
    - Saves both `TOKEN_ADDRESS` and `MULTISIG_ADDRESS` to `.env`

2. **Fund the Multisig (optional):**
    ```bash
    make fund-multisig
    ```
    Transfer 1000 K42T from deployer to Multisig wallet

#### Execute a Multisig Transaction

The complete 2-step flow to transfer tokens via Multisig:

```bash
# Step 1 & 2 automated (both owners with private keys):
make transfer-bonus
```

This runs both owner approvals and executes automatically.

**Manual control** (if you need to execute steps separately):

```bash
# Step 1: Owner1 (Deployer) submits transaction
make submit-bonus

# Step 2: Owner2 confirms with their private key
make confirm-bonus TX_ID=0
```

#### Raw `cast` Commands (Advanced)

If you prefer direct control:

```bash
# Submit a transaction (example: renounce ownership)
cast send $MULTISIG_ADDRESS "submitTransaction(address,uint256,bytes)" \
  $TOKEN_ADDRESS 0 \
  $(cast calldata "renounceOwnershipPublic()") \
  --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL

# Confirm the transaction (with second owner's key)
cast send $MULTISIG_ADDRESS "confirmTransaction(uint256)" 0 \
  --private-key $SECOND_PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL
```

#### Testing Multisig Locally

```bash
make test-bonus
```

This runs tests that verify:
- Multisig requires 2/3 approvals
- Execution happens automatically at threshold
- Owners can vote

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

---

## 📚 Learn More

| Topic | File | Description |
|-------|------|-------------|
| **Concepts** | [theory_explanation.md](theory_explanation.md) | What is ERC-20? What is Multisig? Real examples |
| **Code Details** | [../code_explanation.md](../code_explanation.md) | How each function works, line-by-line breakdown |
| **Project Vision** | [whitepaper.md](whitepaper.md) | Why this project exists, use cases |
| **Deployment** | This file (usage.md) | Step-by-step commands to deploy |

---

## Quick Command Reference

| Task | Command |
|------|---------|
| Build & Start | `make build && make up` |
| Install tools | `make install-deps` |
| Compile contracts | `make build-contracts` |
| Run tests | `make test` |
| Deploy token | `make deploy-mandatory` |
| Deploy with Multisig | `make deploy-bonus` |
| Transfer tokens directly | `make transfer-mandatory` |
| Transfer via Multisig | `make transfer-bonus` |
| Test Multisig | `make test-bonus` |
| Check status | `make status` |
| Verify contracts | `make verify-mandatory` or `make verify-bonus` |
| Shell access | `make shell` |
| Cleanup | `make clean` or `make fclean` |
