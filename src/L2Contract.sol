// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {L1Contract} from "./L1Contract.sol";
import {IArbSys} from "./interfaces/IArbSys.sol";

/// @title L2Contract
/// @notice An example L2 contract that interacts with an L1 contract (sends & receives messages)
/// @author saucepoint
contract L2Contract {
    // A number set by an L1-to-L2 message
    uint256 public numberFromL1;

    // Address of the L1 contract, where messages will be sent and received
    address public l1Target;

    // Arbitrum precompile, used to send messages to L1
    IArbSys constant arbsys = IArbSys(address(0x0000000000000000000000000000000000000064));

    /// @notice Sends a message to the L1 contract (set a uint256)
    /// @param number The number to set on the L1 contract state
    function createL1Message(uint256 number) external {
        bytes memory data = abi.encodeWithSelector(L1Contract.handleMessageFromL2.selector, number);
        arbsys.sendTxToL1(l1Target, data);
    }

    /// @notice Handle a message from the L1 contract
    /// @dev TODO: Add a modifier to ensure that this function can only be called by the L1 contract
    /// @param number The number received from the L1 contract
    function handleMessageFromL1(uint256 number) external {
        // Do something with the number
        numberFromL1 = number;
    }

    /// @notice Sets the L1 contract address
    /// @param _l1Target The address of the L1 contract that will be sending messages to this contract
    function setL1Target(address _l1Target) external {
        l1Target = _l1Target;
    }
}
