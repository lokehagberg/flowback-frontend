// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "lib/forge-std/src/console.sol";
import "./SharedErrors.sol"; // Import the shared error contract

/**
 * @title PollHelpers
 * @dev Provides utility functions to manage and interact with polls, including creating, voting, and ensuring compliance with poll phases.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract PollHelpers is SharedErrors {

    /// Custom Errors
    error PH_ProposalPhaseEnded(uint256 pollId, uint256 proposalEndDate, uint256 currentTimestamp);
    error PH_VotingNotAllowed(uint256 pollId, uint256 votingStartDate, uint256 endDate, uint256 currentTimestamp);
    error PH_PollDoesNotExist(uint256 pollId);
    error PH_MaxVoteScoreOutOfRange(uint8 providedScore);
    error PH_VoteScoreExceedsMax(uint8 providedScore, uint8 maxScore);

    /// @dev Struct representing a poll.
    struct Poll {
        string title;
        string tag;
        uint256 group;
        uint256 pollStartDate;
        uint256 proposalEndDate;
        uint256 votingStartDate;
        uint256 delegateEndDate;
        uint256 endDate;
        uint8 maxVoteScore;
        uint256 pollId;
        uint256 proposalCount;
    }

    event VoteCast(address indexed voter, uint256 indexed pollId);
    event DelegateVoteCast(address indexed delegateVoter, uint256 indexed pollId);

    /// @notice Mapping from poll ID to Poll structure.
    mapping(uint256 => Poll) public polls;

    /// @notice Mapping from poll ID to a mapping of addresses representing voters for that poll.
    mapping(uint256 => mapping(address => bool)) internal votersForPoll;

    /// @notice Mapping from poll ID to a mapping of addresses representing delegate voters for that poll.
    mapping(uint256 => mapping(address => bool)) internal delegateVotersForPoll;

    /// @notice Tracks the total number of polls created.
    uint256 public pollCount = 0;

    /**
     * @notice Ensures that the proposal phase is still open for the given poll.
     * @dev Reverts if the proposal phase has ended.
     * @param _pollId The ID of the poll to check.
     */
    function controlProposalEndDate(uint256 _pollId) internal view {
        if (polls[_pollId].proposalEndDate <= block.timestamp) {
            revert PH_ProposalPhaseEnded(_pollId, polls[_pollId].proposalEndDate, block.timestamp);
        }
    }

    /**
     * @notice Returns the details of a specific poll by ID.
     * @param _pollId The ID of the poll to retrieve.
     * @return Poll The Poll structure containing the poll details.
     */
    function getPoll(uint256 _pollId) external view returns (Poll memory) {
        requirePollToExist(_pollId);
        return polls[_pollId];
    }

    /**
     * @notice Ensures that the voting phase is open for the given poll.
     * @dev Reverts if the voting phase is not currently open.
     * @param _pollId The ID of the poll to check.
     */
    function isVotingOpen(uint256 _pollId) internal view {
        if (block.timestamp < polls[_pollId].votingStartDate || block.timestamp > polls[_pollId].endDate) {
            console.log("Voting is NOT allowed.");
            revert PH_VotingNotAllowed(_pollId, polls[_pollId].votingStartDate, polls[_pollId].endDate, block.timestamp);
        }
    }

    /**
     * @notice Ensures that the poll exists.
     * @dev Reverts if the poll does not exist.
     * @param _pollId The ID of the poll to check.
     */
    function requirePollToExist(uint256 _pollId) internal view {
        if (_pollId == 0 || _pollId > pollCount) {
            revert PH_PollDoesNotExist(_pollId);
        }
    }

    /**
     * @notice Ensures that the maximum vote score is within the allowed range.
     * @dev Reverts if the max vote score is greater than 100.
     * @param _maxVoteScore The maximum vote score to validate.
     */
    function requireMaxVoteScoreWithinRange(uint8 _maxVoteScore) internal pure {
        if (_maxVoteScore > 100) {
            revert PH_MaxVoteScoreOutOfRange(_maxVoteScore);
        }
    }

    /**
     * @notice Ensures that the voter's score is within the allowed range for the poll.
     * @dev Reverts if the vote score exceeds the poll's maximum vote score.
     * @param _score The score to validate.
     * @param _pollId The ID of the poll to check the score against.
     */
    function requireVoterScoreWithinRange(uint8 _score, uint256 _pollId) internal view {
        if (_score > polls[_pollId].maxVoteScore) {
            revert PH_VoteScoreExceedsMax(_score, polls[_pollId].maxVoteScore);
        }
    }

    /**
     * @notice Checks whether the caller has already voted in the specified poll.
     * @param _pollId The ID of the poll to check.
     * @return voted True if the caller has voted, false otherwise.
     */
    function hasVoted(uint256 _pollId) internal view returns (bool voted) {
        return votersForPoll[_pollId][msg.sender];
    }

    /**
     * @notice Checks whether the caller has voted as a delegate in the specified poll.
     * @param _pollId The ID of the poll to check.
     * @return voted True if the caller has voted as a delegate, false otherwise.
     */
    function hasVotedAsDelegate(uint256 _pollId) internal view returns (bool voted) {
        return delegateVotersForPoll[_pollId][msg.sender];
    }

    /**
     * @notice Adds the caller as a voter for a specific poll.
     * @param _pollId The ID of the poll where the caller is voting.
     */
    function castVote(uint256 _pollId) external {
        requirePollToExist(_pollId);

        if (hasVoted(_pollId)) {
            revert SH_AlreadyVoted(_pollId, msg.sender);
        }

        // Mark the user as having voted
        votersForPoll[_pollId][msg.sender] = true;

        emit VoteCast(msg.sender, _pollId);
    }

    /**
     * @notice Adds the caller as a delegate voter for a specific poll.
     * @param _pollId The ID of the poll where the caller votes as a delegate.
     */
    function castDelegateVote(uint256 _pollId) external {
        requirePollToExist(_pollId);

        if (hasVotedAsDelegate(_pollId)) {
            revert SH_AlreadyVoted(_pollId, msg.sender);
        }

        // Mark the user as having voted as a delegate
        delegateVotersForPoll[_pollId][msg.sender] = true;
        emit DelegateVoteCast(msg.sender, _pollId);
    }


    //____________TESTING FUNCTIONS_____________


    /**
     * @notice Exposes the isVotingOpen function to the public for checking voting status.
     * @param _pollId The ID of the poll to check voting status.
     */
    function publicIsVotingOpen(uint256 _pollId) external view {
        isVotingOpen(_pollId);
    }

    /**
     * @notice Exposes the controlProposalEndDate function to the public for checking proposal phase status.
     * @param _pollId The ID of the poll to check proposal phase.
     */
    function publicControlProposalEndDate(uint256 _pollId) external view {
        controlProposalEndDate(_pollId);
    }

    /**
     * @notice Exposes the requireMaxVoteScoreWithinRange function to the public for validating maximum vote score.
     * @param _maxVoteScore The maximum vote score to validate.
     */
    function publicRequireMaxVoteScoreWithinRange(uint8 _maxVoteScore) external pure {
        requireMaxVoteScoreWithinRange(_maxVoteScore);
    }

    /**
     * @notice Exposes the requireVoterScoreWithinRange function to the public for validating voter score.
     * @param _score The score to validate.
     * @param _pollId The ID of the poll to check the score against.
     */
    function publicRequireVoterScoreWithinRange(uint8 _score, uint256 _pollId) external view {
        requireVoterScoreWithinRange(_score, _pollId);
    }
}
