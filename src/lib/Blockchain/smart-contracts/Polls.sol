// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {RightToVote} from "./RightToVote.sol";
import {Delegations} from "./Delegations.sol";
import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {Predictions} from "./Predictions.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";
import {PredictionBetHelpers} from "./PredictionBetHelpers.sol";
import {PredictionBets} from "./PredictionBets.sol";

/**
 * @title Polls
 * @dev This contract manages the creation and voting on polls and proposals. It integrates several modules such as voting rights, delegations, and predictions.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova.
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
    /// @notice Emitted when a new poll is created.
    /// @param pollId The unique ID of the created poll.
    /// @param title The title of the poll.
    event PollCreated(uint256 pollId, string title);

    /**
     * @notice Creates a new poll with the given parameters.
     * @dev This function increments the poll count and emits the PollCreated event.
     * @param _title The title of the poll.
     * @param _tag The tag categorizing the poll.
     * @param _group The group associated with the poll.
     * @param _pollStartDate The start date of the poll.
     * @param _proposalEndDate The date when the proposal phase ends.
     * @param _votingStartDate The date when the voting phase begins.
     * @param _delegateEndDate The date when the delegation phase ends.
     * @param _endDate The date when the poll ends.
     * @param _maxVoteScore The maximum score that can be given in the poll.
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
    ) public {
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

    /// @notice Emitted when a vote is submitted to a proposal.
    /// @param pollId The ID of the poll the vote was cast in.
    /// @param voter The address of the voter.
    /// @param votesForProposal The total number of votes cast for the proposal.
    event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);

    /**
     * @notice Casts a vote in a specific poll for a proposal.
     * @dev This function ensures the user has not already voted, checks that the proposal exists, and ensures that the user has not delegated their vote.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal to vote on.
     * @param _score The score assigned to the proposal by the voter.
     */
    function vote(uint256 _pollId, uint256 _proposalId, uint8 _score) public {
        uint256 _pollGroup = polls[_pollId].group;

        requirePollToExist(_pollId);
        require(isUserMemberOfGroup(_pollId), "The user is not a member of poll group");
        isVotingOpen(_pollId);
        require(!hasVoted(_pollId), "Vote has already been cast");
        require(requireProposalToExist(_pollId, _proposalId));
        require(!hasDelegatedInGroup(_pollGroup), "You have delegated your vote in the polls group.");
        requireVoterScoreWithinRange(_score, _pollId);

        Proposal[] storage pollProposals = proposals[_pollId];
        uint256 proposalsLength = pollProposals.length;
        uint256 _votesForProposal;

        for (uint256 i; i < proposalsLength;) {
            if (pollProposals[i].proposalId == _proposalId) {
                pollProposals[i].voteCount += 1;
                pollProposals[i].score += _score;
                _votesForProposal = pollProposals[i].voteCount;
                votersForPoll[_pollId].push(msg.sender);
                emit VoteSubmitted(_pollId, msg.sender, _votesForProposal);
                return;
            }
            unchecked {
                ++i;
            }
        }
        return;
    }

    /**
     * @notice Casts a delegate vote in a specific poll for a proposal.
     * @dev This function checks if the user is a delegate and if the delegate has already voted. It calculates delegated voting power and applies it to the vote.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal to vote on.
     * @param _score The score assigned to the proposal by the delegate voter.
     */
    function voteAsDelegate(uint256 _pollId, uint256 _proposalId, uint8 _score) public {
        uint256 _pollGroup = polls[_pollId].group;
        uint256 delegatedVotingPower;
        address[] memory delegatingAddresses;

        requirePollToExist(_pollId);
        require(isUserMemberOfGroup(_pollId), "The user is not a member of poll group");
        isVotingOpen(_pollId);
        require(!hasVotedAsDelegate(_pollId), "Delegate vote has already been cast");
        require(requireProposalToExist(_pollId, _proposalId));
        require(!hasDelegatedInGroup(_pollGroup), "You have delegated your vote in the polls group.");
        requireVoterScoreWithinRange(_score, _pollId);

        Proposal[] storage pollProposals = proposals[_pollId];
        uint256 pollGroupLength = groupDelegates[_pollGroup].length;

        for (uint256 i; i < pollGroupLength;) {
            if (groupDelegates[_pollGroup][i].delegate == msg.sender) {
                delegatedVotingPower = groupDelegates[_pollGroup][i].delegatedVotes;
                delegatingAddresses = groupDelegates[_pollGroup][i].delegationsFrom;
            }
            unchecked {
                ++i;
            }
        }

        for (uint256 i; i < delegatingAddresses.length; i++) {
            uint256 pollDelegateEndDate = polls[_pollId].delegateEndDate;

            for (uint256 j = 0; j < groupDelegationsByUser[delegatingAddresses[i]].length; j++) {
                if (groupDelegationsByUser[delegatingAddresses[i]][j].groupId == _pollGroup) {
                    if (groupDelegationsByUser[delegatingAddresses[i]][j].timeOfDelegation > pollDelegateEndDate) {
                        delegatedVotingPower = delegatedVotingPower > 0 ? delegatedVotingPower - 1 : 0;
                    }
                    break;
                }
            }
        }

        uint256 proposalsLength = pollProposals.length;
        uint256 _votesForProposal;

        for (uint256 i; i < proposalsLength;) {
            if (pollProposals[i].proposalId == _proposalId) {
                pollProposals[i].voteCount += delegatedVotingPower;
                pollProposals[i].score += _score * delegatedVotingPower;
                _votesForProposal = pollProposals[i].voteCount;
                votersForPoll[_pollId].push(msg.sender);
                emit VoteSubmitted(_pollId, msg.sender, _votesForProposal);
                return;
            }
            unchecked {
                ++i;
            }
        }
        return;
    }
}
