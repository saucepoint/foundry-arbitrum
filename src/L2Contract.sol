// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract L2Contract {
    uint256 public numberFromL1;

    function handleMessageFromL1(uint256 number) external {
        // Do something with the number
        numberFromL1 = number;
    }
}
