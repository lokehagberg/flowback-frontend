// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {RightToVote} from "./RightToVote.sol";

/**
 * @title Delegations
 * @dev A contract that manages delegations for different groups.
 * This contract allows users to delegate their votes to other users in specific groups.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract Delegations is RightToVote {
    /// Custom errors
    error D_AlreadyDelegate(uint256 groupId, address delegate);
    error D_NotGroupMember(uint256 groupId, address user);
    error D_NotADelegate(uint256 groupId, address potentialDelegate);
    error D_CannotDelegateToSelf(address user);
    error D_NoDelegationToRemove(uint256 groupId, address user, address delegate);

    /// @notice Maps group IDs to their list of delegates.
    mapping(uint256 => GroupDelegate[]) public groupDelegates;

    /// @notice Maps group IDs to the count of delegates in the group.
    mapping(uint256 => uint256) internal groupDelegateCount;

    /// @notice Tracks the groups in which each user has delegated their votes.
    mapping(address => GroupDelegation[]) internal groupDelegationsByUser;

    /// @dev Struct to represent a group delegate.
    struct GroupDelegate {
        address delegate;
        uint256 groupId;
        uint256 delegatedVotes;
        address[] delegationsFrom;
        uint256 groupDelegateId;
    }

    /// @dev Struct to represent a user's group delegation.
    struct GroupDelegation {
        uint256 groupId;
        uint256 timeOfDelegation;
    }

    /// @dev Event emitted when a new delegate is created
    event NewDelegate(
        address indexed delegate,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom,
        uint256 indexed groupDelegateId
    );
    /// @dev Event emitted when a new delegation is made
    event NewDelegation(
        address indexed from,
        address indexed to,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom
    );

    /// @dev Event emitted when a delegate resigns
    event DelegateResignation(address indexed delegate, uint256 indexed groupId);

    /// @dev Event emitted when a delegate is removed
    event DelegationRemoved(address indexed user, address indexed delegate, uint256 indexed groupId);

     /**
     * @notice Internal function to check if an address is a delegate in a specific group.
     * @dev Reverts if the provided address is not a delegate for the specified group.
     * @param _groupId The ID of the group to check.
     * @param _potentialDelegate The address to check if it's a delegate.
     */
    function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view {
        if (!addressIsDelegate(_groupId, _potentialDelegate)) {
            revert D_NotADelegate(_groupId, _potentialDelegate);
        }
    }

    /**
     * @notice Allows a user to become a delegate in a specific group.
     * @param _groupId The ID of the group to become a delegate in.
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
     * @notice Allows a user to delegate their vote to a specific delegate in a group.
     * @param _delegate The address of the delegate to delegate the vote to.
     * @param _groupId The ID of the group to delegate in.
     */    function delegateToDelegate(address _delegate, uint256 _groupId) external {
        if (!addressIsDelegate(_groupId, _delegate)) {
            revert D_NotADelegate(_groupId, _delegate);
        }
        if (!isUserMemberOfGroup(_groupId)) {
            revert D_NotGroupMember(_groupId, msg.sender);
        }
        if (msg.sender == _delegate) {
            revert D_CannotDelegateToSelf(msg.sender);
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
     * @notice Allows a user to remove their delegation from a specific delegate in a group.
     * @param _delegate The address of the delegate to remove the delegation from.
     * @param _groupId The ID of the group to remove the delegation from.
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
     * @notice Allows a delegate to resign from a group.
     * @param _groupId The ID of the group to resign from.
     * @dev This function ensures the caller is a delegate in the specified group. 
     * It removes the delegate from the group and updates affected users' delegations accordingly.
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
     * @notice Checks if an address is a delegate in a specific group.
     * @param _groupId The ID of the group to check.
     * @param _potentialDelegate The address to check if it is a delegate.
     * @return isDelegate True if the address is a delegate, false otherwise.
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
     * @notice Checks if the user has an active delegation in a specific group.
     * @param _groupId The ID of the group to check.
     * @return True if the user has an active delegation, false otherwise.
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
     * @notice Checks if the user has delegated to a specific delegate in a group.
     * @param _groupId The ID of the group to check.
     * @param _delegate The address of the delegate to check.
     * @return True if the user has delegated to the delegate, false otherwise.
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


   //__________GETTERS FOR TESTING PURPOSES
   /**
     * @notice Returns the number of delegates in a specific group.
     * @param _groupId The ID of the group to check.
     * @return The count of delegates in the specified group.
     */
    function getDelegateCount(uint256 _groupId) external view returns (uint256) {
        return groupDelegateCount[_groupId];
    }

    /**
     * @notice Returns the vote count for a specific delegate in a group.
     * @param _groupId The ID of the group to check.
     * @param _delegate The address of the delegate to check.
     * @return The number of votes delegated to the specified delegate.
     */
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
