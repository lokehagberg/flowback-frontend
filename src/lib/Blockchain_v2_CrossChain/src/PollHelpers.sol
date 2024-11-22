// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "lib/forge-std/src/console.sol";
import "./SharedErrors.sol";

/**
 * @title PollHelpers Contract
 * @notice This contract provides helper functions and utilities for managing polls, including poll creation,
 *         validation, and voting score checks. It defines the structure and essential details of a poll, such as
 *         voting and proposal phases, and stores each poll's settings.
 * @dev This contract is designed to be inherited by other contracts that require poll management functionality.
 *      It includes modular validation functions to ensure that poll phases and voting scores meet specified criteria.
 *
 * Inherits:
 * - `Ownable`: Provides authorization control for functions restricted to the contract owner.
 * - `SharedErrors`: Includes custom error handling for reusability across multiple contracts.
 *
 * Features:
 * - **Poll Creation**: Allows the owner to create new polls with specified parameters.
 * - **Voting Validation**: Provides functions to check if a poll is in the voting phase and if a given score is valid.
 * - **Delegate Voting Tracking**: Tracks delegate voting activity within each poll.
 * - **Custom Error Handling**: Uses custom errors to reduce gas costs for failed transactions.
 *
 * State Variables:
 * - `metaVoting`: The address of the MetaVoting contract authorized to manage specific voting operations.
 * - `pollCount`: The total number of polls created.
 *
 * Mappings:
 * - `polls`: Maps each poll ID to its respective `Poll` structure.
 * - `pollSettings`: Maps each poll ID to its `PollSettings`, defining poll configuration.
 * - `votersForPoll`: Tracks addresses that have voted in specific polls.
 * - `delegateVotersForPoll`: Tracks addresses that have voted as delegates in specific polls.
 * - `userVotes`: Stores individual user votes for each proposal within each poll.
 *
 * Events:
 * - `PollCreated`: Emitted when a new poll is created, recording the poll ID, title, and on-chain storage preference.
 * - `DelegateVoteCast`: Emitted when a delegate casts a vote, recording the delegate address and poll ID.
 *
 * Requirements:
 * - Only the contract owner can set the MetaVoting address and create polls.
 * - Polls must be validated for existence and active voting phases before any voting activity.
 * - Score values must be within defined limits to prevent invalid votes.
 */
