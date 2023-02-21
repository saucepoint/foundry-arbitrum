# foundry-arbitrum

Mocked Arbitrum contracts (`Inbox.sol, ArbSys.sol`) to enable cross-chain message testing within [foundry](https://book.getfoundry.sh)

> 🚧 Currently experimental, and does not replace extensive testing (local nodes or testnet)

---

## Usage

Assumes your contracts are using the Arbitrum Inbox and the ArbSys precompile:
```solidity
import {IInbox} from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";

// L1 Contract that sends messages to L2
// calls `handleMessageFromL1(uint256 num)` on L2
bytes memory data = abi.encodeWithSelector(L2Contract.handleMessageFromL1.selector, number);

inbox.createRetryableTicket{value: msg.value}(
    l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
);
```

```solidity
import {IArbSys} from "./interfaces/IArbSys.sol";

// L2 Contract that sends a message to L1
IArbSys constant arbsys = IArbSys(address(0x0000000000000000000000000000000000000064));

bytes memory data = abi.encodeWithSelector(L1Contract.handleMessageFromL2.selector, number);
arbsys.sendTxToL1(l1Target, data);
```

In the foundry tests, use the mock contracts such that cross-chain messages are executed:
```
import {ArbitrumInboxMock} from "saucepoint/foundry-arbitrum/ArbitrumInboxMock.sol";
import {ArbSysMock} from "saucepoint/foundry-arbitrum/ArbSysMock.sol";

import {L1Contract} from "../src/L1Contract.sol";
import {L2Contract} from "../src/L2Contract.sol";

contract ExampleTest is Test {
    ArbSysMock arbsys;
    ArbitrumInboxMock inbox;
    
    L1Contract l1Contract;
    L2Contract l2Contract;

    function setUp() public {
        // Etch the mocked ArbSys to the precompile address
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
}
```