// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {SharedErrors} from "./SharedErrors.sol";
import "lib/forge-std/src/console.sol";

/**
 * @title ProposalHelpers
 * @notice This contract provides functions for managing proposals within polls, including adding proposals,
 *         casting votes, updating scores, and retrieving proposal details.
 * @dev Extends the `PollHelpers` contract and interacts with `SharedErrors`.
 */
contract ProposalHelpers is PollHelpers {

    // -------------------- Structs -------------------------

    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 proposalId;
        uint256 predictionCount;
        uint256 score;
        uint256 totalScore;
        address creator;
    }

    // -------------------- State Variables ------------------
    mapping(uint256 => mapping(uint256 => Proposal)) public proposals;
    mapping(uint256 => uint256) public proposalCount;

    // -------------------- Events ---------------------------
    event ProposalAdded(uint256 indexed pollId, uint256 indexed proposalId, string description);
    event ProposalUpdated(uint256 pollId, uint256 proposalId, uint256 newVoteCount, uint256 newScore);
    event VoteCast(address indexed voter, uint256 indexed pollId, uint256 indexed proposalId);


        // -------------------- External Functions --------------------

    /**
     * @notice Adds a new proposal to a poll.
     * @dev The poll must exist and be within the proposal submission phase.
     * @param _pollId The ID of the poll to add a proposal to.
     * @param _description The description of the proposal.
     * 
     * Requirements:
     * - The specified poll must exist.
     * - The current time must be within the proposal submission period.
     *
     * Emits:
     * - `ProposalAdded`: Logs the poll ID, proposal ID, and proposal description.
     */
    function addProposal(uint256 _pollId, string calldata _description) external {
        requirePollToExist(_pollId); // Ensure the poll exists
        controlProposalEndDate(_pollId); // Check if the proposal period is still open
        uint256 _proposalId = proposalCount[_pollId]++;
        Proposal memory newProposal = Proposal({
            description: _description,
            voteCount: 0,
            proposalId: _proposalId,
            predictionCount: 0,
            score: 0,
            totalScore: 0,
            creator: msg.sender
        });

        proposals[_pollId][_proposalId] = newProposal;
        emit ProposalAdded(_pollId, _proposalId, _description);
    }

    /**
     * @notice Casts a vote on a specific proposal within a poll.
     * @param _pollId The ID of the poll containing the proposal.
     * @param _proposalId The ID of the proposal to vote on.
     * 
     * Requirements:
     * - The specified poll and proposal must exist.
     * - The voter must not have already voted on the proposal.
     * 
     * Emits:
     * - `VoteCast`: Logs the voter address, poll ID, and proposal ID.
     */
    function castVote(uint256 _pollId, uint256 _proposalId) external {
        requirePollToExist(_pollId);
        requireProposalToExist(_pollId, _proposalId);

        if (userVotes[_pollId][msg.sender][_proposalId] != 0) {
            revert SH_AlreadyVoted(_pollId, msg.sender);
        }
        votersForPoll[_pollId][msg.sender] = true;
        userVotes[_pollId][msg.sender][_proposalId] = 1; // Default score, or pass the score as an argument if needed

        emit VoteCast(msg.sender, _pollId, _proposalId);
    }

    /**
     * @notice Records a meta-transaction vote on a proposal within a poll.
     * @param _pollId The ID of the poll containing the proposal.
     * @param _proposalId The ID of the proposal to vote on.
     * @param voter The address of the voter.
     * 
     * Requirements:
     * - Only the MetaVoting contract can call this function.
     * - The specified poll and proposal must exist.
     * - The voter must not have already voted on the proposal.
     */
    function recordMetaVote(uint256 _pollId, uint256 _proposalId, address voter) external {
        require(msg.sender == metaVoting, "Only MetaVoting contract can call");
        requirePollToExist(_pollId);
        requireProposalToExist(_pollId, _proposalId);

        require(!hasVoted(_pollId), "Already voted");

        votersForPoll[_pollId][voter] = true;
        userVotes[_pollId][voter][_proposalId] = 1;

        emit VoteCast(voter, _pollId, _proposalId);
    }

    /**
     * @notice Retrieves all proposals associated with a specific poll.
     * @param _pollId The ID of the poll to retrieve proposals from.
     * @return An array of Proposal structs representing all proposals in the specified poll.
     * 
     * Requirements:
     * - The specified poll must exist.
     */
    function getProposals(uint256 _pollId) external view returns (Proposal[] memory) {
        requirePollToExist(_pollId); // Ensure the poll exists

        uint256 count = proposalCount[_pollId];
        Proposal[] memory pollProposals = new Proposal[](count);

        for (uint256 i = 0; i < count; ++i) {
            pollProposals[i] = proposals[_pollId][i];
        }

        return pollProposals;
    }
        /**
     * @notice Retrieves descriptions, vote counts, and scores for all proposals within a poll.
     * @param _pollId The ID of the poll to retrieve results from.
     * @return proposalDescriptions An array of descriptions for each proposal.
     * @return voteCounts An array of vote counts for each proposal.
     * @return scores An array of scores for each proposal.
     * 
     * Requirements:
     * - The specified poll must exist.
     */
    function getPollResults(uint256 _pollId)
        external
        view
        returns (string[] memory proposalDescriptions, uint256[] memory voteCounts, uint256[] memory scores)
    {
        requirePollToExist(_pollId); // Ensure the poll exists

        uint256 count = proposalCount[_pollId];
        proposalDescriptions = new string[](count);
        voteCounts = new uint256[](count);
        scores = new uint256[](count);

        for (uint256 i = 0; i < count; ++i) {
            Proposal memory proposal = proposals[_pollId][i];
            proposalDescriptions[i] = proposal.description;
            voteCounts[i] = proposal.voteCount;
            scores[i] = proposal.score;
        }

        return (proposalDescriptions, voteCounts, scores);
    }

    // -------------------- Public Functions --------------------


    /**
     * @notice Retrieves a specific proposal within a poll.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal.
     * @return The proposal struct.
     * 
     * Requirements:
     * - The specified proposal must exist within the poll.
     */
    function getProposal(uint256 _pollId, uint256 _proposalId) public view returns (Proposal memory) {
        requireProposalToExist(_pollId, _proposalId); // Ensure the proposal exists
        return proposals[_pollId][_proposalId];
    }
      /**
     * @notice Updates the vote count and score of a specific proposal.
     * @param _pollId The ID of the poll containing the proposal.
     * @param _proposalId The ID of the proposal to update.
     * @param voteIncrease The amount to increase the vote count by.
     * @param scoreIncrease The amount to increase the score by.
     * 
     * Requirements:
     * - The specified proposal must exist.
     * - Either `voteIncrease` or `scoreIncrease` must be greater than zero.
     * 
     * Emits:
     * - `ProposalUpdated`: Logs the poll ID, proposal ID, new vote count, and new score.
     */
    function updateProposalVotes(uint256 _pollId, uint256 _proposalId, uint256 voteIncrease, uint256 scoreIncrease)
        public
    {
        requireProposalToExist(_pollId, _proposalId); // Ensure the proposal exists
        require(voteIncrease > 0 || scoreIncrease > 0, "No changes to update"); // Check input values

        Proposal storage proposal = proposals[_pollId][_proposalId];
        proposal.voteCount += voteIncrease;
        proposal.score += scoreIncrease;
        emit ProposalUpdated(_pollId, _proposalId, proposal.voteCount, proposal.score);
    }

    // -------------------- Internal Functions --------------------

        /**
     * @dev Checks that a specified proposal exists within a poll.
     * @param pollId The ID of the poll.
     * @param proposalId The ID of the proposal.
     * 
     * Reverts:
     * - `SH_ProposalDoesNotExist` if the proposal does not exist.
     */
    function requireProposalToExist(uint256 pollId, uint256 proposalId) internal view {
        console.log("Checking proposal existence: pollId =", pollId, "proposalId =", proposalId);
        if (proposals[pollId][proposalId].creator == address(0)) {
            revert SH_ProposalDoesNotExist(pollId, proposalId);
        }
        console.log("Proposal exists:", pollId, proposalId);
    }
    /**
     * @dev Ensures that the current time is within the proposal submission period for the specified poll.
     * @param _pollId The ID of the poll to check.
     * 
     * Reverts:
     * - `PH_ProposalPhaseEnded` if the proposal submission period has ended.
     */
    function controlProposalEndDate(uint256 _pollId) internal view {
        if (polls[_pollId].details.proposalEndDate <= block.timestamp) {
            revert PH_ProposalPhaseEnded(_pollId, polls[_pollId].details.proposalEndDate, block.timestamp);
        }
    }

    // -------------------- Testing Functions --------------------
    function publicControlProposalEndDate(uint256 _pollId) external view {
        controlProposalEndDate(_pollId);
    }
}
