// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {PollHelpers} from "./PollHelpers.sol";

/**
 * @title ProposalHelpers
 * @dev This contract manages proposals associated with polls, including adding proposals, retrieving results, and ensuring proposals exist.
 * @notice This contract allows for the creation of proposals within polls and retrieves the results of proposals.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract ProposalHelpers is PollHelpers {
    /**
     * @dev Struct representing a proposal in a poll.
     * @param description The text describing the proposal.
     * @param voteCount The total number of votes received by the proposal.
     * @param proposalId The unique ID of the proposal.
     * @param predictionCount The count of predictions linked to the proposal.
     * @param score The total score assigned to the proposal by voters.
     */
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 proposalId;
        uint256 predictionCount;
        uint256 score;
    }

    /// @notice Maps a poll ID to an array of proposals within that poll.
    mapping(uint256 => Proposal[]) public proposals;

    /**
     * @notice Emitted when a new proposal is added to a poll.
     * @param pollId The ID of the poll to which the proposal was added.
     * @param proposalId The unique ID of the added proposal.
     * @param description The description of the added proposal.
     */
    event ProposalAdded(uint256 indexed pollId, uint256 proposalId, string description);

    /**
     * @notice Adds a new proposal to a specified poll.
     * @dev The poll must exist, and the proposal phase must still be open for a new proposal to be added.
     * @param _pollId The ID of the poll to add the proposal to.
     * @param _description The text description of the proposal.
     */
    function addProposal(uint256 _pollId, string calldata _description) public {
        requirePollToExist(_pollId);
        controlProposalEndDate(_pollId);
        polls[_pollId].proposalCount++;
        uint256 _proposalId = polls[_pollId].proposalCount;

        proposals[_pollId].push(
            Proposal({description: _description, voteCount: 0, proposalId: _proposalId, predictionCount: 0, score: 0})
        );

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
        public
        view
        returns (string[] memory proposalDescriptions, uint256[] memory voteCounts, uint256[] memory scores)
    {
        requirePollToExist(_pollId);

        Proposal[] memory pollProposals = proposals[_pollId];

        proposalDescriptions = new string[](pollProposals.length);
        voteCounts = new uint256[](pollProposals.length);
        scores = new uint256[](pollProposals.length);

        for (uint256 i = 0; i < pollProposals.length; i++) {
            proposalDescriptions[i] = pollProposals[i].description;
            voteCounts[i] = pollProposals[i].voteCount;
            scores[i] = pollProposals[i].score;
        }

        return (proposalDescriptions, voteCounts, scores);
    }

    /**
     * @notice Retrieves all proposals associated with a specified poll.
     * @param _pollId The ID of the poll to retrieve proposals from.
     * @return An array of Proposal structs representing all proposals in the specified poll.
     */
    function getProposals(uint256 _pollId) external view returns (Proposal[] memory) {
        requirePollToExist(_pollId);
        return proposals[_pollId];
    }

    /**
     * @notice Ensures that a proposal exists within a specified poll.
     * @dev This function checks if a proposal with the specified ID exists in the poll's proposal list.
     * @param _pollId The ID of the poll to check.
     * @param _proposalId The ID of the proposal to check.
     * @return True if the proposal exists, false otherwise.
     */
    function requireProposalToExist(uint256 _pollId, uint256 _proposalId) internal view returns (bool) {
        uint256 proposalsLength = proposals[_pollId].length;
        for (uint256 i = 0; i < proposalsLength; i++) {
            if (proposals[_pollId][i].proposalId == _proposalId) {
                return true;
            }
        }
        return false;
    }
}
