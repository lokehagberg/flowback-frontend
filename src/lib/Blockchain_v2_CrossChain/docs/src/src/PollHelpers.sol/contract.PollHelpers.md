# PollHelpers
**Inherits:**
[SharedErrors](/src/SharedErrors.sol/contract.SharedErrors.md), Ownable

This contract provides helper functions and utilities for managing polls, including poll creation,
validation, and voting score checks. It defines the structure and essential details of a poll, such as
voting and proposal phases, and stores each poll's settings.

*This contract is designed to be inherited by other contracts that require poll management functionality.
It includes modular validation functions to ensure that poll phases and voting scores meet specified criteria.
Inherits:
- `Ownable`: Provides authorization control for functions restricted to the contract owner.
- `SharedErrors`: Includes custom error handling for reusability across multiple contracts.
Features:
- **Poll Creation**: Allows the owner to create new polls with specified parameters.
- **Voting Validation**: Provides functions to check if a poll is in the voting phase and if a given score is valid.
- **Delegate Voting Tracking**: Tracks delegate voting activity within each poll.
- **Custom Error Handling**: Uses custom errors to reduce gas costs for failed transactions.
State Variables:
- `metaVoting`: The address of the MetaVoting contract authorized to manage specific voting operations.
- `pollCount`: The total number of polls created.
Mappings:
- `polls`: Maps each poll ID to its respective `Poll` structure.
- `pollSettings`: Maps each poll ID to its `PollSettings`, defining poll configuration.
- `votersForPoll`: Tracks addresses that have voted in specific polls.
- `delegateVotersForPoll`: Tracks addresses that have voted as delegates in specific polls.
- `userVotes`: Stores individual user votes for each proposal within each poll.
Events:
- `PollCreated`: Emitted when a new poll is created, recording the poll ID, title, and on-chain storage preference.
- `DelegateVoteCast`: Emitted when a delegate casts a vote, recording the delegate address and poll ID.
Requirements:
- Only the contract owner can set the MetaVoting address and create polls.
- Polls must be validated for existence and active voting phases before any voting activity.
- Score values must be within defined limits to prevent invalid votes.*


## State Variables
### metaVoting

```solidity
address public metaVoting;
```


### polls

```solidity
mapping(uint256 => Poll) public polls;
```


### votersForPoll

```solidity
mapping(uint256 => mapping(address => bool)) internal votersForPoll;
```


### delegateVotersForPoll

```solidity
mapping(uint256 => mapping(address => bool)) internal delegateVotersForPoll;
```


### pollCount

```solidity
uint256 public pollCount = 0;
```


### pollSettings

```solidity
mapping(uint256 => PollSettings) public pollSettings;
```


### userVotes

```solidity
mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userVotes;
```


## Functions
### setMetaVoting

Sets the address of the MetaVoting contract.

*This function is restricted to the contract owner. It assigns the `_metaVoting`
address to the `metaVoting` state variable, allowing interaction with an
external MetaVoting contract for enhanced voting operations.*


```solidity
function setMetaVoting(address _metaVoting) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_metaVoting`|`address`|The address of the MetaVoting contract to be set. Requirements: - Caller must be the contract owner.|


### createPoll

Creates a new poll with specified details and settings.

*This function can only be called by the contract owner. It sets up the structure
and settings of the poll, including the poll phases and score restrictions.*


