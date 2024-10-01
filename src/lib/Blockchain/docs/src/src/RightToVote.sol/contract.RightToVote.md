# RightToVote
**Author:**
@EllenLng, @KristofferGW

This contract tracks users' memberships in various voting groups and provides the ability to manage membership.

Audited by @MashaVaverova

*This contract manages voting group memberships, allowing users to join, leave, and check group memberships.*


## State Variables
### voters
Maps an address to a Voter struct containing membership information.


```solidity
mapping(address => Voter) private voters;
```


## Functions
### becomeMemberOfGroup

Allows a user to join a specific group.

*Adds the group to the user's list of memberships and emits the GroupMembershipChanged event.*


```solidity
function becomeMemberOfGroup(uint256 _group) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group the user wants to join.|


### removeGroupMembership

Allows a user to leave a specific group.

*Removes the group from the user's list of memberships and emits the GroupMembershipChanged event.*


```solidity
function removeGroupMembership(uint256 _group) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group the user wants to leave.|


### isUserMemberOfGroup

Checks if the user is a member of a specific group.


```solidity
function isUserMemberOfGroup(uint256 _group) public view returns (bool isMember);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isMember`|`bool`|True if the user is a member of the group, false otherwise.|


### getGroupsUserIsMemberIn

Retrieves the list of all groups that the user is a member of.


```solidity
function getGroupsUserIsMemberIn() public view returns (uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|memberGroups An array of group IDs that the user is a member of.|


## Events
### GroupMembershipChanged
Emitted when a user's group membership changes.


```solidity
event GroupMembershipChanged(address indexed user, uint256 indexed group, bool isMember);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user whose membership status changed.|
|`group`|`uint256`|The ID of the group affected.|
|`isMember`|`bool`|True if the user joined the group, false if the user left the group.|

## Structs
### Voter
*Struct representing a voter and their membership in different groups.*


```solidity
struct Voter {
    mapping(uint256 => bool) isMemberOfGroup;
    uint256[] memberGroups;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`isMemberOfGroup`|`mapping(uint256 => bool)`|Mapping of group IDs to membership status.|
|`memberGroups`|`uint256[]`|Array to track the group IDs that the user is a member of.|

