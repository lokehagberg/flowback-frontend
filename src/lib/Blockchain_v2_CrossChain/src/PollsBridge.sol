// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

/**
 * @title PollsBridge
 * @notice This contract facilitates bridging poll results between the Base and Ethereum networks. 
 *         It enables the transfer of finalized poll results from the Polls contract on Base to 
 *         the corresponding Polls contract on Ethereum using cross-chain messaging.
 * @dev This contract is designed to interact with cross-chain solutions (e.g., LayerZero, Axelar, Chainlink CCIP)
 *      to securely bridge poll data across chains. Only the authorized Polls contract on Base can initiate a 
 *      bridge request to send results to Ethereum.
 * 
 * State Variables:
 * - `ethereumPollsContract`: The address of the Polls contract on Ethereum, where results will be sent.
 * - `basePollsContract`: The address of the Polls contract on Base, which has permission to bridge results.
 * 
 * Events:
 * - `BridgeRequestSent`: Emitted when a bridge request is sent to Ethereum, including the poll ID and result hash.
 * 
 * Requirements:
 * - Only the designated `basePollsContract` can call `bridgeResults` to ensure only authorized results are bridged.
 * 
 * Usage:
 * - **Cross-Chain Bridging**: Use `bridgeResults` to send finalized poll results to the Polls contract on Ethereum.
 * - **Contract Address Management**: Use `setEthereumPollsContract` and `setBasePollsContract` to set or update 
 *   the respective Polls contract addresses.
 */
contract PollsBridge {
    // -------------------- Events --------------------

    event BridgeRequestSent(uint256 indexed pollId, bytes32 resultHash);

    // -------------------- State Variables --------------------

    address public ethereumPollsContract;
    address public basePollsContract;

    // -------------------- External Functions --------------------

    // Set the address of the Polls contract on Ethereum
    function setEthereumPollsContract(address _ethereumPollsContract) external {
        ethereumPollsContract = _ethereumPollsContract;
    }

    // Set the address of the Polls contract on Base
    function setBasePollsContract(address _basePollsContract) external {
        basePollsContract = _basePollsContract;
    }

    /**
     * @notice Sends the finalized poll results to the Ethereum contract.
     * @param _pollId The ID of the poll.
     * @param _resultHash The result hash of the poll.
     */
    function bridgeResults(uint256 _pollId, bytes32 _resultHash) external {
        require(msg.sender == basePollsContract, "Only the Polls contract on Base can call this");

        // !!Use cross-chain messaging solution here to send data to Ethereum
        // !!Example: LayerZero, Axelar, Chainlink CCIP integration

        emit BridgeRequestSent(_pollId, _resultHash);
    }
}