contract PollHelpers is SharedErrors, Ownable {
    // -------------------- Errors --------------------
    error PH_ProposalPhaseEnded(uint256 pollId, uint256 proposalEndDate, uint256 currentTimestamp);
    error PH_VotingNotAllowed(uint256 pollId, uint256 votingStartDate, uint256 endDate, uint256 currentTimestamp);
    error PH_PollDoesNotExist(uint256 pollId);
    error PH_MaxVoteScoreOutOfRange(uint8 providedScore);
    error PH_VoteScoreExceedsMax(uint8 providedScore, uint8 maxScore);

    // -------------------- Structs --------------------
    struct Poll {
        PollDetails details;
        PollSettings settings;
        uint256 pollId;
        uint256 proposalCount;
    }

    struct PollDetails {
        string title;
        string tag;
        uint256 group;
        uint256 pollStartDate;
        uint256 proposalEndDate;
        uint256 votingStartDate;
        uint256 delegateEndDate;
        uint256 endDate;
    }

    struct PollSettings {
        uint8 maxVoteScore;
        bool storeOnEthereum;
        bool finalized;
        bytes32 resultHash;
    }

    // -------------------- State Variables --------------------
    address public metaVoting;

    mapping(uint256 => Poll) public polls;
    mapping(uint256 => mapping(address => bool)) internal votersForPoll;
    mapping(uint256 => mapping(address => bool)) internal delegateVotersForPoll;
    uint256 public pollCount = 0;
    mapping(uint256 => PollSettings) public pollSettings;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userVotes;

    // -------------------- Events --------------------
    event PollCreated(uint256 indexed pollId, string title, bool storeOnEthereum);
    event DelegateVoteCast(address indexed delegateVoter, uint256 indexed pollId);

    // -------------------- External Functions --------------------
    /**
     * @notice Sets the address of the MetaVoting contract.
     * @dev This function is restricted to the contract owner. It assigns the `_metaVoting`
     *      address to the `metaVoting` state variable, allowing interaction with an
     *      external MetaVoting contract for enhanced voting operations.
     * @param _metaVoting The address of the MetaVoting contract to be set.
     * Requirements:
     * - Caller must be the contract owner.
     */
    function setMetaVoting(address _metaVoting) external onlyOwner {
        metaVoting = _metaVoting;
    }

    /**
     * @notice Creates a new poll with specified details and settings.
     * @dev This function can only be called by the contract owner. It sets up the structure 
     *      and settings of the poll, including the poll phases and score restrictions.
     * @param _title The title of the poll.
     * @param _tag A tag categorizing the poll.
     * @param _group The ID of the group associated with the poll.
     * @param _pollStartDate The start date of the poll (timestamp in seconds).
     * @param _proposalEndDate The end date for submitting proposals (timestamp in seconds).
     * @param _votingStartDate The start date for voting in the poll (timestamp in seconds).
     * @param _delegateEndDate The end date for delegating votes (timestamp in seconds).
     * @param _endDate The end date for the poll (timestamp in seconds).
     * @param _maxVoteScore The maximum allowable score for votes in this poll.
     * @param _storeOnEthereum Boolean flag indicating if poll results will be stored on Ethereum. 
     * Requirements:
     * - `_maxVoteScore` must be within the allowable range (checked by `requireMaxVoteScoreWithinRange`).
     * - Only the contract owner can create a poll. 
     * Emits:
     * - `PollCreated`: Emitted upon successful poll creation, logging the poll ID, title, 
     *   and whether the results will be stored on Ethereum.
     */
    function createPoll(
        string memory _title,
        string memory _tag,
        uint256 _group,
        uint256 _pollStartDate,
        uint256 _proposalEndDate,
        uint256 _votingStartDate,
        uint256 _delegateEndDate,
        uint256 _endDate,
        uint8 _maxVoteScore,
        bool _storeOnEthereum
    ) external onlyOwner {
        requireMaxVoteScoreWithinRange(_maxVoteScore);

        pollCount++;
        Poll storage newPoll = polls[pollCount];

        newPoll.pollId = pollCount;
        newPoll.details = PollDetails({
            title: _title,
            tag: _tag,
            group: _group,
            pollStartDate: _pollStartDate,
            proposalEndDate: _proposalEndDate,
            votingStartDate: _votingStartDate,
            delegateEndDate: _delegateEndDate,
            endDate: _endDate
        });

        newPoll.settings = PollSettings({
            maxVoteScore: _maxVoteScore,
            storeOnEthereum: _storeOnEthereum,
            finalized: false,
            resultHash: bytes32(0)
        });
        pollSettings[pollCount] = newPoll.settings;

        emit PollCreated(newPoll.pollId, _title, _storeOnEthereum);
    }

    // -------------------- Public Functions --------------------
    /**
     * @notice Retrieves the details of a specified poll.
     * @param _pollId The ID of the poll to retrieve.
     * @return A `Poll` structure containing the details and settings of the specified poll.
     * Requirements:
     * - The poll with `_pollId` must exist.
     * Reverts:
     * - `PH_PollDoesNotExist` if the poll with the specified `_pollId` does not exist.
     */
    function getPoll(uint256 _pollId) external view returns (Poll memory) {
        requirePollToExist(_pollId);
        return polls[_pollId];
    }

    // -------------------- Internal Functions --------------------

    /**
     * @dev Ensures that a poll with the specified ID exists.
     * @param _pollId The ID of the poll to check.
     * Requirements:
     * - `_pollId` must be greater than zero and less than or equal to the current `pollCount`.
     * Reverts:
     * - `PH_PollDoesNotExist` if `_pollId` is zero or exceeds the number of existing polls.
     */
    function requirePollToExist(uint256 _pollId) internal view {
        if (_pollId == 0 || _pollId > pollCount) {
            revert PH_PollDoesNotExist(_pollId);
        }
    }

    /**
     * @dev Validates that a given vote score is within the allowable range.
     * @param score The score to validate.
     * Requirements:
     * - `score` must be 100 or less.
     * Reverts:
     * - `PH_MaxVoteScoreOutOfRange` if `score` exceeds 100.
     */
    function requireMaxVoteScoreWithinRange(uint8 score) internal pure{
        if (score > 100) {
            revert PH_MaxVoteScoreOutOfRange(score);
        }
    }

    /**
     * @dev Ensures that the given vote `score` does not exceed the maximum allowed score for the specified poll.
     * @param score The vote score to validate.
     * @param pollId The ID of the poll for which the score is being validated.
     * Requirements:
     * - `score` must be less than or equal to the maximum vote score allowed in the poll settings.
     * Reverts:
     * - `PH_VoteScoreExceedsMax` if `score` is greater than the poll's defined maximum score.
     */
    function requireVoterScoreWithinRange(uint8 score, uint256 pollId) internal view {
        uint8 maxScore = pollSettings[pollId].maxVoteScore;
        if (score > maxScore) {
            revert PH_VoteScoreExceedsMax(score, maxScore);
        }
    }

    /**
     * @dev Checks if the caller has already voted in a specific poll.
     * @param _pollId The ID of the poll to check.
     * @return voted `true` if the caller has voted in the poll, otherwise `false`.
     */
    function hasVoted(uint256 _pollId) internal view returns (bool voted) {
        return votersForPoll[_pollId][msg.sender];
    }

       /**
     * @dev Checks if the voting phase is currently open for a specific poll.
     * @param _pollId The ID of the poll to check.
     * @return `true` if the current timestamp is within the voting period, otherwise `false`.
     * Requirements:
     * - The poll's voting start date must be in the past, and the end date must be in the future.
     */
    function isVotingOpen(uint256 _pollId) internal view returns (bool) {
        Poll storage poll = polls[_pollId];
        return (block.timestamp >= poll.details.votingStartDate && block.timestamp <= poll.details.endDate);
    }

    // -------------------- TESTING POURPOSE --------------------

    // Expose requireMaxVoteScoreWithinRange for testing
    function publicRequireMaxVoteScoreWithinRange(uint8 score) external pure {
        requireMaxVoteScoreWithinRange(score);
    }

    // Expose controlProposalEndDate for testing
    function publicIsVotingOpen(uint256 _pollId) external view {
        require(isVotingOpen(_pollId), "PH_VotingNotAllowed");
    }
    // Expose requireVoterScoreWithinRange for testing

    function publicRequireVoterScoreWithinRange(uint8 score, uint256 pollId) external view {
        requireVoterScoreWithinRange(score, pollId);
    }
}
