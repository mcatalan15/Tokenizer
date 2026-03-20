// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Kicks42Token} from "src/Kicks42Token.sol";
import {Multisig} from "bonus/src/Multisig.sol";

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
    }
}