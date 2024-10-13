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

    function setUp() public {
        DeployPolls deployPolls = new DeployPolls();
        testPolls = deployPolls.run();

        // Initialize dynamic time-based constants
        POLL_START_DATE = block.timestamp; // When the poll is created
        PROPOSAL_END_DATE = POLL_START_DATE + 2 days; // Proposal phase ends 2 days after poll start
        VOTING_START_DATE = PROPOSAL_END_DATE + 1 days; // Voting starts 1 day after proposal ends
        DELEGATE_END_DATE = VOTING_START_DATE + 2 days; // Delegation ends 2 days after voting starts
        POLL_END_DATE = DELEGATE_END_DATE + 1 days; // Poll ends 1 day after delegation ends
    }

    function testProposalRegistration() public {
        // Create the poll
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

        // Add a proposal
        vm.warp(block.timestamp + 1 days); // Fast-forward time to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        // Ensure proposal exists
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals.length, 1, "Proposal should be registered");
        assertEq(pollProposals[0].description, "Pizza", "Proposal description should match");
    }

    function testAddProposal() public {
        // Create the poll first
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

        // Add a proposal
        vm.warp(block.timestamp + 1 days); // Fast-forward time to the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        // Fetch proposals to check if it was added correctly
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].description, "Pizza");
    }

    function testVoteOnProposal() public {
        // Create poll and add proposal
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

        // Move to voting phase
        vm.warp(block.timestamp + 1 days);

        // Ensure USER1 becomes a member of the group
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Check if USER1 is a member of the group
        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");

        // USER1 votes on the proposal
        vm.prank(USER1);
        testPolls.vote(1, 1, 80); // Vote with a score of 80

        // Check the proposal vote count and score
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);

        assertEq(pollProposals[0].voteCount, 1);
        assertEq(pollProposals[0].score, 80);
    }

    function testDelegateVoting() public {
        // Create poll and add proposal
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

        // Ensure USER1 becomes a member of the group before delegating
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Ensure USER2 becomes a member of the group
        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Debugging Check
        bool isMemberUser2 = testPolls.isAddressMemberOfGroup(USER2, POLL_GROUP);
        assertTrue(isMemberUser2, "USER2 should be a member of the group");

        bool isMemberUser1 = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMemberUser1, "USER1 should be a member of the group");

        // Delegate logic: USER2 becomes delegate, USER1 delegates to USER2
        vm.prank(USER2);
        testPolls.becomeDelegate(POLL_GROUP);
        console.log("USER2 successfully became a delegate.");

        vm.prank(USER1);
        testPolls.delegateToDelegate(USER2, POLL_GROUP);

        // Move to voting phase and delegate vote
        vm.warp(block.timestamp + 1 days);

        vm.prank(USER2);
        testPolls.voteAsDelegate(1, 1, 50);

        // Check proposal vote count and score
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].voteCount, 1);
        assertEq(pollProposals[0].score, 50);
    }

    function testDoubleVotingRevert() public {
        uint256 pollId = 1; // Declare and initialize pollId
        address userAddress = USER1;

        // Step 1: Create poll and add proposal
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

        // Step 2: Fast forward to allow proposal creation and add a proposal
        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        // Step 3: Fast forward to the voting phase and make USER1 a group member
        vm.warp(block.timestamp + 1 days);
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Verify USER1 is now a member of the group
        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");

        // Step 4: USER1 votes on the proposal
        vm.prank(USER1);
        testPolls.vote(1, 1, 80);

        // Expect revert due to double voting
        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, userAddress));

        // Ensure the second vote attempt uses the correct address (USER1)
        vm.prank(USER1);
        testPolls.vote(1, 1, 80); // This should fail and revert
    }

    // ========================================
    // PollHelpers-specific Tests
    // ========================================

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

        // Test valid poll existence
        vm.prank(USER1);
        testPolls.getPoll(1); // Poll ID 1 should exist

        // Test non-existent poll
        vm.expectRevert(abi.encodeWithSignature("PH_PollDoesNotExist(uint256)", 999));
        testPolls.getPoll(999); // Poll ID 999 does not exist
    }

    function testProposalPhaseValidation() public {
        // Create a poll with proposalEndDate in the future
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

        // Test during valid proposal phase
        vm.warp(block.timestamp + 1 days); // Warp within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Burger");

        // Fast-forward past the proposalEndDate
        vm.warp(block.timestamp + 3 days);

        // Expect revert because the proposal phase has ended
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_ProposalPhaseEnded(uint256,uint256,uint256)", 1, PROPOSAL_END_DATE, block.timestamp
            )
        );
        testPolls.addProposal(1, "Pasta");
    }

    function testCreatePollMaxVoteScoreOutOfRange() public {
        // Try creating a poll with an invalid max vote score (above 100)
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
        // Step 1: Create poll
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

        // Step 2: Fast forward to the proposal phase
        vm.warp(block.timestamp + 1 days);

        // Step 3: Add a proposal (this step might have been missing or misconfigured)
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Ensure the proposal exists

        // Step 4: Move to voting phase
        vm.warp(VOTING_START_DATE + 1);

        // Step 5: Attempt to vote without being a member, expect revert
        vm.prank(USER1);
        vm.expectRevert(); // Expect revert because USER1 is not a group member yet
        testPolls.vote(1, 1, 50); // Voting on proposal 1

        // Step 6: Become a member of the group
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Step 7: Try voting again as a group member (this should succeed)
        vm.prank(USER1);
        testPolls.vote(1, 1, 50); // USER1 votes on proposal 1
    }

    function testDoubleVoting() public {
        uint256 pollId = 1; // Declare pollId with an appropriate value
        address userAddress = USER1; // Assign userAddress with USER1 or another valid address

        // Step 1: Create poll
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

        // Step 2: Add a proposal
        vm.warp(block.timestamp + 1 days); // Move to the proposal phase
        vm.prank(userAddress);
        testPolls.addProposal(pollId, "Pizza");

        // Step 3: Move to the voting phase
        vm.warp(block.timestamp + 2 days);

        // Step 4: Make USER1 a member of the group
        vm.prank(userAddress);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Step 5: First vote
        vm.prank(userAddress);
        testPolls.vote(pollId, 1, 80); // Voting for proposal 1

        // Step 6: Attempt double voting, expecting revert with SH_AlreadyVoted
        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, userAddress));
        vm.prank(userAddress);
        testPolls.vote(pollId, 1, 80); // This second vote should fail
    }
}
