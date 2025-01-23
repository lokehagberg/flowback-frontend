// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";

/**
 * @title Predictions
 * @dev This contract manages the creation and retrieval of predictions associated with proposals in polls.
 * @notice This contract allows users to create predictions for proposals and retrieve existing predictions for a specific poll and proposal.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract Predictions is PollHelpers, ProposalHelpers, PredictionHelpers {
    /**
     * @notice Emitted when a new prediction is created.
     * @param pollId The ID of the poll in which the prediction was created.
     * @param proposalId The ID of the proposal associated with the prediction.
     * @param predictionId The unique ID of the prediction.
     * @param prediction The text content of the prediction.
     */
    event PredictionCreated(
        uint256 indexed pollId, uint256 indexed proposalId, uint256 indexed predictionId, string prediction
    );

    /**
     * @notice Creates a new prediction for a specific proposal within a poll.
     * @dev The proposal must exist before a prediction can be created. The prediction ID is incremented and assigned automatically.
     * @param _pollId The ID of the poll where the prediction is being created.
     * @param _proposalId The ID of the proposal associated with the prediction.
     * @param _prediction The content of the prediction.
     */
    function createPrediction(uint256 _pollId, uint256 _proposalId, string memory _prediction) external {
        // Call requireProposalToExist without an additional require statement.
        requireProposalToExist(_pollId, _proposalId);

        // Access the proposal directly, no need to subtract 1 from the proposalId.
        Proposal storage proposal = proposals[_pollId][_proposalId];
        proposal.predictionCount++; // Increment prediction count by one
        uint256 _predictionId = proposal.predictionCount; // Set prediction ID

        // Add the prediction to the list of predictions for this proposal
        predictions[_proposalId].push(
            Prediction({pollId: _pollId, proposalId: _proposalId, predictionId: _predictionId, prediction: _prediction})
        );
        emit PredictionCreated(_pollId, _proposalId, _predictionId, _prediction);
    }

    /**
     * @notice Retrieves all predictions associated with a specific proposal in a poll.
     * @dev The proposal must exist before predictions can be retrieved.
     * @param _pollId The ID of the poll containing the proposal.
     * @param _proposalId The ID of the proposal for which predictions are being retrieved.
     * @return An array of Prediction structs representing all predictions for the given proposal.
     */
    function getPredictions(uint256 _pollId, uint256 _proposalId) external view returns (Prediction[] memory) {
        // Call requireProposalToExist without an additional require statement.
        requireProposalToExist(_pollId, _proposalId);
        // Return the list of predictions for the given proposal
        return predictions[_proposalId];
    }
}
