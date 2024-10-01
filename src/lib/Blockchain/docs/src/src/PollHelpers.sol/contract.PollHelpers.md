# PollHelpers
**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova.

*Provides utility functions to manage and interact with polls, including creating, voting, and ensuring compliance with poll phases.*


## State Variables
### polls
Mapping from poll ID to Poll structure.


```solidity
mapping(uint256 => Poll) public polls;
```


### votersForPoll
Mapping from poll ID to an array of addresses representing voters for that poll.


```solidity
mapping(uint256 => address[]) internal votersForPoll;
```


### delegateVotersForPoll
Mapping from poll ID to an array of addresses representing delegate voters for that poll.


```solidity
mapping(uint256 => address[]) internal delegateVotersForPoll;
```


### pollCount
Tracks the total number of polls created.


```solidity
uint256 public pollCount;
```


## Functions
### controlProposalEndDate

Ensures that the proposal phase is still open for the given poll.

*Reverts if the proposal phase has ended.*


```solidity
function controlProposalEndDate(uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|


### getPoll

Returns the details of a specific poll by ID.


```solidity
function getPoll(uint256 _pollId) public view returns (Poll memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to retrieve.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Poll`|Poll The Poll structure containing the poll details.|


### isVotingOpen

Ensures that the voting phase is open for the given poll.

*Reverts if the voting phase is not currently open.*


```solidity
function isVotingOpen(uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|


### requirePollToExist

Ensures that the poll exists.

*Reverts if the poll does not exist.*


```solidity
function requirePollToExist(uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|


### requireMaxVoteScoreWithinRange

Ensures that the maximum vote score is within the allowed range.

*Reverts if the max vote score is greater than 100.*


```solidity
function requireMaxVoteScoreWithinRange(uint8 _maxVoteScore) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxVoteScore`|`uint8`|The maximum vote score to validate.|


### requireVoterScoreWithinRange

Ensures that the voter's score is within the allowed range for the poll.

*Reverts if the vote score exceeds the poll's maximum vote score.*


```solidity
function requireVoterScoreWithinRange(uint8 _score, uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_score`|`uint8`|The score to validate.|
|`_pollId`|`uint256`|The ID of the poll to check the score against.|


### hasVoted

Checks whether the caller has already voted in the specified poll.


```solidity
function hasVoted(uint256 _pollId) internal view returns (bool voted);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`voted`|`bool`|True if the caller has voted, false otherwise.|


### hasVotedAsDelegate

Checks whether the caller has voted as a delegate in the specified poll.


```solidity
function hasVotedAsDelegate(uint256 _pollId) internal view returns (bool voted);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`voted`|`bool`|True if the caller has voted as a delegate, false otherwise.|


## Structs
### Poll
*Structure to store poll details.*


```solidity
struct Poll {
    string title;
    string tag;
    uint256 group;
    uint256 pollStartDate;
    uint256 proposalEndDate;
    uint256 votingStartDate;
    uint256 delegateEndDate;
    uint256 endDate;
    uint8 maxVoteScore;
    uint256 pollId;
    uint256 proposalCount;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`title`|`string`|Title of the poll.|
|`tag`|`string`|Tag for categorizing the poll.|
|`group`|`uint256`|The group associated with the poll.|
|`pollStartDate`|`uint256`|The timestamp when the poll starts.|
|`proposalEndDate`|`uint256`|The timestamp when the proposal phase ends.|
|`votingStartDate`|`uint256`|The timestamp when the voting phase starts.|
|`delegateEndDate`|`uint256`|The timestamp when the delegate phase ends.|
|`endDate`|`uint256`|The timestamp when the poll ends.|
|`maxVoteScore`|`uint8`|The maximum score a voter can give.|
|`pollId`|`uint256`|The unique ID of the poll.|
|`proposalCount`|`uint256`|The total number of proposals submitted for the poll.|

