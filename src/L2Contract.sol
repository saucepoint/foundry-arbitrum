// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {L1Contract} from "./L1Contract.sol";
import {IArbSys} from "./interfaces/IArbSys.sol";

contract L2Contract {
    uint256 public numberFromL1;
    address public l1Target;

    IArbSys constant arbsys = IArbSys(address(0x0000000000000000000000000000000000000064));

    /// @notice Handle a message from the L1 contract
    /// @dev TODO: Add a modifier to ensure that this function can only be called by the L1 contract
    /// @param number The number to handle
    function handleMessageFromL1(uint256 number) external {
        // Do something with the number
        numberFromL1 = number;
    }

    function createL1Message(uint256 number) external {
        bytes memory data = abi.encodeWithSelector(L1Contract.handleMessageFromL2.selector, number);
        arbsys.sendTxToL1(l1Target, data);
    }

    function setL1Target(address _l1Target) external {
        l1Target = _l1Target;
    }
}
