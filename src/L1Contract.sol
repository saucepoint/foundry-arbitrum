// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {L2Contract} from "./L2Contract.sol";
import {IInbox} from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";

/// @title L1Contract
/// @notice An example L1 contract that interacts with an L2 contract (sends & receives messages)
/// @author saucepoint
contract L1Contract {
    // A number set by an L2-to-L1 message
    uint256 public numberFromL2;

    // Address of the L2 contract
    address public immutable l2Target;

    // Arbitrum Inbox (message handler)
    IInbox public inbox;

    constructor(address _inbox, address _l2Target) {
        inbox = IInbox(_inbox);
        l2Target = _l2Target;
    }

    /// @notice Sends a message to the L2 contract (set a uint256)
    /// @param number The number to set on the L2 contract state
    function createL2Message(uint256 number) external payable {
        bytes memory data = abi.encodeWithSelector(L2Contract.handleMessageFromL1.selector, number);

        // In production, these values should be set by the caller
        // It's the gas that is paid for L2 txn execution
        uint256 maxSubmissionCost = 0.1 ether;
        uint256 maxGas = 1_000_000;
        uint256 gasPriceBid = 10 gwei;

        // Send the message to the L2 contract
        // (~10 min delay, but is executed immediately in tests)
        inbox.createRetryableTicket{value: msg.value}(
            l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
        );
    }

    /// @notice Handles a message originating from L2
    /// @param number The number to set on the L1 contract state, provided by a message from L2
    function handleMessageFromL2(uint256 number) external {
        // Do something with the number
        numberFromL2 = number;
    }
}
