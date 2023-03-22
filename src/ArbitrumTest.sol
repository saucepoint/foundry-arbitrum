// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TestBase} from "forge-std/Base.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";
import {ArbSysMock} from "../src/ArbSysMock.sol";

contract ArbitrumTest is TestBase {
    ArbSysMock arbsys;
    ArbitrumInboxMock inbox;

    constructor() {
        // L2 contracts explicitly reference 0x64 for the ArbSys precompile
        // We'll replace it with the mock contract where L2-to-L1 messages are executed immediately
        arbsys = new ArbSysMock();
        vm.etch(address(0x0000000000000000000000000000000000000064), address(arbsys).code);

        // use the mocked Arbitrum inbox where L1-to-L2 messages are executed immediately
        inbox = new ArbitrumInboxMock();
    }
}
