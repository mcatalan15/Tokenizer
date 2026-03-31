# Code Explanation: Kicks42Token & Multisig System

## 1. Configuration (foundry.toml)

**Key settings:**
- `src = 'code/src'` - Smart contract source location
- `remappings` - Import shortcuts (e.g., `@openzeppelin/contracts`)
- `ffi = true` - Allow shell commands from scripts
- `fs_permissions` - Scripts can read/write `.env` file
- `optimizer = true` - Gas optimization enabled

**Why FFI & fs_permissions?** Deployment scripts save contract addresses to `.env` for future use.

---

## 2. MANDATORY PART: Token Creation

### 2.1 Kicks42Token Contract (`code/src/Kicks42Token.sol`)

```solidity
contract Kicks42Token is ERC20, Ownable {
    uint public constant TOTAL_SUPPLY = 10_000_000 * 10**18;

    constructor() ERC20("Kicks42Token", "K42T") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);  // Deployer gets all 10M tokens
    }
}
```

**What it does:**
- Inherits ERC20 (standard token) + Ownable (access control)
- Creates 10M tokens, mints all to deployer
- Owner can call `renounceOwnershipPublic()` to make token truly decentralized

**Why this structure?**
- ERC20: All wallets/exchanges recognize it
- Ownable: Control who can make critical changes
- Fixed supply: No inflation, transparent

---

### 2.2 Deployment Script (`deployment/script/DeployKicks42Token.s.sol`)

```solidity
function run() external {
    vm.startBroadcast();
    Kicks42Token token = new Kicks42Token();
    vm.stopBroadcast();

    console.log("Deployed at:", address(token));
    updateEnvVariable("CONTRACT_ADDRESS", vm.toString(address(token)));
}
```

**What it does:**
1. Creates token contract on Sepolia
2. Saves contract address to `.env` via shell command
3. Makes address available for later scripts

---

### 2.3 Token Tests (`code/tests/Kicks42Token.t.sol`)

Tests verify:
- Initial supply = 10M tokens owned by deployer
- Transfers work correctly (balance changes)
- Ownership renouncement works

---

## 3. BONUS PART: Multisig Governance

### 3.1 Multisig Contract (`bonus/src/Multisig.sol`)

**State:**
```solidity
address[] public owners;              // List of signers
uint256 public requiredSignatures;    // How many approvals needed (e.g., 2/3)
mapping(uint => mapping(address => bool)) public confirmations;  // Who voted yes
Transaction[] public transactions;    // Stored proposals
```

**Key functions:**

```solidity
// Owner1 proposes a transaction
function submitTransaction(address dest, uint value, bytes data)
    external onlyOwner returns(uint txId)
    // Stores proposal + Owner1 auto-votes YES
    // Returns transaction ID

// Owner2 confirms the transaction
function confirmTransaction(uint txId) public onlyOwner
    // Owner2 votes YES
    // If threshold reached (e.g., 2/2): AUTO-EXECUTE

// Internal: Execute the stored call
function executeTransaction(uint txId) internal
    // destination.call{value}(data)
    // Example: Token.transfer(recipient, amount)
```

**Why multisig?**
- Single owner risk: One compromised key = all tokens lost
- Multisig safety: Need 2+ approvals for any action
- Consensus-based governance

---

### 3.2 Multisig Deployment (`bonus/script/DeployWithMultisig.s.sol`)

```solidity
// Create 2/2 multisig
address[] owners = [msg.sender, 0xbe462fD16...];
Multisig multisig = new Multisig(owners, 2);

// Deploy token
Kicks42Token token = new Kicks42Token();

// CRITICAL: Transfer ownership to multisig
token.transferOwnership(address(multisig));

// Save both addresses
updateEnvVariable("TOKEN_ADDRESS", address(token));
updateEnvVariable("MULTISIG_ADDRESS", address(multisig));
```

**Why transfer ownership?**
- Before: Deployer alone can control token (risky)
- After: Only Multisig can control token
- Result: Need 2/2 approvals for any owner action

---

### 3.3 Multisig Tests (`bonus/tests/MultisigBonus.t.sol`)

Tests 2/3 multisig (2 out of 3 owners needed):
1. Owner1 submits renounceOwnership proposal → 1/2 approvals
2. Verify transaction not executed yet
3. Owner2 confirms → 2/2 approvals → AUTO-EXECUTE
4. Verify execution succeeded + ownership gone

---

## 4. Deployment Workflow

```
make deploy-mandatory
  └─ Runs DeployKicks42Token script
  └─ Saves CONTRACT_ADDRESS to .env
  └─> Token deployed, deployer owns it

make deploy-bonus
  └─ Runs DeployWithMultisig script
  └─ Saves TOKEN_ADDRESS + MULTISIG_ADDRESS to .env
  └─> Token + Multisig deployed, Multisig owns token

make transfer-bonus
  └─ Owner1: submitTransaction(transfer 500 K42T)
  └─ Owner2: confirmTransaction → triggers execution
  └─> Tokens transferred via multisig
```

---

## 5. Security Model

| Aspect | Mandatory | Bonus |
|--------|-----------|-------|
| Owner | Single deployer | Multisig (2/2 or 2/3) |
| Risk | One key stolen = all lost | Need 2+ keys stolen |
| Control | Single person decides | Consensus required |
| Governance | Centralized | Decentralized |

---

## Key Files

| File | Purpose |
|------|---------|
| `code/src/Kicks42Token.sol` | Token contract (10M supply, ERC20 standard) |
| `deployment/script/DeployKicks42Token.s.sol` | Deploy token + save address |
| `promotion/src/Multisig.sol` | Multi-signature wallet |
| `bonus/script/DeployWithMultisig.s.sol` | Deploy multisig + token, transfer ownership |
| `.env` | Stores deployed contract addresses |
| `Makefile` | Automation for deployment, transfer, tests |

---

## Technical Highlights

**FFI (Foreign Function Interface):**
- Allows Solidity scripts to run shell commands
- Used to update `.env` file with new contract addresses
- Only enabled for testnet (security measure)

**Address Saving:**
```bash
# Shell command via FFI in deployment script
grep -v '^CONTRACT_ADDRESS=' .env > .env.tmp && \
mv .env.tmp .env && \
echo 'CONTRACT_ADDRESS=0x...' >> .env
```
- Removes old value (if exists)
- Appends new value
- Result: Single updated entry

**Multisig Execution:**
```solidity
(bool success, ) = txToExec.destination.call{value: txToExec.value}(txToExec.data);
// Calls Token.transfer() from Multisig smart contract
// msg.sender = Multisig contract (not original owner)
```

---

## Testing Checklist

- ✅ Token: Initial supply correct
- ✅ Token: Transfers work
- ✅ Token: Ownership renouncement works
- ✅ Multisig: Execution requires 2/3 approvals
- ✅ Multisig: Can't execute twice
- ✅ Multisig: Ownership transfer to Multisig works
