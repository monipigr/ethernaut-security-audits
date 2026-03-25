// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    // @audit transfer is deprecated
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // @audit ownership can be stolen sending ETH
    // @audit receive function should not include bussiness logic
    // q can receive function have an access control
    // q can anyone take control of the contract just by sending some ether
    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}
