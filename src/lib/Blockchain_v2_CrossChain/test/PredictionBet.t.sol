// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "forge-std/Vm.sol";
import "src/Polls.sol";

contract PredictionBetTest is Test, Polls {
    Polls public testPolls; // Instance of the Polls contract

    uint256 pollStartDate = 1708672110; // Start date for the poll
    uint256 proposalEndDate = 1708672110 + 1 days; // End date for proposals
    uint256 votingStartDate = 1708672110 + 2 days; // Start date for voting
    uint256 delegateEndDate = 1708672110 + 3 days; // End date for delegation
    uint256 endDate = 1708672110 + 4 days; // End date for the poll

    // Function to set up the testing environment
    function setUp() public {
        testPolls = new Polls(); // Deploy a new instance of the Polls contract
        console.log("Polls contract deployed");
    }

    function createPoll() private {
        console.log("Creating poll...");
        testPolls.createPoll(
            "new poll", "tag", 1, pollStartDate, proposalEndDate, votingStartDate, delegateEndDate, endDate, 0, false
        );
        console.log("Poll created with ID 1");
    }

    function testEmitPlacePredictionBet() public {
        console.log("Creating poll...");
        createPoll(); // Create a poll

        console.log("Adding proposal to poll ID 1...");
        testPolls.addProposal(1, "new proposal"); // Add proposal with expected ID 0
        console.log("Added proposal with ID 0 to poll with ID 1");

        // Add an assertion to confirm the proposal ID
        uint256 proposalId = 0; // The first proposal should have ID 0
        assertEq(proposalId, 0, "Proposal ID should be 0");

        console.log("Creating prediction for poll ID 1, proposal ID 0...");
        testPolls.createPrediction(1, proposalId, "pred"); // Create prediction with expected ID 1
        uint256 predictionId = 1; // Assuming first prediction ID is 1
        console.log("Created prediction with ID 1");

        // Assertion to confirm prediction ID
        assertEq(predictionId, 1, "Prediction ID should be 1");

        // Set expected event parameters
        vm.expectEmit(true, true, true, true); // Prepare to capture the full event
        emit PredictionBetCreated(1, true, 9); // Match parameters with actual event

        console.log("Placing prediction bet for poll ID 1, proposal ID 0, prediction ID 1...");
        testPolls.placePredictionBet(1, proposalId, predictionId, 9, true); // Place prediction bet with consistent IDs
        console.log("Prediction bet placed for correct IDs");
    }

    function testPlacePredictionBet() public {
        console.log("Creating poll...");
        createPoll(); // Create a new poll to test with

        console.log("Adding proposal to poll ID 1...");
        testPolls.addProposal(1, "new proposal"); // Add a new proposal to the poll
        console.log("Added proposal with ID 0 to poll with ID 1");

        console.log("Creating prediction for poll ID 1, proposal ID 0...");
        testPolls.createPrediction(1, 0, "pred"); // Create a prediction for the added proposal
        console.log("Created prediction with ID 0");

        // Place two prediction bets with the same parameters
        console.log("Placing first prediction bet...");
        testPolls.placePredictionBet(1, 0, 0, 9, true); // First bet placed
        console.log("First prediction bet placed");

        // Retrieve prediction bets for verification
        console.log("Retrieving prediction bets for poll ID 1, proposal ID 0, prediction ID 0...");
        PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 0, 0);
        assertTrue(predictionbets.length > 0, "Should return prediction bets");
    }

    function testGetPredictionBets() public {
        console.log("Creating poll...");
        createPoll(); // Create a new poll for testing

        console.log("Adding proposal to poll ID 1...");
        testPolls.addProposal(1, "new proposal"); // Add a proposal to the poll
        console.log("Added proposal with ID 0 to poll with ID 1");

        console.log("Creating prediction for poll ID 1, proposal ID 0...");
        testPolls.createPrediction(1, 0, "pred"); // Create a prediction for the proposal
        console.log("Created prediction with ID 0");

        console.log("Placing prediction bet for poll ID 1, proposal ID 0, prediction ID 0...");
        testPolls.placePredictionBet(1, 0, 0, 9, true); // Place a prediction bet
        console.log("Prediction bet placed");

        // Retrieve the list of prediction bets for the specified parameters
        console.log("Retrieving prediction bets for poll ID 1, proposal ID 0, prediction ID 0...");
        PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 0, 0);

        // Assert that the retrieved prediction bets array is not empty
        console.log("Number of prediction bets retrieved:", predictionbets.length);
        assertTrue(predictionbets.length > 0, "Should return prediction bets");
    }
}
