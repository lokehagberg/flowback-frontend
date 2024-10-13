// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";

/**
 * @title PredictionHelpers
 * @dev This contract manages predictions related to proposals and polls, providing utility functions to ensure predictions exist and are valid.
 * @notice This contract is used to interact with predictions and validate their existence within specific proposals and polls.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract PredictionHelpers is PollHelpers, ProposalHelpers {
    /**
     * @dev Struct representing a prediction linked to a poll and proposal.
     * @param pollId The ID of the poll the prediction is linked to.
     * @param proposalId The ID of the proposal the prediction is related to.
     * @param predictionId The unique ID of the prediction.
     * @param prediction The textual content of the prediction.
     */
    struct Prediction {
        uint256 pollId;
        uint256 proposalId;
        uint256 predictionId;
        string prediction;
    }

    /// @notice Mapping from a proposal ID to an array of predictions related to that proposal.
    mapping(uint256 => Prediction[]) public predictions;

    /**
     * @notice Ensures that the prediction exists for the given proposal.
     * @dev This function checks if a prediction with the specified prediction ID exists within a proposal's predictions.
     * @param _proposalId The ID of the proposal to check for the prediction.
     * @param _predictionId The ID of the prediction to check.
     * @return predictionExists Returns true if the prediction exists, false otherwise.
     */
    function requirePredictionToExist(uint256 _proposalId, uint256 _predictionId)
        internal
        view
        returns (bool predictionExists)
    {
        uint256 predictionsLength = predictions[_proposalId].length;
        for (uint256 i = 0; i < predictionsLength; i++) {
            if (predictions[_proposalId][i].predictionId == _predictionId) {
                return true;
            }
        }
        return false;
    }
}
