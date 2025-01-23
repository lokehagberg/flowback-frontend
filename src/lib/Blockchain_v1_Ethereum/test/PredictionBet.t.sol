// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
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
    }
    function createPoll() private {
        testPolls.createPoll(
            "new poll", // Title of the poll
            "tag", // Tag associated with the poll
            1, // Group ID for the poll
            pollStartDate, // Start date for the poll
            proposalEndDate, // End date for proposals
            votingStartDate, // Start date for voting
            delegateEndDate, // End date for delegation
            endDate, // End date for the poll
            0 // Initial max vote score
        );
    }
    function testEmitPlacePredictionBet() public {
      createPoll(); // Create a new poll to test with
      testPolls.addProposal(1, "new proposal"); // Add a new proposal to the poll
      testPolls.createPrediction(1, 1, "pred"); // Create a prediction for the added proposal

     vm.expectEmit(); // Prepare to expect an event to be emitted
      emit PredictionBetCreated(1, true, 9); // Define the expected event and its parameters

     testPolls.placePredictionBet(1, 1, 1, 9, true); // Place a bet for the prediction
    }
    function testPlacePredictionBet() public {
    createPoll(); // Create a new poll to test with
    testPolls.addProposal(1, "new proposal"); // Add a new proposal to the poll
    testPolls.createPrediction(1, 1, "pred"); // Create a prediction for the added proposal
    // Place two prediction bets with the same parameters
    testPolls.placePredictionBet(1, 1, 1, 9, true); // First bet placed
    testPolls.placePredictionBet(1, 1, 1, 9, true); // Second bet placed
    // Retrieve the list of prediction bets for verification
    PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 1, 1);
 
    // Assert that the number of prediction bets is equal to 2
    assertEq(predictionbets.length, 2); // Verify the count of placed bets
    }
    function testGetPredictionBets() public {
    createPoll(); // Create a new poll for testing
    testPolls.addProposal(1, "new proposal"); // Add a proposal to the poll
    testPolls.createPrediction(1, 1, "pred"); // Create a prediction for the proposal
    testPolls.placePredictionBet(1, 1, 1, 9, true); // Place a prediction bet
    // Retrieve the list of prediction bets for the specified parameters
    PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 1, 1); 
    // Assert that the retrieved prediction bets array is not empty
    assertTrue(predictionbets.length > 0, "Should return prediction bets"); // Verify that there are prediction bets
    }
}
