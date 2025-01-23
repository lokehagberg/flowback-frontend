// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Polls} from "./Polls.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MetaTxHandler
 * @notice This contract handles meta-transactions for voting, allowing off-chain signature verification
 *         and relayed transactions to the Polls contract for gasless voting.
 * @dev The MetaTxHandler contract interacts with an instance of the Polls contract, enabling
 *      verified votes to be relayed by an authorized relayer. The relayer is initially set to the
 *      deployer but can be changed by the contract owner.
 * Inherits:
 * - `Ownable`: Provides access control, allowing only the owner to change the relayer address.
 * State Variables:
 * - `pollsContract`: Address of the Polls contract instance where votes are relayed.
 * - `relayer`: Address authorized to submit meta-transaction votes on behalf of users.
 * Features:
 * - **Relayer Management**: Allows the owner to set or update the relayer responsible for submitting
 *   meta-transactions.
 * - **Meta-Vote Handling**: Processes meta-votes, which are relayed to the Polls contract after
 *   off-chain signature verification.
 * Events:
 * - `Debug`: Emitted to log and track each meta-vote, useful for off-chain debugging and monitoring.
 * Requirements:
 * - Only the contract owner can set a new relayer address.
 * - Only the relayer can submit meta-votes via the `handleMetaVote` function.
 */
contract MetaTxHandler is Ownable {
    // -------------------- State Variables --------------------
    Polls public pollsContract;
    address public relayer;

    // -------------------- Modifiers --------------------
    modifier onlyRelayer() {
        require(msg.sender == relayer, "Only the relayer can call this function");
        _;
    }

    // -------------------- Constructor --------------------
    constructor(address _pollsContract) {
        pollsContract = Polls(_pollsContract);
        relayer = msg.sender; // Initially set the deployer as the relayer
    }

    // --------------------External Functions --------------------

    /**
     * @notice Sets a new relayer responsible for submitting meta-transactions.
     * @dev Only the owner can set the relayer.
     * @param _relayer The address of the new relayer.
     */
    function setRelayer(address _relayer) external onlyOwner {
        relayer = _relayer;
    }

    /**
     * @notice Processes a meta-vote after off-chain verification.
     * @dev Only the relayer can call this function after verifying the voter's signature off-chain.
     * @param _pollId The ID of the poll.
     * @param _proposalId The ID of the proposal within the poll.
     * @param _score The score for the vote.
     * @param voter The address of the voter.
     * @param _group The ID of the group in which the voter is participating.
     */
    function handleMetaVote(uint256 _pollId, uint256 _proposalId, uint8 _score, address voter, uint256 _group)
        external
        onlyRelayer
    {
        // Emit debug information for tracking
        emit Debug(voter, _pollId, _proposalId, _score, _group);

        // Relay the vote directly after off-chain verification by relayer
        pollsContract.vote(_pollId, _proposalId, _score, _group);
    }

    // -------------------- Test Functions --------------------
    event Debug(address voter, uint256 pollId, uint256 proposalId, uint8 score, uint256 group);
}
