// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Inbox} from "./forks/Inbox.sol";
import {IBridge} from "@arbitrum/nitro-contracts/src/bridge/IBridge.sol";
import {Bridge} from "@arbitrum/nitro-contracts/src/bridge/Bridge.sol";
import {ISequencerInbox} from "@arbitrum/nitro-contracts/src/bridge/ISequencerInbox.sol";
import {SequencerInbox} from "@arbitrum/nitro-contracts/src/bridge/SequencerInbox.sol";
import {MAX_DATA_SIZE} from "@arbitrum/nitro-contracts/src/libraries/Constants.sol";
import {
    DataTooLarge,
    RetryableData,
    GasLimitTooLarge,
    InsufficientSubmissionCost
} from "@arbitrum/nitro-contracts/src/libraries/Error.sol";

/// @title ArbitrumInboxMock
/// @notice Replaces the canonical Arbitrum Inbox with a mock that *immediately* executes the message
///         Normally, `createRetryableTicket` will execute ~10 mins after the L1 transaction is mined
/// @notice This is intended to be used in Foundry tests, should not be used in production, and does
///         not replace extensive testing.
/// @notice Additional script-based testing (against local nitro nodes or testnet) is recommended
/// @author saucepoint
contract ArbitrumInboxMock is Inbox {
    uint256 public msgNum;

    /// @dev Override ticket creation such that messages are immediately executed
    ///      instead of being queued into the delayed inbox
    function unsafeCreateRetryableTicket(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes calldata data
    ) public payable override whenNotPaused onlyAllowed returns (uint256 _msgNum) {
        // gas price and limit of 1 should never be a valid input, so instead they are used as
        // magic values to trigger a revert in eth calls that surface data without requiring a tx trace
        if (gasLimit == 1 || maxFeePerGas == 1) {
            revert RetryableData(
                msg.sender,
                to,
                l2CallValue,
                msg.value,
                maxSubmissionCost,
                excessFeeRefundAddress,
                callValueRefundAddress,
                gasLimit,
                maxFeePerGas,
                data
            );
        }

        // arbos will discard retryable with gas limit too large
        if (gasLimit > type(uint64).max) {
            revert GasLimitTooLarge();
        }

        uint256 submissionFee = calculateRetryableSubmissionFee(data.length, block.basefee);
        if (maxSubmissionCost < submissionFee) {
            revert InsufficientSubmissionCost(submissionFee, maxSubmissionCost);
        }

        // ----------------- BEGIN MODIFICATION -----------------
        // Instead of queueing the message into the delayedInbox or the sequencer inbox
        // we immediately execute the message against the target contract

        (bool success,) = to.call{value: l2CallValue}(data);
        require(success, "ArbitrumInboxMock: call failed");

        // msgNum is 0-indexed, so increment after returning
        _msgNum = msgNum;
        unchecked {
            ++msgNum;
        }
        // ----------------- END MODIFICATION -----------------
    }
}
