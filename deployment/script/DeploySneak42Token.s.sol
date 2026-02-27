// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../code/src/Sneak42Token.sol";

contract DeploySneak42Token is Script {
    function run() external {
        vm.startBroadcast();  // uses PRIVATE_KEY from --private-key flag
        Sneak42Token token = new Sneak42Token();
        vm.stopBroadcast();

        // Optional: log the address so it's easy to see
        console.log("Sneak42Token deployed at:", address(token));
    }
}