# Delegations
**Inherits:**
[RightToVote](/src/RightToVote.sol/contract.RightToVote.md)

**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova

*A contract that manages delegations for different groups.
This contract allows users to delegate their votes to other users in specific groups.*


## State Variables
### groupDelegates
Maps group IDs to their list of delegates.


```solidity
mapping(uint256 => GroupDelegate[]) public groupDelegates;
```


### groupDelegateCount
Maps group IDs to the count of delegates in the group.


```solidity
mapping(uint256 => uint256) internal groupDelegateCount;
```


### groupDelegationsByUser
Tracks the groups in which each user has delegated their votes.


```solidity
mapping(address => GroupDelegation[]) internal groupDelegationsByUser;
```


## Functions
### _requireAddressIsDelegate

Internal function to check if an address is a delegate in a specific group.

*Reverts if the provided address is not a delegate for the specified group.*


```solidity
function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_potentialDelegate`|`address`|The address to check if it's a delegate.|


### becomeDelegate

Allows a user to become a delegate in a specific group.


```solidity
function becomeDelegate(uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to become a delegate in.|


### delegateToDelegate

Allows a user to delegate their vote to a specific delegate in a group.


```solidity
function delegateToDelegate(address _delegate, uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_delegate`|`address`|The address of the delegate to delegate the vote to.|
|`_groupId`|`uint256`|The ID of the group to delegate in.|


### removeDelegation

Allows a user to remove their delegation from a specific delegate in a group.


```solidity
function removeDelegation(address _delegate, uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_delegate`|`address`|The address of the delegate to remove the delegation from.|
|`_groupId`|`uint256`|The ID of the group to remove the delegation from.|


### resignAsDelegate

Allows a delegate to resign from a group.

*This function ensures the caller is a delegate in the specified group.
It removes the delegate from the group and updates affected users' delegations accordingly.*


```solidity
function resignAsDelegate(uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to resign from.|


### addressIsDelegate

Checks if an address is a delegate in a specific group.


```solidity
function addressIsDelegate(uint256 _groupId, address _potentialDelegate) public view returns (bool isDelegate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_potentialDelegate`|`address`|The address to check if it is a delegate.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isDelegate`|`bool`|True if the address is a delegate, false otherwise.|


### hasDelegatedInGroup

Checks if the user has an active delegation in a specific group.


```solidity
function hasDelegatedInGroup(uint256 _groupId) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user has an active delegation, false otherwise.|


### hasDelegatedToDelegateInGroup

Checks if the user has delegated to a specific delegate in a group.


```solidity
function hasDelegatedToDelegateInGroup(uint256 _groupId, address _delegate) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_delegate`|`address`|The address of the delegate to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user has delegated to the delegate, false otherwise.|


### getDelegateCount

Returns the number of delegates in a specific group.


```solidity
function getDelegateCount(uint256 _groupId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The count of delegates in the specified group.|


### getDelegateVoteCount

Returns the vote count for a specific delegate in a group.


```solidity
function getDelegateVoteCount(uint256 _groupId, address _delegate) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_delegate`|`address`|The address of the delegate to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The number of votes delegated to the specified delegate.|


## Events
### NewDelegate
*Event emitted when a new delegate is created*


```solidity
event NewDelegate(
    address indexed delegate,
    uint256 indexed groupId,
    uint256 delegatedVotes,
    address[] delegationsFrom,
    uint256 indexed groupDelegateId
);
```

### NewDelegation
*Event emitted when a new delegation is made*


```solidity
event NewDelegation(
    address indexed from, address indexed to, uint256 indexed groupId, uint256 delegatedVotes, address[] delegationsFrom
);
```

### DelegateResignation
*Event emitted when a delegate resigns*


```solidity
event DelegateResignation(address indexed delegate, uint256 indexed groupId);
```

### DelegationRemoved
*Event emitted when a delegate is removed*


```solidity
event DelegationRemoved(address indexed user, address indexed delegate, uint256 indexed groupId);
```

## Errors
### D_AlreadyDelegate
Custom errors


```solidity
error D_AlreadyDelegate(uint256 groupId, address delegate);
```

### D_NotGroupMember

```solidity
error D_NotGroupMember(uint256 groupId, address user);
```

### D_NotADelegate

```solidity
error D_NotADelegate(uint256 groupId, address potentialDelegate);
```

### D_CannotDelegateToSelf

```solidity
error D_CannotDelegateToSelf(address user);
```

### D_NoDelegationToRemove

```solidity
error D_NoDelegationToRemove(uint256 groupId, address user, address delegate);
```

## Structs
### GroupDelegate
*Struct to represent a group delegate.*


```solidity
struct GroupDelegate {
    address delegate;
    uint256 groupId;
    uint256 delegatedVotes;
    address[] delegationsFrom;
    uint256 groupDelegateId;
}
```

### GroupDelegation
*Struct to represent a user's group delegation.*


```solidity
struct GroupDelegation {
    uint256 groupId;
    uint256 timeOfDelegation;
}
```

