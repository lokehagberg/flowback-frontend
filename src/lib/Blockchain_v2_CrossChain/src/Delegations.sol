// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {RightToVote} from "./RightToVote.sol";

/**
 * @title Delegations Contract
 * @notice This contract enables users to delegate their votes within specific groups, allowing decentralized
 *         representation through delegates. Users can become delegates, delegate their votes to others,
 *         remove delegations, and resign as delegates. The contract tracks group-specific delegations,
 *         including each delegate's voting power and history of delegations.
 * @dev This contract extends the `RightToVote` contract for eligibility verification.
 *
 * Inherits:
 * - `RightToVote`: Provides group membership and voting rights verification.
 *
 * Features:
 * - **Delegate Management**: Allows users to become delegates within groups, and other users to delegate
 *   their votes to those delegates.
 * - **Delegation Tracking**: Maintains a record of active delegates and their voting power within each group,
 *   along with delegator details.
 * - **Delegation Removal and Resignation**: Enables users to remove their delegation from a delegate and
 *   allows delegates to resign from their role.
 * - **Validation Utilities**: Includes utilities to verify if a user is a delegate, has delegated to a specific
 *   delegate, or holds active delegations within a group.
 *
 * State Variables:
 * - `groupDelegates`: Maps each group ID to an array of `GroupDelegate` structs, representing active delegates.
 * - `groupDelegateCount`: Tracks the count of delegates within each group.
 * - `groupDelegationsByUser`: Records delegations from each user, indicating their delegated groups.
 *
 * Events:
 * - `NewDelegate`: Emitted when a user becomes a new delegate within a group.
 * - `NewDelegation`: Emitted when a user delegates their vote to a delegate in a group.
 * - `DelegateResignation`: Emitted when a delegate resigns from a group.
 * - `DelegationRemoved`: Emitted when a user removes their delegation from a delegate in a group.
 *
 * Requirements:
 * - Users must be members of a group to become delegates or delegate their votes.
 * - Delegates cannot delegate their votes to themselves.
 * - Delegates must manage delegations responsibly, as resignations impact all associated delegators.
 *
 * Usage:
 * - **Delegate Management**: Users can use `becomeDelegate` to register as a delegate within a group and
 *   `resignAsDelegate` to step down.
 * - **Delegation**: Users can delegate to a delegate within a group using `delegateToDelegate` and remove
 *   their delegation via `removeDelegation`.
 * - **Validation Functions**: Developers can use helper functions like `addressIsDelegate` and
 *   `hasDelegatedToDelegateInGroup` to validate delegation statuses.
 */
