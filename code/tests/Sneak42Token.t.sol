// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Sneak42Token} from "src/Sneak42Token.sol";

contract Sneak42TokenTest is Test {
    Sneak42Token token;
    address owner = address(this);
    address user1 = makeAddr("user1");

    function setUp() public {
        token = new Sneak42Token();
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), token.TOTAL_SUPPLY());
        assertEq(token.balanceOf(owner), token.TOTAL_SUPPLY());
    }

    function testTransfer() public {
        uint256 amount = 1000 * 10**18;
        console.log("Owner balance before transfer:", token.balanceOf(owner) / 1e18, "tokens");
        bool success = token.transfer(user1, amount);
        require(success, "Transfer failed");
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), token.TOTAL_SUPPLY() - amount);
    }

    function testOwnership() public {
        assertEq(token.owner(), owner);
        token.renounceOwnershipPublic();
        assertEq(token.owner(), address(0));
    }
}