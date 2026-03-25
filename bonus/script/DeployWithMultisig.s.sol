// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Kicks42Token} from "src/Kicks42Token.sol";
import {Multisig} from "bonus/Multisig.sol";

contract DeployWithMultisig is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Deploy Multisig (2-of-3)
        address[] memory owners = new address[](3);
        owners[0] = msg.sender;
        owners[1] = makeAddr("owner2");
        owners[2] = makeAddr("owner3");
        Multisig multisig = new Multisig(owners, 2);

        // 2. Deploy Token (mandatory contract)
        Kicks42Token token = new Kicks42Token();

        // 3. Transfer ownership to Multisig (bonus security)
        token.transferOwnership(address(multisig));

        vm.stopBroadcast();

        console.log("=== BONUS DEPLOYMENT SUCCESS ===");
        console.log("Kicks42Token:", address(token));
        console.log("Multisig (2/3):", address(multisig));
        console.log("Ownership transferred to Multisig");

        // Save addresses to .env file for verification and future use
        updateEnvVariable("TOKEN_ADDRESS", vm.toString(address(token)));
        updateEnvVariable("MULTISIG_ADDRESS", vm.toString(address(multisig)));
        // Also save CONTRACT_ADDRESS for consistency with mandatory deployment
        updateEnvVariable("CONTRACT_ADDRESS", vm.toString(address(token)));
    }

    function updateEnvVariable(string memory key, string memory value) private {
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