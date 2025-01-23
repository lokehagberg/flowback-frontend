# PollHelpers
**Inherits:**
[SharedErrors](/src/SharedErrors.sol/contract.SharedErrors.md)

**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova

*Provides utility functions to manage and interact with polls, including creating, voting, and ensuring compliance with poll phases.*


## State Variables
### polls
Mapping from poll ID to Poll structure.


```solidity
mapping(uint256 => Poll) public polls;
```


### votersForPoll
Mapping from poll ID to a mapping of addresses representing voters for that poll.


```solidity
mapping(uint256 => mapping(address => bool)) internal votersForPoll;
```


### delegateVotersForPoll
Mapping from poll ID to a mapping of addresses representing delegate voters for that poll.


```solidity
mapping(uint256 => mapping(address => bool)) internal delegateVotersForPoll;
```


### pollCount
Tracks the total number of polls created.


```solidity
uint256 public pollCount = 0;
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
function getPoll(uint256 _pollId) external view returns (Poll memory);
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


### castVote

Adds the caller as a voter for a specific poll.


```solidity
function castVote(uint256 _pollId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll where the caller is voting.|


### castDelegateVote

Adds the caller as a delegate voter for a specific poll.


```solidity
function castDelegateVote(uint256 _pollId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll where the caller votes as a delegate.|


### publicIsVotingOpen

Exposes the isVotingOpen function to the public for checking voting status.


```solidity
function publicIsVotingOpen(uint256 _pollId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check voting status.|


### publicControlProposalEndDate

Exposes the controlProposalEndDate function to the public for checking proposal phase status.


```solidity
function publicControlProposalEndDate(uint256 _pollId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check proposal phase.|


### publicRequireMaxVoteScoreWithinRange

Exposes the requireMaxVoteScoreWithinRange function to the public for validating maximum vote score.


```solidity
function publicRequireMaxVoteScoreWithinRange(uint8 _maxVoteScore) external pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxVoteScore`|`uint8`|The maximum vote score to validate.|


### publicRequireVoterScoreWithinRange

Exposes the requireVoterScoreWithinRange function to the public for validating voter score.


```solidity
function publicRequireVoterScoreWithinRange(uint8 _score, uint256 _pollId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_score`|`uint8`|The score to validate.|
|`_pollId`|`uint256`|The ID of the poll to check the score against.|


## Events
### VoteCast

```solidity
event VoteCast(address indexed voter, uint256 indexed pollId);
```

### DelegateVoteCast

```solidity
event DelegateVoteCast(address indexed delegateVoter, uint256 indexed pollId);
```

## Errors
### PH_ProposalPhaseEnded
Custom Errors


```solidity
error PH_ProposalPhaseEnded(uint256 pollId, uint256 proposalEndDate, uint256 currentTimestamp);
```

### PH_VotingNotAllowed

```solidity
error PH_VotingNotAllowed(uint256 pollId, uint256 votingStartDate, uint256 endDate, uint256 currentTimestamp);
```

### PH_PollDoesNotExist

```solidity
error PH_PollDoesNotExist(uint256 pollId);
```

### PH_MaxVoteScoreOutOfRange

```solidity
error PH_MaxVoteScoreOutOfRange(uint8 providedScore);
```

### PH_VoteScoreExceedsMax

```solidity
error PH_VoteScoreExceedsMax(uint8 providedScore, uint8 maxScore);
```

## Structs
### Poll
*Struct representing a poll.*


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

