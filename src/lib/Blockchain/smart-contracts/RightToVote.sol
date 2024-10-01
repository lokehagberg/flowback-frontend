// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

/**
 * @title RightToVote
 * @dev This contract manages voting group memberships, allowing users to join, leave, and check group memberships.
 * @notice This contract tracks users' memberships in various voting groups and provides the ability to manage membership.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract RightToVote {
    /**
     * @dev Struct representing a voter and their membership in different groups.
     * @param isMemberOfGroup Mapping of group IDs to membership status.
     * @param memberGroups Array to track the group IDs that the user is a member of.
     */
    struct Voter {
        mapping(uint256 => bool) isMemberOfGroup;
        uint256[] memberGroups;
    }

    /// @notice Maps an address to a Voter struct containing membership information.
    mapping(address => Voter) private voters;

    /**
     * @notice Emitted when a user's group membership changes.
     * @param user The address of the user whose membership status changed.
     * @param group The ID of the group affected.
     * @param isMember True if the user joined the group, false if the user left the group.
     */
    event GroupMembershipChanged(address indexed user, uint256 indexed group, bool isMember);

    /**
     * @notice Allows a user to join a specific group.
     * @dev Adds the group to the user's list of memberships and emits the GroupMembershipChanged event.
     * @param _group The ID of the group the user wants to join.
     */
    function becomeMemberOfGroup(uint256 _group) public {
        require(!voters[msg.sender].isMemberOfGroup[_group], "Already a member of this group");
        voters[msg.sender].isMemberOfGroup[_group] = true;
        voters[msg.sender].memberGroups.push(_group);
        emit GroupMembershipChanged(msg.sender, _group, true);
    }

    /**
     * @notice Allows a user to leave a specific group.
     * @dev Removes the group from the user's list of memberships and emits the GroupMembershipChanged event.
     * @param _group The ID of the group the user wants to leave.
     */
    function removeGroupMembership(uint256 _group) public {
        require(voters[msg.sender].isMemberOfGroup[_group], "Not a member of this group");

        // Remove the group from the memberGroups array
        uint256 index;
        for (index = 0; index < voters[msg.sender].memberGroups.length; index++) {
            if (voters[msg.sender].memberGroups[index] == _group) {
                break;
            }
        }
        require(index < voters[msg.sender].memberGroups.length, "Group not found");

        for (; index < voters[msg.sender].memberGroups.length - 1; index++) {
            voters[msg.sender].memberGroups[index] = voters[msg.sender].memberGroups[index + 1];
        }
        voters[msg.sender].memberGroups.pop();
        voters[msg.sender].isMemberOfGroup[_group] = false;

        emit GroupMembershipChanged(msg.sender, _group, false);
    }

    /**
     * @notice Checks if the user is a member of a specific group.
     * @param _group The ID of the group to check.
     * @return isMember True if the user is a member of the group, false otherwise.
     */
    function isUserMemberOfGroup(uint256 _group) public view returns (bool isMember) {
        return voters[msg.sender].isMemberOfGroup[_group];
    }

    /**
     * @notice Retrieves the list of all groups that the user is a member of.
     * @return memberGroups An array of group IDs that the user is a member of.
     */
    function getGroupsUserIsMemberIn() public view returns (uint256[] memory) {
        return voters[msg.sender].memberGroups;
    }
}
