// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";

/**
 * @title PredictionBetHelpers
 * @dev This contract extends PollHelpers, ProposalHelpers, and PredictionHelpers to manage prediction bets related to polls and proposals.
 * @notice This contract facilitates the storage and management of prediction bets made by users on proposals and predictions within polls.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract PredictionBetHelpers is PollHelpers, ProposalHelpers, PredictionHelpers {
    /**
     * @dev Struct to represent a prediction bet placed by a user.
     * @param pollId The ID of the poll where the bet is placed.
     * @param proposalId The ID of the proposal within the poll that the bet is related to.
     * @param predictionId The ID of the prediction related to the bet.
     * @param bet A boolean representing whether the bet is for or against the prediction.
     * @param likelihood The likelihood score assigned to the prediction.
     */
    struct PredictionBet {
        uint256 pollId;
        uint256 proposalId;
        uint256 predictionId;
        bool bet;
        uint256 likelihood;
    }

    /// @notice Maps a poll ID to an array of PredictionBet structures representing all bets made in that poll.
    mapping(uint256 => mapping(uint256 => PredictionBet[])) public predictionBets;
}
