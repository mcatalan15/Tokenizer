// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Kicks42Token} from "../../code/src/Kicks42Token.sol";

contract DeployKicks42Token is Script {
    function run() external {
        vm.startBroadcast();  // uses PRIVATE_KEY from --private-key flag
        Kicks42Token token = new Kicks42Token();
        vm.stopBroadcast();

        // Log the address for console output
        console.log("Kicks42Token deployed at:", address(token));

        // Save the contract address to .env file
        updateEnvVariable("CONTRACT_ADDRESS", vm.toString(address(token)));
    }

    function updateEnvVariable(string memory key, string memory value) private {
        // Read current .env content
        string memory envContent;
        try vm.readFile(".env") returns (string memory content) {
            envContent = content;
        } catch {
            // If .env doesn't exist, create basic content
            envContent = "SEPOLIA_RPC_URL=https://ethereum-sepolia.publicnode.com\nPRIVATE_KEY=e44e2e740bcdeaad251ad696b3f21f3975bcfcfd4eba7aa3bc8c8c75fa18d5a9\nETHERSCAN_API_KEY=68VUWK5R8TFET3872ZCKR4MJMZVGU1YRPY\nWALLET_ADDRESS=0xd0Be4B40b5232852Af94F0d9B8D6d663ddDd590a";
        }

        // Use shell command to update the .env file properly
        // This removes any existing line with the key and adds the new one
        string[] memory cmd = new string[](3);
        cmd[0] = "bash";
        cmd[1] = "-c";
        cmd[2] = string(abi.encodePacked(
            "grep -v '^", key, "=' .env > .env.tmp && mv .env.tmp .env; ",
            "echo '", key, "=", value, "' >> .env"
        ));

        vm.ffi(cmd);
        console.log("Updated .env:", key, "=", value);
    }
}