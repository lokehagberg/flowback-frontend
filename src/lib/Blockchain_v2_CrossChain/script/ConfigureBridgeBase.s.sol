// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {PollsBridge} from "../src/PollsBridge.sol";

contract ConfigureBridgeBase is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address pollsBridgeAddr = vm.envAddress("POLLS_BRIDGE_ADDRESS");
        address pollsAddr = vm.envAddress("POLLS_ADDRESS");
        address pollsOnEthAddr = vm.envAddress("POLLS_ON_ETHEREUM_ADDRESS");

        PollsBridge bridge = PollsBridge(pollsBridgeAddr);

        bridge.setBasePollsContract(pollsAddr);
        bridge.setEthereumPollsContract(pollsOnEthAddr);

        console.log("Configured PollsBridge:", pollsBridgeAddr);
        console.log("basePollsContract:", pollsAddr);
        console.log("ethereumPollsContract:", pollsOnEthAddr);

        vm.stopBroadcast();
    }
}