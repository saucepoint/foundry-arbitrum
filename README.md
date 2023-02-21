# foundry-arbitrum

> 🚧 Currently experimental and actively being dogfooded

> 🚨 These utility mocks do not replace extensive testing (use of local nodes or testnet)

Reusable, mocked Arbitrum contracts to enable cross-chain message testing within the [foundry](https://book.getfoundry.sh) testing environment

*Assuming the messages are **successful**, is the state changing as expected?*

---

## Usage

```bash
forge install saucepoint/foundry-arbitrum
```

In the test files, apply the mock contracts:

> Use `ArbitrumInboxMock` for L1 -> L2 messages

> Use `ArbSysMock` for L2 -> L1 messages

```solidity
import {ArbSysMock} from "saucepoint/foundry-arbitrum/ArbSysMock.sol";
import {ArbitrumInboxMock} from "saucepoint/foundry-arbitrum/ArbitrumInboxMock.sol";

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

    function testMessage() public {
        // assert how *succesful* cross-chain messages would modify state
    }
}
```

---

Intended for contracts relying on the Arbitrum `Inbox.sol` and the `ArbSys.sol` precompile:

L1 Contract:
```solidity
import {IInbox} from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";

// Arbitrum Inbox (message handler)
IInbox public inbox;

constructor(address _inbox, address _l2Target) {
    inbox = IInbox(_inbox);
    l2Target = _l2Target;
}

...

// calls `handleMessageFromL1(uint256 num)` on L2
bytes memory data = abi.encodeWithSelector(L2Contract.handleMessageFromL1.selector, number);

inbox.createRetryableTicket{value: msg.value}(
    l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
);
```

L2 Contract:
```solidity
import {IArbSys} from "./interfaces/IArbSys.sol";

// canonical precompile used to send messages to L1
IArbSys constant arbsys = IArbSys(address(0x0000000000000000000000000000000000000064));

...

// calls `handleMessageFromL2(uint256 num)` on L1
bytes memory data = abi.encodeWithSelector(L1Contract.handleMessageFromL2.selector, number);
arbsys.sendTxToL1(l1Target, data);
```