// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

/**
 * @title PollsOnEthereum
 * @notice This contract manages poll results and individual votes that are bridged from the Base network. 
 *         It stores finalized poll results and individual voter scores for verification on Ethereum.
 * @dev Only the designated bridge contract can call functions that store results and votes, ensuring 
 *      that only verified data from the bridge is recorded.
 * 
 * State Variables:
 * - `bridgeContract`: The address of the bridge contract authorized to store poll results and votes.
 * - `pollResults`: Mapping of poll IDs to their respective `PollResult` structs, storing poll results and finalization status.
 * - `voterScores`: Mapping that stores individual scores given by voters for each proposal in a poll.
 * 
 * Structs:
 * - `PollResult`: Contains the poll ID, result hash, and finalization status, representing the finalized state of a poll.
 * 
 * Events:
 * - `PollResultReceived`: Emitted when a poll result is successfully stored, including poll ID and result hash.
 * - `VoteStored`: Emitted when an individual vote score is recorded, including poll ID, voter, proposal ID, and score.
 * 
 * Modifiers:
 * - `onlyBridge`: Restricts function access to the bridge contract, ensuring that only verified data is stored.
 * 
 * Requirements:
 * - Only the bridge contract can call `storePollResult` and `storeIndividualVote`.
 * - Poll results can only be stored once; subsequent calls to store a finalized poll will revert.
 * 
 * Usage:
 * - **Set Bridge Contract**: Use `setBridgeContract` to set or update the bridge contract address.
 * - **Store Poll Results**: Use `storePollResult` to store bridged poll results, which finalizes the poll.
 * - **Store Individual Votes**: Use `storeIndividualVote` to record individual scores for verification on Ethereum.
 */
contract PollsOnEthereum {
    // -------------------- Structs --------------------
    struct PollResult {
        uint256 pollId;
        bytes32 resultHash;
        bool finalized;
    }

    // -------------------- State Variables --------------------
    address public bridgeContract;

    mapping(uint256 => PollResult) public pollResults;
    mapping(uint256 => mapping(address => mapping(uint256 => uint8))) public voterScores;

    // -------------------- Events --------------------
    event PollResultReceived(uint256 indexed pollId, bytes32 resultHash);
    event VoteStored(uint256 indexed pollId, address indexed voter, uint256 proposalId, uint8 score);

    // -------------------- Modifiers --------------------
    // Only the bridge contract can update results
    modifier onlyBridge() {
        require(msg.sender == bridgeContract, "Only bridge contract can call this");
        _;
    }

    // -------------------- External Functions --------------------

   /**
     * @notice Sets the address of the bridge contract.
     * @param _bridgeContract The address of the bridge contract authorized to store results and votes.
     */
    function setBridgeContract(address _bridgeContract) external {
        bridgeContract = _bridgeContract;
    }

    /**
     * @notice Stores the bridged poll result from Base.
     * @param _pollId The ID of the poll.
     * @param _resultHash The result hash.
     * 
     * Requirements:
     * - Only the bridge contract can call this function.
     * - The poll must not have already been finalized.
     * 
     * Emits:
     * - `PollResultReceived` with the poll ID and result hash.
     */
    function storePollResult(uint256 _pollId, bytes32 _resultHash) external onlyBridge {
        PollResult storage result = pollResults[_pollId];
        require(!result.finalized, "Poll already finalized");

        result.pollId = _pollId;
        result.resultHash = _resultHash;
        result.finalized = true;

        emit PollResultReceived(_pollId, _resultHash);
    }

    /**
     * @notice Allows storing of individual votes for verification.
     * @param _pollId The poll ID.
     * @param _voter The voter's address.
     * @param _proposalId The proposal ID.
     * @param _score The score given by the voter.
     * 
     * Requirements:
     * - Only the bridge contract can call this function.
     * 
     * Emits:
     * - `VoteStored` with the poll ID, voter's address, proposal ID, and score.
     */
    function storeIndividualVote(uint256 _pollId, address _voter, uint256 _proposalId, uint8 _score)
        external
        onlyBridge
    {
        voterScores[_pollId][_voter][_proposalId] = _score;
        emit VoteStored(_pollId, _voter, _proposalId, _score);
    }
}
