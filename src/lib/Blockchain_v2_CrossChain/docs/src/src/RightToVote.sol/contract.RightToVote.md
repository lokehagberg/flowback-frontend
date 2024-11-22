# RightToVote
**Inherits:**
[SharedErrors](/src/SharedErrors.sol/contract.SharedErrors.md)

This contract tracks users' memberships in various voting groups and provides the ability to manage membership.

*This contract manages voting group memberships, allowing users to join, leave, and check group memberships.*


## State Variables
### voters

```solidity
mapping(address => Voter) private voters;
```


## Functions
### becomeMemberOfGroup

Allows a user to join a specified group.

*Adds the group to the user's memberships and emits `GroupMembershipChanged`.*


```solidity
function becomeMemberOfGroup(uint256 _group) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group the user wishes to join. Requirements: - The user must not already be a member of the specified group. Emits: - `GroupMembershipChanged` event indicating the user joined the group.|


### removeGroupMembership

Allows a user to leave a specified group.

*Removes the group from the user's memberships and emits `GroupMembershipChanged`.*


```solidity
function removeGroupMembership(uint256 _group) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group the user wishes to leave. Requirements: - The user must already be a member of the specified group. Emits: - `GroupMembershipChanged` event indicating the user left the group.|


### isUserMemberOfGroup

Checks if the caller is a member of a specified group.


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
|`isMember`|`bool`|`true` if the caller is a member of the group; otherwise, `false`.|


### isAddressMemberOfGroup

Checks if a specific address is a member of a specified group.


```solidity
function isAddressMemberOfGroup(address _user, uint256 _group) public view returns (bool isMember);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user to check.|
|`_group`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isMember`|`bool`|`true` if the user is a member of the group; otherwise, `false`.|


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

```solidity
event GroupMembershipChanged(address indexed user, uint256 indexed group, bool isMember);
```

## Errors
### RTV_GroupNotFound

```solidity
error RTV_GroupNotFound(uint256 groupId);
```

## Structs
### Voter

```solidity
struct Voter {
    mapping(uint256 => bool) isMemberOfGroup;
    uint256[] memberGroups;
}
```

