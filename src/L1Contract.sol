// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {L2Contract} from "./L2Contract.sol";
import {IInbox} from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";

contract L1Contract {
    uint256 public numberFromL2;

    address public immutable l2Target;
    IInbox public inbox;

    constructor(address _inbox, address _l2Target) {
        inbox = IInbox(_inbox);
        l2Target = _l2Target;
    }

    function createL2Message(uint256 number) external payable {
        bytes memory data = abi.encodeWithSelector(L2Contract.handleMessageFromL1.selector, number);

        // In production, these values should be set by the caller
        // It's the gas that is paid for L2 txn execution
        uint256 maxSubmissionCost = 0.1 ether;
        uint256 maxGas = 1_000_000;
        uint256 gasPriceBid = 10 gwei;

        inbox.createRetryableTicket{value: msg.value}(
            l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
        );
    }

    function handleMessageFromL2(uint256 number) external {
        // Do something with the number
        numberFromL2 = number;
    }
}