contract Delegations is RightToVote {
    // -------------------- Errors --------------------
    error D_AlreadyDelegate(uint256 groupId, address delegate);
    error D_NotGroupMember(uint256 groupId, address user);
    error D_NoDelegationToRemove(uint256 groupId, address user, address delegate);
    error D_NotADelegate(uint256 groupId, address potentialDelegate);

    // -------------------- Structs --------------------
    struct GroupDelegate {
        address delegate;
        uint256 groupId;
        uint256 delegatedVotes;
        address[] delegationsFrom;
        uint256 groupDelegateId;
    }

    struct GroupDelegation {
        uint256 groupId;
        uint256 timeOfDelegation;
    }

    // -------------------- State Variables --------------------
    mapping(uint256 => GroupDelegate[]) public groupDelegates;
    mapping(uint256 => uint256) internal groupDelegateCount;
    mapping(address => GroupDelegation[]) internal groupDelegationsByUser;

    // -------------------- Events --------------------
    event NewDelegate(
        address indexed delegate,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom,
        uint256 indexed groupDelegateId
    );
    event NewDelegation(
        address indexed from,
        address indexed to,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom
    );
    event DelegateResignation(address indexed delegate, uint256 indexed groupId);
    event DelegationRemoved(address indexed user, address indexed delegate, uint256 indexed groupId);

    /**
     * @dev Verifies that a specified address is a delegate in a given group.
     *      Reverts with an error if the address is not a delegate for the specified group.
     * @param _groupId The ID of the group in which to check the delegate status.
     * @param _potentialDelegate The address to verify as a delegate.
     */
    function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view {
        if (!addressIsDelegate(_groupId, _potentialDelegate)) {
            revert D_NotADelegate(_groupId, _potentialDelegate);
        }
    }

    /**
     * @notice Registers the caller as a delegate in a specified group.
     * @param _groupId The ID of the group where the caller wants to become a delegate.
     *
     * Requirements:
     * - Caller must not already be a delegate in the specified group.
     * - Caller must be a member of the specified group.
     *
     * Emits:
     * - `NewDelegate` event with the new delegate's details.
     *
     * Reverts:
     * - `D_AlreadyDelegate` if the caller is already a delegate in the group.
     * - `D_NotGroupMember` if the caller is not a member of the group.
     */
    function becomeDelegate(uint256 _groupId) external {
        if (addressIsDelegate(_groupId, msg.sender)) {
            revert D_AlreadyDelegate(_groupId, msg.sender);
        }
        if (!isUserMemberOfGroup(_groupId)) {
            revert D_NotGroupMember(_groupId, msg.sender);
        }

        groupDelegateCount[_groupId]++;

        GroupDelegate memory newGroupDelegate = GroupDelegate({
            delegate: msg.sender,
            groupId: _groupId,
            delegatedVotes: 0,
            delegationsFrom: new address[](0),
            groupDelegateId: groupDelegateCount[_groupId]
        });
        groupDelegates[_groupId].push(newGroupDelegate);

        emit NewDelegate(
            newGroupDelegate.delegate,
            newGroupDelegate.groupId,
            newGroupDelegate.delegatedVotes,
            newGroupDelegate.delegationsFrom,
            newGroupDelegate.groupDelegateId
        );
    }

    /**
     * @notice Delegates the caller's vote to a specified delegate within a group.
     * @param _delegate The address of the delegate to whom the vote is delegated.
     * @param _groupId The ID of the group in which the delegation is made.
     *
     * Requirements:
     * - `_delegate` must be a valid delegate in `_groupId`.
     * - Caller must be a member of `_groupId`.
     * - Caller cannot delegate to themselves.
     * - Caller cannot delegate multiple times to the same delegate in the same group.
     *
     * Emits:
     * - `NewDelegation` event with details of the delegation.
     *
     * Reverts:
     * - `SH_InvalidDelegation` if `_delegate` is not a valid delegate in the group.
     * - `D_NotGroupMember` if caller is not a member of the group.
     * - `SH_CannotDelegateToSelf` if caller attempts to delegate to themselves.
     * - `D_AlreadyDelegate` if caller has already delegated to `_delegate` in `_groupId`.
     */
    function delegateToDelegate(address _delegate, uint256 _groupId) external {
        if (!addressIsDelegate(_groupId, _delegate)) {
            revert SH_InvalidDelegation(_groupId, _delegate);
        }
        if (!isUserMemberOfGroup(_groupId)) {
            revert D_NotGroupMember(_groupId, msg.sender);
        }
        if (msg.sender == _delegate) {
            revert SH_CannotDelegateToSelf(msg.sender);
        }
        if (hasDelegatedToDelegateInGroup(_groupId, _delegate)) {
            revert D_AlreadyDelegate(_groupId, _delegate);
        }

        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        bool found = false;

        // Iterate through the delegates to find the matching one
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == _delegate) {
                delegates[i].delegatedVotes++; // Increment the delegate's votes
                delegates[i].delegationsFrom.push(msg.sender); // Add the delegator
                found = true;

                // Emit the event here inside the loop
                emit NewDelegation(
                    msg.sender,
                    _delegate,
                    _groupId,
                    delegates[i].delegatedVotes, // Access via the index
                    delegates[i].delegationsFrom // Access via the index
                );

                break; // Break the loop once the delegate is found
            }
        }

        // Ensure delegate was found
        require(found, "Delegate not found");

        // Add the new delegation for the user
        GroupDelegation memory newGroupDelegation =
            GroupDelegation({groupId: _groupId, timeOfDelegation: block.timestamp});
        groupDelegationsByUser[msg.sender].push(newGroupDelegation);
    }

    /**
     * @notice Removes the caller's delegation to a specified delegate within a group.
     * @param _delegate The address of the delegate from whom the vote is being removed.
     * @param _groupId The ID of the group where the delegation is being removed.
     *
     * Requirements:
     * - Caller must have an active delegation to `_delegate` in `_groupId`.
     *
     * Emits:
     * - `DelegationRemoved` event with details of the removed delegation.
     *
     * Reverts:
     * - `D_NoDelegationToRemove` if the caller does not have a delegation to `_delegate` in `_groupId`.
     */
    function removeDelegation(address _delegate, uint256 _groupId) external {
        if (!hasDelegatedToDelegateInGroup(_groupId, _delegate)) {
            revert D_NoDelegationToRemove(_groupId, msg.sender, _delegate);
        }

        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        uint256 foundIndex;
        bool found = false; // Flag to check if delegate is found

        // Iterate through the delegates to find the matching delegate
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == _delegate) {
                delegates[i].delegatedVotes--;

                // Iterate through the delegationsFrom array to find and delete msg.sender
                for (uint256 k = 0; k < delegates[i].delegationsFrom.length; k++) {
                    if (delegates[i].delegationsFrom[k] == msg.sender) {
                        delete delegates[i].delegationsFrom[k]; // Delete the delegator
                        break;
                    }
                }

                foundIndex = i; // Store the index of the found delegate
                found = true;
                break;
            }
        }

        // Ensure the delegate was found
        require(found, "Delegate not found");

        // Remove the delegation from the user's delegations
        GroupDelegation[] storage userDelegations = groupDelegationsByUser[msg.sender];
        for (uint256 i = 0; i < userDelegations.length; i++) {
            if (userDelegations[i].groupId == _groupId) {
                delete userDelegations[i]; // Delete the user's delegation
                break;
            }
        }
        emit DelegationRemoved(msg.sender, _delegate, _groupId);
    }

    /**
     * @notice Allows the caller to resign as a delegate in a specified group.
     * @param _groupId The ID of the group from which the caller wants to resign as a delegate.
     *
     * Requirements:
     * - Caller must be an active delegate in `_groupId`.
     *
     * Effects:
     * - Removes the caller as a delegate from `_groupId`.
     * - Updates delegations of users who had delegated to the caller in `_groupId`.
     *
     * Emits:
     * - `DelegateResignation` event with the caller's address and group ID.
     *
     * Reverts:
     * - `Delegate not found` if the caller is not an active delegate in the specified group.
     */
    function resignAsDelegate(uint256 _groupId) external {
        // Ensure the user is a delegate in the group
        _requireAddressIsDelegate(_groupId, msg.sender);

        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        bool delegateFound = false;
        address[] memory affectedUsers; // Initialize the memory array

        // Loop to find the delegate and initialize affectedUsers
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == msg.sender) {
                uint256 length = delegates[i].delegationsFrom.length;

                // Initialize affectedUsers if there are delegations
                if (length > 0) {
                    affectedUsers = new address[](length); // Properly initialize the memory array
                    for (uint256 j = 0; j < length; j++) {
                        affectedUsers[j] = delegates[i].delegationsFrom[j];
                    }
                }

                // Remove the delegate from the group
                delegates[i] = delegates[delegates.length - 1]; // Swap with the last element
                delegates.pop(); // Remove the last element

                delegateFound = true;

                // Emit the event here as soon as the delegate is found and removed
                emit DelegateResignation(msg.sender, _groupId);

                break; // Break the loop after finding and processing the delegate
            }
        }

        // Ensure the delegate was found
        require(delegateFound, "Delegate not found");

        // Iterate over affectedUsers and delete their group delegations
        for (uint256 i = 0; i < affectedUsers.length; i++) {
            GroupDelegation[] storage userDelegations = groupDelegationsByUser[affectedUsers[i]];
            for (uint256 k = 0; k < userDelegations.length; k++) {
                if (userDelegations[k].groupId == _groupId) {
                    // Swap-and-pop to remove the delegation
                    userDelegations[k] = userDelegations[userDelegations.length - 1];
                    userDelegations.pop();
                    break;
                }
            }
        }
    }

    /**
     * @notice Checks if a specified address is a delegate within a given group.
     * @param _groupId The ID of the group to check.
     * @param _potentialDelegate The address to verify as a delegate.
     * @return isDelegate `true` if the address is a delegate in the group, otherwise `false`.
     */
    function addressIsDelegate(uint256 _groupId, address _potentialDelegate) public view returns (bool isDelegate) {
        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == _potentialDelegate) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Checks if the caller has an active delegation in a specified group.
     * @param _groupId The ID of the group to check for an active delegation.
     * @return `true` if the caller has delegated in the group, otherwise `false`.
     */
    function hasDelegatedInGroup(uint256 _groupId) public view returns (bool) {
        GroupDelegation[] storage userDelegations = groupDelegationsByUser[msg.sender];
        for (uint256 i = 0; i < userDelegations.length; i++) {
            if (userDelegations[i].groupId == _groupId) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Checks if the caller has delegated their vote to a specific delegate within a given group.
     * @param _groupId The ID of the group to check.
     * @param _delegate The address of the delegate to verify.
     * @return `true` if the caller has delegated to `_delegate` in the group, otherwise `false`.
     */
    function hasDelegatedToDelegateInGroup(uint256 _groupId, address _delegate) public view returns (bool) {
        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == _delegate) {
                for (uint256 k = 0; k < delegates[i].delegationsFrom.length; k++) {
                    if (delegates[i].delegationsFrom[k] == msg.sender) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    // -------------------- Test Functions --------------------

    function getDelegateCount(uint256 _groupId) external view returns (uint256) {
        return groupDelegateCount[_groupId];
    }

    function getDelegateVoteCount(uint256 _groupId, address _delegate) external view returns (uint256) {
        GroupDelegate[] storage delegates = groupDelegates[_groupId];
        for (uint256 i = 0; i < delegates.length; i++) {
            if (delegates[i].delegate == _delegate) {
                return delegates[i].delegatedVotes;
            }
        }
        revert("Delegate not found");
    }
}
