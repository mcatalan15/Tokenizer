# Kicks42Token - Tokenizer Project

**ERC-20 loyalty points token for a sneaker reselling community**, built as part of the **42 / BNB Chain Tokenizer** exercise.

The token rewards community members for trades, listings, and referrals. Points can later be redeemed for priority drops, fee discounts, and other perks.

---

## Choices and Reasons

- **Token Name & Ticker**: `Kicks42Token` (K42T)  
  Reason: Must contain "42" per project rules. Theme is sneaker reselling community — clean, relevant, and non-insulting.

- **Blockchain & Network**: Ethereum Sepolia testnet (Chain ID 11155111)  
  Reason: Stable public testnet, no real money required, excellent tool support.

- **Standard**: ERC-20 (using OpenZeppelin)  
  Reason: Standard for fungible tokens, matches project requirements.

- **Supply**: Fixed 10,000,000 tokens (all minted to deployer on creation)  
  Reason: Prevents inflation and gives full control over distribution.

- **Tools & Stack**: Solidity ^0.8.20 + **Foundry** (forge, cast, anvil) + Docker (Alpine) + Makefile + docker-compose  
  Reason: Modern, fast, and powerful development environment. Teaches real-world blockchain workflows.

- **Security**: Ownable + full test coverage  
  Reason: Demonstrates ownership, privileges, and secure coding practices required by the subject.

### Bonus Feature (Multisig)
- Added a **2-of-3 Multisig** contract.
- Token ownership is automatically transferred to the multisig after deployment.
- No single person can perform privileged actions anymore — real extra security layer.

---

## Deployed Contracts (Sepolia)

**Mandatory Token**  
- Address: `0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc`  
- Explorer: [https://sepolia.etherscan.io/address/0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc](https://sepolia.etherscan.io/address/0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc)  
- Verified: Yes

**Bonus – Multisig (2/3)**  
- Address: `[Will appear after running `make deploy-bonus`]`  
- Controls the token ownership

---

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

---

## Quick Start

```bash
make build && make up
make install-deps
make test
make deploy-bonus          # Full version (mandatory + bonus)
make verify-bonus
```

---

## Documentation

- **[Usage Guide](documentation/usage.md)** – Full commands, demos, and multisig usage
- **[Whitepaper](documentation/whitepaper.md)** – Project explanation and vision

---

**Made with ❤️ using Solidity, Foundry, Docker & OpenZeppelin**  
42 School × BNB Chain Tokenizer Project
