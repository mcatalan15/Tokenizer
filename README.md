# Kicks42Token - Tokenizer Project
This project implements a simple ERC-20 token called Kicks42Token (ticker:K42T) as part of the 42/BNB Chain Tokenizer project. The token represents a loyalty points system for a sneakers reselling community, rewarding members for activities like trades, listings, and referrals. Points can be redeemed for perks such as priority acces to drops or fee discounts. The implementation uses a fixed supply of 10,000,000 tokens, all minted to the deployer upon creation for controlled distribution.

## Choices and Reasons
- **Token Name and Ticker:** Kicks42Token (K42T).
Reason: The name includes "42" as required by the project constraints. The theme is inspired by a sneakers reselling community, making it relatable. The ticker K42T is short, memorable, and incorporates "42".

- **Blockchain Platform and Network:** Ethereum Sepolia testnet (Chain ID: 11155111).
Reason: Sepolia is a stable, public Ethereum testnet that supports ERC-20 tokens without real money. It was chosen over BSC testnet for broader compatibility with Ethereum tools and standards, allowing easier learning of public blockchain technology. No real money is used, alliging with the project's safety rule to use test chains.

- **Token Standard:** ERC-20.
Reason: ERC-20 is the standard for fungible tokens on Ethereum, as mentioned in the project (e.g., ERC20 for ETH). It provides basic functionality like transfer, balanceOf, and totalSupply without complexity, fitting the mandatory part's simple requirements.

- **Supply and Minting Mechanisms:** Fixed supply of 10,000,000 tokens, all minted to the deployer in the constructor.
Reason: A fixed supply prevents inflation and ensures scarcity, suitable for a loyalty points system where points are distributed by the community admin (deployer). Minting only on deployment avoids ongoing mint privilages, enhancing security and aligning with the project's emphasis on ownership and privileges.

- **Programming Lenguage and Tools:** Solidity ^0.8.20 with Foundry (forge, cast, anvil) for development, testing, and deployment; OpenZeppelin for ERC-20 and Ownable bases: Docker (Alpine-based container) for reproducible environment; docker-compose and Makefile for automation.
Reason: Solidity is the standard for Ethereum smart contracts. Foundry is a modern, efficient alternative to Hardhat or Remix, offering fast testing and scripting all written in Solidity. OpenZeppelin provides secure, audited implementations. Docker ensures consistency across machines, teching DevOps alongside blockchain. Makefile simplifies commands, making the prokect easy to run and evaluate. This stack respects the project's language freedom and tool examples (IDE, Truffle, Remix, Hardhat) while pushing learning out of the comfort zone.

- **Security Considerations:** Inherited Ownable for ownership control (deployer initially owns, can renounce for decentralization).
No post-deployment minting or burning to prevent abuse. Code is commented with readable names. Tests Cover basic functions and ownership.
Reason: The project requires thinking about security, ownership, and privileges. Ownable demostrates privileges (e.g., renounceOwnershipPublic). Fixed mint reduces vulnerabilities like unauthorized supply increase. This keeps the token safe for demo purposes withput complex features.

## Deployed Contract
- Network: Sepolia (Chain ID: 11155111)
- Contract Address: 0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc
- Transaction Hash: 0x934fc05d4f214d154594a5b9ff2ef0c1f2c72219873ed44f7e5a83d9b44edd06
- Explorer: https://sepolia.etherscan.io/address/0xB2E3C1A70FbdDF0CE253aD335072b85fEA3FBdDc
- Verified: Yes (source code is public on Etherscan)

The contract was deployed using Foundry scripts and verified on Etherscan. For details on how to interact with it, see [Usage Guide](documentation/usage.md).






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
