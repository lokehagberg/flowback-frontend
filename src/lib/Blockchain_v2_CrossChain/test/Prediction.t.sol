// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/Polls.sol"; // Importing the Polls contract to inherit from
import "../src/Predictions.sol";
import {SharedErrors} from "../src/SharedErrors.sol";

contract PredictionTest is Test, Polls {
    Polls public testPolls;
    uint256 pollStartDate = 1708672110;
    uint256 proposalEndDate = 1708672110 + 1 days;
    uint256 votingStartDate = 1708672110 + 2 days;
    uint256 delegateEndDate = 1708672110 + 3 days;
    uint256 endDate = 1708672110 + 4 days;

    function setUp() public {
        testPolls = new Polls();
        console.log("Setup complete, testPolls deployed at:", address(testPolls));
    }

    function createPoll() private {
        testPolls.createPoll(
            "new poll", "tag", 1, pollStartDate, proposalEndDate, votingStartDate, delegateEndDate, endDate, 0, true
        );
        console.log("Poll created with startDate:", pollStartDate, "endDate:", endDate);
    }

    function testCreatePrediction() public {
        createPoll();
        testPolls.addProposal(1, "new proposal");

        vm.expectRevert(abi.encodeWithSelector(SH_ProposalDoesNotExist.selector, 1, 1)); // Ensure selector matches contract
        testPolls.createPrediction(1, 1, "pred");
        testPolls.addProposal(1, "new proposal");
        testPolls.createPrediction(1, 1, "predone");
        testPolls.createPrediction(1, 1, "predtwo");

        Predictions.Prediction[] memory preds = testPolls.getPredictions(1, 1);
        assertEq(preds[0].prediction, "predone");
        assertEq(preds[1].prediction, "predtwo");
        assertEq(preds[0].predictionId, 1);
        assertEq(preds[1].predictionId, 2);
        assertEq(preds.length, 2);
    }

    function testGetPredictions() public {
        // Expect revert if proposal does not exist
        console.log("Expecting SH_ProposalDoesNotExist revert for non-existing proposal.");
        vm.expectRevert(abi.encodeWithSelector(SH_ProposalDoesNotExist.selector, 1, 1));
        testPolls.getPredictions(1, 1);

        // Create poll
        console.log("Creating poll...");
        createPoll();

        // Add proposal to poll
        console.log("Adding proposal to poll ID 1...");
        testPolls.addProposal(1, "new proposal");

        // Add first prediction
        console.log("Creating first prediction for poll ID 1, proposal ID 0...");
        testPolls.createPrediction(1, 0, "predone");

        // Add second prediction
        console.log("Creating second prediction for poll ID 1, proposal ID 0...");
        testPolls.createPrediction(1, 0, "predtwo");

        // Retrieve predictions
        console.log("Retrieving predictions for poll ID 1, proposal ID 0...");
        Predictions.Prediction[] memory preds = testPolls.getPredictions(1, 0);

        // Check first prediction
        console.log("Checking first prediction values...");
        assertEq(preds[0].predictionId, 1);
        assertEq(preds[0].prediction, "predone");

        // Check second prediction
        console.log("Checking second prediction values...");
        assertEq(preds[1].predictionId, 2);
        assertEq(preds[1].prediction, "predtwo");

        // Ensure predictions array length is greater than 0
        console.log("Verifying predictions array is not empty...");
        assertTrue(preds.length > 0, "Should return predictions");
    }

    /*
    function testEmitPredictionCreated() public {
    // Step 1: Create a new poll
    createPoll();

    // Step 2: Add a proposal to the created poll
    testPolls.addProposal(1, "new proposal");

    // Step 3: Expect and emit PredictionCreated event for the first prediction
    vm.expectEmit(true, true, true, true);
    emit PredictionCreated(1, 1, 1, "pred");
    testPolls.createPrediction(1, 1, "pred");

    // Step 4: Expect and emit PredictionCreated event for the second prediction
    vm.expectEmit(true, true, true, true);
    emit PredictionCreated(1, 1, 2, "predone");
    testPolls.createPrediction(1, 1, "predone");

    // Step 5: Expect and emit PredictionCreated event for the third prediction
    vm.expectEmit(true, true, true, true);
    emit PredictionCreated(1, 1, 3, "predtwo");
    testPolls.createPrediction(1, 1, "predtwo");

    // Logging expected values for debugging purposes
    console.log("Expecting PredictionCreated events for prediction IDs 1, 2, and 3 with predictions 'pred', 'predone', 'predtwo'");
    }
    */
}
