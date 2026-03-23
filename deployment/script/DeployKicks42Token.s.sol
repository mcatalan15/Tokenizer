// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Kicks42Token} from "../../code/src/Kicks42Token.sol";

contract DeployKicks42Token is Script {
    function run() external {
        vm.startBroadcast();  // uses PRIVATE_KEY from --private-key flag
        Kicks42Token token = new Kicks42Token();
        vm.stopBroadcast();

        // Optional: log the address so it's easy to see
        console.log("Kicks42Token deployed at:", address(token));
    }
}