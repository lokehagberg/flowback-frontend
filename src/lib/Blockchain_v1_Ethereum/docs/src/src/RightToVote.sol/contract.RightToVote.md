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
function becomeMemberOfGroup(uint256 _group) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group the user wants to join.|


### removeGroupMembership

Allows a user to leave a specific group.

*Removes the group from the user's list of memberships and emits the GroupMembershipChanged event.*


```solidity
function removeGroupMembership(uint256 _group) external;
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


### isAddressMemberOfGroup

Checks if a specific address is a member of a specific group.


```solidity
function isAddressMemberOfGroup(address _user, uint256 _group) external view returns (bool isMember);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user to check.|
|`_group`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isMember`|`bool`|True if the user is a member of the group, false otherwise.|


### getGroupsUserIsMemberIn

Retrieves the list of all groups that the user is a member of.


```solidity
function getGroupsUserIsMemberIn() external view returns (uint256[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|memberGroups An array of group IDs that the user is a member of.|


### getGroupsAddressIsMemberIn

Retrieves the list of all groups a specific address is a member of.


```solidity
function getGroupsAddressIsMemberIn(address _user) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user to retrieve group memberships for.|

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

## Errors
### RTV_AlreadyMember
Custom error definitions


```solidity
error RTV_AlreadyMember(uint256 groupId);
```

### RTV_NotMember

```solidity
error RTV_NotMember(uint256 groupId);
```

### RTV_GroupNotFound

```solidity
error RTV_GroupNotFound(uint256 groupId);
```

## Structs
### Voter
*Struct representing a voter and their membership in different groups.*


```solidity
struct Voter {
    mapping(uint256 => bool) isMemberOfGroup;
    uint256[] memberGroups;
}
```

