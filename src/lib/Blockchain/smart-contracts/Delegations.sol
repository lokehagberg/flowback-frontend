// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {RightToVote} from "./RightToVote.sol";

/**
 * @title Delegations
 * @dev A contract that manages delegations for different groups.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova.
 */
contract Delegations is RightToVote {
    /// @notice Maps group IDs to their list of delegates.
    mapping(uint256 => GroupDelegate[]) public groupDelegates;

    /// @notice Maps group IDs to the count of delegates in the group.
    mapping(uint256 => uint256) internal groupDelegateCount;

    /// @notice Tracks the groups in which each user has delegated their votes.
    mapping(address => GroupDelegation[]) internal groupDelegationsByUser;

    /**
     * @dev Represents a delegate in a group.
     * @param delegate The address of the delegate.
     * @param groupId The group ID the delegate belongs to.
     * @param delegatedVotes The number of delegated votes the delegate has received.
     * @param delegationsFrom Addresses of users who have delegated to the delegate.
     * @param groupDelegateId The unique delegate ID within the group.
     */
    struct GroupDelegate {
        address delegate;
        uint256 groupId;
        uint256 delegatedVotes;
        address[] delegationsFrom;
        uint256 groupDelegateId;
    }

    /**
     * @dev Represents a user's delegation in a group.
     * @param groupId The group ID where the user has delegated their vote.
     * @param timeOfDelegation The timestamp when the delegation was made.
     */
    struct GroupDelegation {
        uint256 groupId;
        uint256 timeOfDelegation;
    }

    /**
     * @notice Emitted when a new delegate is added to a group.
     * @param delegate The address of the newly added delegate.
     * @param groupId The group ID the delegate belongs to.
     * @param delegatedVotes The number of votes initially assigned to the delegate.
     * @param delegationsFrom The addresses of users who delegated to the new delegate.
     * @param groupDelegateId The unique delegate ID within the group.
     */
    event NewDelegate(
        address indexed delegate,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom,
        uint256 groupDelegateId
    );

    /**
     * @notice Emitted when a user delegates their vote to a delegate.
     * @param from The address of the user delegating their vote.
     * @param to The address of the delegate receiving the vote.
     * @param groupId The group ID where the delegation occurred.
     * @param delegatedVotes The total number of votes the delegate now has.
     * @param delegationsFrom The addresses of users who delegated to the delegate.
     */
    event NewDelegation(
        address indexed from,
        address indexed to,
        uint256 indexed groupId,
        uint256 delegatedVotes,
        address[] delegationsFrom
    );

    /**
     * @notice Emitted when a delegate resigns from a group.
     * @param delegate The address of the delegate who resigned.
     * @param groupId The group ID the delegate resigned from.
     */
    event DelegateResignation(address indexed delegate, uint256 indexed groupId);

    /**
     * @notice Internal function to check if an address is a delegate in a specific group.
     * @dev This function is used by the `requireAddressIsDelegate` modifier.
     * @param _groupId The group ID to check.
     * @param _potentialDelegate The address of the potential delegate.
     */
    function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view {
        require(addressIsDelegate(_groupId, _potentialDelegate), "The address is not a delegate in the specified group");
    }

    /**
     * @notice Modifier to require that an address is a delegate in a specific group.
     * @param _groupId The group ID to check.
     * @param _potentialDelegate The address of the potential delegate.
     */
    modifier requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) {
        _requireAddressIsDelegate(_groupId, _potentialDelegate);
        _;
    }

    /**
     * @notice Allows a user to become a delegate in a specific group.
     * @dev The user must be a member of the group and must not already be a delegate in the group.
     * @param _groupId The group ID in which the user wants to become a delegate.
     */
    function becomeDelegate(uint256 _groupId) public {
        require(!addressIsDelegate(_groupId, msg.sender), "You are already a delegate in this group");
        require(isUserMemberOfGroup(_groupId), "You must be a member of the group to become a delegate");

        groupDelegateCount[_groupId]++;

        // Create and add the new delegate
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
     * @dev The user must be a member of the group and must not have already delegated in the group.
     * @param _groupId The group ID where the vote is being delegated.
     * @param _delegateTo The address of the delegate receiving the vote.
     */
    
    function delegate(uint256 _groupId, address _delegateTo) public requireAddressIsDelegate(_groupId, _delegateTo) {
        require(isUserMemberOfGroup(_groupId), "You can only delegate in groups you are a member of.");
        require(!hasDelegatedInGroup(_groupId), "You have already delegated in this group.");
        require(_delegateTo != msg.sender, "You cannot delegate to yourself");

        // Record the delegation
        GroupDelegation memory newGroupDelegation = GroupDelegation({
            groupId: _groupId,
            timeOfDelegation: block.timestamp
        });
        groupDelegationsByUser[msg.sender].push(newGroupDelegation);

        // Update delegate vote count
        uint256 delegatedVotes;
        address[] memory delegationsFrom;
        uint256 arrayLength = groupDelegates[_groupId].length;
        for (uint256 i; i < arrayLength;) {
            if (groupDelegates[_groupId][i].delegate == _delegateTo) {
                groupDelegates[_groupId][i].delegatedVotes++;
                groupDelegates[_groupId][i].delegationsFrom.push(msg.sender);
                delegatedVotes = groupDelegates[_groupId][i].delegatedVotes;
                delegationsFrom = groupDelegates[_groupId][i].delegationsFrom;
            }
            unchecked {
                ++i;
            }
        }

        emit NewDelegation(msg.sender, _delegateTo, _groupId, delegatedVotes, delegationsFrom);
    }

    /**
     * @notice Allows a user to remove their delegation from a specific delegate in a group.
     * @dev The user must have previously delegated to the specified delegate.
     * @param _delegate The address of the delegate from whom the delegation is being removed.
     * @param _groupId The group ID where the delegation was made.
     */
    function removeDelegation(address _delegate, uint256 _groupId) public {
        require(hasDelegatedToDelegateInGroup(_groupId, _delegate), "You have not delegated to this delegate in this group");

        uint256 delegatedVotes;
        uint256 arrayLength = groupDelegates[_groupId].length;

        // Decrease the delegate's votes and remove the user from delegations
        for (uint256 i; i < arrayLength;) {
            if (groupDelegates[_groupId][i].delegate == _delegate) {
                groupDelegates[_groupId][i].delegatedVotes--;
                delegatedVotes = groupDelegates[_groupId][i].delegatedVotes;
                for (uint256 k; k < groupDelegates[_groupId][i].delegationsFrom.length;) {
                    if (groupDelegates[_groupId][i].delegationsFrom[k] == msg.sender) {
                        delete groupDelegates[_groupId][i].delegationsFrom[k];
                    }
                    unchecked {
                        ++k;
                    }
                }
            }
            unchecked {
                ++i;
            }
        }

        // Remove the group from the user's delegation record
        arrayLength = groupDelegationsByUser[msg.sender].length;
        for (uint256 i; i < arrayLength;) {
            if (groupDelegationsByUser[msg.sender][i].groupId == _groupId) {
                delete groupDelegationsByUser[msg.sender][i];
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Allows a delegate to resign from a group.
     * @dev The delegate is removed from the group, and all delegations to the delegate are cleared.
     * @param _groupId The group ID from which the delegate is resigning.
     */
    function resignAsDelegate(uint256 _groupId) public requireAddressIsDelegate(_groupId, msg.sender) {
        address[] memory affectedUsers;

        // Remove the delegate
        uint256 arrayLength = groupDelegates[_groupId].length;
        for (uint256 i; i < arrayLength;) {
            if (groupDelegates[_groupId][i].delegate == msg.sender) {
                affectedUsers = groupDelegates[_groupId][i].delegationsFrom;
                delete groupDelegates[_groupId][i];
            }
            unchecked {
                ++i;
            }
        }

        // Clear delegations to the resigned delegate
        for (uint256 i; i < affectedUsers.length; i++) {
            arrayLength = groupDelegationsByUser[affectedUsers[i]].length;
            for (uint256 k; k < arrayLength;) {
                if (groupDelegationsByUser[affectedUsers[i]][k].groupId == _groupId) {
                    delete groupDelegationsByUser[affectedUsers[i]][k];
                }
                unchecked {
                    ++k;
                }
            }
        }

        emit DelegateResignation(msg.sender, _groupId);
    }

    /**
     * @notice Checks if an address is a delegate in a specific group.
     * @param _groupId The group ID to check.
     * @param _potentialDelegate The address to check for delegate status.
     * @return isDelegate True if the address is a delegate in the group, false otherwise.
     */
    function addressIsDelegate(uint256 _groupId, address _potentialDelegate) public view returns (bool isDelegate) {
        uint256 arrayLength = groupDelegates[_groupId].length;
        for (uint256 i; i < arrayLength;) {
            if (groupDelegates[_groupId][i].delegate == _potentialDelegate) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @notice Checks if the user has an active delegation in a specific group.
     * @param _groupId The group ID to check.
     * @return hasDelegated True if the user has delegated their vote in the group, false otherwise.
     */
    function hasDelegatedInGroup(uint256 _groupId) public view returns (bool) {
        for (uint256 i = 0; i < groupDelegationsByUser[msg.sender].length;) {
            if (groupDelegationsByUser[msg.sender][i].groupId == _groupId) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /**
     * @notice Checks if the user has delegated to a specific delegate in a group.
     * @param _groupId The group ID to check.
     * @param _delegate The address of the delegate.
     * @return hasDelegated True if the user has delegated to the specified delegate, false otherwise.
     */
    function hasDelegatedToDelegateInGroup(uint256 _groupId, address _delegate) public view returns (bool) {
        uint256 arrayLength = groupDelegates[_groupId].length;
        for (uint256 i; i < arrayLength;) {
            if (groupDelegates[_groupId][i].delegate == _delegate) {
                arrayLength = groupDelegates[_groupId][i].delegationsFrom.length;
                for (uint256 k; k < arrayLength;) {
                    if (groupDelegates[_groupId][i].delegationsFrom[k] == msg.sender) {
                        return true;
                    }
                    unchecked {
                        ++k;
                    }
                }
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }
}
