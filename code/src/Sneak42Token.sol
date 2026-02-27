// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Sneak42Token
 * @dev Simple ERC-20 token for sneaker reselling loyalty points.
 * Fixed supply minted to deployer (owner). Ownable for potential transfers or renounces.
 * Security: Only owner can renounce; no additional minting to prevent inflation.
 */

contract Sneak42Token is ERC20, Ownable {
    uint public constant TOTAL_SUPPLY = 10_000_000 * 10**18; // 10M tokens, 18 decimals

    constructor() ERC20("Sneak42Token", "S42T") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY); // Mint all to deployer for controlled distribution
    }

    // Optional: Function to demostrate ownership (e.g., renounce for decentralization)
    function renounceOwnershipPublic() public onlyOwner {
        renounceOwnership();
    }
}