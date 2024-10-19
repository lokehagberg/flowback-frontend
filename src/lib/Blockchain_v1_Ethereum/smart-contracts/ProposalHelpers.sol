// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol"; // Handles poll-specific logic
import "lib/forge-std/src/console.sol"; // For debugging, remove in production

/**
 * @title ProposalHelpers
 * @dev This contract manages proposals within polls, including adding proposals,
 * retrieving proposal details, and updating proposal votes and scores.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract ProposalHelpers is PollHelpers {
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 proposalId;
        uint256 predictionCount;
        uint256 score;
        address creator;
    }

    // Mapping to store proposals by pollId and proposalId
    mapping(uint256 => mapping(uint256 => Proposal)) public proposals;
    // Mapping to track the number of proposals per poll
    mapping(uint256 => uint256) public proposalCount;

    // Custom error for when a proposal doesn't exist
    error PH_ProposalDoesNotExist(uint256 pollId, uint256 proposalId);

    // Event emitted when a proposal is added
    event ProposalAdded(uint256 indexed pollId, uint256 indexed proposalId, string description);
    event ProposalUpdated(uint256 pollId, uint256 proposalId, uint256 newVoteCount, uint256 newScore);


   /**
     * @notice Adds a proposal to a poll.
     * @param _pollId The ID of the poll to add a proposal to.
     * @param _description The description of the proposal.
     */
    function addProposal(uint256 _pollId, string calldata _description) external {
        console.log("addProposal called for pollId:", _pollId, "by:", msg.sender);

        requirePollToExist(_pollId); // Ensure the poll exists
        controlProposalEndDate(_pollId); // Check if the proposal period is still open

        // Increment the proposal count and assign the new proposal ID
        proposalCount[_pollId]++;
        uint256 _proposalId = proposalCount[_pollId];

        // Create and store the new proposal
        Proposal memory newProposal = Proposal({
            description: _description,
            voteCount: 0,
            proposalId: _proposalId,
            predictionCount: 0,
            score: 0,
            creator: msg.sender
        });

        proposals[_pollId][_proposalId] = newProposal;

        console.log("Proposal added:", _proposalId, "Description:", _description);
        emit ProposalAdded(_pollId, _proposalId, _description);
    }

     /**
     * @notice Retrieves the results of all proposals in a specified poll.
     * @param _pollId The ID of the poll to retrieve results from.
     * @return proposalDescriptions An array of descriptions of the proposals.
     * @return voteCounts An array of vote counts for each proposal.
     * @return scores An array of scores for each proposal.
     */
    function getPollResults(uint256 _pollId)
        external
        view
        returns (string[] memory proposalDescriptions, uint256[] memory voteCounts, uint256[] memory scores) {
        requirePollToExist(_pollId); // Ensure the poll exists

        uint256 count = proposalCount[_pollId];
        proposalDescriptions = new string[](count);
        voteCounts = new uint256[](count);
        scores = new uint256[](count);

        for (uint256 i = 1; i <= count; i++) {
            Proposal memory proposal = proposals[_pollId][i];
            proposalDescriptions[i - 1] = proposal.description;
            voteCounts[i - 1] = proposal.voteCount;
            scores[i - 1] = proposal.score;
        }

        return (proposalDescriptions, voteCounts, scores);
    }

    /**
     * @notice Retrieves a specific proposal within a poll.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal.
     * @return The proposal struct.
     */
    function getProposal(uint256 _pollId, uint256 _proposalId) public view returns (Proposal memory) {
        requireProposalToExist(_pollId, _proposalId); // Ensure the proposal exists
        return proposals[_pollId][_proposalId];
    }

     /**
     * @notice Retrieves all proposals associated with a specific poll.
     * @param _pollId The ID of the poll to retrieve proposals from.
     * @return An array of Proposal structs representing all proposals in the specified poll.
     */
    function getProposals(uint256 _pollId) external view returns (Proposal[] memory) {
        requirePollToExist(_pollId); // Ensure the poll exists

        uint256 count = proposalCount[_pollId];
        Proposal[] memory pollProposals = new Proposal[](count);

        for (uint256 i = 1; i <= count; i++) {
            pollProposals[i - 1] = proposals[_pollId][i];
        }

        return pollProposals;
    }
    
     /**
     * @notice Updates the vote count and score of a specific proposal.
     * @param _pollId The ID of the poll containing the proposal.
     * @param _proposalId The ID of the proposal to update.
     * @param voteIncrease The amount to increase the vote count by.
     * @param scoreIncrease The amount to increase the score by.
     */
    function updateProposalVotes(uint256 _pollId, uint256 _proposalId, uint256 voteIncrease, uint256 scoreIncrease)
        public {
        Proposal storage proposal = proposals[_pollId][_proposalId];
        proposal.voteCount += voteIncrease;
        proposal.score += scoreIncrease;
        emit ProposalUpdated(_pollId, _proposalId, proposal.voteCount, proposal.score);
    }

    /**
     * @notice Ensures that a proposal exists within a specified poll.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal.
     */
    function requireProposalToExist(uint256 _pollId, uint256 _proposalId) internal view {
        if (proposals[_pollId][_proposalId].creator == address(0)) {
            revert PH_ProposalDoesNotExist(_pollId, _proposalId);
        }
    }
}
