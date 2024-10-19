// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {RightToVote} from "./RightToVote.sol";
import {Delegations} from "./Delegations.sol";
import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {Predictions} from "./Predictions.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";
import {PredictionBetHelpers} from "./PredictionBetHelpers.sol";
import {PredictionBets} from "./PredictionBets.sol";
import "lib/forge-std/src/console.sol";

import "lib/forge-std/src/console.sol";

contract Polls is
    RightToVote,
    Delegations,
    PollHelpers,
    ProposalHelpers,
    PredictionHelpers,
    Predictions,
    PredictionBetHelpers,
    PredictionBets
{
    event PollCreated(uint256 indexed pollId, string title);
    event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);

    error P_UserNotMemberOfGroup(uint256 groupId, address user);
    error P_AlreadyDelegatedVote(uint256 groupId, address voter);
    error P_InvalidScore(uint256 score);

    function createPoll(
        string calldata _title,
        string calldata _tag,
        uint256 _group,
        uint256 _pollStartDate,
        uint256 _proposalEndDate,
        uint256 _votingStartDate,
        uint256 _delegateEndDate,
        uint256 _endDate,
        uint8 _maxVoteScore
    ) external {
        requireMaxVoteScoreWithinRange(_maxVoteScore);
        pollCount++;

        Poll memory newPoll = Poll({
            title: _title,
            tag: _tag,
            group: _group,
            pollStartDate: _pollStartDate,
            proposalEndDate: _proposalEndDate,
            votingStartDate: _votingStartDate,
            delegateEndDate: _delegateEndDate,
            endDate: _endDate,
            maxVoteScore: _maxVoteScore,
            pollId: pollCount,
            proposalCount: 0
        });

        emit PollCreated(newPoll.pollId, newPoll.title);
        polls[pollCount] = newPoll;
    }
    /// @dev Expose the internal controlProposalEndDate function for testing purposes

    function vote(uint256 _pollId, uint256 _proposalId, uint8 _score) external {
        console.log("Voting initiated by:", msg.sender);

        Poll storage poll = polls[_pollId];
        require(poll.pollId > 0, "Poll does not exist");
        console.log("Poll exists, title:", poll.title);

        if (_score == 0) {
            revert P_InvalidScore(_score);
        }
        console.log("Score is valid:", _score);

        if (!isUserMemberOfGroup(poll.group)) {
            revert P_UserNotMemberOfGroup(poll.group, msg.sender);
        }
        console.log("User is a member of the group:", msg.sender);

        if (hasVoted(_pollId)) {
            revert SH_AlreadyVoted(_pollId, msg.sender);
        }
        console.log("User has not yet voted in the poll");

        if (hasDelegatedInGroup(poll.group)) {
            revert P_AlreadyDelegatedVote(poll.group, msg.sender);
        }
        console.log("User has not delegated their vote");

        // Retrieve the proposal using inherited getProposal
        Proposal memory proposal = getProposal(_pollId, _proposalId);
        console.log("Fetched proposal ID:", proposal.proposalId);

        updateProposalVotes(_pollId, _proposalId, 1, _score); // Update the proposal

        console.log("Vote successful. Updated vote count:", proposal.voteCount + 1);

        votersForPoll[_pollId][msg.sender] = true;
        emit VoteSubmitted(_pollId, msg.sender, proposal.voteCount + 1);
    }

    function voteAsDelegate(uint256 _pollId, uint256 _proposalId, uint8 _score) external {
        console.log("Delegate voting initiated by:", msg.sender);

        Poll storage poll = polls[_pollId];
        require(poll.pollId > 0, "Poll does not exist");
        console.log("Poll exists, title:", poll.title);

        uint256 delegatedVotingPower = _getDelegatedVotes(poll.group);
        console.log("Delegated voting power for the user:", delegatedVotingPower);

        if (_score == 0) {
            revert P_InvalidScore(_score);
        }
        console.log("Score is valid:", _score);

        if (!isUserMemberOfGroup(poll.group)) {
            revert P_UserNotMemberOfGroup(poll.group, msg.sender);
        }
        console.log("User is a member of the group:", msg.sender);

        if (hasVotedAsDelegate(_pollId)) {
            revert SH_AlreadyVoted(_pollId, msg.sender);
        }
        console.log("User has not voted as a delegate");

        if (hasDelegatedInGroup(poll.group)) {
            revert P_AlreadyDelegatedVote(poll.group, msg.sender);
        }
        console.log("User has not delegated their vote in this group");

        Proposal memory proposal = getProposal(_pollId, _proposalId);
        console.log("Fetched proposal ID:", proposal.proposalId);

        updateProposalVotes(_pollId, _proposalId, delegatedVotingPower, _score * delegatedVotingPower);

        console.log("Before updating: voteCount =", proposal.voteCount);
        console.log("After updating: voteCount =", proposal.voteCount + delegatedVotingPower);

        delegateVotersForPoll[_pollId][msg.sender] = true;
        emit VoteSubmitted(_pollId, msg.sender, proposal.voteCount + delegatedVotingPower);
    }

    // Function to fetch delegated votes (unchanged)
    function _getDelegatedVotes(uint256 _group) internal view returns (uint256) {
        uint256 totalVotes = 0;
        GroupDelegate[] storage groupDelegatesList = groupDelegates[_group];

        for (uint256 i = 0; i < groupDelegatesList.length; i++) {
            GroupDelegate storage delegate = groupDelegatesList[i];
            if (delegate.delegate == msg.sender) {
                totalVotes = delegate.delegatedVotes;
                break;
            }
        }
        return totalVotes;
    }
}
