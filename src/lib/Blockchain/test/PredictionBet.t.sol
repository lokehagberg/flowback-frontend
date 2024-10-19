// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "src/Polls.sol";

contract PredictionBetTest is Test, Polls {
    Polls public testPolls;
    uint256 pollStartDate = 1708672110;
    uint256 proposalEndDate = 1708672110 + 1 days;
    uint256 votingStartDate = 1708672110 + 2 days;
    uint256 delegateEndDate = 1708672110 + 3 days;
    uint256 endDate = 1708672110 + 4 days;

    function setUp() public {
        testPolls = new Polls();
    }

    function createPoll() private {
        testPolls.createPoll(
            "new poll", "tag", 1, pollStartDate, proposalEndDate, votingStartDate, delegateEndDate, endDate, 0
        );
    }

    function testEmitPlacePredictionBet() public {
        createPoll();
        testPolls.addProposal(1, "new proposal");
        testPolls.createPrediction(1, 1, "pred");
        vm.expectEmit();
        emit PredictionBetCreated(1, true, 9);
        testPolls.placePredictionBet(1, 1, 1, 9, true);
    }

    function testPlacePredictionBet() public {
        createPoll();
        testPolls.addProposal(1, "new proposal");
        testPolls.createPrediction(1, 1, "pred");
        testPolls.placePredictionBet(1, 1, 1, 9, true);
        testPolls.placePredictionBet(1, 1, 1, 9, true);
        PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 1, 1);
        assertEq(predictionbets.length, 2);
    }

    function testGetPredictionBets() public {
        createPoll();
        testPolls.addProposal(1, "new proposal");
        testPolls.createPrediction(1, 1, "pred");
        testPolls.placePredictionBet(1, 1, 1, 9, true);
        PredictionBets.PredictionBet[] memory predictionbets = testPolls.getPredictionBets(1, 1, 1);
        assertTrue(predictionbets.length > 0, "Should return predictionbets");
    }

    // //private/internal functions (passed testing) ------------------------------------------------------------

    //     // function testRequirePollPropPredToExist() public{
    //     //        testPolls.createPoll(
    //           "new poll",
    //            "tag",
    //            1,
    //            pollStartDate,
    //            proposalEndDate ,
    //            votingStartDate,
    //            delegateEndDate,
    //            endDate
    //            );
    //     //     testPolls.createPoll("new poll", "tag", 1, 1, 1, 1, 1, 1);
    //     //     testPolls.addProposal(1, "new proposal");
    //     //     testPolls.createPrediction(1, 1, "pred");
    //     //     assertTrue(testPolls.requirePollPropPredToExist(1,1,1));
    //     //     assertFalse(testPolls.requirePollPropPredToExist(1,1,2));
    //     //     assertFalse(testPolls.requirePollPropPredToExist(1,2,1));
    //     //     assertFalse(testPolls.requirePollPropPredToExist(2,1,1));

    //     // }
}
