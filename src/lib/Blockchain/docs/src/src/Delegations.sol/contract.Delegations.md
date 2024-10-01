# Delegations
**Inherits:**
[RightToVote](/src/RightToVote.sol/contract.RightToVote.md)

**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova.

*A contract that manages delegations for different groups.*


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

*This function is used by the `requireAddressIsDelegate` modifier.*


```solidity
function _requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID to check.|
|`_potentialDelegate`|`address`|The address of the potential delegate.|


### requireAddressIsDelegate

Modifier to require that an address is a delegate in a specific group.


```solidity
modifier requireAddressIsDelegate(uint256 _groupId, address _potentialDelegate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID to check.|
|`_potentialDelegate`|`address`|The address of the potential delegate.|


### becomeDelegate

Allows a user to become a delegate in a specific group.

*The user must be a member of the group and must not already be a delegate in the group.*


```solidity
function becomeDelegate(uint256 _groupId) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID in which the user wants to become a delegate.|


### delegate

Allows a user to delegate their vote to a specific delegate in a group.

*The user must be a member of the group and must not have already delegated in the group.*


```solidity
function delegate(uint256 _groupId, address _delegateTo) public requireAddressIsDelegate(_groupId, _delegateTo);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID where the vote is being delegated.|
|`_delegateTo`|`address`|The address of the delegate receiving the vote.|


### removeDelegation

Allows a user to remove their delegation from a specific delegate in a group.

*The user must have previously delegated to the specified delegate.*


```solidity
function removeDelegation(address _delegate, uint256 _groupId) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_delegate`|`address`|The address of the delegate from whom the delegation is being removed.|
|`_groupId`|`uint256`|The group ID where the delegation was made.|


### resignAsDelegate

Allows a delegate to resign from a group.

*The delegate is removed from the group, and all delegations to the delegate are cleared.*


```solidity
function resignAsDelegate(uint256 _groupId) public requireAddressIsDelegate(_groupId, msg.sender);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID from which the delegate is resigning.|


### addressIsDelegate

Checks if an address is a delegate in a specific group.


```solidity
function addressIsDelegate(uint256 _groupId, address _potentialDelegate) public view returns (bool isDelegate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID to check.|
|`_potentialDelegate`|`address`|The address to check for delegate status.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isDelegate`|`bool`|True if the address is a delegate in the group, false otherwise.|


### hasDelegatedInGroup

Checks if the user has an active delegation in a specific group.


```solidity
function hasDelegatedInGroup(uint256 _groupId) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|hasDelegated True if the user has delegated their vote in the group, false otherwise.|


### hasDelegatedToDelegateInGroup

Checks if the user has delegated to a specific delegate in a group.


```solidity
function hasDelegatedToDelegateInGroup(uint256 _groupId, address _delegate) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_groupId`|`uint256`|The group ID to check.|
|`_delegate`|`address`|The address of the delegate.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|hasDelegated True if the user has delegated to the specified delegate, false otherwise.|


## Events
### NewDelegate
Emitted when a new delegate is added to a group.


```solidity
event NewDelegate(
    address indexed delegate,
    uint256 indexed groupId,
    uint256 delegatedVotes,
    address[] delegationsFrom,
    uint256 groupDelegateId
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`delegate`|`address`|The address of the newly added delegate.|
|`groupId`|`uint256`|The group ID the delegate belongs to.|
|`delegatedVotes`|`uint256`|The number of votes initially assigned to the delegate.|
|`delegationsFrom`|`address[]`|The addresses of users who delegated to the new delegate.|
|`groupDelegateId`|`uint256`|The unique delegate ID within the group.|

### NewDelegation
Emitted when a user delegates their vote to a delegate.


```solidity
event NewDelegation(
    address indexed from, address indexed to, uint256 indexed groupId, uint256 delegatedVotes, address[] delegationsFrom
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address of the user delegating their vote.|
|`to`|`address`|The address of the delegate receiving the vote.|
|`groupId`|`uint256`|The group ID where the delegation occurred.|
|`delegatedVotes`|`uint256`|The total number of votes the delegate now has.|
|`delegationsFrom`|`address[]`|The addresses of users who delegated to the delegate.|

### DelegateResignation
Emitted when a delegate resigns from a group.


```solidity
event DelegateResignation(address indexed delegate, uint256 indexed groupId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`delegate`|`address`|The address of the delegate who resigned.|
|`groupId`|`uint256`|The group ID the delegate resigned from.|

## Structs
### GroupDelegate
*Represents a delegate in a group.*


```solidity
struct GroupDelegate {
    address delegate;
    uint256 groupId;
    uint256 delegatedVotes;
    address[] delegationsFrom;
    uint256 groupDelegateId;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`delegate`|`address`|The address of the delegate.|
|`groupId`|`uint256`|The group ID the delegate belongs to.|
|`delegatedVotes`|`uint256`|The number of delegated votes the delegate has received.|
|`delegationsFrom`|`address[]`|Addresses of users who have delegated to the delegate.|
|`groupDelegateId`|`uint256`|The unique delegate ID within the group.|

### GroupDelegation
*Represents a user's delegation in a group.*


```solidity
struct GroupDelegation {
    uint256 groupId;
    uint256 timeOfDelegation;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`groupId`|`uint256`|The group ID where the user has delegated their vote.|
|`timeOfDelegation`|`uint256`|The timestamp when the delegation was made.|

