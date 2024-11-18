// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {PollsOnEthereum} from "../src/PollsOnEthereum.sol";

contract ETH_deploy is Script {
    function run() external returns (PollsOnEthereum polls) {
        vm.startBroadcast();
        polls = new PollsOnEthereum();
        vm.stopBroadcast();
        return polls;
    }
}
