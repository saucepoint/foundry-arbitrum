// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";
import {ArbSysMock} from "../src/ArbSysMock.sol";

import {L1Contract} from "../src/examples/L1Contract.sol";
import {L2Contract} from "../src/examples/L2Contract.sol";

contract ExampleTest is Test {
    ArbSysMock arbsys;
    ArbitrumInboxMock inbox;
    L1Contract l1Contract;
    L2Contract l2Contract;

    function setUp() public {
        // L2 contracts explicitly reference 0x64 for the ArbSys precompile
        // We'll replace it with the mock contract where L2-to-L1 messages are executed immediately
        arbsys = new ArbSysMock();
        vm.etch(address(0x0000000000000000000000000000000000000064), address(arbsys).code);

        // use the mocked Arbitrum inbox where L1-to-L2 messages are executed immediately
        inbox = new ArbitrumInboxMock();

        // Our L2 contract that will communicate with the L1 contract
        l2Contract = new L2Contract();

        // Our L1 contract that will communicate with the L2 contract
        l1Contract = new L1Contract(address(inbox), address(l2Contract));

        l2Contract.setL1Target(address(l1Contract));
    }

    // Test that L1-to-L2 messages are modifying the L2 contract state
    function testL1ToL2Message(uint256 num) public {
        l1Contract.createL2Message{value: 1 ether}(num);
        assertEq(l2Contract.numberFromL1(), num);
    }

    // Test that L2-to-L1 messages are modifying the L1 contract state
    function testL2ToL1Message(uint256 num) public {
        l2Contract.createL1Message(num);
        assertEq(l1Contract.numberFromL2(), num);
    }

    // Be doubly-sure that the mocked ArbSys precompile is available
    function testArbSys() public {
        assertEq(address(0x64).code.length > 0, true);
    }
}
