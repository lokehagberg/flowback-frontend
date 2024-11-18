// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {PollsBridge} from "./PollsBridge.sol";
import {RightToVote} from "./RightToVote.sol";
import {Delegations} from "./Delegations.sol";
import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {Predictions} from "./Predictions.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";
import {PredictionBetHelpers} from "./PredictionBetHelpers.sol";
import {PredictionBets} from "./PredictionBets.sol";
import "forge-std/console.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Polls Contract
 * @notice This contract manages decentralized voting polls, supporting direct voting,
 *         delegate voting, and meta-transactions for gasless interactions.
 * @dev The contract integrates multiple modules for voting, delegation, proposal management,
 *      and cross-chain bridging. It allows the contract owner to set a bridge contract for
 *      cross-chain operations and a meta-transaction handler for gasless voting.
 *
 * Inherits:
 * - Ownable: Ensures that certain functions can only be called by the contract owner.
 * - RightToVote: Manages voting rights and eligibility.
 * - Delegations: Supports delegated voting where users can allow others to vote on their behalf.
 * - PollHelpers, ProposalHelpers, PredictionHelpers, Predictions, PredictionBetHelpers, PredictionBets:
 *   Provide additional functionality for proposal and prediction management within polls.
 *
 * Features:
 * - **Direct Voting:** Users can cast votes directly for a specified proposal within a poll.
 * - **Delegate Voting:** Allows designated delegates to vote with delegated power on behalf of others.
 * - **Meta-Transaction Voting:** Supports gasless voting by allowing an authorized meta-transaction handler
 *   to submit votes on behalf of users.
 * - **Cross-Chain Bridging:** Finalized poll results can be bridged to another blockchain using a specified
 *   bridge contract.
 *
 * Events:
 * - `VoteSubmitted`: Emitted whenever a vote is cast, logging the poll ID, voter address, and vote details.
 * - `PollFinalized`: Emitted when a poll is finalized, providing the result hash and storage location.
 * - `PollBridgedToEthereum`: Emitted when a poll's result is bridged to another chain, logging the poll ID
 *   and result hash.
 *
 * Errors:
 * - `P_UnauthorizedMetaTx`: Thrown when an unauthorized address attempts to handle meta-transactions.
 *
 * Modifiers:
 * - `onlyMetaTxHandler`: Restricts access to certain functions to the authorized meta-transaction handler.
 *
 * State Variables:
 * - `bridgeContract`: The address of the cross-chain bridge contract.
 * - `metaTxHandler`: The address authorized to handle meta-transactions.
 *
 * Requirements:
 * - Only the contract owner can set the bridge contract and meta-transaction handler.
 * - Voting and finalization actions are subject to various checks, including poll existence, voting eligibility,
 *   and finalization conditions.
 *
 * Usage:
 * - Contract users can vote directly or through delegates, depending on eligibility.
 * - The meta-transaction handler facilitates gasless transactions.
 * - The owner can set a bridge contract to enable cross-chain operations, which bridges the result to a
 *   specified chain after poll finalization.
 */
