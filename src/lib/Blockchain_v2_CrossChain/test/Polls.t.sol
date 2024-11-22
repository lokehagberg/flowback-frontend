// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {SharedErrors} from "../src/SharedErrors.sol";
import {Polls} from "../src/Polls.sol";
import {Base_deploy} from "../script/Base_deploy.s.sol";
import {ProposalHelpers} from "../src/ProposalHelpers.sol";
import {PollHelpers} from "../src/PollHelpers.sol";
import {Test, console} from "forge-std/Test.sol";
import {MetaVoting} from "../src/MetaVoting.sol";
import {MetaTxHandler} from "../src/MetaTxHandler.sol";

contract PollsTest is Test {
    Polls testPolls;
    MetaTxHandler metaTxHandler;

    string public constant POLL_TITLE = "Dinner Poll";
    string public constant POLL_TAG = "Food";
    uint256 public constant POLL_GROUP = 1;

    uint256 public POLL_START_DATE;
    uint256 public PROPOSAL_END_DATE;
    uint256 public VOTING_START_DATE;
    uint256 public DELEGATE_END_DATE;
    uint256 public POLL_END_DATE;

    address public USER1 = address(0x1);
    address public USER2 = address(0x2);
    address public owner = address(0x1234);

    event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);

    function setUp() public {
        console.log("Starting setup...");

        // Initialize timestamp variables
        POLL_START_DATE = block.timestamp;
        PROPOSAL_END_DATE = POLL_START_DATE + 1 days;
        VOTING_START_DATE = PROPOSAL_END_DATE + 1 days;
        DELEGATE_END_DATE = VOTING_START_DATE + 1 days;
        POLL_END_DATE = DELEGATE_END_DATE + 1 days;

        // Deploy contracts
        Base_deploy baseDeploy = new Base_deploy();
        baseDeploy.run();

        // Set up Polls and MetaTxHandler
        testPolls = Polls(address(baseDeploy.polls()));
        metaTxHandler = new MetaTxHandler(address(testPolls));

        vm.startPrank(owner);
        testPolls.setMetaTxHandler(address(metaTxHandler));
        vm.stopPrank();

        console.log("Setup complete.");
    }

    function testProposalRegistration() public {
        // Step 1: Create the poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true // storeOnEthereum (additional argument)
        );

        // Step 2: Move within the proposal phase
        vm.warp(POLL_START_DATE + 1); // Move to a time within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Add a proposal

        // Step 3: Validate the proposal was registered
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals.length, 1, "Proposal should be registered");
        assertEq(pollProposals[0].description, "Pizza", "Proposal description should match");
    }

    function addProposal() public {
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        vm.warp(block.timestamp + 1 days); // Fast-forward time to the proposal phase
        vm.prank(owner);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1); // Set USER1 as the caller
        testPolls.addProposal(1, "Pizza");

        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].description, "Pizza");
    }

    function testVoteOnProposal() public {
        // Step 1: Create a poll as the owner
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to a time within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Move to the voting phase and make USER1 a member of the group
        vm.warp(VOTING_START_DATE + 1); // Move to a time within the voting phase
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Verify that USER1 is a member of the group
        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");

        // Step 4: USER1 votes on the proposal with a score of 80
        vm.prank(USER1);
        testPolls.vote(1, 0, 80, POLL_GROUP); // Voting for proposalId = 0 (Pizza) with a score of 80

        // Step 5: Retrieve the proposals and verify the vote count and score
        ProposalHelpers.Proposal[] memory pollProposals = testPolls.getProposals(1);
        assertEq(pollProposals[0].voteCount, 1, "Vote count for 'Pizza' proposal should be 1");
        assertEq(pollProposals[0].score, 80, "Score for 'Pizza' proposal should be 80");
    }

    function testDelegateVoting() public {
        // Step 1: Create the poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to proposal phase and add a proposal as USER1
        vm.warp(POLL_START_DATE + 1); // Move to just after POLL_START_DATE, within proposal phase
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza");

        // Verify the proposal was added
        ProposalHelpers.Proposal memory proposal = testPolls.getProposal(1, 0);
        require(proposal.creator != address(0), "Proposal was not created correctly");

        // Step 3: Set up USER2 as a delegate and delegate voting rights to them
        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER2);
        testPolls.becomeDelegate(POLL_GROUP);

        vm.prank(USER1);
        testPolls.delegateToDelegate(USER2, POLL_GROUP);

        // Verify that USER2 is a delegate
        bool addressIsDelegate = testPolls.addressIsDelegate(POLL_GROUP, USER2);
        assertTrue(addressIsDelegate, "USER2 should be a delegate in the group");

        // Step 4: Move to voting phase and cast a delegate vote
        vm.warp(VOTING_START_DATE + 1); // Move to just after VOTING_START_DATE, within voting phase
        vm.prank(USER2);
        testPolls.voteAsDelegate(1, 0, 50, USER2); // USER2 votes as delegate for proposalId = 0

        // Step 5: Validate the voting result
        proposal = testPolls.getProposal(1, 0); // Retrieve updated proposal details
        assertEq(proposal.voteCount, 1, "Vote count should be 1");
        assertEq(proposal.score, 50, "Score should be 50");
    }

    function testDoubleVotingRevert() public {
        uint256 pollId = 1; // Declare and initialize pollId
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 1: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(pollId, "Pizza");

        // Step 2: Move to the voting phase and make USER1 a member of the group
        vm.warp(VOTING_START_DATE + 1); // Move to within the voting phase
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Verify USER1 is a member
        bool isMember = testPolls.isAddressMemberOfGroup(USER1, POLL_GROUP);
        assertTrue(isMember, "USER1 should be a member of the group");

        // Step 3: USER1 casts their first vote
        vm.prank(USER1);
        testPolls.vote(pollId, 0, 80, POLL_GROUP);

        // Step 4: Expect a revert on double voting attempt
        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, USER1));
        vm.prank(USER1);
        testPolls.vote(pollId, 0, 80, POLL_GROUP); // This should fail and revert
    }

    function testPollExistenceValidation() public {
        // Create a poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );
        vm.prank(owner);
        testPolls.getPoll(1); // Poll ID 1 should exist
        vm.expectRevert(abi.encodeWithSignature("PH_PollDoesNotExist(uint256)", 999));
        testPolls.getPoll(999); // Poll ID 999 does not exist
    }

    function testProposalPhaseValidation() public {
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 1: Move within the proposal phase
        vm.warp(POLL_START_DATE + 1); // Move to a time within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Burger"); // This should succeed since we are within the proposal phase

        // Step 2: Move past the proposal end date to ensure phase has ended
        vm.warp(PROPOSAL_END_DATE + 1); // Move past the proposal end date

        // Step 3: Attempt to add another proposal, which should revert
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_ProposalPhaseEnded(uint256,uint256,uint256)", 1, PROPOSAL_END_DATE, block.timestamp
            )
        );
        testPolls.addProposal(1, "Pasta"); // This should fail as we are beyond the proposal phase
    }

    function testCreatePollMaxVoteScoreOutOfRange() public {
        vm.prank(owner);
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
            150, // Invalid max vote score (above 100)
            true
        );
    }

    function testMemberValidationForVoting() public {
        // Step 1: Create a poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase based on POLL_START_DATE and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to the proposal phase based on POLL_START_DATE
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Move to the voting phase based on VOTING_START_DATE and attempt to vote without group membership
        vm.warp(VOTING_START_DATE + 1); // Move to the voting phase
        vm.prank(USER1);
        vm.expectRevert(abi.encodeWithSelector(SharedErrors.SH_NotMember.selector, POLL_GROUP, USER1)); // Expect SH_NotMember error
        testPolls.vote(1, 0, 50, POLL_GROUP); // Voting on proposalId = 0 should revert

        // Step 4: Make USER1 a member of the group
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Step 5: USER1 votes successfully now that they're a member
        vm.prank(USER1);
        testPolls.vote(1, 0, 50, POLL_GROUP); // USER1 votes on proposalId = 0
    }

    function testDoubleVoting() public {
        uint256 pollId = 1; // Declare pollId with an appropriate value
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 1: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(pollId, "Pizza");

        // Step 2: Move to the voting phase and make USER1 a member of the group
        vm.warp(VOTING_START_DATE + 1); // Move to within the voting phase
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Step 3: USER1 casts their first vote
        vm.prank(USER1);
        testPolls.vote(pollId, 0, 80, POLL_GROUP); // USER1 votes on proposal 0 with a score of 80

        // Step 4: Attempt to vote again and expect a revert
        vm.expectRevert(abi.encodeWithSignature("SH_AlreadyVoted(uint256,address)", pollId, USER1));
        vm.prank(USER1);
        testPolls.vote(pollId, 0, 80, POLL_GROUP); // This second vote should fail and revert
    }

    function testGetProposal() public {
        // Step 1: Create the poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to the proposal phase based on POLL_START_DATE
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with ID 0

        // Step 3: Retrieve and validate the proposal
        ProposalHelpers.Proposal memory retrievedProposal = testPolls.getProposal(1, 0);

        assertEq(retrievedProposal.description, "Pizza", "Proposal description should match");
        assertEq(retrievedProposal.voteCount, 0, "Initial vote count should be 0");
        assertEq(retrievedProposal.score, 0, "Initial score should be 0");
        assertEq(retrievedProposal.creator, USER1, "Creator should be USER1");
    }

    function testGetPollResults() public {
        // Step 1: Create a poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add proposals
        vm.warp(POLL_START_DATE + 1); // Ensure within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Proposal ID should be 0

        vm.prank(USER2);
        testPolls.addProposal(1, "Burger"); // Proposal ID should be 1

        // Step 3: Move to the voting phase
        vm.warp(VOTING_START_DATE + 1); // Ensure within the voting phase

        // Step 4: Ensure both users are group members and can vote
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1);
        testPolls.vote(1, 0, 80, POLL_GROUP); // USER1 votes on "Pizza" (proposalId = 0)

        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER2);
        testPolls.vote(1, 1, 60, POLL_GROUP); // USER2 votes on "Burger" (proposalId = 1)

        // Step 5: Retrieve and validate poll results
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
        // Step 1: Create a poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to a time within the proposal phase
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Move to the voting phase
        vm.warp(VOTING_START_DATE + 1); // Move to a time within the voting phase

        // Step 4: Update the proposal votes and score
        vm.prank(USER1);
        testPolls.updateProposalVotes(1, 0, 2, 150); // Increase votes by 2 and score by 150 on proposalId = 0

        // Step 5: Retrieve the updated proposal and verify
        ProposalHelpers.Proposal memory updatedProposal = testPolls.getProposal(1, 0);
        assertEq(updatedProposal.voteCount, 2, "Proposal vote count should be 2");
        assertEq(updatedProposal.score, 150, "Proposal score should be 150");
    }

    function testCastVote() public {
        // Step 1: Create the poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add a proposal
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Move to the voting phase
        vm.warp(block.timestamp + 2 days);
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Step 4: Set expectations for the emitted event
        vm.expectEmit(true, true, false, false);
        emit VoteSubmitted(1, USER1, 80); // Expect event with pollId = 1, voter = USER1, votesForProposal = 80

        // Step 5: USER1 votes on proposalId = 0 with a score of 80
        vm.prank(USER1);
        testPolls.vote(1, 0, 80, POLL_GROUP); // Voting on proposalId = 0 (Pizza) with a score of 80

        // Step 6: Verify voting status
        bool hasVoted = testPolls.hasUserVoted(1, USER1);
        assertTrue(hasVoted, "USER1 should have voted in the poll");
    }

    function testCastVoteAsDelegate() public {
        // Step 1: Create a poll with precise dates for each phase
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase to add a proposal
        vm.warp(POLL_START_DATE + 1); // Move just after poll start to allow proposal submission
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Move to the delegate phase
        vm.warp(DELEGATE_END_DATE - 1); // Ensure we are within the delegate phase before its end

        // Step 4: Set up USER1 as a group member and delegate
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        vm.prank(USER1);
        testPolls.becomeDelegate(POLL_GROUP);

        // Step 5: Set expectations for the emitted VoteSubmitted event
        vm.expectEmit(true, true, false, false); // Indexed parameters: pollId and voter
        emit VoteSubmitted(1, USER1, 50); // Expected parameters: pollId = 1, voter = USER1, votesForProposal = 50

        // Step 6: USER1 votes as a delegate on proposalId = 0 with a score of 50
        vm.prank(USER1);
        testPolls.voteAsDelegate(1, 0, 50, USER1); // Correct proposalId is 0

        // Step 7: Verify USER1's delegate voting status
        bool hasVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER1);
        assertTrue(hasVotedAsDelegate, "USER1 should have voted as a delegate in the poll");
    }

    function testHasVoted() public {
        // Step 1: Create the poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to the proposal phase based on POLL_START_DATE
        vm.prank(USER1);
        testPolls.addProposal(1, "Pizza"); // Adds proposal with proposalId = 0

        // Step 3: Set up voting eligibility for USER1
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);

        // Check that USER1 has not voted yet
        bool hasUserVoted = testPolls.hasUserVoted(1, USER1);
        assertFalse(hasUserVoted, "USER1 should not have voted yet");

        // Step 4: Move to the voting phase and cast a vote
        vm.warp(VOTING_START_DATE + 1); // Move to the voting phase based on VOTING_START_DATE
        vm.prank(USER1);
        testPolls.vote(1, 0, 80, POLL_GROUP); // USER1 votes on proposalId = 0 (Pizza) with a score of 80

        // Check that USER1's vote was recorded
        hasUserVoted = testPolls.hasUserVoted(1, USER1);
        assertTrue(hasUserVoted, "USER1 should have voted");
    }

    function testHasVotedAsDelegate() public {
        // Step 1: Create a poll
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to the proposal phase based on POLL_START_DATE and add a proposal
        vm.warp(POLL_START_DATE + 1); // Move to the proposal phase based on POLL_START_DATE
        vm.prank(USER1);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER1);
        testPolls.addProposal(1, "Burger");

        // Step 3: Set up USER2 as a delegate
        vm.prank(USER2);
        testPolls.becomeMemberOfGroup(POLL_GROUP);
        vm.prank(USER2);
        testPolls.becomeDelegate(POLL_GROUP);

        vm.prank(USER1);
        testPolls.delegateToDelegate(USER2, POLL_GROUP);

        // Verify USER2 is a delegate in POLL_GROUP
        bool addressIsDelegate = testPolls.addressIsDelegate(POLL_GROUP, USER2);
        assertTrue(addressIsDelegate, "USER2 should be a delegate in the group");

        // Step 4: Confirm USER2 hasn't voted as delegate yet
        bool hasVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER2);
        assertFalse(hasVotedAsDelegate, "USER2 should not have voted as a delegate yet");

        // Step 5: Move to the voting phase based on VOTING_START_DATE and vote as delegate
        vm.warp(VOTING_START_DATE + 1); // Move to voting phase based on VOTING_START_DATE
        vm.prank(USER2);
        testPolls.voteAsDelegate(1, 0, 50, USER2); // USER2 votes as delegate for proposalId = 0

        // Step 6: Verify USER2 has voted as delegate
        hasVotedAsDelegate = testPolls.hasUserVotedAsDelegate(1, USER2);
        assertTrue(hasVotedAsDelegate, "USER2 should have voted as a delegate");
    }

    function testIsVotingOpen() public {
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Move to a time just before the voting phase and expect revert
        vm.warp(VOTING_START_DATE - 1);
        vm.expectRevert("PH_VotingNotAllowed");
        testPolls.publicIsVotingOpen(1);

        // Move to a time within the voting phase and call without expecting revert
        vm.warp(VOTING_START_DATE + 1);
        testPolls.publicIsVotingOpen(1); // Should not revert in the voting phase

        // Move to a time after the poll's end date and expect revert
        vm.warp(POLL_END_DATE + 1);
        vm.expectRevert("PH_VotingNotAllowed");
        testPolls.publicIsVotingOpen(1);
    }

    function testControlProposalEndDate() public {
        // Step 1: Create the poll with specified phase dates
        vm.prank(owner);
        testPolls.createPoll(
            POLL_TITLE,
            POLL_TAG,
            POLL_GROUP,
            POLL_START_DATE,
            PROPOSAL_END_DATE,
            VOTING_START_DATE,
            DELEGATE_END_DATE,
            POLL_END_DATE,
            100,
            true
        );

        // Step 2: Move to a time within the proposal phase and call control function
        vm.warp(POLL_START_DATE + 1); // Warp just after the poll starts, within the proposal phase
        testPolls.publicControlProposalEndDate(1); // Should not revert since we are within the proposal phase

        // Step 3: Move to after the proposal phase and check for revert
        vm.warp(PROPOSAL_END_DATE + 1); // Warp to a time after the proposal phase ends
        vm.expectRevert(
            abi.encodeWithSignature(
                "PH_ProposalPhaseEnded(uint256,uint256,uint256)", 1, PROPOSAL_END_DATE, block.timestamp
            )
        );
        testPolls.publicControlProposalEndDate(1); // Should revert since the proposal phase has ended
    }

    function testRequireMaxVoteScoreWithinRange() public {
        vm.prank(owner);
        testPolls.publicRequireMaxVoteScoreWithinRange(50); // Should not revert
        vm.expectRevert(abi.encodeWithSignature("PH_MaxVoteScoreOutOfRange(uint8)", 150));
        testPolls.publicRequireMaxVoteScoreWithinRange(150); // Should revert due to out-of-range score
    }

    function testRequireVoterScoreWithinRange() public {
        // Set the caller as the owner to perform the poll creation
        vm.prank(owner);

        // Create a poll with a max vote score of 100
        testPolls.createPoll(
            "Test Poll Title",
            "Test Tag",
            1, // Group ID
            block.timestamp, // Poll start date
            block.timestamp + 1 days, // Proposal end date
            block.timestamp + 2 days, // Voting start date
            block.timestamp + 3 days, // Delegate end date
            block.timestamp + 4 days, // Poll end date
            100, // Max vote score
            true // Store on Ethereum
        );

        // Test score within range - should not revert
        testPolls.publicRequireVoterScoreWithinRange(80, 1);

        // Expect a revert when the score exceeds the max score
        vm.expectRevert(abi.encodeWithSignature("PH_VoteScoreExceedsMax(uint8,uint8)", 150, 100));
        testPolls.publicRequireVoterScoreWithinRange(150, 1);
    }
}
