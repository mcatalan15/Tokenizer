// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Kicks42Token} from "../../code/src/Kicks42Token.sol";
import {Multisig} from "../src/Multisig.sol";

contract MultisigBonusTest is Test {
    Kicks42Token public token;
    Multisig public multisig;
    
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    address owner3 = address(0x3);
    address[] owners;

    function setUp() public {
        owners = [owner1, owner2, owner3];
        // 1. Deploy Multisig (2/3)
        multisig = new Multisig(owners, 2);
        // 2. Deploy Token
        token = new Kicks42Token();
        // 3. Transfer ownership to Multisig
        token.transferOwnership(address(multisig));
    }

    function test_MultisigCanRenounceOwnership() public {
        // Prepare the call: renounceOwnershipPublic()
        bytes memory data = abi.encodeWithSignature("renounceOwnershipPublic()");

        // Owner 1 submits (this also auto-confirms in your Multisig.sol)
        vm.prank(owner1);
        uint256 txId = multisig.submitTransaction(address(token), 0, data);

        // Verify it is NOT executed yet (needs 2nd sig)
        (,,,bool executed) = multisig.transactions(txId);
        assertEq(executed, false);
        assertEq(token.owner(), address(multisig));

        // Owner 2 confirms (this should trigger execution)
        vm.prank(owner2);
        multisig.confirmTransaction(txId);

        // Verify success!
        (,,,executed) = multisig.transactions(txId);
        assertEq(executed, true);
        assertEq(token.owner(), address(0)); // Ownership successfully renounced
        console.log("Multisig successfully renounced token ownership!");
    }
}