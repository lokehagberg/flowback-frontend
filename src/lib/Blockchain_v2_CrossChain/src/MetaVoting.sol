// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProposalHelpers.sol"; 

/**
 * @title MetaVoting
 * @notice This contract enables meta-transactions for voting, allowing a relayer to submit votes on behalf
 *         of users. It facilitates gasless voting through a relayer who covers the transaction fees.
 * @dev This contract interacts with ProposalHelpers to record votes, using a designated relayer to submit
 *      meta-transaction votes for participants in various polls.
 *
 * Inherits:
 * - `Ownable`: Allows only the contract owner to assign the relayer.
 *
 * State Variables:
 * - `relayer`: The address authorized to submit meta-transactions on behalf of voters.
 * - `proposalHelpersContract`: Reference to the ProposalHelpers contract where votes are recorded.
 *
 * Features:
 * - **Relayer Management**: Enables the contract owner to assign a relayer responsible for submitting votes.
 * - **Meta-Vote Submission**: Allows the relayer to submit a vote via `castVoteMeta` for a specified voter and proposal.
 *
 * Events:
 * - `VoteCastMeta`: Emitted when a meta-vote is successfully cast, providing poll and proposal IDs along with the voter's address.
 *
 * Requirements:
 * - Only the contract owner can change the relayer.
 * - Only the designated relayer can call `castVoteMeta`.
 */
contract MetaVoting is Ownable {
    // -------------------- State Variables --------------------
    address public relayer;
    ProposalHelpers public proposalHelpersContract; // Reference to ProposalHelpers contract

    // -------------------- Events --------------------
    event VoteCastMeta(uint256 indexed pollId, uint256 indexed proposalId, address indexed voter);

    // -------------------- Constructor --------------------
    constructor(address _proposalHelpersContract) {
        relayer = msg.sender; // Set the contract deployer as the initial relayer
        proposalHelpersContract = ProposalHelpers(_proposalHelpersContract); // Initialize with ProposalHelpers contract
    }

    // -------------------- Public Functions --------------------

    /**
     * @notice Sets a new relayer responsible for submitting meta-transactions.
     * @dev Only the owner can set the relayer.
     * @param _relayer The address of the new relayer.
     */
    function setRelayer(address _relayer) external onlyOwner {
        relayer = _relayer;
    }

    /**
     * @notice Casts a vote via meta-transaction on behalf of a voter.
     * @dev The relayer submits this transaction on behalf of the voter, covering the gas fees.
     * @param pollId The ID of the poll in which to cast a vote.
     * @param proposalId The ID of the proposal within the poll to vote on.
     * @param voter The address of the voter casting the vote.
     */
    function castVoteMeta(uint256 pollId, uint256 proposalId, address voter) external {
        require(msg.sender == relayer, "Only relayer can submit meta-votes");
        // Call the internal voting function to process the vote
        _processVote(pollId, proposalId, voter);
    }

    /**
     * @dev Internal function to process the vote. Calls recordMetaVote in ProposalHelpers.
     * @param pollId The ID of the poll.
     * @param proposalId The ID of the proposal.
     * @param voter The address of the voter casting the vote.
     */
    function _processVote(uint256 pollId, uint256 proposalId, address voter) internal {
        proposalHelpersContract.recordMetaVote(pollId, proposalId, voter);
        emit VoteCastMeta(pollId, proposalId, voter);
    }
}
