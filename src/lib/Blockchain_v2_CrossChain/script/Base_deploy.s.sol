// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {PollsBridge} from "../src/PollsBridge.sol";
import {RightToVote} from "../src/RightToVote.sol";
import {Delegations} from "../src/Delegations.sol";
import {PollHelpers} from "../src/PollHelpers.sol";
import {ProposalHelpers} from "../src/ProposalHelpers.sol";
import {Predictions} from "../src/Predictions.sol";
import {PredictionHelpers} from "../src/PredictionHelpers.sol";
import {PredictionBetHelpers} from "../src/PredictionBetHelpers.sol";
import {PredictionBets} from "../src/PredictionBets.sol";
import {SharedErrors} from "../src/SharedErrors.sol";
import {Polls} from "../src/Polls.sol";
import {MetaVoting} from "../src/MetaVoting.sol";

contract Base_deploy is Script {
    Polls public polls;
    MetaVoting public metaVoting;
    PollHelpers public pollHelpers;
    PollsBridge public pollsBridge;
    RightToVote public rightToVote;
    Delegations public delegations;
    ProposalHelpers public proposalHelpers;
    Predictions public predictions;
    PredictionHelpers public predictionHelpers;
    PredictionBetHelpers public predictionBetHelpers;
    PredictionBets public predictionBets;

    function run() external {
        address deployer = address(0x1234); // Define a deployer address

        // Start broadcasting transactions to deploy contracts
        vm.startBroadcast();

        console.log("Deploying PollsBridge contract...");
        pollsBridge = new PollsBridge();
        console.log("Deployed PollsBridge at:", address(pollsBridge));

        console.log("Deploying RightToVote contract...");
        rightToVote = new RightToVote();
        console.log("Deployed RightToVote at:", address(rightToVote));

        console.log("Deploying Delegations contract...");
        delegations = new Delegations();
        console.log("Deployed Delegations at:", address(delegations));

        console.log("Deploying PollHelpers contract...");
        pollHelpers = new PollHelpers();
        console.log("Deployed PollHelpers at:", address(pollHelpers));

        console.log("Deploying ProposalHelpers contract...");
        proposalHelpers = new ProposalHelpers();
        console.log("Deployed ProposalHelpers at:", address(proposalHelpers));

        console.log("Deploying Predictions contract...");
        predictions = new Predictions();
        console.log("Deployed Predictions at:", address(predictions));

        console.log("Deploying PredictionHelpers contract...");
        predictionHelpers = new PredictionHelpers();
        console.log("Deployed PredictionHelpers at:", address(predictionHelpers));

        console.log("Deploying PredictionBetHelpers contract...");
        predictionBetHelpers = new PredictionBetHelpers();
        console.log("Deployed PredictionBetHelpers at:", address(predictionBetHelpers));

        console.log("Deploying PredictionBets contract...");
        predictionBets = new PredictionBets();
        console.log("Deployed PredictionBets at:", address(predictionBets));

        // Deploy Polls contract
        console.log("Deploying Polls contract...");
        polls = new Polls();
        console.log("Deployed Polls at:", address(polls));

        // Deploy MetaVoting contract
        console.log("Deploying MetaVoting contract...");
        metaVoting = new MetaVoting(address(pollHelpers));
        console.log("Deployed MetaVoting at:", address(metaVoting));

        // Set MetaVoting in PollHelpers
        console.log("Setting MetaVoting in PollHelpers...");
        pollHelpers.setMetaVoting(address(metaVoting));

        // Set bridge contract in Polls
        console.log("Setting bridge contract in Polls...");
        polls.setBridgeContract(address(pollsBridge));

        // Set relayer for MetaVoting
        console.log("Setting relayer for MetaVoting...");
        metaVoting.setRelayer(deployer);

        // Transfer ownership of Polls contract to deployer
        console.log("Transferring ownership of Polls to deployer...");
        polls.transferOwnership(deployer);
        console.log("Ownership transfer complete. Current owner of Polls:", polls.owner());

        vm.stopBroadcast();
    }
}
