// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IArbSys {
    function sendTxToL1(address _l1Target, bytes memory _data) external;
}