contract Polls is
    Ownable,
    RightToVote,
    Delegations,
    PollHelpers,
    ProposalHelpers,
    PredictionHelpers,
    Predictions,
    PredictionBetHelpers,
    PredictionBets
{
    // -------------------- Events --------------------

    event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);
    event PollFinalized(uint256 indexed pollId, bytes32 resultHash, bool storedOnEthereum);
    event ProposalVotes(uint256 indexed pollId, uint256 indexed proposalId, uint256 voteCount, uint256 totalScore);
    event IndividualVotes(uint256 indexed pollId, uint256 indexed proposalId, address voter, uint256 score);
    event PollBridgedToEthereum(uint256 indexed pollId, bytes32 resultHash);

    // -------------------- Errors --------------------

    error P_UnauthorizedMetaTx();

    // -------------------- State Variables --------------------

    address public bridgeContract;
    address public metaTxHandler; // Authorized address to handle meta-transactions

    // -------------------- Modifiers --------------------

    modifier onlyMetaTxHandler() {
        require(msg.sender == metaTxHandler, "P_UnauthorizedMetaTx");
        _;
    }

    // -------------------- External Functions --------------------

    /**
     * @notice Updates the address authorized to handle meta-transactions.
     * @dev This function can only be called by the contract owner. The specified address will
     *      be authorized to submit meta-transactions on behalf of other users, which allows
     *      for gasless transactions.
     * @param _metaTxHandler The new address to set as the meta-transaction handler.
     * @custom:requirement Ensure the `_metaTxHandler` address is a trusted address.
     */
    function setMetaTxHandler(address _metaTxHandler) public onlyOwner {
        metaTxHandler = _metaTxHandler;
    }

    /**
     * @notice Allows a user to cast a vote for a specific proposal within a poll.
     * @dev This function is a public-facing wrapper that calls `_internalVote` to handle
     *      the voting logic, ensuring the vote is processed according to internal rules.
     * @param _pollId The unique identifier of the poll in which the vote is cast.
     * @param _proposalId The unique identifier of the proposal within the specified poll.
     * @param _score The score the voter assigns to the proposal, indicating the preference
     *        or weight of their vote. Must be a positive, non-zero integer.
     * @param _group The identifier of the group to which the voter should belong to
     *        participate in this poll.
     *
     * Requirements:
     * - The caller must be a member of the specified `_group`.
     * - The poll and proposal IDs must be valid and exist in the system.
     * - `_score` must be a positive, non-zero integer.
     * - Each voter can only vote once per poll.
     *
     * Calls:
     * - `_internalVote` to handle the core voting logic, validation, and state updates.
     */
    function vote(uint256 _pollId, uint256 _proposalId, uint8 _score, uint256 _group) external {
        _internalVote(_pollId, _proposalId, _score, msg.sender, _group);
    }
    /**
     * @notice Allows the meta-transaction handler to submit a vote on behalf of a user.
     * @dev This function is intended for gasless voting through meta-transactions, allowing
     *      an authorized handler to cast votes on behalf of users. Access is restricted to
     *      the `metaTxHandler` via the `onlyMetaTxHandler` modifier.
     * @param _pollId The unique identifier of the poll in which the vote is cast.
     * @param _proposalId The unique identifier of the proposal within the specified poll.
     * @param _score The score assigned to the proposal by the voter, representing the
     *        weight or preference of the vote. Must be a positive, non-zero integer.
     * @param _voter The address of the user on whose behalf the vote is being cast.
     * @param _group The identifier of the group to which the `_voter` must belong to
     *        participate in this poll.
     *
     * Requirements:
     * - The caller must be the authorized `metaTxHandler`.
     * - The `_voter` must be a member of the specified `_group`.
     * - The poll and proposal IDs must be valid and exist in the system.
     * - `_score` must be a positive, non-zero integer.
     * - Each voter can only vote once per poll.
     *
     * Calls:
     * - `_internalVote` to execute the voting logic and update the vote state.
     *
     * Emits:
     * - A {VoteSubmitted} event upon successful vote casting, logging the poll ID,
     *   voter's address, and score.
     */

    function castVoteMeta(uint256 _pollId, uint256 _proposalId, uint8 _score, address _voter, uint256 _group)
        external
        onlyMetaTxHandler
    {
        _internalVote(_pollId, _proposalId, _score, _voter, _group);
    }

    /**
     * @notice Allows a delegate to cast a vote on behalf of others within a specific poll and proposal.
     * @dev This function enables delegate voting, allowing an authorized delegate to submit a vote with
     *      their delegated voting power. If the caller is not `metaTxHandler`, they must be the delegate
     *      casting the vote. Each delegate can only vote once per poll.
     * @param _pollId The unique identifier of the poll in which the delegate is voting.
     * @param _proposalId The unique identifier of the proposal within the specified poll.
     * @param _score The score or weight the delegate assigns to the proposal. Must be a positive, non-zero integer.
     * @param delegate The address of the delegate casting the vote on behalf of others.
     *
     * Requirements:
     * - The poll identified by `_pollId` and proposal identified by `_proposalId` must exist.
     * - `_score` must be a positive, non-zero integer.
     * - The caller must either be the delegate themselves or, if using a meta-transaction,
     *   the `metaTxHandler`.
     * - The delegate can only vote once per poll, enforced by the `delegateVotersForPoll` mapping.
     * - The delegate must have a valid delegated voting power within the poll’s group, determined by
     *   `_getDelegatedVotes`.
     *
     * Details:
     * - Calculates the effective vote score by multiplying `_score` with the delegate’s voting power.
     * - Calls `updateProposalVotes` to update the total votes for the proposal with the effective score.
     *
     * Emits:
     * - A {VoteSubmitted} event with the poll ID, delegate address, and calculated vote score.
     */
    function voteAsDelegate(uint256 _pollId, uint256 _proposalId, uint8 _score, address delegate) external {
        requirePollToExist(_pollId);
        requireProposalToExist(_pollId, _proposalId);
        require(_score > 0, "Invalid score");

        if (msg.sender != metaTxHandler) {
            require(msg.sender == delegate, "Unauthorized caller");
        }

        require(!delegateVotersForPoll[_pollId][delegate], "Already voted as delegate");

        uint256 delegatedVotingPower = _getDelegatedVotes(polls[_pollId].details.group);
        if (delegatedVotingPower == 0) {
            delegatedVotingPower = 1;
        }

        uint256 voteScore = _score * uint8(delegatedVotingPower);
        userVotes[_pollId][delegate][_proposalId] = voteScore;
        updateProposalVotes(_pollId, _proposalId, delegatedVotingPower, voteScore);

        delegateVotersForPoll[_pollId][delegate] = true;

        emit VoteSubmitted(_pollId, delegate, voteScore);
    }
    /**
     * @notice Finalizes a poll by setting its finalized status, calculating its result hash,
     *         and optionally emitting proposal and individual vote data if stored on Ethereum.
     * @param _pollId The unique identifier of the poll to finalize.
     *
     * Requirements:
     * - The poll identified by `_pollId` must exist.
     * - The poll must not have been previously finalized.
     * - The poll’s end date must have passed (`block.timestamp` should be greater than or equal to `endDate`).
     *
     * Details:
     * - Marks the poll as finalized by setting `poll.settings.finalized` to `true`.
     * - Computes the `resultHash` using `keccak256`, based on the poll ID, proposal count,
     *   poll end date, and a combined hash of all votes (using `calculateVotesHash`).
     * - If `storeOnEthereum` is true, emits detailed vote data for each proposal, including:
     *   - `ProposalVotes` event with the vote count and total score for each proposal.
     *   - `IndividualVotes` event capturing the total score from each proposal cast by `msg.sender`.
     *
     * Emits:
     * - A {PollFinalized} event with the poll ID, result hash, and a boolean indicating whether
     *   the results are stored on Ethereum.
     * - If `storeOnEthereum` is true, additional {ProposalVotes} and {IndividualVotes} events
     *   are emitted for each proposal within the poll.
     */

    function finalizePoll(uint256 _pollId) external {
        Poll storage poll = polls[_pollId];
        require(poll.pollId > 0, "Poll does not exist");
        require(!poll.settings.finalized, "Poll is already finalized");
        require(block.timestamp >= poll.details.endDate, "Poll has not ended yet");

        poll.settings.finalized = true;

        bytes32 resultHash =
            keccak256(abi.encodePacked(_pollId, poll.proposalCount, poll.details.endDate, calculateVotesHash(_pollId)));
        poll.settings.resultHash = resultHash;

        if (poll.settings.storeOnEthereum) {
            emit PollFinalized(_pollId, resultHash, true);

            for (uint256 i = 0; i < poll.proposalCount; i++) {
                Proposal memory proposal = getProposal(_pollId, i);
                emit ProposalVotes(_pollId, i, proposal.voteCount, proposal.totalScore);
                emit IndividualVotes(_pollId, i, msg.sender, proposal.totalScore);
            }
        } else {
            emit PollFinalized(_pollId, resultHash, false);
        }
    }

    /**
     * @notice Finalizes a poll and bridges its result to an external chain if specified.
     * @dev This function finalizes the poll, calculates the result hash, and, if configured,
     *      sends the result to an external chain via the bridge contract.
     * @param _pollId The unique identifier of the poll to finalize and potentially bridge.
     *
     * Requirements:
     * - The poll identified by `_pollId` must exist.
     * - The poll must not have already been finalized.
     * - The poll’s end date must have passed (`block.timestamp` >= `endDate`).
     * - If bridging is required, the `bridgeContract` address must be set.
     *
     * Details:
     * - Marks the poll as finalized and calculates a `resultHash` based on the poll ID,
     *   proposal count, end date, and combined vote data (via `calculateVotesHash`).
     * - Emits a `PollFinalized` event with the result hash and a boolean indicating whether
     *   results are stored on Ethereum.
     * - If `storeOnEthereum` is true, the function checks that the `bridgeContract` address is set,
     *   then calls `bridgeResults` on the bridge contract to relay the poll result to the external chain.
     *
     * Emits:
     * - A {PollFinalized} event with the poll ID, result hash, and boolean for on-chain storage.
     * - A {PollBridgedToEthereum} event with the poll ID and result hash if the poll is bridged.
     */
    function finalizeAndBridge(uint256 _pollId) external {
        Poll storage poll = polls[_pollId];
        require(poll.pollId > 0, "Poll does not exist");
        require(!poll.settings.finalized, "Poll already finalized");
        require(block.timestamp >= poll.details.endDate, "Poll has not ended yet");

        poll.settings.finalized = true;

        bytes32 resultHash =
            keccak256(abi.encodePacked(_pollId, poll.proposalCount, poll.details.endDate, calculateVotesHash(_pollId)));
        poll.settings.resultHash = resultHash;

        emit PollFinalized(_pollId, resultHash, poll.settings.storeOnEthereum);

        if (poll.settings.storeOnEthereum) {
            require(bridgeContract != address(0), "Bridge contract not set");
            PollsBridge(bridgeContract).bridgeResults(_pollId, resultHash);
            emit PollBridgedToEthereum(_pollId, resultHash);
        }
    }
    /**
     * @notice Sets the address of the bridge contract used for cross-chain communication.
     * @dev This function can only be called by the contract owner.
     * @param _bridgeContract The address of the new bridge contract.
     *
     * Requirements:
     * - Caller must be the contract owner.
     *
     * Details:
     * - Updates the `bridgeContract` state variable to the specified `_bridgeContract` address.
     * - The bridge contract is used for interactions between this contract and other chains.
     */

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        bridgeContract = _bridgeContract;
    }

    /**
     * @dev Retrieves the result of a specified poll if it has been finalized and is not stored on Ethereum.
     * @param _pollId The unique identifier of the poll.
     * @return bytes32 The hash of the result for the specified poll.
     *
     * Requirements:
     * - The poll identified by `_pollId` must be finalized.
     * - The result must not be stored directly on Ethereum (`storeOnEthereum` should be `false`).
     *
     * Details:
     * - Accesses the `polls` mapping to load the poll’s settings and validate its finalization status.
     * - If requirements are met, returns the `resultHash`, which represents the off-chain result of the poll.
     */
    function getResult(uint256 _pollId) external view returns (bytes32) {
        Poll storage poll = polls[_pollId];
        require(poll.settings.finalized, "Poll is not finalized");
        require(!poll.settings.storeOnEthereum, "Result is stored on Ethereum");
        return poll.settings.resultHash;
    }

    // -------------------- Public Functions --------------------
    /**
     * @dev Checks if a user has already voted in a specified poll.
     * @param _pollId The unique identifier of the poll.
     * @param _user The address of the user being checked.
     * @return bool `true` if the user has voted in the specified poll, otherwise `false`.
     *
     * Details:
     * - Uses the `votersForPoll` mapping to determine if `_user` has previously voted in `_pollId`.
     * - Provides a quick way to verify user voting status without altering any state.
     */
    function hasUserVoted(uint256 _pollId, address _user) public view returns (bool) {
        return votersForPoll[_pollId][_user];
    }

    /**
     * @dev Checks if a user has already voted as a delegate in a specified poll.
     * @param _pollId The unique identifier of the poll.
     * @param _user The address of the user being checked.
     * @return bool `true` if the user has voted as a delegate in the specified poll, otherwise `false`.
     *
     * Details:
     * - Uses the `delegateVotersForPoll` mapping to determine if `_user` has cast a vote as a delegate
     *   in `_pollId`.
     * - This function allows quick verification of delegate voting status without modifying any state.
     */
    function hasUserVotedAsDelegate(uint256 _pollId, address _user) public view returns (bool) {
        return delegateVotersForPoll[_pollId][_user];
    }

    // -------------------- Internal Functions --------------------

    /**
     * @dev Executes the core voting logic for a specific poll and proposal. This function
     *      is used internally by both `vote` and `castVoteMeta` to handle the vote submission
     *      process, ensuring consistency in voting validation and record updates.
     * @param _pollId The unique identifier of the poll in which the vote is cast.
     * @param _proposalId The unique identifier of the proposal within the specified poll.
     * @param _score The score assigned to the vote by the voter, representing the weight or
     *        preference of the vote. Must be greater than zero.
     * @param _voter The address of the user casting the vote.
     * @param _group The group identifier used for validating the voter's membership.
     *
     * Requirements:
     * - The poll identified by `_pollId` must exist.
     * - The proposal identified by `_proposalId` within the poll must exist.
     * - `_score` must be a positive, non-zero integer.
     * - The `_voter` must be a member of the specified `_group`.
     * - The caller must either be the `_voter` directly or, if handling a meta-transaction,
     *   the `metaTxHandler`.
     * - A voter can only vote once per poll, enforced by the `votersForPoll` mapping.
     *
     * Emits a {VoteSubmitted} event with the poll ID, voter address, and vote score.
     */
    function _internalVote(uint256 _pollId, uint256 _proposalId, uint8 _score, address _voter, uint256 _group)
        internal
    {
        requirePollToExist(_pollId);
        requireProposalToExist(_pollId, _proposalId);
        require(_score > 0, "Invalid score");

        // Membership validation
        if (!isAddressMemberOfGroup(_voter, _group)) {
            revert SH_NotMember(_group, _voter);
        }

        if (msg.sender != metaTxHandler) {
            require(msg.sender == _voter, "Unauthorized caller");
        }

        if (votersForPoll[_pollId][_voter]) {
            revert SH_AlreadyVoted(_pollId, _voter);
        }

        userVotes[_pollId][_voter][_proposalId] = _score;
        updateProposalVotes(_pollId, _proposalId, 1, _score);
        votersForPoll[_pollId][_voter] = true;

        emit VoteSubmitted(_pollId, _voter, _score);
    }

    /**
     * @dev Retrieves the number of delegated votes assigned to the caller within a specified group.
     * @param _group The identifier of the group for which the delegated votes are being checked.
     * @return totalVotes The number of votes delegated to the caller within the specified group.
     *         Returns 0 if the caller is not a registered delegate for the group.
     *
     * Details:
     * - Iterates through the list of `GroupDelegate`s within the `_group` to find the delegate record
     *   matching the caller (`msg.sender`).
     * - If a match is found, assigns `totalVotes` to the `delegatedVotes` count associated with the
     *   delegate and exits the loop.
     * - Optimized by breaking out of the loop upon finding the first matching delegate.
     */
    function _getDelegatedVotes(uint256 _group) internal view returns (uint256) {
        uint256 totalVotes = 0;
        GroupDelegate[] storage groupDelegatesList = groupDelegates[_group];

        for (uint256 i = 0; i < groupDelegatesList.length; i++) {
            GroupDelegate storage delegate = groupDelegatesList[i];
            if (delegate.delegate == msg.sender) {
                totalVotes = delegate.delegatedVotes;
                break;
            }
        }
        return totalVotes;
    }

    /**
     * @dev Calculates a hash representing the collective voting data for a specified poll.
     * @param _pollId The unique identifier of the poll for which to compute the votes hash.
     * @return bytes32 A hash of the concatenated voting data for each proposal within the poll.
     *
     * Details:
     * - Iterates over each proposal in the specified poll, gathering its `proposalId`, `voteCount`,
     *   and `totalScore`.
     * - Uses `abi.encodePacked` to concatenate this data into a single byte array (`voteData`).
     * - Returns a `keccak256` hash of `voteData`, capturing an immutable snapshot of the vote
     *   state for the entire poll.
     *
     * Usage:
     * - This hash is used as part of the final poll result, representing the total vote state in a
     *   compact, verifiable format.
     */
    function calculateVotesHash(uint256 _pollId) internal view returns (bytes32) {
        bytes memory voteData;

        for (uint256 i = 0; i < polls[_pollId].proposalCount; i++) {
            Proposal memory proposal = getProposal(_pollId, i);
            voteData = abi.encodePacked(voteData, proposal.proposalId, proposal.voteCount, proposal.totalScore);
        }

        return keccak256(voteData);
    }
}
