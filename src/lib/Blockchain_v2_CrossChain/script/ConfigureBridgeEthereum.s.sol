// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {PollsOnEthereum} from "../src/PollsOnEthereum.sol";

contract ConfigureBridgeEthereum is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);

        vm.startBroadcast(pk);

        address pollsOnEthAddr = vm.envAddress("POLLS_ON_ETHEREUM_ADDRESS");

        PollsOnEthereum p = PollsOnEthereum(pollsOnEthAddr);

        // مؤقتا: نخلي المصرح له على Ethereum هو deployer
        p.setBridgeContract(deployer);

        console.log("Configured PollsOnEthereum:", pollsOnEthAddr);
        console.log("bridgeContract:", deployer);

        vm.stopBroadcast();
    }
}