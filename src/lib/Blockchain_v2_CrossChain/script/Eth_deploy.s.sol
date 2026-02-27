// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {PollsOnEthereum} from "../src/PollsOnEthereum.sol";

contract ETH_deploy is Script {
    function run() external returns (PollsOnEthereum polls) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        polls = new PollsOnEthereum();
        vm.stopBroadcast();
        return polls;
    }
}
