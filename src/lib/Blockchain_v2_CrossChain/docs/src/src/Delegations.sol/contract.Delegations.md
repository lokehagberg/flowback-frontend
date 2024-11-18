# Delegations
**Inherits:**
[RightToVote](/src/RightToVote.sol/contract.RightToVote.md)

This contract enables users to delegate their votes within specific groups, allowing decentralized
representation through delegates. Users can become delegates, delegate their votes to others,
remove delegations, and resign as delegates. The contract tracks group-specific delegations,
including each delegate's voting power and history of delegations.

*This contract extends the `RightToVote` contract for eligibility verification.
Inherits:
- `RightToVote`: Provides group membership and voting rights verification.
Features:
- **Delegate Management**: Allows users to become delegates within groups, and other users to delegate
their votes to those delegates.
- **Delegation Tracking**: Maintains a record of active delegates and their voting power within each group,
along with delegator details.
- **Delegation Removal and Resignation**: Enables users to remove their delegation from a delegate and
allows delegates to resign from their role.
- **Validation Utilities**: Includes utilities to verify if a user is a delegate, has delegated to a specific
delegate, or holds active delegations within a group.
State Variables:
- `groupDelegates`: Maps each group ID to an array of `GroupDelegate` structs, representing active delegates.
- `groupDelegateCount`: Tracks the count of delegates within each group.
- `groupDelegationsByUser`: Records delegations from each user, indicating their delegated groups.
Events:
- `NewDelegate`: Emitted when a user becomes a new delegate within a group.
- `NewDelegation`: Emitted when a user delegates their vote to a delegate in a group.
- `DelegateResignation`: Emitted when a delegate resigns from a group.
- `DelegationRemoved`: Emitted when a user removes their delegation from a delegate in a group.
Requirements:
- Users must be members of a group to become delegates or delegate their votes.
- Delegates cannot delegate their votes to themselves.
- Delegates must manage delegations responsibly, as resignations impact all associated delegators.
Usage:
- **Delegate Management**: Users can use `becomeDelegate` to register as a delegate within a group and
`resignAsDelegate` to step down.
- **Delegation**: Users can delegate to a delegate within a group using `delegateToDelegate` and remove
their delegation via `removeDelegation`.
- **Validation Functions**: Developers can use helper functions like `addressIsDelegate` and
`hasDelegatedToDelegateInGroup` to validate delegation statuses.*


## State Variables
### groupDelegates

```solidity
mapping(uint256 => GroupDelegate[]) public groupDelegates;
```


### groupDelegateCount

```solidity
mapping(uint256 => uint256) internal groupDelegateCount;
```


### groupDelegationsByUser

```solidity
mapping(address => GroupDelegation[]) internal groupDelegationsByUser;
```


## Functions
### _requireAddressIsDelegate

*Verifies that a specified address is a delegate in a given group.
Reverts with an error if the address is not a delegate for the specified group.*


```solidity
function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group in which to check the delegate status.|
|`_potentialDelegate`|`address`|The address to verify as a delegate.|


### becomeDelegate

Registers the caller as a delegate in a specified group.


```solidity
function becomeDelegate(uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group where the caller wants to become a delegate. Requirements: - Caller must not already be a delegate in the specified group. - Caller must be a member of the specified group. Emits: - `NewDelegate` event with the new delegate's details. Reverts: - `D_AlreadyDelegate` if the caller is already a delegate in the group. - `D_NotGroupMember` if the caller is not a member of the group.|


### delegateToDelegate

Delegates the caller's vote to a specified delegate within a group.


```solidity
function delegateToDelegate(address _delegate, uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_delegate`|`address`|The address of the delegate to whom the vote is delegated.|
|`_groupId`|`uint256`|The ID of the group in which the delegation is made. Requirements: - `_delegate` must be a valid delegate in `_groupId`. - Caller must be a member of `_groupId`. - Caller cannot delegate to themselves. - Caller cannot delegate multiple times to the same delegate in the same group. Emits: - `NewDelegation` event with details of the delegation. Reverts: - `SH_InvalidDelegation` if `_delegate` is not a valid delegate in the group. - `D_NotGroupMember` if caller is not a member of the group. - `SH_CannotDelegateToSelf` if caller attempts to delegate to themselves. - `D_AlreadyDelegate` if caller has already delegated to `_delegate` in `_groupId`.|


### removeDelegation

Removes the caller's delegation to a specified delegate within a group.


```solidity
function removeDelegation(address _delegate, uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_delegate`|`address`|The address of the delegate from whom the vote is being removed.|
|`_groupId`|`uint256`|The ID of the group where the delegation is being removed. Requirements: - Caller must have an active delegation to `_delegate` in `_groupId`. Emits: - `DelegationRemoved` event with details of the removed delegation. Reverts: - `D_NoDelegationToRemove` if the caller does not have a delegation to `_delegate` in `_groupId`.|


### resignAsDelegate

Allows the caller to resign as a delegate in a specified group.


```solidity
function resignAsDelegate(uint256 _groupId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group from which the caller wants to resign as a delegate. Requirements: - Caller must be an active delegate in `_groupId`. Effects: - Removes the caller as a delegate from `_groupId`. - Updates delegations of users who had delegated to the caller in `_groupId`. Emits: - `DelegateResignation` event with the caller's address and group ID. Reverts: - `Delegate not found` if the caller is not an active delegate in the specified group.|


### addressIsDelegate

Checks if a specified address is a delegate within a given group.


```solidity
function addressIsDelegate(uint256 _groupId, address _potentialDelegate) public view returns (bool isDelegate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_potentialDelegate`|`address`|The address to verify as a delegate.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isDelegate`|`bool`|`true` if the address is a delegate in the group, otherwise `false`.|


### hasDelegatedInGroup

Checks if the caller has an active delegation in a specified group.


```solidity
function hasDelegatedInGroup(uint256 _groupId) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check for an active delegation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|`true` if the caller has delegated in the group, otherwise `false`.|


### hasDelegatedToDelegateInGroup

Checks if the caller has delegated their vote to a specific delegate within a given group.


```solidity
function hasDelegatedToDelegateInGroup(uint256 _groupId, address _delegate) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The ID of the group to check.|
|`_delegate`|`address`|The address of the delegate to verify.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|`true` if the caller has delegated to `_delegate` in the group, otherwise `false`.|


### getDelegateCount


```solidity
function getDelegateCount(uint256 _groupId) external view returns (uint256);
```

### getDelegateVoteCount


```solidity
function getDelegateVoteCount(uint256 _groupId, address _delegate) external view returns (uint256);
```

## Events
### NewDelegate

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

```solidity
event NewDelegation(
    address indexed from, address indexed to, uint256 indexed groupId, uint256 delegatedVotes, address[] delegationsFrom
);
```

### DelegateResignation

```solidity
event DelegateResignation(address indexed delegate, uint256 indexed groupId);
```

### DelegationRemoved

```solidity
event DelegationRemoved(address indexed user, address indexed delegate, uint256 indexed groupId);
```

## Errors
### D_AlreadyDelegate

```solidity
error D_AlreadyDelegate(uint256 groupId, address delegate);
```

### D_NotGroupMember

```solidity
error D_NotGroupMember(uint256 groupId, address user);
```

### D_NoDelegationToRemove

```solidity
error D_NoDelegationToRemove(uint256 groupId, address user, address delegate);
```

### D_NotADelegate

```solidity
error D_NotADelegate(uint256 groupId, address potentialDelegate);
```

## Structs
### GroupDelegate

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

```solidity
struct GroupDelegation {
    uint256 groupId;
    uint256 timeOfDelegation;
}
```

