// // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/Polls.sol";

contract PredictionTest is Test, Polls {
    Polls public testPolls; // Instance of the Polls contract
    uint256 pollStartDate = 1708672110; // Start date for the poll
    uint256 proposalEndDate = 1708672110 + 1 days; // End date for proposal submissions
    uint256 votingStartDate = 1708672110 + 2 days; // Start date for voting
    uint256 delegateEndDate = 1708672110 + 3 days; // End date for delegation
    uint256 endDate = 1708672110 + 4 days; // End date for the poll

    // Function to set up the test environment
    function setUp() public {
        testPolls = new Polls(); // Deploy a new instance of the Polls contract
    }
    // Function to simulate broadcasting a transaction
    function run() public {
        vm.broadcast(0x18d1161FaBAC4891f597386f0c9B932E3fD3A1FD); // Broadcast a transaction to a specific address
    }
    // Private function to create a new poll
    function createPoll() private {
        testPolls.createPoll(
            "new poll", "tag", 1, pollStartDate, proposalEndDate, votingStartDate, delegateEndDate, endDate, 0
        ); // Call the createPoll function with specified parameters
    }
    function testCreatePrediction() public {
        createPoll(); // Create a new poll
        // Expect revert when trying to create a prediction without an existing proposal
        vm.expectRevert(abi.encodeWithSelector(PH_ProposalDoesNotExist.selector, 1, 1));
        testPolls.createPrediction(1, 1, "pred"); // Attempt to create a prediction
        vm.stopPrank(); // Stop any prank state (not applicable here but good practice)
        
        testPolls.addProposal(1, "new proposal"); // Add a new proposal
        testPolls.createPrediction(1, 1, "predone"); // Create the first prediction
        testPolls.createPrediction(1, 1, "predtwo"); // Create the second prediction
        
        // Retrieve predictions and assert their values
        Predictions.Prediction[] memory preds = testPolls.getPredictions(1, 1);
        assertEq(preds[0].prediction, "predone"); // Check that the first prediction matches
        assertEq(preds[1].prediction, "predtwo"); // Check that the second prediction matches
        assertEq(preds[0].predictionId, 1); // Check that the first prediction has the correct ID
        assertEq(preds[1].predictionId, 2); // Check that the second prediction has the correct ID
        assertEq(preds.length, 2); // Verify that there are two predictions
    }
    function testGetPredictions() public {
        // Expect revert when trying to get predictions without an existing proposal
        vm.expectRevert(abi.encodeWithSelector(PH_ProposalDoesNotExist.selector, 1, 1));
        testPolls.getPredictions(1, 1); // Attempt to retrieve predictions
        vm.stopPrank(); // Stop any prank state

        createPoll(); // Create a new poll
        testPolls.addProposal(1, "new proposal"); // Add a new proposal
        testPolls.createPrediction(1, 1, "predone"); // Create the first prediction
        testPolls.createPrediction(1, 1, "predtwo"); // Create the second prediction

        // Retrieve predictions and assert their values
        Predictions.Prediction[] memory preds = testPolls.getPredictions(1, 1);
        assertEq(preds[0].predictionId, 1); // Check that the first prediction has the correct ID
        assertEq(preds[1].predictionId, 2); // Check that the second prediction has the correct ID
        assertEq(preds[0].prediction, "predone"); // Check that the first prediction matches
        assertEq(preds[1].prediction, "predtwo"); // Check that the second prediction matches
        assertTrue(preds.length > 0, "Should return predictions"); // Verify that there are predictions
    }
    function testEmitPredictionCreated() public {
        createPoll(); // Create a new poll
        testPolls.addProposal(1, "new proposal"); // Add a new proposal
        vm.expectEmit(); // Expect the PredictionCreated event to be emitted
        emit PredictionCreated(1, 1, 1, "pred"); // Emit the event with expected parameters
        testPolls.createPrediction(1, 1, "pred"); // Create a prediction, which should trigger the event
    }
}