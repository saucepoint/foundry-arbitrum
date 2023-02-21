// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title ArbSysMock
/// @notice a mocked version of the Arbitrum system contract, add additional methods as needed
contract ArbSysMock {
    function sendTxToL1(address _l1Target, bytes memory _data) external {
        (bool success,) = _l1Target.call(_data);
        require(success, "Arbsys: sendTxToL1 failed");
    }
}
