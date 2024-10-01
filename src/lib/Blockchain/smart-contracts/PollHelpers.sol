// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

/**
 * @title PollHelpers
 * @dev Provides utility functions to manage and interact with polls, including creating, voting, and ensuring compliance with poll phases.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova.
 */
contract PollHelpers {
    /**
     * @dev Structure to store poll details.
     * @param title Title of the poll.
     * @param tag Tag for categorizing the poll.
     * @param group The group associated with the poll.
     * @param pollStartDate The timestamp when the poll starts.
     * @param proposalEndDate The timestamp when the proposal phase ends.
     * @param votingStartDate The timestamp when the voting phase starts.
     * @param delegateEndDate The timestamp when the delegate phase ends.
     * @param endDate The timestamp when the poll ends.
     * @param maxVoteScore The maximum score a voter can give.
     * @param pollId The unique ID of the poll.
     * @param proposalCount The total number of proposals submitted for the poll.
     */
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

    /// @notice Mapping from poll ID to Poll structure.
    mapping(uint256 => Poll) public polls;

    /// @notice Mapping from poll ID to an array of addresses representing voters for that poll.
    mapping(uint256 => address[]) internal votersForPoll;

    /// @notice Mapping from poll ID to an array of addresses representing delegate voters for that poll.
    mapping(uint256 => address[]) internal delegateVotersForPoll;

    /// @notice Tracks the total number of polls created.
    uint256 public pollCount;

    /**
     * @notice Ensures that the proposal phase is still open for the given poll.
     * @dev Reverts if the proposal phase has ended.
     * @param _pollId The ID of the poll to check.
     */
    function controlProposalEndDate(uint256 _pollId) internal view {
        require(polls[_pollId].proposalEndDate > block.timestamp, "The proposal phase has ended.");
    }

    /**
     * @notice Returns the details of a specific poll by ID.
     * @param _pollId The ID of the poll to retrieve.
     * @return Poll The Poll structure containing the poll details.
     */
    function getPoll(uint256 _pollId) public view returns (Poll memory) {
        requirePollToExist(_pollId);
        return polls[_pollId];
    }

    /**
     * @notice Ensures that the voting phase is open for the given poll.
     * @dev Reverts if the voting phase is not currently open.
     * @param _pollId The ID of the poll to check.
     */
    function isVotingOpen(uint256 _pollId) internal view {
        require(
            polls[_pollId].votingStartDate < block.timestamp && polls[_pollId].endDate > block.timestamp,
            "Voting is not allowed at this time"
        );
    }

    /**
     * @notice Ensures that the poll exists.
     * @dev Reverts if the poll does not exist.
     * @param _pollId The ID of the poll to check.
     */
    function requirePollToExist(uint256 _pollId) internal view {
        require(_pollId > 0 && _pollId <= pollCount, "Poll ID does not exist");
    }

    /**
     * @notice Ensures that the maximum vote score is within the allowed range.
     * @dev Reverts if the max vote score is greater than 100.
     * @param _maxVoteScore The maximum vote score to validate.
     */
    function requireMaxVoteScoreWithinRange(uint8 _maxVoteScore) internal pure {
        require(_maxVoteScore <= 100, "Max vote score must be betweeen 0 and 100");
    }

    /**
     * @notice Ensures that the voter's score is within the allowed range for the poll.
     * @dev Reverts if the vote score exceeds the poll's maximum vote score.
     * @param _score The score to validate.
     * @param _pollId The ID of the poll to check the score against.
     */
    function requireVoterScoreWithinRange(uint8 _score, uint256 _pollId) internal view {
        require(_score <= polls[_pollId].maxVoteScore, "Vote score must be between 0 and max score");
    }

    /**
     * @notice Checks whether the caller has already voted in the specified poll.
     * @param _pollId The ID of the poll to check.
     * @return voted True if the caller has voted, false otherwise.
     */
    function hasVoted(uint256 _pollId) internal view returns (bool voted) {
        address[] memory addresses = votersForPoll[_pollId];

        for (uint256 i; i < addresses.length;) {
            if (addresses[i] == msg.sender) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @notice Checks whether the caller has voted as a delegate in the specified poll.
     * @param _pollId The ID of the poll to check.
     * @return voted True if the caller has voted as a delegate, false otherwise.
     */
    function hasVotedAsDelegate(uint256 _pollId) internal view returns (bool voted) {
        address[] memory addresses = delegateVotersForPoll[_pollId];

        for (uint256 i; i < addresses.length;) {
            if (addresses[i] == msg.sender) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }
}
