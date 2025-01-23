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

/**
 * @title Polls
 * @dev This contract manages the creation and voting of polls, leveraging multiple helper contracts for additional functionalities.
 * @notice Users can create polls, submit votes, and manage group memberships within this contract.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
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

    /**
     * @notice Creates a new poll with specified parameters.
     * @param _title The title of the poll.
     * @param _tag A tag associated with the poll.
     * @param _group The group ID associated with the poll.
     * @param _pollStartDate The start date of the poll.
     * @param _proposalEndDate The end date for proposal submissions.
     * @param _votingStartDate The date when voting starts.
     * @param _delegateEndDate The end date for delegation.
     * @param _endDate The end date for the poll.
     * @param _maxVoteScore The maximum score a user can give in the poll.
     */
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

    /**
     * @notice Allows a user to vote on a proposal in a specified poll.
     * @param _pollId The ID of the poll to vote in.
     * @param _proposalId The ID of the proposal being voted on.
     * @param _score The score assigned to the vote.
     */
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

    /**
     * @notice Allows a user to vote as a delegate on a proposal in a specified poll.
     * @param _pollId The ID of the poll to vote in.
     * @param _proposalId The ID of the proposal being voted on.
     * @param _score The score assigned to the vote.
     */
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

    /**
     * @notice Retrieves the total number of delegated votes for a user in a specified group.
     * @param _group The ID of the group to check.
     * @return totalVotes The total number of delegated votes for the user.
     */
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

    /**
     * @notice Checks if a user has voted in a specified poll.
     * @param _pollId The ID of the poll to check.
     * @param _user The address of the user to check.
     * @return True if the user has voted, false otherwise.
     */
    function hasUserVoted(uint256 _pollId, address _user) public view returns (bool) {
        return votersForPoll[_pollId][_user];
    }

    /**
     * @notice Checks if a user has voted as a delegate in a specified poll.
     * @param _pollId The ID of the poll to check.
     * @param _user The address of the user to check.
     * @return True if the user has voted as a delegate, false otherwise.
     */
    function hasUserVotedAsDelegate(uint256 _pollId, address _user) public view returns (bool) {
        return delegateVotersForPoll[_pollId][_user];
    }
}
