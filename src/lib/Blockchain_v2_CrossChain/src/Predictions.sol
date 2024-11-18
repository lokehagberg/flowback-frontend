// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";
import "forge-std/console.sol";

/**
 * @title Predictions
 * @notice This contract allows users to create and retrieve predictions associated with specific proposals in polls.
 * @dev Extends `PollHelpers`, `ProposalHelpers`, and `PredictionHelpers`.
 * Events:
 * - `PredictionCreated`: Emitted when a new prediction is successfully created.
 * Requirements:
 * - Proposals must exist within a poll before predictions can be created or retrieved.
 * Usage:
 * - **Creating Predictions**: Call `createPrediction` to add a prediction to a specific proposal within a poll.
 * - **Retrieving Predictions**: Call `getPredictions` to view all predictions associated with a specific proposal.
 */
contract Predictions is PollHelpers, ProposalHelpers, PredictionHelpers {

    // -------------------- Events --------------------
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

    // --------------------External Functions -------------------
    /**
     * @notice Creates a new prediction for a specific proposal within a poll.
     * @dev The proposal must exist before a prediction can be created. The prediction ID is auto-incremented.
     * @param _pollId The ID of the poll where the prediction is being created.
     * @param _proposalId The ID of the proposal associated with the prediction.
     * @param _prediction The content of the prediction.
     *
     * Requirements:
     * - The proposal identified by `_pollId` and `_proposalId` must exist.
     *
     * Emits:
     * - `PredictionCreated`: Logs the poll ID, proposal ID, prediction ID, and prediction text.
     */
    function createPrediction(uint256 _pollId, uint256 _proposalId, string memory _prediction) external {
        // Ensure the proposal exists
        requireProposalToExist(_pollId, _proposalId);
        // Access the proposal and increment the prediction count
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
     *
     * Requirements:
     * - The proposal identified by `_pollId` and `_proposalId` must exist.
     */
    function getPredictions(uint256 _pollId, uint256 _proposalId) external view returns (Prediction[] memory) {
        // Call requireProposalToExist without an additional require statement.
        requireProposalToExist(_pollId, _proposalId);
        // Return the list of predictions for the given proposal
        return predictions[_proposalId];
    }
}