```solidity
function createPoll(
    string memory _title,
    string memory _tag,
    uint256 _group,
    uint256 _pollStartDate,
    uint256 _proposalEndDate,
    uint256 _votingStartDate,
    uint256 _delegateEndDate,
    uint256 _endDate,
    uint8 _maxVoteScore,
    bool _storeOnEthereum
) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_title`|`string`|The title of the poll.|
|`_tag`|`string`|A tag categorizing the poll.|
|`_group`|`uint256`|The ID of the group associated with the poll.|
|`_pollStartDate`|`uint256`|The start date of the poll (timestamp in seconds).|
|`_proposalEndDate`|`uint256`|The end date for submitting proposals (timestamp in seconds).|
|`_votingStartDate`|`uint256`|The start date for voting in the poll (timestamp in seconds).|
|`_delegateEndDate`|`uint256`|The end date for delegating votes (timestamp in seconds).|
|`_endDate`|`uint256`|The end date for the poll (timestamp in seconds).|
|`_maxVoteScore`|`uint8`|The maximum allowable score for votes in this poll.|
|`_storeOnEthereum`|`bool`|Boolean flag indicating if poll results will be stored on Ethereum. Requirements: - `_maxVoteScore` must be within the allowable range (checked by `requireMaxVoteScoreWithinRange`). - Only the contract owner can create a poll. Emits: - `PollCreated`: Emitted upon successful poll creation, logging the poll ID, title, and whether the results will be stored on Ethereum.|


### getPoll

Retrieves the details of a specified poll.


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
|`<none>`|`Poll`|A `Poll` structure containing the details and settings of the specified poll. Requirements: - The poll with `_pollId` must exist. Reverts: - `PH_PollDoesNotExist` if the poll with the specified `_pollId` does not exist.|


### requirePollToExist

*Ensures that a poll with the specified ID exists.*


```solidity
function requirePollToExist(uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check. Requirements: - `_pollId` must be greater than zero and less than or equal to the current `pollCount`. Reverts: - `PH_PollDoesNotExist` if `_pollId` is zero or exceeds the number of existing polls.|


### requireMaxVoteScoreWithinRange

*Validates that a given vote score is within the allowable range.*


```solidity
function requireMaxVoteScoreWithinRange(uint8 score) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`score`|`uint8`|The score to validate. Requirements: - `score` must be 100 or less. Reverts: - `PH_MaxVoteScoreOutOfRange` if `score` exceeds 100.|


### requireVoterScoreWithinRange

*Ensures that the given vote `score` does not exceed the maximum allowed score for the specified poll.*


```solidity
function requireVoterScoreWithinRange(uint8 score, uint256 pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`score`|`uint8`|The vote score to validate.|
|`pollId`|`uint256`|The ID of the poll for which the score is being validated. Requirements: - `score` must be less than or equal to the maximum vote score allowed in the poll settings. Reverts: - `PH_VoteScoreExceedsMax` if `score` is greater than the poll's defined maximum score.|


### hasVoted

*Checks if the caller has already voted in a specific poll.*


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
|`voted`|`bool`|`true` if the caller has voted in the poll, otherwise `false`.|


### isVotingOpen

*Checks if the voting phase is currently open for a specific poll.*


```solidity
function isVotingOpen(uint256 _pollId) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|`true` if the current timestamp is within the voting period, otherwise `false`. Requirements: - The poll's voting start date must be in the past, and the end date must be in the future.|


### publicRequireMaxVoteScoreWithinRange


```solidity
function publicRequireMaxVoteScoreWithinRange(uint8 score) external pure;
```

### publicIsVotingOpen


```solidity
function publicIsVotingOpen(uint256 _pollId) external view;
```

### publicRequireVoterScoreWithinRange


```solidity
function publicRequireVoterScoreWithinRange(uint8 score, uint256 pollId) external view;
```

## Events
### PollCreated

```solidity
event PollCreated(uint256 indexed pollId, string title, bool storeOnEthereum);
```

### DelegateVoteCast

```solidity
event DelegateVoteCast(address indexed delegateVoter, uint256 indexed pollId);
```

## Errors
### PH_ProposalPhaseEnded

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

```solidity
struct Poll {
    PollDetails details;
    PollSettings settings;
    uint256 pollId;
    uint256 proposalCount;
}
```

### PollDetails

```solidity
struct PollDetails {
    string title;
    string tag;
    uint256 group;
    uint256 pollStartDate;
    uint256 proposalEndDate;
    uint256 votingStartDate;
    uint256 delegateEndDate;
    uint256 endDate;
}
```

### PollSettings

```solidity
struct PollSettings {
    uint8 maxVoteScore;
    bool storeOnEthereum;
    bool finalized;
    bytes32 resultHash;
}
```

