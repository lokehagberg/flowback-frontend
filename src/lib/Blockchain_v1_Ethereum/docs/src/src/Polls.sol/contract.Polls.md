# Polls
**Inherits:**
[RightToVote](/src/RightToVote.sol/contract.RightToVote.md), [Delegations](/src/Delegations.sol/contract.Delegations.md), [PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md), [Predictions](/src/Predictions.sol/contract.Predictions.md), [PredictionBetHelpers](/src/PredictionBetHelpers.sol/contract.PredictionBetHelpers.md), [PredictionBets](/src/PredictionBets.sol/contract.PredictionBets.md)

**Author:**
@EllenLng, @KristofferGW

Users can create polls, submit votes, and manage group memberships within this contract.

Audited by @MashaVaverova

*This contract manages the creation and voting of polls, leveraging multiple helper contracts for additional functionalities.*


## Functions
### createPoll

Creates a new poll with specified parameters.


```solidity
function createPoll(
    string calldata _title,
    string calldata _tag,
    uint256 _group,
    uint256 _pollStartDate,
    uint256 _proposalEndDate,
    uint256 _votingStartDate,
    uint256 _delegateEndDate,
    uint256 _endDate,
    uint8 _maxVoteScore
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_title`|`string`|The title of the poll.|
|`_tag`|`string`|A tag associated with the poll.|
|`_group`|`uint256`|The group ID associated with the poll.|
|`_pollStartDate`|`uint256`|The start date of the poll.|
|`_proposalEndDate`|`uint256`|The end date for proposal submissions.|
|`_votingStartDate`|`uint256`|The date when voting starts.|
|`_delegateEndDate`|`uint256`|The end date for delegation.|
|`_endDate`|`uint256`|The end date for the poll.|
|`_maxVoteScore`|`uint8`|The maximum score a user can give in the poll.|


### vote

Allows a user to vote on a proposal in a specified poll.


```solidity
function vote(uint256 _pollId, uint256 _proposalId, uint8 _score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to vote in.|
|`_proposalId`|`uint256`|The ID of the proposal being voted on.|
|`_score`|`uint8`|The score assigned to the vote.|


### voteAsDelegate

Allows a user to vote as a delegate on a proposal in a specified poll.


```solidity
function voteAsDelegate(uint256 _pollId, uint256 _proposalId, uint8 _score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to vote in.|
|`_proposalId`|`uint256`|The ID of the proposal being voted on.|
|`_score`|`uint8`|The score assigned to the vote.|


### _getDelegatedVotes

Retrieves the total number of delegated votes for a user in a specified group.


```solidity
function _getDelegatedVotes(uint256 _group) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`uint256`|The ID of the group to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|totalVotes The total number of delegated votes for the user.|


### hasUserVoted

Checks if a user has voted in a specified poll.


```solidity
function hasUserVoted(uint256 _pollId, address _user) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|
|`_user`|`address`|The address of the user to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user has voted, false otherwise.|


### hasUserVotedAsDelegate

Checks if a user has voted as a delegate in a specified poll.


```solidity
function hasUserVotedAsDelegate(uint256 _pollId, address _user) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|
|`_user`|`address`|The address of the user to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the user has voted as a delegate, false otherwise.|


## Events
### PollCreated

```solidity
event PollCreated(uint256 indexed pollId, string title);
```

### VoteSubmitted

```solidity
event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);
```

## Errors
### P_UserNotMemberOfGroup

```solidity
error P_UserNotMemberOfGroup(uint256 groupId, address user);
```

### P_AlreadyDelegatedVote

```solidity
error P_AlreadyDelegatedVote(uint256 groupId, address voter);
```

### P_InvalidScore

```solidity
error P_InvalidScore(uint256 score);
```

