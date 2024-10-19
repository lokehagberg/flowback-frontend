// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {Polls} from "../src/Polls.sol";
import {DeployPolls} from "../script/DeployPolls.s.sol";
import {ProposalHelpers} from "../src/ProposalHelpers.sol";
import {PollHelpers} from "../src/PollHelpers.sol";
import {Test, console} from "forge-std/Test.sol";

contract PollsTest is Test {
    Polls testPolls;

    // Define some test constants
    string public constant POLL_TITLE = "Dinner Poll";
    string public constant POLL_TAG = "Food";
    uint256 public constant POLL_GROUP = 1;

    uint256 public POLL_START_DATE;
    uint256 public PROPOSAL_END_DATE;
    uint256 public VOTING_START_DATE;
    uint256 public DELEGATE_END_DATE;
    uint256 public POLL_END_DATE;

    address public constant USER1 = address(0x1);
    address public constant USER2 = address(0x2);

    // Declare events
    event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);

    function setUp() public {
        DeployPolls deployPolls = new DeployPolls();
        testPolls = deployPolls.run();
        POLL_START_DATE = block.timestamp; // When the poll is created
        PROPOSAL_END_DATE = POLL_START_DATE + 2 days; // Proposal phase ends 2 days after poll start
        VOTING_START_DATE = PROPOSAL_END_DATE + 1 days; // Voting starts 1 day after proposal ends
        DELEGATE_END_DATE = VOTING_START_DATE + 2 days; // Delegation ends 2 days after voting starts
        POLL_END_DATE = DELEGATE_END_DATE + 1 days; // Poll ends 1 day after delegation ends
    }


    function testProposalRegistration() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Fast-forward time to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals.length, 1, "Proposal should be registered");
        assertEq(pollProposals[0].description, "Pizza", "Proposal description should match");
    }
    function testAddProposal() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Fast-forward time to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].description, "Pizza");
    }

    function testVoteOnProposal() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");
        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");
        vm.prank(USER1);
        testPolls.vote(1, 1, 80); // Vote with a score of 80
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);

        assertEq(pollProposals[0].voteCount, 1);
        assertEq(pollProposals[0].score, 80);
    }
    function testDelegateVoting() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER2);
        testPolls.becomeDelegate(POLL_GROUP);
        vm.prank(USER1);
        testPolls.delegateToDelegate(USER2, POLL_GROUP);
        vm.warp(block.timestamp + 1 days);
        vm.prank(USER2);
        testPolls.voteAsDelegate(1, 1, 50);

        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].voteCount, 1);
        assertEq(pollProposals[0].score, 50);
    }
    function testDoubleVotingRevert() public {
        uint256 pollId = 1; // Declare and initialize pollId
        address userAddress = USER1;
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");

        vm.prank(USER1);
        testPolls.vote(1, 1, 80);

        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, userAddress));

        vm.prank(USER1);
        testPolls.vote(1, 1, 80); // This should fail and revert
    }
    function testPollExistenceValidation() public {
        // Create a poll
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );
        vm.prank(USER1);
        testPolls.getPoll(1); // Poll ID 1 should exist
        vm.expectRevert(abi.encodeWithSignature("PH_PollDoesNotExist(uint256)", 999));
        testPolls.getPoll(999); // Poll ID 999 does not exist
    }
    function testProposalPhaseValidation() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );
        vm.warp(block.timestamp + 1 days); // Warp within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Burger");
        vm.warp(block.timestamp + 3 days);

        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_ProposalPhaseEnded(uint256,uint256,uint256)", 1, PROPOSAL_END_DATE, block.timestamp
            )
        );
        testPolls.addProposal(1, "Pasta");
    }
    function testCreatePollMaxVoteScoreOutOfRange() public {
        vm.prank(USER1);
        vm.expectRevert(abi.encodeWithSignature("PH_MaxVoteScoreOutOfRange(uint8)", 150));
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            150 // Invalid max vote score (above 100)
        );
    }
    function testMemberValidationForVoting() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days);

        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Ensure the proposal exists

        vm.warp(VOTING_START_DATE + 1);

        vm.prank(USER1);
        vm.expectRevert(); // Expect revert because USER1 is not a group member yet
        testPolls.vote(1, 1, 50); // Voting on proposal 1

        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1);
        testPolls.vote(1, 1, 50); // USER1 votes on proposal 1
    }
    function testDoubleVoting() public {
        uint256 pollId = 1; // Declare pollId with an appropriate value
        address userAddress = USER1; // Assign userAddress with USER1 or another valid address

        vm.prank(userAddress);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(userAddress);
        testPolls.addProposal(pollId, "Pizza");

        vm.warp(block.timestamp + 2 days);

        vm.prank(userAddress);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(userAddress);
        testPolls.vote(pollId, 1, 80); // Voting for proposal 1

        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, userAddress));
        vm.prank(userAddress);
        testPolls.vote(pollId, 1, 80); // This second vote should fail
    }
    function testGetProposal() public {
        // Step 1: Create the poll
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        ProposalHelpers.Proposal memory retrievedProposal = testPolls.getProposal(1, 1);

        assertEq(retrievedProposal.description, "Pizza", "Proposal description should match");
        assertEq(retrievedProposal.voteCount, 0, "Initial vote count should be 0");
        assertEq(retrievedProposal.score, 0, "Initial score should be 0");
        assertEq(retrievedProposal.creator, USER1, "Creator should be USER1");
    }
    function testGetPollResults() public {
        // Step 1: Create a poll
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.prank(USER2);
        testPolls.addProposal(1, "Burger");

        vm.warp(block.timestamp + 1 days); // Move to the voting phase

        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1);
        testPolls.vote(1, 1, 80);

        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER2);
        testPolls.vote(1, 2, 60);
        vm.prank(USER1); // Ensure USER1 is calling the function
        (string[] memory proposalDescriptions, uint256[] memory voteCounts, uint256[] memory scores) =
            testPolls.getPollResults(1);

        assertEq(proposalDescriptions[0], "Pizza", "First proposal description should be Pizza");
        assertEq(voteCounts[0], 1, "Pizza proposal should have 1 vote");
        assertEq(scores[0], 80, "Pizza proposal score should be 80");

        assertEq(proposalDescriptions[1], "Burger", "Second proposal description should be Burger");
        assertEq(voteCounts[1], 1, "Burger proposal should have 1 vote");
        assertEq(scores[1], 60, "Burger proposal score should be 60");
    }
    function testUpdateProposalVotes() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.prank(USER1);
        testPolls.updateProposalVotes(1, 1, 2, 150); // Increase votes by 2 and score by 150
        ProposalHelpers.Proposal memory updatedProposal = testPolls.getProposal(1, 1);

        assertEq(updatedProposal.voteCount, 2, "Proposal 1 vote count should be 2");
        assertEq(updatedProposal.score, 150, "Proposal 1 score should be 150");
    }
    function testCastVote() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.warp(block.timestamp + 2 days); // Move to the voting phase
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.expectEmit(true, true, false, false);
        emit VoteSubmitted(1, USER1, 1); // Adjust this to match the event signature in the contract

        vm.prank(USER1);
        testPolls.vote(1, 1, 80); // USER1 votes for proposal 1 with a score of 80

        bool hasVoted = testPolls.hasUserVoted(1, USER1);
        assertTrue(hasVoted, "USER1 should have voted in the poll");
    }
    function testCastVoteAsDelegate() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.warp(block.timestamp + 2 days); // Move to the delegate phase

        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP); // Ensure USER1 is part of the group
        vm.prank(USER1);
        testPolls.becomeDelegate(POLL_GROUP); // Become a delegate for the group, not with the address

        vm.expectEmit(true, true, false, false);
        emit VoteSubmitted(1, USER1, 1); // Adjust this to match the event signature in the contract
        vm.prank(USER1);
        testPolls.voteAsDelegate(1, 1, 50); // USER1 votes as delegate for proposal 1 with a score of 50

        bool hasVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER1);
        assertTrue(hasVotedAsDelegate, "USER1 should have voted as a delegate in the poll");
    }
    function testHasVoted() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        bool hasUserVoted = testPolls.hasUserVoted(1, USER1);
        assertFalse(hasUserVoted, "USER1 should not have voted yet");

        vm.prank(USER1);
        testPolls.vote(1, 1, 80);

        hasUserVoted = testPolls.hasUserVoted(1, USER1);
        assertTrue(hasUserVoted, "USER1 should have voted");
    }
    function testHasVotedAsDelegate() public {
        // Step 1: Create a poll
        vm.prank(USER2);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );
        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(USER2);
        testPolls.addProposal(1, "Burger");

        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER2);
        testPolls.becomeDelegate(POLL_GROUP);

        bool hasUserVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER2);
        assertFalse(hasUserVotedAsDelegate, "USER2 should not have voted as a delegate yet");

        vm.prank(USER2);
        testPolls.voteAsDelegate(1, 1, 60);

        hasUserVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER2);
        assertTrue(hasUserVotedAsDelegate, "USER2 should have voted as a delegate");
    }
    function testIsVotingOpen() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(POLL_START_DATE + 1 days); // Fast-forward to after the poll creation, but before voting starts
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_VotingNotAllowed(uint256,uint256,uint256,uint256)",
                1,
                VOTING_START_DATE,
                POLL_END_DATE,
                block.timestamp
            )
        );
        testPolls.publicIsVotingOpen(1);

        vm.warp(VOTING_START_DATE + 1 days); // Fast-forward to within the voting period
        testPolls.publicIsVotingOpen(1);
        vm.warp(POLL_END_DATE + 1 days); // Fast-forward to after the poll's end date
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_VotingNotAllowed(uint256,uint256,uint256,uint256)",
                1,
                VOTING_START_DATE,
                POLL_END_DATE,
                block.timestamp
            )
        );
        testPolls.publicIsVotingOpen(1);
    }
    function testControlProposalEndDate() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100
        );

        vm.warp(POLL_START_DATE + 1 days); // Fast-forward to within the proposal phase
        testPolls.publicControlProposalEndDate(1); // Should not revert
        vm.warp(PROPOSAL_END_DATE + 1 days); // Fast-forward to after the proposal end date
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_ProposalPhaseEnded(uint256,uint256,uint256)", 1, PROPOSAL_END_DATE, block.timestamp
            )
        );
        testPolls.publicControlProposalEndDate(1); // Should revert since the proposal phase has ended
    }
    function testRequireMaxVoteScoreWithinRange() public {
        testPolls.publicRequireMaxVoteScoreWithinRange(50); // Should not revert
        vm.expectRevert(abi.encodeWithSignature("PH_MaxVoteScoreOutOfRange(uint8)", 150));
        testPolls.publicRequireMaxVoteScoreWithinRange(150); // Should revert due to out-of-range score
    }
    function testRequireVoterScoreWithinRange() public {
        vm.prank(USER1);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100 // Max vote score
        );

        testPolls.publicRequireVoterScoreWithinRange(80, 1); // Should not revert
        vm.expectRevert(abi.encodeWithSignature("PH_VoteScoreExceedsMax(uint8,uint8)", 150, 100));
        testPolls.publicRequireVoterScoreWithinRange(150, 1); // Should revert due to score out of range
    }
}
