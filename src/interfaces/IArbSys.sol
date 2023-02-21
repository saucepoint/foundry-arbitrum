// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title IArbSys
/// @dev a minimum interface for the Arbitrum system contract, add additional methods as needed
interface IArbSys {
    function sendTxToL1(address _l1Target, bytes memory _data) external;
}
