// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";
import {ArbSys} from "../src/forks/ArbSys.sol";

import {L1Contract} from "../src/L1Contract.sol";
import {L2Contract} from "../src/L2Contract.sol";

contract ExampleTest is Test {
    ArbSys arbsys;
    ArbitrumInboxMock inbox;
    L1Contract l1Contract;
    L2Contract l2Contract;

    function setUp() public {
        // bytes memory code = vm.getCode("ArbSys.sol:ArbSys");
        // vm.etch(address(0x0000000000000000000000000000000000000064), code);
        arbsys = new ArbSys();
        vm.etch(address(0x0000000000000000000000000000000000000064), address(arbsys).code);

        inbox = new ArbitrumInboxMock();
        l2Contract = new L2Contract();
        l1Contract = new L1Contract(address(inbox), address(l2Contract));
        
        l2Contract.setL1Target(address(l1Contract));
    }

    function testL1ToL2Message(uint256 num) public {
        l1Contract.createL2Message{value: 1 ether}(num);
        assertEq(l2Contract.numberFromL1(), num);
    }

    function testL2ToL1Message(uint256 num) public {
        l2Contract.createL1Message(num);
        assertEq(l1Contract.numberFromL2(), num);
    }

    function testArbSys() public {
        assertEq(address(0x64).code.length > 0, true);
    }
}
