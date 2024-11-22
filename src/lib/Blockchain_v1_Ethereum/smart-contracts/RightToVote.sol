// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "lib/forge-std/src/console.sol";
/**
 * @title RightToVote
 * @dev This contract manages voting group memberships, allowing users to join, leave, and check group memberships.
 * @notice This contract tracks users' memberships in various voting groups and provides the ability to manage membership.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */

contract RightToVote {
    /// Custom error definitions
    error RTV_AlreadyMember(uint256 groupId);
    error RTV_NotMember(uint256 groupId);
    error RTV_GroupNotFound(uint256 groupId);

    /// @dev Struct representing a voter and their membership in different groups.
    struct Voter {
        mapping(uint256 => bool) isMemberOfGroup;
        uint256[] memberGroups;
    }

    /// @notice Maps an address to a Voter struct containing membership information.
    mapping(address => Voter) private voters;

    /// @notice Emitted when a user's group membership changes.
    /// @param user The address of the user whose membership status changed.
    /// @param group The ID of the group affected.
    /// @param isMember True if the user joined the group, false if the user left the group.
    event GroupMembershipChanged(address indexed user, uint256 indexed group, bool isMember);

    /**
     * @notice Allows a user to join a specific group.
     * @dev Adds the group to the user's list of memberships and emits the GroupMembershipChanged event.
     * @param _group The ID of the group the user wants to join.
     */
    function becomeMemberOfGroup(uint256 _group) external {
        console.log("becomeMemberOfGroup called by:", msg.sender);
        console.log("Is msg.sender already a member of group?", _group, voters[msg.sender].isMemberOfGroup[_group]);

        if (voters[msg.sender].isMemberOfGroup[_group]) {
            revert RTV_AlreadyMember(_group);
        }

        voters[msg.sender].isMemberOfGroup[_group] = true;
        voters[msg.sender].memberGroups.push(_group);
        console.log("Added msg.sender to group:", _group);

        emit GroupMembershipChanged(msg.sender, _group, true);
    }

    /**
     * @notice Allows a user to leave a specific group.
     * @dev Removes the group from the user's list of memberships and emits the GroupMembershipChanged event.
     * @param _group The ID of the group the user wants to leave.
     */
    function removeGroupMembership(uint256 _group) external {
        if (!voters[msg.sender].isMemberOfGroup[_group]) {
            revert RTV_NotMember(_group);
        }

        uint256 index;
        uint256 memberGroupsLength = voters[msg.sender].memberGroups.length;
        bool found = false;

        for (index = 0; index < memberGroupsLength; index++) {
            if (voters[msg.sender].memberGroups[index] == _group) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert RTV_GroupNotFound(_group);
        }
        // Shift the array to remove the group
        for (uint256 i = index; i < memberGroupsLength - 1; i++) {
            voters[msg.sender].memberGroups[i] = voters[msg.sender].memberGroups[i + 1];
        }

        // Remove the last element after shifting
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
     * @notice Checks if a specific address is a member of a specific group.
     * @param _user The address of the user to check.
     * @param _group The ID of the group to check.
     * @return isMember True if the user is a member of the group, false otherwise.
     */
    function isAddressMemberOfGroup(address _user, uint256 _group) external view returns (bool isMember) {
        return voters[_user].isMemberOfGroup[_group];
    }

    /**
     * @notice Retrieves the list of all groups that the user is a member of.
     * @return memberGroups An array of group IDs that the user is a member of.
     */
    function getGroupsUserIsMemberIn() external view returns (uint256[] memory) {
        return voters[msg.sender].memberGroups;
    }

    /**
     * @notice Retrieves the list of all groups a specific address is a member of.
     * @param _user The address of the user to retrieve group memberships for.
     * @return memberGroups An array of group IDs that the user is a member of.
     */
    function getGroupsAddressIsMemberIn(address _user) external view returns (uint256[] memory) {
        return voters[_user].memberGroups;
    }
}
