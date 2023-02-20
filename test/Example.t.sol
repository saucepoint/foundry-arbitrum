// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";

import {L1Contract} from "../src/L1Contract.sol";
import {L2Contract} from "../src/L2Contract.sol";

contract ExampleTest is Test {
    ArbitrumInboxMock inbox;
    L1Contract l1Contract;
    L2Contract l2Contract;

    function setUp() public {
        inbox = new ArbitrumInboxMock();

        l2Contract = new L2Contract();
        l1Contract = new L1Contract(address(inbox), address(l2Contract));
    }

    function testL1ToL2Message(uint256 num) public {
        l1Contract.createL2Message{value: 1 ether}(num);
        assertEq(l2Contract.numberFromL1(), num);
    }
}
